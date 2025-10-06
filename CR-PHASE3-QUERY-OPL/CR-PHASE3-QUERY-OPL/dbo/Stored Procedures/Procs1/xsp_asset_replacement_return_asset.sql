--Created, Rian at 02/01/2023

CREATE PROCEDURE dbo.xsp_asset_replacement_return_asset
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@agreement_no			nvarchar(50)
			,@old_asset_no			nvarchar(50)
			,@new_fa_code			nvarchar(50)
			,@new_fa_name			nvarchar(250)
			,@system_date			datetime
			,@old_fa_code			nvarchar(50)
			,@old_fa_name			nvarchar(50)
			,@code					nvarchar(50)
			,@client_name			nvarchar(50)
			,@remark_old			nvarchar(4000)
			,@remark_new			nvarchar(4000)
			,@date					datetime
			,@remark				nvarchar(4000)
			,@replacement_type		nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(50)
			,@handover_address		nvarchar(4000)
			,@handover_phone_area	nvarchar(5)
			,@handover_phone_no		nvarchar(15)
			,@handover_eta_date		datetime 
			,@old_handover_in_date	datetime
			,@new_handover_out_date	datetime
			,@agreement_external_no	nvarchar(50)
			,@client_no				nvarchar(50)
			,@bbn_location			nvarchar(250)

	begin try

		--set system date
		set @system_date = dbo.xfn_get_system_date() ;

		-- Set agreement no      
		select	@agreement_no = agreement_no
				,@branch_code = branch_code
				,@branch_name = branch_name
				,@date		  = date
				,@remark	  = remark
		from	dbo.asset_replacement
		where	code = @p_code ;

		--update to table asset replacement
		if exists
		(
			select	1
			from	asset_replacement
			where	code = @p_code
					and status <> 'POST'
		)
		begin
			set @msg = 'Data already Proceed.' ;
			raiserror(@msg, 16, -1) ;
		end ;

		
	
		--Update to table agreement asset
		update	dbo.agreement_asset
		set		replacement_fa_code		= null
				,replacement_fa_name	= null
				,replacement_end_date	= null
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	agreement_no			= @agreement_no

		--looping asset replacement detail
		declare c_asset_replacement_detail cursor for
		select	old_asset_no
				,new_fa_code
				,new_fa_name
				,replacement_type
				,estimate_return_date
		from	dbo.asset_replacement_detail
		where	replacement_code = @p_code ;

		open c_asset_replacement_detail ;

		fetch c_asset_replacement_detail
		into @old_asset_no
			 ,@new_fa_code
			 ,@new_fa_name
			 ,@replacement_type 
			 ,@handover_eta_date ;

		while @@fetch_status = 0
		begin

			--Select old asset 
			select		@old_fa_name			= ass.fa_name
						,@old_fa_code			= ass.fa_code
						,@client_no				= am.client_no
						,@client_name			= am.client_name
						,@handover_address		= ass.deliver_to_address
						,@handover_phone_area	= ass.deliver_to_area_no
						,@handover_phone_no		= ass.deliver_to_phone_no
						,@agreement_external_no	= am.agreement_external_no
						,@bbn_location			= ass.bbn_location_description
			from		dbo.agreement_main am
			inner join	dbo.agreement_asset	ass on (ass.agreement_no = am.agreement_no)
			where		ass.asset_no = @old_asset_no

			--select handover date di tabel asset replacement detail
			select	@old_handover_in_date	= old_handover_in_date
					,@new_handover_out_date = new_handover_out_date
			from	dbo.asset_replacement_detail
			where	replacement_code = @p_code 
			and		old_asset_no	 = @old_asset_no;

			--validasi jika pickup dan delivery assetbelum dilakukan
			if (@old_handover_in_date is null)
			begin
				set @msg = 'Pick Up ' + @old_fa_name + ' Not Finish Yet.'
				raiserror(@msg, 16, -1)
			end ;
			else if (@new_handover_out_date is null)
			begin
				set @msg = 'Delivery ' + @new_fa_name + ' Not Finish Yet.'
				raiserror(@msg, 16, -1)
			end

			if exists	(	select	1 
						from	dbo.asset_replacement_detail asd
								inner join ifinams.dbo.maintenance mtn on mtn.code = asd.reff_no
						where	mtn.status <> 'DONE'
						and		asd.replacement_code = @p_code
					)
			begin
				set @msg = 'Please Done transaction Maintenance First For Return Asset' ;
				raiserror(@msg, 16, -1) ;
			end ;

			--insert old asset to opl_interface_handover_asset
			set @remark_old = 'Pengembalian pengantian Unit Sewa Untuk Application : ' + @agreement_external_no + ' - ' + @client_name + '. dari Asset ' + @new_fa_code + ' - ' + @new_fa_name + ' menjadi ' + @old_fa_code + ' - ' + @old_fa_name ;

			exec dbo.xsp_opl_interface_handover_asset_insert	@p_code						= @code output
																,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_status					= 'HOLD'
																,@p_transaction_date		= @system_date
																,@p_type					= 'RETURN OUT'
																,@p_remark					= @remark_old
																,@p_fa_code					= @old_fa_code
																,@p_fa_name					= @old_fa_name
																,@p_handover_from			= 'INTERNAL'
																,@p_handover_to				= @client_name
																,@p_handover_address		= @handover_address  
																,@p_handover_phone_area		= @handover_phone_area
																,@p_handover_phone_no		= @handover_phone_no 
																,@p_handover_eta_date		= @system_date 
																,@p_unit_condition			= ''
																,@p_reff_no					= @p_code
																,@p_reff_name				= 'ASSET REPLACEMENT'
																,@p_agreement_external_no	= @agreement_external_no
																,@p_agreement_no			= @agreement_no
																,@p_asset_no				= @old_asset_no
																,@p_client_no				= @client_no
																,@p_client_name				= @client_name
																,@p_bbn_location			= @bbn_location
																--
																,@p_cre_date				= @p_mod_date
																,@p_cre_by					= @p_mod_by
																,@p_cre_ip_address			= @p_mod_ip_address
																,@p_mod_date				= @p_mod_date
																,@p_mod_by					= @p_mod_by
																,@p_mod_ip_address			= @p_mod_ip_address ;

			--insert new asset to opl_interface_handover_asset
			set @remark_new = 'Penarikan pengantian Unit Sewa Untuk Application : ' + @agreement_external_no + ' - ' + @client_name + '. dari Asset ' + @new_fa_code + ' - ' + @new_fa_name + ' menjadi ' + @old_fa_code + ' - ' + @old_fa_name ;

			exec dbo.xsp_opl_interface_handover_asset_insert	@p_code						= @code output
																,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_status					= 'HOLD'
																,@p_transaction_date		= @system_date
																,@p_type					= 'RETURN IN'
																,@p_remark					= @remark_new
																,@p_fa_code					= @new_fa_code
																,@p_fa_name					= @new_fa_name
																,@p_handover_from			= @client_name
																,@p_handover_to				= 'INTERNAL'
																,@p_handover_address		= @handover_address  
																,@p_handover_phone_no		= @handover_phone_no 
																,@p_handover_eta_date		= @system_date 
																,@p_unit_condition			= ''
																,@p_reff_no					= @p_code
																,@p_reff_name				= 'ASSET REPLACEMENT'
																,@p_agreement_external_no	= @agreement_external_no
																,@p_agreement_no			= @agreement_no
																,@p_asset_no				= @old_asset_no
																,@p_client_no				= @client_no
																,@p_client_name				= @client_name
																,@p_bbn_location			= @bbn_location
																--
																,@p_cre_date				= @p_mod_date
																,@p_cre_by					= @p_mod_by
																,@p_cre_ip_address			= @p_mod_ip_address
																,@p_mod_date				= @p_mod_date
																,@p_mod_by					= @p_mod_by
																,@p_mod_ip_address			= @p_mod_ip_address ;

			----Update table aggrement asset history
			--update	dbo.agreement_asset_replacement_history
			--set		is_latest = '0'
			--where	asset_no = @old_asset_no ;

			--Insert to table agreement log
			insert into dbo.agreement_log
			(
				agreement_no
				,asset_no
				,log_source_no
				,log_date
				,log_remarks
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@agreement_no
				,@old_asset_no
				,@p_code
				,@date
				,'Return Asset Replacement ' + @replacement_type + ' -With new Asset: ' + @new_fa_code + ' ' + @new_fa_name + ' ,Note: ' + @remark
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			fetch c_asset_replacement_detail
			into @old_asset_no
				 ,@new_fa_code
				 ,@new_fa_name
				 ,@replacement_type 
				 ,@handover_eta_date ;
		end ;

		close c_asset_replacement_detail ;
		deallocate c_asset_replacement_detail ;

		update	dbo.asset_replacement
		set		status				= 'RETURN'
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code	= @p_code

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;
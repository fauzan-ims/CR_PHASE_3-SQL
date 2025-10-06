/*
exec dbo.xsp_job_agreement_mature_request_handover_manual
*/
-- Louis Senin, 11 September 2023 14.47.19 -- 
CREATE PROCEDURE [dbo].[xsp_job_agreement_mature_request_handover_manual]
(
	@p_agreement_no nvarchar(50)
)
as
begin
	declare @msg						nvarchar(max)
			,@mod_date					datetime	  = getdate()
			,@mod_by					nvarchar(15)  = N'EOD'
			,@mod_ip_address			nvarchar(15)  = N'SYSTEM'
			,@handover_code				nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(50)
			,@remark					nvarchar(4000)
			,@fa_code					nvarchar(50)
			,@fa_name					nvarchar(50)
			,@handover_from				nvarchar(50)
			,@unit_condition			nvarchar(50)
			,@reff_no					nvarchar(50)
			,@reff_name					nvarchar(50)
			,@asset_no					nvarchar(50)
			,@handover_address			nvarchar(4000)
			,@handover_phone_area		nvarchar(5)
			,@handover_phone_no			nvarchar(15)
			,@handover_eta_date			datetime
			,@agreement_no				nvarchar(50)
			,@agreement_external_no		nvarchar(50)
			,@client_no					nvarchar(50)
			,@client_name				nvarchar(250)
			,@bbn_location				nvarchar(250)
			,@max_request_handover_days int ;

	begin try
		set @p_agreement_no = replace(@p_agreement_no, '/','.')

		select	@max_request_handover_days = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAXRHMADAY' ;

		--mencari data dangan cara loop dengan kondisi result = stop, status = on process, dan maturity dan date nya = system date 
		declare c_asset cursor for

		select	ma.branch_code
				,ma.branch_name
				,md.asset_no
				,aa.fa_code
				,isnull(aa.fa_name, '')
				,aa.asset_no
				,aa.asset_name
				,aa.asset_condition
				,isnull(aa.pickup_name, am.client_name)
				,isnull(aa.pickup_phone_area_no, '')
				,isnull(aa.pickup_phone_no, '')
				,isnull(aa.pickup_address, '')
				,ma.pickup_date
				,am.agreement_no
				,am.agreement_external_no
				,am.client_no
				,am.client_name
				,aa.bbn_location_description
		from	dbo.maturity ma
				inner join dbo.maturity_detail md on (ma.code		 = md.maturity_code)
				inner join dbo.agreement_asset aa on (aa.asset_no	 = md.asset_no)
				inner join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
		where	ma.status		= 'APPROVE'
				and md.result	= 'STOP'
				and am.AGREEMENT_NO = @p_agreement_no 
				
		open c_asset ;

		fetch c_asset
		into	@branch_code
				,@branch_name
				,@asset_no
				,@fa_code
				,@fa_name
				,@reff_no
				,@reff_name
				,@unit_condition
				,@handover_from
				,@handover_phone_area
				,@handover_phone_no 
				,@handover_address
				,@handover_eta_date 
				,@agreement_no			
				,@agreement_external_no	
				,@client_no				
				,@client_name			
				,@bbn_location			

		while @@fetch_status = 0
		begin
		 
				set @remark = 'Pengembalian Unit Sewa, Maturity Stop Untuk Agreement No :  ' + @agreement_external_no + '. dari Asset : ' + @fa_code + ' - ' + @fa_name + '.'

				--set Remark jika continue Rental
				if exists
				(
					select	1
					from	ifinams.dbo.asset a 
					where	a.code	= @fa_code
							and isnull(a.re_rent_status, '') = 'CONTINUE' 
				)
				begin
					 set @remark = 'No Need To Pickup Unit Sewa, Maturity Stop Untuk Agreement No :  ' + @agreement_external_no + '. dari Asset : ' + @fa_code + ' - ' + @fa_name + '.'
				end ;

				--insert data ke tabel opl_interface_handover_asset

				exec dbo.xsp_opl_interface_handover_asset_insert @p_code					= @handover_code output
																 ,@p_branch_code			= @branch_code
																 ,@p_branch_name			= @branch_name
																 ,@p_status					= N'HOLD'  
																 ,@p_transaction_date		= @mod_date
																 ,@p_type					= N'PICK UP'
																 ,@p_remark					= @remark
																 ,@p_fa_code				= @fa_code
																 ,@p_fa_name				= @fa_name
																 ,@p_handover_from			= @handover_from
																 ,@p_handover_to			= N'INTERNAL'
																 ,@p_handover_address		= @handover_address  
																 ,@p_handover_phone_area	= @handover_phone_area
																 ,@p_handover_phone_no		= @handover_phone_no 
																 ,@p_handover_eta_date		= @handover_eta_date 
																 ,@p_unit_condition			= @unit_condition
																 ,@p_reff_no				= @reff_no
																 ,@p_reff_name				= @reff_name
																 ,@p_agreement_external_no	= @agreement_external_no
																 ,@p_agreement_no			= @agreement_no
																 ,@p_asset_no				= @asset_no
																 ,@p_client_no				= @client_no
																 ,@p_client_name			= @client_name
																 ,@p_bbn_location			= @bbn_location
																 --							
																 ,@p_cre_date				= @mod_date		
																 ,@p_cre_by					= @mod_by		   
																 ,@p_cre_ip_address			= @mod_ip_address 
																 ,@p_mod_date				= @mod_date		
																 ,@p_mod_by					= @mod_by		
																 ,@p_mod_ip_address			= @mod_ip_address
				
				--update status di agreement
				--update	dbo.agreement_asset
				--set		asset_status	= 'RETURN'
				--		,mod_date		= @mod_date		
				--		,mod_by			= @mod_by
				--		,mod_ip_address	= @mod_ip_address
				--where	asset_no		= @asset_no

			fetch c_asset
			into	@branch_code
					,@branch_name
					,@asset_no
					,@fa_code
					,@fa_name
					,@reff_no
					,@reff_name
					,@unit_condition
					,@handover_from
					,@handover_phone_area
					,@handover_phone_no 
					,@handover_address
					,@handover_eta_date 
					,@agreement_no			
					,@agreement_external_no	
					,@client_no				
					,@client_name			
					,@bbn_location	
		end ;

		close c_asset ;
		deallocate c_asset ;

		--update status di maturity nya
		update	dbo.maturity
		set		status			= 'POST'
				,mod_date		= @mod_date		
				,mod_by			= @mod_by
				,mod_ip_address	= @mod_ip_address
		where	status			= 'APPROVE'
				and AGREEMENT_NO = @p_agreement_no 

		--update	dbo.maturity
		--set		status						 = 'APPROVE'
		--		,mod_date					 = @mod_date		
		--		,mod_by						 = @mod_by
		--		,mod_ip_address				 = @mod_ip_address
		--where	result						 = 'CONTINUE'
		--		and status					 = 'HANDOVER'
		--		--and AGREEMENT_NO = '0001273.4.01.02.2023'
		--		and cast(pickup_date as date) <= cast(dateadd(day, @max_request_handover_days, dbo.xfn_get_system_date()) as date) ;
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

--Created, Rian at 26/12/2022

CREATE PROCEDURE [dbo].[xsp_handover_request_proceed]
(
	@p_code					nvarchar(50)
	,@p_branch_code			nvarchar(50)
	-- 
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
    
	declare @msg				  nvarchar(max)
			,@year				  nvarchar(4)
			,@month				  nvarchar(2)
			,@date				  datetime		= getdate()
			,@code				  nvarchar(50)
			,@branch_code		  nvarchar(50)
			,@branch_name		  nvarchar(50)
			,@type				  nvarchar(50)
			,@handover_from		  nvarchar(50)
			,@handover_to		  nvarchar(50)
			,@handover_address	  nvarchar(4000)
			,@handover_phone_area nvarchar(5)
			,@handover_phone_no	  nvarchar(15)
			,@fa_code			  nvarchar(50)
			,@remark			  nvarchar(4000)
			,@reff_code			  nvarchar(50)
			,@reff_name			  nvarchar(50)
			,@fa_type			  nvarchar(50) ;

	begin try

	if exists (select 1 from dbo.handover_request where code = @p_code and status <> 'HOLD')
	begin
		set @msg = 'Data Already Post.';
		raiserror(@msg, 16, -1) ;
	end

	set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = @p_branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'HNR'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'HANDOVER_ASSET'
												,@p_run_number_length	 = 6
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;
		update	dbo.handover_request
		set		handover_code	= @code
				,status			= 'POST'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;

		select	@branch_code			= branch_code
				,@branch_name			= branch_name
				,@type					= type
				,@handover_from			= handover_from
				,@handover_to			= handover_to
				,@handover_address		= handover_address
				,@handover_phone_area	= handover_phone_area
				,@handover_phone_no		= handover_phone_no
				,@fa_code				= fa_code
				,@reff_code				= reff_code
				,@reff_name				= reff_name
				,@remark				= remark
		from	dbo.handover_request
		where	code = @p_code ;	

		if(@handover_from = 'INTERNAL')
		begin
			set @handover_from = 'PT. DIPO START FINANCE'
		end
		if(@handover_to = 'INTERNAL')
		begin
			set @handover_to = 'PT. DIPO START FINANCE'
		end

		exec dbo.xsp_handover_asset_insert @p_code					= @code
										   ,@p_branch_code			= @branch_code
										   ,@p_branch_name			= @branch_name
										   ,@p_status				= 'HOLD'
										   ,@p_transaction_date		= @date
										   ,@p_handover_date		= null
										   ,@p_type					= @type
										   ,@p_remark				= @remark
										   ,@p_fa_code				= @fa_code
										   ,@p_handover_from		= @handover_from
										   ,@p_handover_to			= @handover_to
										   ,@p_unit_condition		= ''
										   ,@p_reff_code			= @reff_code
										   ,@p_reff_name			= @reff_name
										   ,@p_handover_address		= @handover_address
										   ,@p_handover_phone_area	= @handover_phone_area
										   ,@p_handover_phone_no	= @handover_phone_no
										   ,@p_process_status		= ''
										   ,@p_plan_date			= null
										   ,@p_km					= 0
										   --
										   ,@p_cre_date				= @p_mod_date
										   ,@p_cre_by				= @p_mod_by
										   ,@p_cre_ip_address		= @p_mod_ip_address
										   ,@p_mod_date				= @p_mod_date
										   ,@p_mod_by				= @p_mod_by
										   ,@p_mod_ip_address		= @p_mod_ip_address

			select	@fa_type = type_code
			from	dbo.asset
			where	code = @fa_code ;

			insert into dbo.handover_asset_checklist
			(
				handover_code
				,checklist_code
				,checklist_status
				,checklist_remark
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@code
					,code
					,''
					,''
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.master_bast_checklist_asset
			where	asset_type_code = @fa_type
					and is_active	= '1' ;

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

end



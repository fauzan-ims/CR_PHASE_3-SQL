CREATE PROCEDURE dbo.xsp_insurance_policy_main_approve
(
	@p_code							nvarchar(50)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@status							nvarchar(50)
			,@code_interface_payment			nvarchar(50)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@remarks							nvarchar(4000)
			,@date								datetime = getdate()
			,@payment_amount					decimal(18,2)
			,@sp_name							nvarchar(250)
			,@debet_or_credit					nvarchar(10)
			,@gl_link_code						nvarchar(50)
			,@transaction_name					nvarchar(250)
			,@orig_amount_cr					decimal(18, 2)
			,@orig_amount_db					decimal(18, 2)
			,@amount							decimal(18, 2)
			,@return_value						decimal(18, 2)
			,@interface_remarks					nvarchar(4000)
			,@reff_approval_category_code		nvarchar(50)
			,@approval_code						nvarchar(50)
			,@reff_dimension_code				nvarchar(50)
			,@reff_dimension_name				nvarchar(250)
			,@dimension_code					nvarchar(50)
			,@table_name						nvarchar(50)
			,@primary_column					nvarchar(50)
			,@dim_value							nvarchar(50)
			,@process_code						nvarchar(50)
			,@value_approval					nvarchar(250)
			,@path								nvarchar(250)
			,@req_date							datetime
			,@request_code						nvarchar(50)
			,@payment_source					nvarchar(50)
			,@payment_source_no					nvarchar(250)
			,@url_path							nvarchar(250)
			,@approval_path						nvarchar(4000)
			,@payment_remark					nvarchar(4000)
			,@requestor_code					nvarchar(50)
			,@requestor_name					nvarchar(250)
			,@payment_req_code					nvarchar(50)
			,@invoice_no						nvarchar(50)
			,@register_code						nvarchar(4000)
			,@payment_request_code_for_validate	nvarchar(4000)
			,@maintenance_code					nvarchar(50)
			,@claim_type						nvarchar(50)
			,@asset_code						nvarchar(50)
			,@policy_no							nvarchar(50)

	begin try
		select	@requestor_code		= code
				,@requestor_name	= name
		from	ifinsys.dbo.sys_employee_main
		where	code = @p_mod_by ;

		select	@branch_code		= branch_code
				,@branch_name		= branch_name
				,@payment_amount	= total_premi_buy_amount
				,@status			= policy_payment_status
				,@policy_no			= policy_no
		from	dbo.insurance_policy_main
		where	code = @p_code ;

		if exists
		(
			select	1
			from	dbo.insurance_policy_main					   a
					inner join dbo.insurance_policy_asset		   b on b.policy_code		  = a.code
					inner join dbo.insurance_policy_asset_coverage c on c.register_asset_code = b.code
			where	a.code							  = @p_code
					and isnull(c.master_tax_code, '') = ''
		)
		begin
			set @msg = N'Please input tax in coverage first.' ;

			raiserror(@msg, 16, -1) ;
		end ;


		if (@status = 'HOLD')
		begin
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select @path = value 
			from sys_global_param
			WHERE code = 'PATHINS'

			set @interface_remarks = 'Approval insurance for ' + @policy_no + ', branch : ' + @branch_name + ' .';
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'APVINS' ;

			--set approval path
			set	@approval_path = @url_path + @path + @p_code

			exec dbo.xsp_ams_interface_approval_request_insert @p_code						= @request_code output
															   ,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_request_status			= N'HOLD'
																,@p_request_date			= @req_date
																,@p_request_amount			= @payment_amount
																,@p_request_remarks			= @interface_remarks
																,@p_reff_module_code		= N'IFINAMS'
																,@p_reff_no					= @p_code
																,@p_reff_name				= N'INSURANCE APPROVAL'
																,@p_paths					= @approval_path
																,@p_approval_category_code	= @reff_approval_category_code
																,@p_approval_status			= N'HOLD'
																,@p_requestor_code			= @requestor_code
																,@p_requestor_name			= @requestor_name
																,@p_expired_date			= @date
																,@p_cre_date				= @p_mod_date
																,@p_cre_by					= @p_mod_by
																,@p_cre_ip_address			= @p_mod_ip_address
																,@p_mod_date				= @p_mod_date
																,@p_mod_by					= @p_mod_by
																,@p_mod_ip_address			= @p_mod_ip_address


			declare curr_appv cursor fast_forward read_only for
			select 	approval_code
					,reff_dimension_code
					,reff_dimension_name
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'APVINS'
			
			open curr_appv
			
			fetch next from curr_appv 
			into @approval_code
				,@reff_dimension_code
				,@reff_dimension_name
				,@dimension_code
			
			while @@fetch_status = 0
			begin
				select	@table_name					 = table_name
						,@primary_column			 = primary_column
				from	dbo.sys_dimension
				where	code						 = @dimension_code

				exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
															,@p_reff_code	= @p_code
															,@p_reff_table	= 'INSURANCE_POLICY_MAIN'
															,@p_output		= @dim_value output ;
				
				exec dbo.xsp_ams_interface_approval_request_dimension_insert @p_id					= 0
																			 ,@p_request_code		= @request_code
																			 ,@p_dimension_code		= @reff_dimension_code
																			 ,@p_dimension_value	= @dim_value
																			 ,@p_cre_date			= @p_mod_date
																			 ,@p_cre_by				= @p_mod_by
																			 ,@p_cre_ip_address		= @p_mod_ip_address
																			 ,@p_mod_date			= @p_mod_date
																			 ,@p_mod_by				= @p_mod_by
																			 ,@p_mod_ip_address		= @p_mod_ip_address ;
				
			
			    fetch next from curr_appv 
				into @approval_code
					,@reff_dimension_code
					,@reff_dimension_name
					,@dimension_code
			end
			
			close curr_appv
			deallocate curr_appv

			update	dbo.insurance_policy_main
			set		policy_payment_status	= 'ON PROCESS'
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_code ;
		end ;
		else
		begin
			set @msg = 'Data already proceed' ;
			raiserror(@msg, 16, -1) ;
		end ;

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

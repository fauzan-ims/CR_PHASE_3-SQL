CREATE PROCEDURE [dbo].[xsp_stop_billing_proceed]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						  nvarchar(max)
			,@branch_code				  nvarchar(20)
			,@branch_name				  nvarchar(50)
			,@request_date				  datetime
			,@interface_remarks			  nvarchar(4000)
			,@aggreement_no				  nvarchar(50)
			,@code						  nvarchar(50)
			,@approval_code				  nvarchar(50)
			,@interface_code			  nvarchar(50)
			,@client_name				  nvarchar(250)
			,@reff_approval_category_code nvarchar(50)
			,@dimension_code			  nvarchar(50)
			,@reff_dimension_code		  nvarchar(50)
			,@dim_value					  nvarchar(100) 
			,@remark					  nvarchar(4000)
			,@agreement_no				  nvarchar(50)
			,@total_amount				  decimal(18, 2)
			,@path						  nvarchar(250)
			,@url_path					  nvarchar(250)
			,@approval_path				  nvarchar(4000)

	begin try

		if exists
		(
			select	1
			from	dbo.stop_billing
			where	status	 = 'ON PROCESS'
					and code = @p_code
		)
		begin
			set @msg = N'Data Already Proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

		select		@aggreement_no = agreement_no
		from		stop_billing
		where		code = @p_code ;

		select		@total_amount = sum(ast.lease_rounded_amount)
		from		dbo.agreement_asset ast
					inner join dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
		where		ast.agreement_no = @aggreement_no ;

		set @approval_code = N'APPROVAL STOP BILLING REQUEST' ;

		select	@branch_code = sb.branch_code
				,@branch_name = sb.branch_name
				,@aggreement_no = am.agreement_external_no
				,@code = sb.code
				,@client_name = am.client_name
				,@remark = sb.remarks
		from	dbo.stop_billing sb
				inner join dbo.agreement_main am on am.agreement_no = sb.agreement_no
		where	code = @p_code ;

		set @request_date = dbo.xfn_get_system_date() ;
		set @interface_remarks = N'Approval Stop Billing Request For '+ @aggreement_no + ' - ' + @client_name +', Request No : ' + @code +' - '+ @remark ;

		select	@reff_approval_category_code = reff_approval_category_code
		from	dbo.master_approval
		where	code = @approval_code ;

		--select path di global param
		select	@url_path = value
		from	dbo.sys_global_param
		where	code = 'URL_PATH' ;

		select	@path = @url_path + value
		from	dbo.sys_global_param
		where	code = 'APVSBR'

		--set approval path
		set	@approval_path = @path + @p_code

		exec dbo.xsp_opl_interface_approval_request_insert @p_code						= @interface_code output
														   ,@p_branch_code				= @branch_code
														   ,@p_branch_name				= @branch_name
														   ,@p_request_status			= N'HOLD'
														   ,@p_request_date				= @request_date
														   ,@p_request_amount			= @total_amount
														   ,@p_request_remarks			= @interface_remarks
														   ,@p_reff_module_code			= N'IFINOPL'
														   ,@p_reff_no					= @p_code
														   ,@p_reff_name				= N'STOP BILLING APPROVAL'
														   ,@p_paths					= @approval_path
														   ,@p_approval_category_code	= @reff_approval_category_code
														   ,@p_approval_status			= N''
														   ,@p_cre_date					= @p_mod_date
														   ,@p_cre_by					= @p_mod_by
														   ,@p_cre_ip_address			= @p_mod_ip_address
														   ,@p_mod_date					= @p_mod_date
														   ,@p_mod_by					= @p_mod_by
														   ,@p_mod_ip_address			= @p_mod_ip_address ;

		declare master_approval_dimension cursor for
		select	reff_dimension_code
				,dimension_code
		from	dbo.master_approval_dimension
		where	approval_code = @approval_code ;

		open master_approval_dimension ;

		fetch next from master_approval_dimension
		into @reff_dimension_code
			 ,@dimension_code ;

		while @@fetch_status = 0
		begin
			exec dbo.xsp_get_table_value_by_dimension @p_dim_code = @dimension_code
													  ,@p_reff_code = @p_code
													  ,@p_reff_table = 'STOP_BILLING'
													  ,@p_output = @dim_value output ;

			exec dbo.xsp_opl_interface_approval_request_dimension_insert @p_id = 0
																		 ,@p_request_code = @interface_code
																		 ,@p_dimension_code = @reff_dimension_code
																		 ,@p_dimension_value = @dim_value
																		 ,@p_cre_date = @p_mod_date
																		 ,@p_cre_by = @p_mod_by
																		 ,@p_cre_ip_address = @p_mod_ip_address
																		 ,@p_mod_date = @p_mod_date
																		 ,@p_mod_by = @p_mod_by
																		 ,@p_mod_ip_address = @p_mod_ip_address ;

			fetch next from master_approval_dimension
			into @reff_dimension_code
				 ,@dimension_code ;
		end ;

		close master_approval_dimension ;
		deallocate master_approval_dimension ;

		update	dbo.stop_billing
		set		status = 'ON PROCESS'
		where	code = @p_code ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;


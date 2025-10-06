CREATE PROCEDURE dbo.xsp_due_date_change_main_proceed
(
	@p_code			   nvarchar(50)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						  nvarchar(max)
			,@change_amount				  decimal(18, 2)
			,@branch_code				  nvarchar(50)
			,@branch_name				  nvarchar(250)
			,@interface_remarks			  nvarchar(4000)
			,@agreement_external_no		  nvarchar(50)
			,@req_date					  datetime
			,@change_exp_date			  datetime
			,@client_name				  nvarchar(250)
			,@reff_approval_category_code nvarchar(50)
			,@code						  nvarchar(50)
			,@request_code				  nvarchar(50)
			,@approval_code				  nvarchar(50)
			,@reff_dimension_code		  nvarchar(50)
			,@reff_dimension_name		  nvarchar(250)
			,@dimension_code			  nvarchar(50)
			,@table_name				  nvarchar(50)
			,@primary_column			  nvarchar(50)
			,@dim_code					  nvarchar(50)
			,@dim_value					  nvarchar(50)
			,@is_approval				  nvarchar(1)
			,@path						  nvarchar(250)
			,@url_path					  nvarchar(250)
			,@approval_path				  nvarchar(4000) ;

	begin try
		if exists
		(
			select	1
			from	dbo.due_date_change_main
			where	code					  = @p_code
					and is_amortization_valid <> '0'
		)
		begin
			set @msg = 'Please recalculate Amortization' ;

			raiserror(@msg, 16, 1) ;
		end ;

		--if exists
		--(
		--	select	1
		--	from	dbo.due_date_change_detail
		--	where	due_date_change_code = @p_code
		--			and new_due_date_day < dbo.xfn_get_system_date()
		--)
		--begin
		--	set @msg = 'New Due Date Must be Greater or Equal Than System Date.' ;
		--	raiserror(@msg, 16, 1) ;
		--end
		if exists(select 1 from due_date_change_main where billing_mode = 'NORMAL' and is_prorate = 'Yes' and code = @p_code)
		begin
		    set @msg = 'Billing Mode: Normal Cannot Be Prorated, Please Change The Billing Mode Or Uncheck Prorate' ;
			raiserror(@msg, 16, 1) ;
		end

		if exists
		(
			select	1
			from	dbo.due_date_change_main
			where	code			  = @p_code
					and change_status <> 'HOLD'
		)
		begin
			set @msg = 'Error data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else
		begin
									 
		if exists
		(
			select	1
			from	dbo.master_approval
			where	code			 = 'CHANGE DUE DATE'
					and is_active	 = '1'
		)
		begin
			select	@branch_code = ddcm.branch_code
					,@branch_name = ddcm.branch_name
					,@client_name = am.client_name
					,@change_amount = ddcm.change_amount
					,@agreement_external_no = am.agreement_external_no
					,@change_exp_date = ddcm.change_exp_date
			from	dbo.due_date_change_main ddcm
					inner join dbo.agreement_main am on (am.agreement_no = ddcm.agreement_no)
			where	ddcm.code = @p_code ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code = 'CHANGE DUE DATE' ;

			update	dbo.due_date_change_main
			set		change_status = 'ON PROCESS'
					,mod_by = @p_mod_by
					,mod_date = @p_mod_date
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;

			set @interface_remarks = 'Approval Change Due Date ' + @agreement_external_no + ' - ' + @client_name ; 
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'CHANGE DUE DATE' ;

			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'DUEDATEPATH';

			--set approval path
			set	@approval_path = @path + @p_code;

			exec dbo.xsp_opl_interface_approval_request_insert @p_code						= @request_code output -- nvarchar(50)
															   ,@p_branch_code				= @branch_code
															   ,@p_branch_name				= @branch_name
															   ,@p_request_status			= N'HOLD'
															   ,@p_request_date				= @req_date
															   ,@p_request_amount			= @change_amount
															   ,@p_request_remarks			= @interface_remarks
															   ,@p_reff_module_code			= N'IFINOPL'
															   ,@p_reff_no					= @p_code
															   ,@p_reff_name				= N'CHANGE DUE DATE APPROVAL'
															   ,@p_paths					= @approval_path
															   ,@p_approval_category_code	= @reff_approval_category_code
															   ,@p_approval_status			= N'HOLD'
															   --
															   ,@p_cre_date					= @p_mod_date
															   ,@p_cre_by					= @p_mod_by
															   ,@p_cre_ip_address			= @p_mod_ip_address
															   ,@p_mod_date					= @p_mod_date
															   ,@p_mod_by					= @p_mod_by
															   ,@p_mod_ip_address			= @p_mod_ip_address ;

			declare master_approval_dimension cursor for
			select	approval_code
					,reff_dimension_code
					,reff_dimension_name
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'CHANGE DUE DATE' ;

			open master_approval_dimension ;

			fetch next from master_approval_dimension
			into @approval_code
					,@reff_dimension_code
					,@reff_dimension_name
					,@dimension_code ;

			while @@fetch_status = 0
			begin 
				select	@table_name					 = table_name
						,@primary_column			 = primary_column
				from	dbo.sys_dimension
				where	code						 = @dimension_code;

				exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
															,@p_reff_code	= @p_code
															,@p_reff_table	= 'DUE_DATE_CHANGE_MAIN'
															,@p_output		= @dim_value output ;
 
				exec dbo.xsp_opl_interface_approval_request_dimension_insert @p_id					= 0
																			 ,@p_request_code		= @request_code
																			 ,@p_dimension_code		= @reff_dimension_code
																			 ,@p_dimension_value	= @dim_value
																			 --
																			 ,@p_cre_date			= @p_mod_date
																			 ,@p_cre_by				= @p_mod_by
																			 ,@p_cre_ip_address		= @p_mod_ip_address
																			 ,@p_mod_date			= @p_mod_date
																			 ,@p_mod_by				= @p_mod_by
																			 ,@p_mod_ip_address		= @p_mod_ip_address ;

				fetch next from master_approval_dimension
				into @approval_code
						,@reff_dimension_code
						,@reff_dimension_name
						,@dimension_code ;
			end ;

			close master_approval_dimension ;
			deallocate master_approval_dimension;
					
		end;
		else
		begin
			set @msg = 'Please setting Master Approval';
			raiserror(@msg, 16, 1) ;
		end ;
	end;

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



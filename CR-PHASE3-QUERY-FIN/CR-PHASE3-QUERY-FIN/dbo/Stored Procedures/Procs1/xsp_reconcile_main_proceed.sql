--created by, Rian at 12/06/2023 

CREATE PROCEDURE [dbo].[xsp_reconcile_main_proceed]
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare	@msg							nvarchar(max)
			,@request_code					nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@source_reff_name				nvarchar(250)
			,@source_reff_code				nvarchar(50)
			,@url_path						nvarchar(250)
			,@path							nvarchar(250)
			,@interface_remarks				nvarchar(4000)
			,@req_date						datetime
			,@reff_approval_category_code	nvarchar(50)
			,@approval_path					nvarchar(250)
			,@reff_dimension_code			nvarchar(50)
			,@dimension_code				nvarchar(50)
			,@dim_value						nvarchar(50)
			,@request_amount				decimal(18,2)

	begin try
		if exists
		(
			select	1
			from	dbo.reconcile_main
			where	code				  = @p_code
					and reconcile_status <> 'HOLD'
		)
		begin
			set	@msg = 'Data Already Proceed.'
			raiserror (@msg, 16, -1)
		end

		if exists
		(
			select	1
			from	dbo.reconcile_main
			where	code			  = @p_code
					and system_amount <> upload_amount
		)
		begin
			set	@msg = 'Upload Amount Must Be Equal Than SYstem Amount.'
			raiserror (@msg, 16, -1)
		end

		if exists
		(
			select	1
			from	dbo.master_approval
			where	code = 'RECONCILE'
		)
		begin

			select	@branch_code			= rm.branch_code
					,@branch_name			= rm.branch_name
					,@request_amount		= rm.system_amount
			from	dbo.reconcile_main rm
			where	rm.code = @p_code ;

			update	dbo.reconcile_main
			set		reconcile_status	= 'ON PROCESS'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code

			set @interface_remarks = 'Approval Reconcile For ' + @p_code;
			set @req_date = dbo.xfn_get_system_date() ;


			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'RECONCILE' ;

			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'RECONCILE'

			--set approval path
			set	@approval_path = @path + @p_code

			exec dbo.xsp_fin_interface_approval_request_insert @p_code						= @request_code output
															   ,@p_branch_code				= @branch_code
															   ,@p_branch_name				= @branch_name
															   ,@p_request_status			= N'HOLD'
															   ,@p_request_date				= @req_date
															   ,@p_request_amount			= @request_amount
															   ,@p_request_remarks			= @interface_remarks
															   ,@p_reff_module_code			= N'IFINFIN'
															   ,@p_reff_no					= @p_code
															   ,@p_reff_name				= N'RECONCILE'
															   ,@p_paths					= @approval_path
															   ,@p_approval_category_code	= @reff_approval_category_code
															   ,@p_approval_status			= N'HOLD'
															   --
															   ,@p_cre_date					= @p_mod_date
															   ,@p_cre_by					= @p_mod_by
															   ,@p_cre_ip_address			= @p_mod_ip_address
															   ,@p_mod_date					= @p_mod_date
															   ,@p_mod_by					= @p_mod_by
															   ,@p_mod_ip_address			= @p_mod_ip_address
			
				declare master_approval_dimension cursor for
				select  reff_dimension_code 
						,dimension_code
				from	dbo.master_approval_dimension
				where	approval_code = 'RECONCILE'

				open master_approval_dimension		
				fetch next from master_approval_dimension
				into @reff_dimension_code 
					 ,@dimension_code
						
				while @@fetch_status = 0

				begin 

					exec dbo.xsp_get_table_value_by_dimension @p_dim_code	 = @dimension_code
															  ,@p_reff_code	 = @p_code
															  ,@p_reff_table = 'RECONCILE_MAIN'
															  ,@p_output	 = @dim_value output ;
 
					exec dbo.xsp_fin_interface_approval_request_dimension_insert @p_id					= 0
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
				into @reff_dimension_code
					,@dimension_code
				end
						
				close master_approval_dimension
				deallocate master_approval_dimension 
		end
		else
		begin
			set @msg = 'Please setting Master Approval';
			raiserror(@msg, 16, 1) ;
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
end

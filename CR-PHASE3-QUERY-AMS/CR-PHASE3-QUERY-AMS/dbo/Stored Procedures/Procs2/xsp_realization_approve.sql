CREATE PROCEDURE [dbo].[xsp_realization_approve]
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
		,@status					  nvarchar(20)
		,@path						  nvarchar(250)
		,@url_path					  nvarchar(250)
		,@branch_code				  nvarchar(50)
		,@branch_name				  nvarchar(250)
		,@interface_remarks			  nvarchar(4000)
		,@req_date					  datetime
		,@reff_approval_category_code nvarchar(50)
		,@approval_path				  nvarchar(4000)
		,@request_code				  nvarchar(50)
		,@payment_amount			  decimal(18, 2)
		,@requestor_code			  nvarchar(50)
		,@requestor_name			  nvarchar(250)
		,@date						  datetime		= dbo.xfn_get_system_date()
		,@approval_code				  nvarchar(50)
		,@reff_dimension_code		  nvarchar(50)
		,@reff_dimension_name		  nvarchar(250)
		,@dimension_code			  nvarchar(50)
		,@table_name				  nvarchar(50)
		,@primary_column			  nvarchar(50)
		,@dim_value					  nvarchar(50)
		,@order_code				  nvarchar(50)
		,@register_code_for_validate	nvarchar(4000)
		,@regis_status				nvarchar(50)

	begin try
		select	@status				= payment_status
				,@branch_code		= branch_code
				,@branch_name		= branch_name
				,@payment_amount	= public_service_settlement_amount
				,@order_code		= order_code
				,@regis_status		= register_status
		from	dbo.register_main
		where	code = @p_code ;

		if(@order_code = '')
		begin
			set @msg = N'Please check order code.' ;

			raiserror(@msg, 16, -1) ;
		end

		if exists(select 1 from dbo.register_main where order_code = @order_code and register_status = 'PENDING')
		begin
			select @register_code_for_validate =	stuff((
				  select	distinct '|' + '(' + av.plat_no + ' - '+ rm.code + ')'  collate Latin1_General_CI_AS
				  from		dbo.register_main rm
				  inner join dbo.asset_vehicle av on av.asset_code = rm.fa_code
				  where		order_code = @order_code
				  and register_status = 'PENDING'
				  for xml path('')
			  ), 1, 1, ''
			 ) ;

			set @msg = N'Please receive transaction for ' + @register_code_for_validate + ' first.' ;

			raiserror(@msg, 16, -1) ;
		end

		if(@regis_status = 'PENDING')
		begin
			set @msg = N'Please receive transaction first.' ;

			raiserror(@msg, 16, -1) ;
		end

		if (@status = 'ON CHECK')
		begin
			update	dbo.register_main
			set		payment_status	= 'ON PROCESS'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = value
			from	sys_global_param
			where	code = 'PATHRLZ' ;

			select	@requestor_code	 = code
					,@requestor_name = name
			from	ifinsys.dbo.sys_employee_main
			where	code = @p_mod_by ;

			set @interface_remarks = N'Approval realization for ' + @p_code + N', branch : ' + @branch_name + N' .' ;
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code = 'APVRLZ' ;

			--set approval path
			set @approval_path = @url_path + @path + @p_code ;

			exec dbo.xsp_ams_interface_approval_request_insert @p_code						= @request_code output
															   ,@p_branch_code				= @branch_code
															   ,@p_branch_name				= @branch_name
															   ,@p_request_status			= N'HOLD'
															   ,@p_request_date				= @req_date
															   ,@p_request_amount			= @payment_amount
															   ,@p_request_remarks			= @interface_remarks
															   ,@p_reff_module_code			= N'IFINAMS'
															   ,@p_reff_no					= @p_code
															   ,@p_reff_name				= N'REALIZATION APPROVAL'
															   ,@p_paths					= @approval_path
															   ,@p_approval_category_code	= @reff_approval_category_code
															   ,@p_approval_status			= N'HOLD'
															   ,@p_requestor_code			= @requestor_code
															   ,@p_requestor_name			= @requestor_name
															   ,@p_expired_date				= @date
															   ,@p_cre_date					= @p_mod_date
															   ,@p_cre_by					= @p_mod_by
															   ,@p_cre_ip_address			= @p_mod_ip_address
															   ,@p_mod_date					= @p_mod_date
															   ,@p_mod_by					= @p_mod_by
															   ,@p_mod_ip_address			= @p_mod_ip_address ;

			declare curr_appv cursor fast_forward read_only for
			select	approval_code
					,reff_dimension_code
					,reff_dimension_name
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'APVRLZ' ;

			open curr_appv ;

			fetch next from curr_appv
			into @approval_code
				 ,@reff_dimension_code
				 ,@reff_dimension_name
				 ,@dimension_code ;

			while @@fetch_status = 0
			begin
				select	@table_name		 = table_name
						,@primary_column = primary_column
				from	dbo.sys_dimension
				where	code = @dimension_code ;

				exec dbo.xsp_get_table_value_by_dimension @p_dim_code = @dimension_code
														  ,@p_reff_code = @p_code
														  ,@p_reff_table = 'REGISTER_MAIN'
														  ,@p_output = @dim_value output ;

				exec dbo.xsp_ams_interface_approval_request_dimension_insert @p_id = 0
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
					 ,@dimension_code ;
			end ;

			close curr_appv ;
			deallocate curr_appv ;
		end ;
		else
		begin
			set @msg = N'Data Already Proceed.' ;

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

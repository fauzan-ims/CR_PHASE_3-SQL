CREATE PROCEDURE [dbo].[master_contract_proceed]
(
	@p_main_contract_no nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@contract_standart				nvarchar(50)
			,@memo_file_path				nvarchar(250)
			,@code							nvarchar(50)
			,@document_code					nvarchar(50)
			,@remarks						nvarchar(4000)
			,@expired_date					datetime
			,@promise_date					datetime
			,@url_path						nvarchar(250)
			,@path							nvarchar(250)
			,@approval_path					nvarchar(4000)
			,@interface_remarks				nvarchar(4000)
			,@req_date						datetime
			,@reff_approval_category_code	nvarchar(50)
			,@request_code					nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@table_name					nvarchar(50)
			,@primary_column				nvarchar(50)
			,@dimension_code				nvarchar(50)
			,@dim_value						nvarchar(50)
			,@reff_dimension_code			nvarchar(50)
			,@reff_dimension_name			nvarchar(250)
			,@approval_code					nvarchar(50)

	begin try
		select	@contract_standart = contract_standart
				,@memo_file_path   = isnull(memo_file_path, '')
		from	dbo.master_contract
		where	main_contract_no = @p_main_contract_no ;

		if (@contract_standart = 'NONSTANDART')
		begin
			if (@memo_file_path = '')
			begin
				set @msg = N'Please upload memo.' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;

		if exists
		(
			select	1
			from	dbo.master_contract
			where	main_contract_no = @p_main_contract_no
					and status		 = 'HOLD'
		)
		begin
			update	dbo.master_contract
			set		status				= 'ON PROCESS'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	main_contract_no	= @p_main_contract_no ;

			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select @path = value 
			from sys_global_param
			WHERE code = 'PATHWO'

			set @interface_remarks = 'Approval master contract for ' + @p_main_contract_no + ' .';
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'MCA' ;

			--set approval path
			set	@approval_path = @url_path + @path + @p_main_contract_no

			select	@branch_name	= description
					,@branch_code	= value
			from	dbo.sys_global_param
			where	code = 'HO' ;

			exec dbo.xsp_opl_interface_approval_request_insert @p_code						= @request_code output
															   ,@p_branch_code				= @branch_code
															   ,@p_branch_name				= @branch_name
															   ,@p_request_status			= 'HOLD'
															   ,@p_request_date				= @req_date
															   ,@p_request_amount			= 0
															   ,@p_request_remarks			= @interface_remarks
															   ,@p_reff_module_code			= 'IFINOPL'
															   ,@p_reff_no					= @p_main_contract_no
															   ,@p_reff_name				= 'MASTER CONTRACT APPROVAL'
															   ,@p_paths					= @approval_path
															   ,@p_approval_category_code	= @reff_approval_category_code
															   ,@p_approval_status			= 'HOLD'
															   ,@p_cre_date					= @p_mod_date
															   ,@p_cre_by					= @p_mod_by
															   ,@p_cre_ip_address			= @p_mod_ip_address
															   ,@p_mod_date					= @p_mod_date
															   ,@p_mod_by					= @p_mod_by
															   ,@p_mod_ip_address			= @p_mod_ip_address
			
			declare curr_appv cursor fast_forward read_only for
			select 	approval_code
					,reff_dimension_code
					,reff_dimension_name
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'MCA'
			
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
															,@p_reff_code	= @p_main_contract_no
															,@p_reff_table	= 'MASTER_CONTRACT'
															,@p_output		= @dim_value output ;
				
				exec dbo.xsp_opl_interface_approval_request_dimension_insert @p_id					= 0
																			 ,@p_request_code		= @request_code
																			 ,@p_dimension_code		= @reff_dimension_code
																			 ,@p_dimension_value	= @dim_value
																			 ,@p_cre_date			= @p_mod_date
																			 ,@p_cre_by				= @p_mod_by
																			 ,@p_cre_ip_address		= @p_mod_ip_address
																			 ,@p_mod_date			= @p_mod_date
																			 ,@p_mod_by				= @p_mod_by
																			 ,@p_mod_ip_address		= @p_mod_ip_address				
			
			    fetch next from curr_appv 
				into @approval_code
					,@reff_dimension_code
					,@reff_dimension_name
					,@dimension_code
			end
			
			close curr_appv
			deallocate curr_appv
			--declare @p_code nvarchar(50) ;
			
			--exec dbo.xsp_document_tbo_insert @p_code				= @code output
			--								 ,@p_main_contract_no	= @p_main_contract_no
			--								 ,@p_status				= 'HOLD'
			--								 ,@p_cre_date			= @p_mod_date
			--								 ,@p_cre_by				= @p_mod_by
			--								 ,@p_cre_ip_address		= @p_mod_ip_address
			--								 ,@p_mod_date			= @p_mod_date
			--								 ,@p_mod_by				= @p_mod_by
			--								 ,@p_mod_ip_address		= @p_mod_ip_address
			
			--declare curr_doc cursor fast_forward read_only for
			--select document_code
			--	  ,remarks
			--	  ,expired_date
			--	  ,promise_date
			--from dbo.master_contract_document
			--where isnull(promise_date,'') <> ''
			--and main_contract_no = @p_main_contract_no
			
			--open curr_doc
			
			--fetch next from curr_doc 
			--into @document_code
			--	,@remarks
			--	,@expired_date
			--	,@promise_date
			
			--while @@fetch_status = 0
			--begin			    
			--    exec dbo.xsp_document_tbo_document_tbo_insert @p_id						= 0
			--    											  ,@p_document_tbo_code		= @code
			--    											  ,@p_document_code			= @document_code
			--    											  ,@p_remarks				= @remarks
			--    											  ,@p_filename				= ''
			--    											  ,@p_paths					= ''
			--    											  ,@p_expired_date			= null
			--    											  ,@p_promise_date			= @promise_date
			--    											  ,@p_is_required			= ''
			--    											  ,@p_is_valid				= ''
			--    											  ,@p_cre_date				= @p_mod_date
			--    											  ,@p_cre_by				= @p_mod_by
			--    											  ,@p_cre_ip_address		= @p_mod_ip_address
			--    											  ,@p_mod_date				= @p_mod_date
			--    											  ,@p_mod_by				= @p_mod_by
			--    											  ,@p_mod_ip_address		= @p_mod_ip_address
			    
			
			--    fetch next from curr_doc 
			--	into @document_code
			--		,@remarks
			--		,@expired_date
			--		,@promise_date
			--end
			
			--close curr_doc
			--deallocate curr_doc
		end ;
		else
		begin
			set @msg = N'Data already proceed' ;

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

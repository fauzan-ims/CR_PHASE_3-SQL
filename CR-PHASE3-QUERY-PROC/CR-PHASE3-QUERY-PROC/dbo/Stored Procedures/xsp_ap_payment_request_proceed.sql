CREATE PROCEDURE [dbo].[xsp_ap_payment_request_proceed]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@interface_remarks				nvarchar(4000)
			,@item_code						nvarchar(50)
			,@item_name						nvarchar(250)
			,@req_date						datetime
			,@reff_approval_category_code	nvarchar(50)
			,@request_code					nvarchar(50)
			,@req_amount					decimal(18,2)
			,@table_name					nvarchar(50)
			,@primary_column				nvarchar(50)
			,@dimension_code				nvarchar(50)
			,@dim_value						nvarchar(50)
			,@reff_dimension_code			nvarchar(50)
			,@reff_dimension_name			nvarchar(250)
			,@approval_code					nvarchar(50)
			,@approval_path					nvarchar(4000)
			,@path							nvarchar(250)
			,@supplier_name					nvarchar(250)
			,@remark						nvarchar(4000)
			,@url_path						nvarchar(250)
			,@requestor_code				nvarchar(50)
			,@requestor_name				nvarchar(250)

	begin try
		if exists
		(
			select	1
			from	dbo.ap_payment_request
			where	code	   = @p_code
					and status = 'HOLD'
		)
		begin
			update	dbo.ap_payment_request
			set		status				= 'ON PROCESS'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;

			--exec dbo.xsp_ap_payment_request_post @p_code = @p_code 
			--									 ,@p_mod_date = @p_mod_date 
			--									 ,@p_mod_by = @p_mod_by
			--									 ,@p_mod_ip_address = @p_mod_ip_address

			declare curr_apv cursor fast_forward read_only for
			select	distinct apr.branch_code
					,apr.branch_name
					--,ird.item_code
					--,ird.item_name
					,apr.invoice_amount
					,apr.supplier_name
					,apr.remark
					,apr.mod_by
					,sem.name
			from dbo.ap_payment_request apr
			inner join dbo.ap_payment_request_detail aprd on (apr.code = aprd.payment_request_code)
			left join ifinsys.dbo.sys_employee_main sem on sem.code = apr.mod_by
			--left join dbo.ap_invoice_registration_detail ird on (ird.invoice_register_code = aprd.invoice_register_code)
			where apr.code = @p_code
			
			open curr_apv
			
			fetch next from curr_apv 
			into @branch_code
				,@branch_name
				--,@item_code
				--,@item_name
				,@req_amount
				,@supplier_name
				,@remark
				,@requestor_code
				,@requestor_name
			
			while @@fetch_status = 0
			begin
			    set @interface_remarks = 'Approval Payment For ' + @supplier_name +  ' Amount: ' + format (@req_amount, '#,###.00', 'DE-de') + '. - ' +  @remark;
				set @req_date = dbo.xfn_get_system_date() ;

				select	@reff_approval_category_code = reff_approval_category_code
				from	dbo.master_approval
				where	code						 = 'PAPV' ;

				--select path di global param
				select	@url_path = value
				from	dbo.sys_global_param
				where	code = 'URL_PATH' ;

				select	@path = @url_path + value
				from	dbo.sys_global_param
				where	code = 'PATHPA'

				--set approval path
				set	@approval_path = @path + @p_code

				exec dbo.xsp_proc_interface_approval_request_insert @p_code						= @request_code output
																	,@p_branch_code				= @branch_code
																	,@p_branch_name				= @branch_name
																	,@p_request_status			= 'HOLD'
																	,@p_request_date			= @req_date
																	,@p_request_amount			= @req_amount
																	,@p_request_remarks			= @interface_remarks
																	,@p_reff_module_code		= 'IFINPROC'
																	,@p_reff_no					= @p_code
																	,@p_reff_name				= 'PAYMENT REQUEST APPROVAL'
																	,@p_paths					= @approval_path
																	,@p_approval_category_code	= @reff_approval_category_code
																	,@p_approval_status			= 'HOLD'
																	,@p_requestor_code			= @request_code
																	,@p_requesttor_name			= @requestor_name
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
				where	approval_code = 'PAPV'
				
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
																,@p_reff_table	= 'AP_PAYMENT_REQUEST'
																,@p_output		= @dim_value output ;
					
					exec dbo.xsp_proc_interface_approval_request_dimension_insert @p_id						= 0
																				  ,@p_request_code			= @request_code
																				  ,@p_dimension_code		= @reff_dimension_code
																				  ,@p_dimension_value		= @dim_value
																				  ,@p_cre_date				= @p_mod_date
																				  ,@p_cre_by				= @p_mod_by
																				  ,@p_cre_ip_address		= @p_mod_ip_address
																				  ,@p_mod_date				= @p_mod_date
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

			    fetch next from curr_apv 
				into @branch_code
					,@branch_name
					--,@item_code
					--,@item_name
					,@req_amount
					,@supplier_name
					,@remark
					,@requestor_code
					,@requestor_name
			end
			
			close curr_apv
			deallocate curr_apv
			
		end ;
		else
		begin
			set @msg = 'Data already process' ;

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
end ;

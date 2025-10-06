CREATE PROCEDURE [dbo].[xsp_payment_transaction_proceed]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
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

	begin try
		select	@status				= dor.payment_status
				,@branch_code		= dor.branch_code
				,@branch_name		= dor.branch_name
				,@payment_amount	= dor.payment_amount
				,@payment_remark	= dor.remark
		from	dbo.payment_transaction dor
		where	dor.code = @p_code ;

		if (@status = 'HOLD')
		begin
			
			--set @remarks = 'PAYMENT FOR TRANSACTION ' + @p_code
			--exec dbo.xsp_efam_interface_payment_request_insert @p_id						= 0
			--												   ,@p_code						= @code_interface_payment output
			--												   ,@p_company_code				= 'DSF'
			--												   ,@p_branch_code				= @branch_code
			--												   ,@p_branch_name				= @branch_name
			--												   ,@p_payment_branch_code		= @branch_code
			--												   ,@p_payment_branch_name		= @branch_name
			--												   ,@p_payment_source			= 'PAYMENT TRANSACTION FIXED ASSET'
			--												   ,@p_payment_request_date		= @date
			--												   ,@p_payment_source_no		= @p_code
			--												   ,@p_payment_status			= 'HOLD'
			--												   ,@p_payment_currency_code	= 'IDR'
			--												   ,@p_payment_amount			= @payment_amount
			--												   ,@p_payment_remarks			= @remarks
			--												   ,@p_to_bank_account_name		= ''
			--												   ,@p_to_bank_name				= ''
			--												   ,@p_to_bank_account_no		= ''
			--												   ,@p_tax_type					= null
			--												   ,@p_tax_file_no				= null
			--												   ,@p_tax_payer_reff_code		= null
			--												   ,@p_tax_file_name			= null
			--												   ,@p_process_date				= null
			--												   ,@p_process_reff_no			= null
			--												   ,@p_process_reff_name		= null
			--												   ,@p_settle_date				= null
			--												   ,@p_job_status				= 'HOLD'
			--												   ,@p_failed_remarks			= ''
			--												   ,@p_cre_date					= @p_mod_date	  
			--												   ,@p_cre_by					= @p_mod_by		  
			--												   ,@p_cre_ip_address			= @p_mod_ip_address
			--												   ,@p_mod_date					= @p_mod_date	  
			--												   ,@p_mod_by					= @p_mod_by		  
			--												   ,@p_mod_ip_address			= @p_mod_ip_address

			--declare curr_payment_detail cursor fast_forward read_only for
			--select orig_amount 
			--from dbo.payment_transaction_detail
			--where payment_transaction_code = @p_code
			
			--open curr_payment_detail
			
			--fetch next from curr_payment_detail 
			--into @orig_amount_db
			
			--while @@fetch_status = 0
			--begin
				
			--	exec dbo.xsp_efam_interface_payment_request_detail_insert @p_id							= 0
			--															  ,@p_payment_request_code		= @code_interface_payment
			--															  ,@p_company_code				= 'DSF'
			--															  ,@p_branch_code				= @branch_code
			--															  ,@p_branch_name				= @branch_name
			--															  ,@p_gl_link_code				= ''
			--															  ,@p_fa_code					= null
			--															  ,@p_facility_code				= null
			--															  ,@p_facility_name				= null
			--															  ,@p_purpose_loan_code			= null
			--															  ,@p_purpose_loan_name			= null
			--															  ,@p_purpose_loan_detail_code	= null
			--															  ,@p_purpose_loan_detail_name	= null
			--															  ,@p_orig_currency_code		= 'IDR'
			--															  ,@p_orig_amount				= @orig_amount_db
			--															  ,@p_division_code				= ''
			--															  ,@p_division_name				= ''
			--															  ,@p_department_code			= ''
			--															  ,@p_department_name			= ''
			--															  ,@p_is_taxable				= '0'
			--															  ,@p_remarks					= @remarks
			--															  ,@p_cre_date					= @p_mod_date	  
			--															  ,@p_cre_by					= @p_mod_by		  
			--															  ,@p_cre_ip_address			= @p_mod_ip_address
			--															  ,@p_mod_date					= @p_mod_date	  
			--															  ,@p_mod_by					= @p_mod_by		  
			--															  ,@p_mod_ip_address			= @p_mod_ip_address
				
			--    fetch next from curr_payment_detail 
			--	into @orig_amount_db
			--end
			
			--close curr_payment_detail
			--deallocate curr_payment_detail
			
			--select @amount  = sum(iipr.payment_amount)
			--from   dbo.efam_interface_payment_request iipr
			--where code = @code_interface_payment

			--select @orig_amount_db = sum(orig_amount) 
			--from  dbo.efam_interface_payment_request_detail
			--where payment_request_code = @code_interface_payment

			----set @amount = @amount + @orig_amount_db
			----+ validasi : total detail =  payment_amount yang di header
			--if (@amount <> @orig_amount_db)
			--begin
			--	set @msg = 'Payment Amount does not balance';
   -- 			raiserror(@msg, 16, -1) ;
			--end		
			
			/* declare variables */
			declare cursor_name cursor fast_forward read_only for
			select pr.payment_source
					--dikomen untuk new object info					
					--,pr.payment_source_no
					,ptd.payment_transaction_code
					,pr.mod_by
					,sem.name
			from dbo.payment_transaction_detail ptd
			left join dbo.payment_request pr on (pr.code = ptd.payment_request_code)
			left join ifinsys.dbo.sys_employee_main sem on sem.code = pr.mod_by
			where ptd.payment_transaction_code =  @p_code
			
			open cursor_name
			
			fetch next from cursor_name 
			into @payment_source
				,@payment_source_no
				,@requestor_code
				,@requestor_name
			
			while @@fetch_status = 0
			begin
				--select path di global param
				select	@url_path = value
				from	dbo.sys_global_param
				where	code = 'URL_PATH' ;

				--if(@payment_source = 'WORK ORDER')
				--begin
				--	select @path = value 
				--	from sys_global_param
				--	WHERE code = 'PATHWO'
				--end
				--else if(@payment_source = 'DP ORDER PUBLIC SERVICE')
				--begin
				--	select @path = value 
				--	from sys_global_param
				--	where code = 'PATHBJS'
				--end
				--else if(@payment_source = 'POLICY')
				--begin
				--	select @path = value 
				--	from sys_global_param
				--	where code = 'PATHINS'
				--end
				--else if(@payment_source = 'REALIZATION FOR PUBLIC SERVICE')
				--begin
				--	select @path = value 
				--	from sys_global_param
				--	where code = 'PATHRLZ'
				--end

				select @path = value 
				from sys_global_param
				WHERE code = 'PATHPAY'
			    			
			    fetch next from cursor_name 
				into @payment_source
					,@payment_source_no
					,@requestor_code
					,@requestor_name
			end
			
			close cursor_name
			deallocate cursor_name

			set @interface_remarks = 'Approval Payment For ' + @p_code + ', branch : ' + @branch_name + ' . '  + format (@payment_amount, '#,###.00', 'DE-de');
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'APVPAY' ;

			--set approval path
			set	@approval_path = @url_path + @path + @payment_source_no

			exec dbo.xsp_ams_interface_approval_request_insert @p_code						= @request_code output
															   ,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_request_status			= N'HOLD'
																,@p_request_date			= @req_date
																,@p_request_amount			= @payment_amount
																,@p_request_remarks			= @payment_remark
																,@p_reff_module_code		= N'IFINAMS'
																,@p_reff_no					= @p_code
																,@p_reff_name				= N'PAYMENT APPROVAL'
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
			where	approval_code = 'APVPAY'
			
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
															,@p_reff_table	= 'PAYMENT_TRANSACTION'
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

			update	dbo.payment_transaction
			set		payment_status		= 'ON PROCESS'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
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

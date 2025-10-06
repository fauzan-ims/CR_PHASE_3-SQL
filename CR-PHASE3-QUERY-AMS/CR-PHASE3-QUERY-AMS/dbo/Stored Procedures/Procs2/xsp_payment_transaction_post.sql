CREATE PROCEDURE dbo.xsp_payment_transaction_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@status					nvarchar(50)
			,@code_interface_payment	nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@remarks					nvarchar(4000)
			,@date						datetime = getdate()
			,@payment_amount			decimal(18,2)
			,@sp_name					nvarchar(250)
			,@debet_or_credit			nvarchar(10)
			,@gl_link_code				nvarchar(50)
			,@transaction_name			nvarchar(250)
			,@orig_amount_cr			decimal(18, 2)
			,@orig_amount_db			decimal(18, 2)
			,@amount					decimal(18, 2)
			,@to_bank_name				nvarchar(250)
			,@to_bank_account_no		nvarchar(50)
			,@to_bank_account_name		nvarchar(250)
			,@payment_remarks			nvarchar(4000)
			,@payment_detail_remarks	nvarchar(4000)
			,@ext_pph_type				nvarchar(20)	
			,@ext_vendor_code			nvarchar(50)
			,@ext_vendor_name			nvarchar(250)
			,@ext_vendor_npwp			nvarchar(20)
			,@ext_vendor_address		nvarchar(4000)
			,@ext_income_type			nvarchar(250)
			,@ext_income_bruto_amount	decimal(18,2)
			,@ext_tax_rate_pct			decimal(5,2)
			,@ext_pph_amount			decimal(18,2)
			,@ext_description			nvarchar(4000)
			,@ext_tax_number			nvarchar(50)
			,@ext_sale_type				nvarchar(10)
			,@ext_tax_date				datetime
			,@branch_code_asset			nvarchar(50)
			,@branch_name_asset			nvarchar(250)
			,@agreement_no				nvarchar(50)


	begin try
		select	@status						= dor.payment_status
				,@branch_code				= dor.branch_code
				,@branch_name				= dor.branch_name
				,@payment_amount			= dor.payment_amount
				,@payment_remarks			= dor.remark
				,@to_bank_name				= dor.to_bank_name
				,@to_bank_account_no		= dor.to_bank_account_no
				,@to_bank_account_name		= dor.to_bank_account_name
		from	dbo.payment_transaction dor
		where	dor.code = @p_code ;

		if (@status = 'ON PROCESS')
		begin

			--set @remarks = 'PAYMENT FOR TRANSACTION ' + @p_code
			exec dbo.xsp_efam_interface_payment_request_insert @p_id						= 0
															   ,@p_code						= @code_interface_payment output
															   ,@p_company_code				= 'DSF'
															   ,@p_branch_code				= @branch_code
															   ,@p_branch_name				= @branch_name
															   ,@p_payment_branch_code		= @branch_code
															   ,@p_payment_branch_name		= @branch_name
															   ,@p_payment_source			= 'PAYMENT TRANSACTION FIXED ASSET'
															   ,@p_payment_request_date		= @date
															   ,@p_payment_source_no		= @p_code
															   ,@p_payment_status			= 'HOLD'
															   ,@p_payment_currency_code	= 'IDR'
															   ,@p_payment_amount			= @payment_amount
															   ,@p_payment_remarks			= @payment_remarks
															   ,@p_to_bank_account_name		= @to_bank_account_name
															   ,@p_to_bank_name				= @to_bank_name
															   ,@p_to_bank_account_no		= @to_bank_account_no
															   ,@p_tax_type					= null
															   ,@p_tax_file_no				= null
															   ,@p_tax_payer_reff_code		= null
															   ,@p_tax_file_name			= null
															   ,@p_process_date				= null
															   ,@p_process_reff_no			= null
															   ,@p_process_reff_name		= null
															   ,@p_settle_date				= null
															   ,@p_job_status				= 'HOLD'
															   ,@p_failed_remarks			= ''
															   ,@p_cre_date					= @p_mod_date	  
															   ,@p_cre_by					= @p_mod_by		  
															   ,@p_cre_ip_address			= @p_mod_ip_address
															   ,@p_mod_date					= @p_mod_date	  
															   ,@p_mod_by					= @p_mod_by		  
															   ,@p_mod_ip_address			= @p_mod_ip_address

			declare curr_payment_detail cursor fast_forward read_only for
			select	prd.gl_link_code
					,prd.orig_amount
					,prd.remarks
					,prd.ext_pph_type
					,prd.ext_vendor_code
					,prd.ext_vendor_name
					,prd.ext_vendor_npwp
					,prd.ext_vendor_address
					,prd.ext_income_type
					,prd.ext_income_bruto_amount
					,prd.ext_tax_rate_pct
					,prd.ext_pph_amount
					,prd.ext_description
					,prd.ext_tax_number
					,prd.ext_sale_type
					,prd.branch_code
					,prd.branch_name
					,prd.agreement_no
					,prd.ext_tax_date
			from	dbo.payment_transaction_detail ptd
			inner join dbo.payment_request_detail prd on (prd.payment_request_code = ptd.payment_request_code)
			where	payment_transaction_code = @p_code ;
			
			open curr_payment_detail
			
			fetch next from curr_payment_detail 
			into @gl_link_code
				,@orig_amount_db
				,@payment_detail_remarks
				,@ext_pph_type				
				,@ext_vendor_code			
				,@ext_vendor_name			
				,@ext_vendor_npwp			
				,@ext_vendor_address		
				,@ext_income_type			
				,@ext_income_bruto_amount	
				,@ext_tax_rate_pct			
				,@ext_pph_amount			
				,@ext_description			
				,@ext_tax_number			
				,@ext_sale_type	
				,@branch_code_asset
				,@branch_name_asset
				,@agreement_no
				,@ext_tax_date
			
			while @@fetch_status = 0
			begin
				
				exec dbo.xsp_efam_interface_payment_request_detail_insert @p_id							= 0
																		  ,@p_payment_request_code		= @code_interface_payment
																		  ,@p_company_code				= 'DSF'
																		  ,@p_branch_code				= @branch_code_asset
																		  ,@p_branch_name				= @branch_name_asset
																		  ,@p_gl_link_code				= @gl_link_code
																		  ,@p_fa_code					= null
																		  ,@p_facility_code				= null
																		  ,@p_facility_name				= null
																		  ,@p_purpose_loan_code			= null
																		  ,@p_purpose_loan_name			= null
																		  ,@p_purpose_loan_detail_code	= null
																		  ,@p_purpose_loan_detail_name	= null
																		  ,@p_orig_currency_code		= 'IDR'
																		  ,@p_orig_amount				= @orig_amount_db
																		  ,@p_division_code				= ''
																		  ,@p_division_name				= ''
																		  ,@p_department_code			= ''
																		  ,@p_department_name			= ''
																		  ,@p_is_taxable				= '0'
																		  ,@p_remarks					= @payment_detail_remarks
																		  ,@p_ext_pph_type				= @ext_pph_type
																	      ,@p_ext_vendor_code			= @ext_vendor_code
																	      ,@p_ext_vendor_name			= @ext_vendor_name
																	      ,@p_ext_vendor_npwp			= @ext_vendor_npwp
																	      ,@p_ext_vendor_address		= @ext_vendor_address
																	      ,@p_ext_income_type			= @ext_income_type
																	      ,@p_ext_income_bruto_amount	= @ext_income_bruto_amount
																	      ,@p_ext_tax_rate_pct			= @ext_tax_rate_pct
																	      ,@p_ext_pph_amount			= @ext_pph_amount
																	      ,@p_ext_description			= @ext_description	
																	      ,@p_ext_tax_number			= @ext_tax_number
																	      ,@p_ext_sale_type				= @ext_sale_type
																		  ,@p_agreement_no				= @agreement_no
																		  ,@p_ext_tax_date				= @ext_tax_date
																		  ,@p_cre_date					= @p_mod_date	  
																		  ,@p_cre_by					= @p_mod_by		  
																		  ,@p_cre_ip_address			= @p_mod_ip_address
																		  ,@p_mod_date					= @p_mod_date	  
																		  ,@p_mod_by					= @p_mod_by		  
																		  ,@p_mod_ip_address			= @p_mod_ip_address
				
			    fetch next from curr_payment_detail 
				into @gl_link_code
					,@orig_amount_db
					,@payment_detail_remarks
					,@ext_pph_type				
					,@ext_vendor_code			
					,@ext_vendor_name			
					,@ext_vendor_npwp			
					,@ext_vendor_address		
					,@ext_income_type			
					,@ext_income_bruto_amount	
					,@ext_tax_rate_pct			
					,@ext_pph_amount			
					,@ext_description			
					,@ext_tax_number			
					,@ext_sale_type	
					,@branch_code_asset
					,@branch_name_asset
					,@agreement_no
					,@ext_tax_date
			end
			
			close curr_payment_detail
			deallocate curr_payment_detail
			
			select @amount  = isnull(sum(iipr.payment_amount),0)
			from   dbo.efam_interface_payment_request iipr
			where code = @code_interface_payment

			select @orig_amount_db = isnull(sum(orig_amount),0)
			from  dbo.efam_interface_payment_request_detail
			where payment_request_code = @code_interface_payment

			--set @amount = @amount + @orig_amount_db
			--+ validasi : total detail =  payment_amount yang di header
			if (@amount <> @orig_amount_db)
			begin
				set @msg = 'Payment Amount does not balance';
    			raiserror(@msg, 16, -1) ;
			end		
			


			update	dbo.payment_transaction
			set		payment_status		= 'APPROVE'
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


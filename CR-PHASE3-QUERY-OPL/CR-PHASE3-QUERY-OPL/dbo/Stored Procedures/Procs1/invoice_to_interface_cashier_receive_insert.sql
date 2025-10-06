CREATE PROCEDURE [dbo].[invoice_to_interface_cashier_receive_insert]
(
	@p_invoice_no	   nvarchar(50)
	-- 
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						  nvarchar(max)
			,@invoice_detail_id			  bigint
			,@code						  nvarchar(50)
			,@branch_code				  nvarchar(50)
			,@branch_name				  nvarchar(250)
			,@detail_branch_code		  nvarchar(50)
			,@detail_branch_name		  nvarchar(250)
			,@currency					  nvarchar(10)
			,@agreement_no				  nvarchar(50)	= N''
			,@sp_name					  nvarchar(250)
			,@gl_link_code				  nvarchar(50)
			,@transaction_name			  nvarchar(4000)
			,@debet_or_credit			  nvarchar(10)
			,@remarks					  nvarchar(4000)
			,@client_name				  nvarchar(250)
			,@facility_code				  nvarchar(50)
			,@facility_name				  nvarchar(250)
			,@return_value				  decimal(18, 2)
			,@orig_amount_db			  decimal(18, 2)
			,@total_billing_amount		  decimal(18, 2)
			,@total_ppn_amount			  int
			,@total_pph_amount			  int
			,@request_amount			  decimal(18, 2)
			,@agreement_external_no		  nvarchar(50)
			,@invoice_no				  nvarchar(50)
			,@invoice_external_no		  nvarchar(50)
			,@invoice_date				  datetime
			,@invoice_due_date			  datetime
			,@invoice_not_balance_migrasi nvarchar(50) 
			,@detail_agreement_no		  nvarchar(50)
			,@process_code				  nvarchar(50)
			,@client_no					  nvarchar(50) -- Louis Rabu, 25 Juni 2025 10.51.22 --  

	begin try
	
		select  @branch_code			= inv.branch_code
				,@branch_name			= inv.branch_name
				,@currency				= inv.currency_code
				,@total_billing_amount	= inv.total_billing_amount - inv.total_discount_amount
				,@total_ppn_amount		= case when inv.billing_to_faktur_type = '01' then inv.total_ppn_amount else 0 end
				,@total_pph_amount		= case when inv.is_invoice_deduct_pph = '1' then inv.total_pph_amount else 0 end
				,@agreement_no			= ivd.agreement_no
				,@client_name			= inv.client_name
				,@facility_code			= ivd.facility_code
				,@facility_name			= ivd.facility_name
				,@request_amount		= inv.total_amount
				,@agreement_external_no	= ivd.agreement_external_no
				,@invoice_no			= inv.invoice_no
				,@invoice_external_no	= inv.invoice_external_no
				,@invoice_date			= inv.invoice_date	
				,@invoice_due_date		= inv.invoice_due_date
				,@client_no				= inv.client_no -- Louis Rabu, 25 Juni 2025 10.51.22 --  
				,@process_code			= case when inv.invoice_type IN ('PENALTY','LATERETURN') then 'INVPENALTY' else 'INVCR' END  -- RAFFY 2025/08/06 CR FASE 3
		from	dbo.invoice inv
				outer apply
				(
					select	top 1 
							am.agreement_no           
							,am.agreement_external_no
							,am.facility_code
							,am.facility_name
					from	dbo.invoice_detail ivd
							left join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no) 
							where ivd.invoice_no = inv.invoice_no
				) ivd
		where	inv.invoice_no = @p_invoice_no ;
		
		if(@agreement_no is null)
		begin
			set @msg = 'Invoice must be have agreement'
			raiserror(@msg, 16, 1) ;
		end
	
		set @remarks = 'Invoice '+@invoice_external_no+ ' Agreement '+ @agreement_external_no +' Client '+ @client_name
		 
		exec dbo.xsp_opl_interface_cashier_received_request_insert	@p_code						= @code output
																	,@p_branch_code				= @branch_code
																	,@p_branch_name				= @branch_name
																	,@p_request_status			= 'HOLD'
																	,@p_request_currency_code	= @currency
																	,@p_request_date			= @p_mod_date
																	,@p_request_amount			= @request_amount
																	,@p_request_remarks			= @remarks
																	,@p_agreement_no			= @agreement_no
																	,@p_client_no				= @client_no -- Louis Rabu, 25 Juni 2025 10.53.13 -- 
																	,@p_client_name				= @client_name-- Louis Rabu, 25 Juni 2025 10.55.03 -- 
																	,@p_pdc_code				= null
																	,@p_pdc_no					= null
																	,@p_doc_reff_code			= @p_invoice_no
																	,@p_doc_reff_name			= 'INVOICE SEND'
																	,@p_doc_reff_fee_code		= 'INVC'
																	,@p_process_date			= null
																	,@p_process_branch_code		= @branch_code
																	,@p_process_branch_name		= @branch_name
																	,@p_process_reff_no			= null
																	,@p_process_reff_name		= null
																	,@p_process_gl_link_code	= ''
																	,@p_invoice_no				= @invoice_no				
																	,@p_invoice_external_no		= @invoice_external_no		
																	,@p_invoice_date			= @invoice_date			
																	,@p_invoice_due_date		= @invoice_due_date		
																	,@p_invoice_billing_amount	= @total_billing_amount
																	,@p_invoice_ppn_amount	  	= @total_ppn_amount	
																	,@p_invoice_pph_amount	  	= @total_pph_amount	
																	--
																	,@p_cre_date				= @p_mod_date		
																	,@p_cre_by					= @p_mod_by			
																	,@p_cre_ip_address			= @p_mod_ip_address
																	,@p_mod_date				= @p_mod_date		
																	,@p_mod_by					= @p_mod_by			
																	,@p_mod_ip_address			= @p_mod_ip_address
			
	 
		declare curr_cashier_send cursor fast_forward read_only for
        select  mt.sp_name
				,mtp.debet_or_credit
				,mtp.gl_link_code
				,mt.transaction_name + ' - ' + invd.DESCRIPTION
				,invd.id
				,am.branch_code
				,am.branch_name
				,invd.agreement_no
		from	dbo.master_transaction_parameter mtp 
				left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
				left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
				inner join dbo.invoice_detail invd on (1 = 1)
				inner join dbo.agreement_main am on (am.agreement_no = invd.agreement_no)
		where	mtp.process_code = @process_code
		and invd.invoice_no = @p_invoice_no
		order by invd.id
			
		open curr_cashier_send
			
		fetch next from curr_cashier_send 
		into @sp_name
			,@debet_or_credit
			,@gl_link_code
			,@transaction_name
			,@invoice_detail_id
			,@detail_branch_code
			,@detail_branch_name
			,@detail_agreement_no
			
		while @@fetch_status = 0
		begin
		
			-- nilainya exec dari MASTER_TRANSACTION.sp_name
			exec @return_value = @sp_name @invoice_detail_id; -- sp ini mereturn value angka 
					
			if (@debet_or_credit = 'DEBIT')
			begin
				set @orig_amount_db = @return_value
			end
			else
			begin
				set @orig_amount_db = @return_value * -1
			end

			--set @orig_amount = @total_billing_amount + @total_ppn_amount
			exec dbo.xsp_opl_interface_cashier_received_request_detail_insert @p_id									= 0
																				,@p_cashier_received_request_code	= @code
																				,@p_branch_code						= @detail_branch_code
																				,@p_branch_name						= @detail_branch_name
																				,@p_gl_link_code					= @gl_link_code
																				,@p_agreement_no					= @detail_agreement_no
																				,@p_facility_code					= @facility_code
																				,@p_facility_name					= @facility_name
																				,@p_purpose_loan_code				= null
																				,@p_purpose_loan_name				= null
																				,@p_purpose_loan_detail_code		= null
																				,@p_purpose_loan_detail_name		= null
																				,@p_orig_currency_code				= @currency
																				,@p_orig_amount						= @orig_amount_db
																				,@p_division_code					= null
																				,@p_division_name					= null
																				,@p_department_code					= null
																				,@p_department_name					= null
																				,@p_remarks							= @transaction_name
																				,@p_cre_date						= @p_mod_date		
																				,@p_cre_by							= @p_mod_by			
																				,@p_cre_ip_address					= @p_mod_ip_address
																				,@p_mod_date						= @p_mod_date		
																				,@p_mod_by							= @p_mod_by			
																				,@p_mod_ip_address					= @p_mod_ip_address
				
			fetch next from curr_cashier_send 
			into @sp_name
				,@debet_or_credit
				,@gl_link_code
				,@transaction_name
				,@invoice_detail_id
				,@detail_branch_code
				,@detail_branch_name
				,@detail_agreement_no
		end
			
		close curr_cashier_send
		deallocate curr_cashier_send
	 

		--validasi
		set @msg = dbo.xfn_finance_request_check_balance('CASHIER',@code)
	
		if @msg <> ''
		begin
			
			if(@p_mod_by = 'MIGRASI_JOB')
			begin
				--sepria 20/20/2023: keperluan migrasi
				select @invoice_not_balance_migrasi = invoice_no from dbo.opl_interface_cashier_received_request
				where code = @code

			   insert into temp_invoice_not_balance_migrasi
			   values (@invoice_not_balance_migrasi,@msg,@p_mod_date)
			end
			else
            begin
				raiserror(@msg,16,1);
            end
			
		end

	end try
	Begin catch
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





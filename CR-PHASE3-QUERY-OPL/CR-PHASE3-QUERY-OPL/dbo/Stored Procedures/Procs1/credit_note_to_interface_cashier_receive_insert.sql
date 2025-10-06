/*
exec dbo.credit_note_to_interface_cashier_receive_insert @p_code = N'' -- nvarchar(50)
														 ,@p_mod_date = '2023-06-15 07.17.22' -- datetime
														 ,@p_mod_by = N'' -- nvarchar(15)
														 ,@p_mod_ip_address = N'' -- nvarchar(15)

*/
-- Louis Kamis, 15 Juni 2023 14.17.30 -- 
CREATE PROCEDURE [dbo].[credit_note_to_interface_cashier_receive_insert]
(
	@p_code			   nvarchar(50)
	-- 
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@invoice_detail_id		bigint
			,@code					nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@invoice_no			nvarchar(50)
			,@invoice_external_no	nvarchar(50)
			,@currency				nvarchar(3)
			,@agreement_no			nvarchar(50)
			,@date_now				datetime
			,@invoice_date			datetime
			,@invoice_due_date		datetime
			,@request_amount		decimal(18, 2)
			,@total_billing_amount	decimal(18, 2)
			,@total_ppn_amount		int
			,@total_pph_amount		int
			,@sp_name				nvarchar(250)
			,@agreement_external_no nvarchar(50)
			,@gl_link_code			nvarchar(50)
			,@transaction_name		nvarchar(4000)
			,@request_remarks		nvarchar(250)
			,@debet_or_credit		nvarchar(10)
			,@return_value			decimal(18, 2)
			,@orig_amount_db		decimal(18, 2)
			,@detail_agreement_no	nvarchar(50)
			,@facility_code			nvarchar(50)
			,@facility_name			nvarchar(250) 
			,@client_no				nvarchar(50) -- Louis Rabu, 25 Juni 2025 10.54.45 -- 
			,@client_name			nvarchar(250) -- Louis Rabu, 25 Juni 2025 10.54.45 -- 

	begin try
		
		set @date_now = dbo.xfn_get_system_date()

		select @branch_code				= cn.branch_code
			  ,@branch_name				= cn.branch_name
			  ,@invoice_no				= cn.invoice_no
			  ,@invoice_external_no		= inv.invoice_external_no
			  ,@currency				= cn.currency_code
			  ,@total_ppn_amount		= case when inv.billing_to_faktur_type = '01' then cn.new_ppn_amount else 0 end
			  ,@total_pph_amount		= case when inv.is_invoice_deduct_pph = '1' then cn.new_pph_amount else 0 end
			  ,@total_billing_amount	= cn.new_total_amount
			  ,@agreement_no			= invd.agreement_no
			  ,@invoice_date			= inv.invoice_date
			  ,@invoice_due_date		= inv.invoice_due_date
			  ,@facility_code			= am.facility_code
			  ,@facility_name			= am.facility_name
			  ,@agreement_external_no	= am.agreement_external_no
			  ,@client_no				= inv.client_no-- Louis Rabu, 25 Juni 2025 10.55.00 -- 
			  ,@client_name				= inv.client_name-- Louis Rabu, 25 Juni 2025 10.55.00 -- 
		from  dbo.credit_note cn
			  left join dbo.invoice_detail invd on (invd.invoice_no = cn.invoice_no)
			  left join dbo.invoice inv on (inv.invoice_no = invd.invoice_no)
			  left join dbo.agreement_main am on (am.agreement_no = invd.agreement_no)
		where cn.code = @p_code

		if(@agreement_no is null)
		begin
			set @msg = 'Invoice must be have agreement'
			raiserror(@msg, 16, 1) ;
		end
	
		set @request_remarks = 'Credit Note For ' + @agreement_external_no

		exec dbo.xsp_opl_interface_cashier_received_request_insert	@p_code						= @code output
																	,@p_branch_code				= @branch_code
																	,@p_branch_name				= @branch_name
																	,@p_request_status			= 'HOLD'
																	,@p_request_currency_code	= @currency
																	,@p_request_date			= @date_now
																	,@p_request_amount			= @total_billing_amount
																	,@p_request_remarks			= @request_remarks
																	,@p_agreement_no			= @agreement_no
																	,@p_client_no				= @client_no-- Louis Rabu, 25 Juni 2025 10.55.03 --
																	,@p_client_name				= @client_name-- Louis Rabu, 25 Juni 2025 10.55.03 -- 
																	,@p_pdc_code				= null
																	,@p_pdc_no					= null
																	,@p_doc_reff_code			= @p_code			
																	,@p_doc_reff_name			= 'CREDIT NOTE'		
																	,@p_doc_reff_fee_code		= 'CN'				
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
			 
		declare curr_credit_note cursor fast_forward read_only for
        select  mt.sp_name
				,mtp.debet_or_credit
				,mtp.gl_link_code
				,mt.transaction_name + ' - ' + invd.DESCRIPTION
				,crnd.invoice_detail_id  
				,invd.agreement_no
		from	dbo.master_transaction_parameter mtp 
				left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
				left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
				inner join dbo.credit_note_detail crnd on (1 = 1) 
				inner join dbo.invoice_detail invd on (invd.id = crnd.invoice_detail_id)
		where	mtp.process_code = 'INVCHRCN'
		and crnd.credit_note_code = @p_code
		order by crnd.id
			
		open curr_credit_note
			
		fetch next from curr_credit_note 
		into @sp_name
			,@debet_or_credit
			,@gl_link_code
			,@transaction_name
			,@invoice_detail_id
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
		 
			exec dbo.xsp_opl_interface_cashier_received_request_detail_insert @p_id									= 0
																				,@p_cashier_received_request_code	= @code
																				,@p_branch_code						= @branch_code
																				,@p_branch_name						= @branch_name
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
				
			fetch next from curr_credit_note 
			into @sp_name
				,@debet_or_credit
				,@gl_link_code
				,@transaction_name
				,@invoice_detail_id
				,@detail_agreement_no
		end
			
		close curr_credit_note
		deallocate curr_credit_note

		--validasi
		set @msg = dbo.xfn_finance_request_check_balance('CASHIER',@code)
		if @msg <> ''
		begin
			raiserror(@msg,16,1);
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





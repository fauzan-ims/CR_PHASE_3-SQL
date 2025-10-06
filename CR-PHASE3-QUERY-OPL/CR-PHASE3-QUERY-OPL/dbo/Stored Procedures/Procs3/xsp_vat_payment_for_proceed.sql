CREATE PROCEDURE dbo.xsp_vat_payment_for_proceed
(
	@p_code					   nvarchar(50)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max) 
			,@invoice_no						nvarchar(50)
			,@invoice_external_no				nvarchar(50)
			,@ppn_amount						int
			,@code								nvarchar(50)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@currency							nvarchar(10)
			,@agreement_no						nvarchar(50)
			,@agreement_external_no				nvarchar(50)
			,@asset_no							nvarchar(50)
			,@total_amount						decimal(18,2)
			,@sp_name							nvarchar(250)
			,@gl_link_code						nvarchar(50)
			,@transaction_name					nvarchar(250)
			,@debet_or_credit					nvarchar(10)
			,@remarks							nvarchar(4000)
			,@faktur_no							nvarchar(50)
			,@client_no							nvarchar(50)
			,@client_name						nvarchar(250)
			,@asset_name						nvarchar(250)
			,@facility_code						nvarchar(50)
			,@facility_name						nvarchar(250)
			,@return_value						decimal(18, 2)
			,@orig_amount_db					decimal(18, 2)
			,@header_amount						decimal(18,2)
			,@detail_amount						decimal(18,2)
			,@ppn_amount_detail					int
			,@remark							nvarchar(4000)
			,@description						nvarchar(4000);

	begin try

		select @invoice_no					= ivd.invoice_no
			  ,@invoice_external_no			= inv.invoice_external_no
			  ,@ppn_amount					= ivd.ppn_amount
			  ,@branch_code					= ivp.branch_code
			  ,@branch_name					= ivp.branch_name
			  ,@currency					= inv.currency_code
			  ,@agreement_no				= ind.agreement_no
			  ,@agreement_external_no		= am.agreement_external_no
			  ,@asset_no					= ind.asset_no
			  ,@total_amount				= isnull(ivp.total_ppn_amount,0)
			  ,@faktur_no					= fm.faktur_no
			  ,@client_no					= inv.client_no
			  ,@client_name					= inv.client_name
			  ,@asset_name					= ass.asset_name
			  ,@facility_code				= am.facility_code
			  ,@facility_name				= am.facility_name
		from dbo.invoice_vat_payment_detail ivd
		left join dbo.invoice_vat_payment ivp on (ivp.code = ivd.tax_payment_code)
		left join dbo.invoice inv on (inv.invoice_no = ivd.invoice_no)
		left join dbo.invoice_detail ind on (ind.invoice_no = inv.invoice_no)
		left join dbo.faktur_main fm on (fm.invoice_no = inv.invoice_no)
		left join dbo.agreement_asset ass on (ass.asset_no = ind.asset_no)
		left join dbo.agreement_main am on (am.agreement_no = ass.agreement_no)
		where ivd.tax_payment_code = @p_code 



		set @remark		=  'Payment VAT from Invoice Operating lease '+ @p_code
		    
		exec dbo.xsp_opl_interface_payment_request_insert @p_code					= @code output
														  ,@p_branch_code			= @branch_code
														  ,@p_branch_name			= @branch_name
														  ,@p_payment_branch_code	= @branch_code
														  ,@p_payment_branch_name	= @branch_name
														  ,@p_payment_source		= 'VAT OUT FOR OPERATING LEASE'
														  ,@p_payment_request_date	= @p_mod_date
														  ,@p_payment_source_no		= @p_code
														  ,@p_payment_status		= 'HOLD'
														  ,@p_payment_currency_code = @currency
														  ,@p_payment_amount		= @total_amount
														  ,@p_payment_remarks		= @remark
														  ,@p_to_bank_account_name	= ''
														  ,@p_to_bank_name			= ''
														  ,@p_to_bank_account_no	= ''
														  ,@p_process_date			= null
														  ,@p_process_reff_no		= null
														  ,@p_process_reff_name		= null
														  ,@p_manual_upload_status	= ''
														  ,@p_manual_upload_remarks = ''
														  ,@p_job_status			= 'HOLD'
														  ,@p_failed_remarks		= ''
														  ,@p_cre_date				= @p_mod_date		
														  ,@p_cre_by				= @p_mod_by			
														  ,@p_cre_ip_address		= @p_mod_ip_address
														  ,@p_mod_date				= @p_mod_date		
														  ,@p_mod_by				= @p_mod_by			
														  ,@p_mod_ip_address		= @p_mod_ip_address
			
			declare curr_vat_proceed cursor fast_forward read_only for
			
            select  mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
			from	dbo.master_transaction_parameter mtp 
					left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
					left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
			where	mtp.process_code = 'INVVAT'	
			
			open curr_vat_proceed
			
			fetch next from curr_vat_proceed 
			into @sp_name
				,@debet_or_credit
				,@gl_link_code
				,@transaction_name
			
			while @@fetch_status = 0
			begin
				 exec @return_value = @sp_name @p_code; -- sp ini mereturn value angka 
					
				if (@debet_or_credit ='DEBIT')
				begin
					set @orig_amount_db = @return_value
				end
				else
				begin
					set @orig_amount_db = @return_value * -1
				end
				--declare curr_vat_proceed_detail cursor fast_forward read_only for

				--select	ppn_amount
				--		,description
				--from dbo.invoice_detail
				--where invoice_no = @invoice_no
				
				--open curr_vat_proceed_detail
				
				--fetch next from curr_vat_proceed_detail 
				--into @ppn_amount_detail
				--	,@description
				
				--while @@fetch_status = 0
				--begin
				    set @remarks = 'VAT Payment Invoice No ' + isnull(@invoice_external_no,'') + ' Faktur No ' + isnull(@faktur_no,'') + ' Agreement ' + ' ' + isnull(@agreement_external_no,'') + ' ' + isnull(@client_name,'') + ' ' + isnull(@asset_no,'') + ' ' + isnull(@asset_name,'') + ' -- ' + isnull(@description,'');
					exec dbo.xsp_opl_interface_payment_request_detail_insert @p_id							= 0
																			 ,@p_payment_request_code		= @code
																			 ,@p_branch_code				= @branch_code
																			 ,@p_branch_name				= @branch_name
																			 ,@p_gl_link_code				= @gl_link_code
																			 ,@p_agreement_no				= @agreement_external_no
																			 ,@p_facility_code				= @facility_code
																			 ,@p_facility_name				= @facility_name
																			 ,@p_purpose_loan_code			= ''
																			 ,@p_purpose_loan_name			= ''
																			 ,@p_purpose_loan_detail_code	= ''
																			 ,@p_purpose_loan_detail_name	= ''
																			 ,@p_orig_currency_code			= @currency
																			 ,@p_orig_amount				= @return_value
																			 ,@p_division_code				= ''
																			 ,@p_division_name				= ''
																			 ,@p_department_code			= ''
																			 ,@p_department_name			= ''
																			 ,@p_remarks					= @remarks
																			 ,@p_cre_date					= @p_mod_date		
																			 ,@p_cre_by						= @p_mod_by			
																			 ,@p_cre_ip_address				= @p_mod_ip_address
																			 ,@p_mod_date					= @p_mod_date		
																			 ,@p_mod_by						= @p_mod_by			
																			 ,@p_mod_ip_address				= @p_mod_ip_address
					
				--    fetch next from curr_vat_proceed_detail 
				--	into @ppn_amount_detail
				--		,@description
				--end
				
				--close curr_vat_proceed_detail
				--deallocate curr_vat_proceed_detail

				
			
			    fetch next from curr_vat_proceed 
				into @sp_name
					,@debet_or_credit
					,@gl_link_code
					,@transaction_name
			end
			
			close curr_vat_proceed
			deallocate curr_vat_proceed

		--validasi
		set @msg = dbo.xfn_finance_request_check_balance('PAYMENT',@code)
		if @msg <> ''
		begin
			raiserror(@msg,16,1);
		end
		
		if exists
		(
			select	1
			from	dbo.invoice_vat_payment
			where	code	= @p_code
			and		status	= 'HOLD'
		)
		begin

			update	dbo.invoice_vat_payment
			set		status					= 'ON PROCESS'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;

		end ;
		else
		begin
			set @msg = 'Data already proceed.';
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


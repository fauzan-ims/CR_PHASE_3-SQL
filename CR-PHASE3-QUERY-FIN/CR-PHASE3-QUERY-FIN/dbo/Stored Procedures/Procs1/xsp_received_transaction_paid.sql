CREATE PROCEDURE dbo.xsp_received_transaction_paid
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg							nvarchar(max)
			,@gl_link_code					nvarchar(50)
			,@agreement_no					nvarchar(50)
			,@gl_link_transaction_code		nvarchar(50)
			,@received_request_code			nvarchar(50)
			,@bank_mutation_code			nvarchar(50)
			,@branch_gl_link_code			nvarchar(50)
			,@branch_bank_code				nvarchar(50)
			,@branch_bank_name				nvarchar(250)
			,@received_base_amount			decimal(18, 2)
			,@received_orig_amount			decimal(18, 2)
			,@received_exch_rate			decimal(18, 6)
			,@exch_rate						decimal(18, 6)
			,@orig_amount					decimal(18, 2)
			,@base_amount					decimal(18, 2)
			,@base_amount_db				decimal(18, 2)
			,@base_amount_cr				decimal(18, 2)
			,@orig_amount_db				decimal(18, 2)
			,@orig_amount_cr				decimal(18, 2)
			,@division_code					nvarchar(50)
			,@division_name					nvarchar(250)
			,@department_code				nvarchar(50)
			,@department_name				nvarchar(250)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@reff_source_name				nvarchar(250)
			,@received_remarks				nvarchar(4000)
			,@remarks						nvarchar(4000)
			,@received_transaction_date		datetime
			,@received_value_date			datetime
			,@received_orig_currency_code	nvarchar(3)
			,@orig_currency_code			nvarchar(3)
			,@index							int = 0
			,@ext_pph_type					nvarchar(20)
			,@ext_vendor_code				nvarchar(50)
			,@ext_vendor_name				nvarchar(250)
			,@ext_vendor_npwp				nvarchar(20)
			,@ext_vendor_address			nvarchar(4000)
			,@ext_vendor_type				nvarchar(20)
			,@ext_income_type				nvarchar(20)
			,@ext_income_bruto_amount		decimal(18,2)
			,@ext_tax_rate_pct				decimal(5,2)
			,@ext_pph_amount				decimal(18,2)
			,@ext_description				nvarchar(4000)
			,@ext_tax_number				nvarchar(50)
			,@ext_sale_type					nvarchar(50)
			,@ext_tax_date					datetime
			,@branch_code_detail			nvarchar(50)
			,@branch_name_detail			nvarchar(250)
			,@system_date					datetime	 = dbo.xfn_get_system_date()
			,@ext_nitku						nvarchar(50)
			,@ext_npwp_ho					nvarchar(50)

	begin try
	
		if	(
				(select received_base_amount from dbo.received_transaction where code = @p_code) <> 
				(select sum(base_amount) from dbo.received_transaction_detail where received_transaction_code = @p_code)
			)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_equal_to('Base Amount','Total Amount');
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from received_transaction where code = @p_code and received_orig_amount <= 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Orig Amount','0');
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.received_transaction where code = @p_code and received_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			update	received_transaction
			set		received_transaction_date = dbo.xfn_get_system_date()
			where	code = @p_code ;

			select	@branch_code					= branch_code
					,@branch_name					= branch_name
					,@received_transaction_date		= received_transaction_date
					,@received_value_date			= received_value_date
					,@received_orig_currency_code	= received_orig_currency_code
					,@received_base_amount			= received_base_amount
					,@received_orig_amount			= received_orig_amount
					,@received_exch_rate			= received_exch_rate
					,@branch_gl_link_code			= bank_gl_link_code
					,@branch_bank_code				= branch_bank_code
					,@branch_bank_name				= branch_bank_name
					,@received_remarks				= received_remarks
			from	dbo.received_transaction
			where	code = @p_code


			exec dbo.xsp_bank_mutation_insert @p_code				= @bank_mutation_code output 
											  ,@p_branch_code		= @branch_code
											  ,@p_branch_name		= @branch_name
											  ,@p_gl_link_code		= @branch_gl_link_code
											  ,@p_branch_bank_code	= @branch_bank_code
											  ,@p_branch_bank_name	= @branch_bank_name
											  ,@p_balance_amount	= @received_orig_amount
											  ,@p_cre_date			= @p_cre_date		
											  ,@p_cre_by			= @p_cre_by			
											  ,@p_cre_ip_address	= @p_cre_ip_address
											  ,@p_mod_date			= @p_mod_date		
											  ,@p_mod_by			= @p_mod_by			
											  ,@p_mod_ip_address	= @p_mod_ip_address


			exec dbo.xsp_bank_mutation_history_insert @p_id						= 0
													  ,@p_bank_mutation_code	= @bank_mutation_code
													  ,@p_transaction_date		= @system_date
													  ,@p_value_date			= @received_value_date
													  ,@p_source_reff_code		= @p_code
													  ,@p_source_reff_name		= N'Received Confirm' 
													  ,@p_orig_amount			= @received_orig_amount
													  ,@p_orig_currency_code	= @received_orig_currency_code
													  ,@p_exch_rate				= @received_exch_rate
													  ,@p_base_amount			= @received_base_amount
													  ,@p_remarks				= @received_remarks
													  ,@p_cre_date				= @p_cre_date		
													  ,@p_cre_by				= @p_cre_by			
													  ,@p_cre_ip_address		= @p_cre_ip_address
													  ,@p_mod_date				= @p_mod_date		
													  ,@p_mod_by				= @p_mod_by			
													  ,@p_mod_ip_address		= @p_mod_ip_address

			declare cur_received_transaction_detail cursor fast_forward read_only for
			
			select	rtd.received_request_code
					,rrd.remarks
					,rtd.exch_rate
					,rrd.orig_amount
					,rtd.exch_rate * rrd.orig_amount
					,rrd.division_code
					,rrd.division_name
					,rrd.department_code
					,rrd.department_name
					,rrd.orig_currency_code
					,rrd.agreement_no
					,rrd.gl_link_code
					,rrd.ext_pph_type
					,rrd.ext_vendor_code
					,rrd.ext_vendor_name
					,rrd.ext_vendor_npwp
					,rrd.ext_vendor_address
					,rrd.ext_vendor_type
					,rrd.ext_income_type
					,rrd.ext_income_bruto_amount
					,rrd.ext_tax_rate_pct
					,rrd.ext_pph_amount
					,rrd.ext_description
					,rrd.ext_tax_number
					,rrd.ext_sale_type
					,rrd.ext_tax_date
					,rrd.branch_code
					,rrd.branch_name
					-- CR NITKU (+) Raffy
					,rrd.ext_nitku
					,rrd.ext_npwp_ho
			from	dbo.received_transaction_detail rtd
					inner join dbo.received_request rr on (rr.code = rtd.received_request_code)
					inner join dbo.received_request_detail rrd on (rrd.received_request_code = rr.code)
			where	rtd.received_transaction_code = @p_code

			open cur_received_transaction_detail
		
			fetch next from cur_received_transaction_detail 
			into	@received_request_code
					,@remarks
					,@exch_rate
					,@orig_amount
					,@base_amount
					,@division_code
					,@division_name
					,@department_code
					,@department_name
					,@orig_currency_code
					,@agreement_no
					,@gl_link_code
					,@ext_pph_type			
					,@ext_vendor_code		
					,@ext_vendor_name		
					,@ext_vendor_npwp		
					,@ext_vendor_address	
					,@ext_vendor_type		
					,@ext_income_type		
					,@ext_income_bruto_amount
					,@ext_tax_rate_pct		
					,@ext_pph_amount		
					,@ext_description		
					,@ext_tax_number		
					,@ext_sale_type
					,@ext_tax_date
					,@branch_code_detail
					,@branch_name_detail
					,@ext_nitku	
					,@ext_npwp_ho


			while @@fetch_status = 0
			begin

				if (@index = 0)
				begin
					set @index = 1
					set @reff_source_name = 'Received Transaction ' + @received_remarks
					exec dbo.xsp_fin_interface_journal_gl_link_transaction_insert @p_id							= 0
																				  ,@p_code						= @gl_link_transaction_code output
																				  ,@p_branch_code				= @branch_code 
																				  ,@p_branch_name				= @branch_name
																				  ,@p_transaction_status		= N'NEW' 
																				  ,@p_transaction_date			= @received_transaction_date
																				  ,@p_transaction_value_date	= @received_value_date
																				  ,@p_transaction_code			= @p_code
																				  ,@p_transaction_name			= N'Received Transaction'
																				  ,@p_reff_module_code			= N'IFINFIN'
																				  ,@p_reff_source_no			= @p_code
																				  ,@p_reff_source_name			= @reff_source_name
																				  ,@p_is_journal_reversal		= '0'
																				  ,@p_reversal_reff_no			= null
																				  ,@p_cre_date					= @p_cre_date		
																				  ,@p_cre_by					= @p_cre_by			
																				  ,@p_cre_ip_address			= @p_cre_ip_address
																				  ,@p_mod_date					= @p_mod_date		
																				  ,@p_mod_by					= @p_mod_by			
																				  ,@p_mod_ip_address			= @p_mod_ip_address


					select	@received_base_amount	= sum(rtd.base_amount) 
					from	dbo.received_transaction_detail rtd
							inner join dbo.received_request rr on (rr.code = rtd.received_request_code)
					where	rtd.received_transaction_code = @p_code
							--and pr.payment_source in ('RELEASE SUSPEND','RELEASE DEPOSIT')
					
				
					exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																						 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						 ,@p_branch_code				= @branch_code
																						 ,@p_branch_name				= @branch_name
																						 ,@p_gl_link_code				= @branch_gl_link_code
																						 ,@p_contra_gl_link_code		= null
																						 ,@p_agreement_no				= null
																						 ,@p_orig_currency_code			= @received_orig_currency_code
																						 ,@p_orig_amount_db				= @received_orig_amount
																						 ,@p_orig_amount_cr				= 0
																						 ,@p_exch_rate					= @received_exch_rate
																						 ,@p_base_amount_db				= @received_base_amount
																						 ,@p_base_amount_cr				= 0
																						 ,@p_remarks					= @received_remarks
																						 ,@p_division_code				= null
																						 ,@p_division_name				= null
																						 ,@p_department_code			= null
																						 ,@p_department_name			= null
																						 ,@p_ext_pph_type				= @ext_pph_type
																						 ,@p_ext_vendor_code			= @ext_vendor_code
																						 ,@p_ext_vendor_name			= @ext_vendor_name
																						 ,@p_ext_vendor_npwp			= @ext_vendor_npwp
																						 ,@p_ext_vendor_address			= @ext_vendor_address
																						 ,@p_ext_vendor_type			= @ext_vendor_type
																						 ,@p_ext_income_type			= @ext_income_type
																						 ,@p_ext_income_bruto_amount	= @ext_income_bruto_amount
																						 ,@p_ext_tax_rate_pct			= @ext_tax_rate_pct
																						 ,@p_ext_pph_amount				= @ext_pph_amount
																						 ,@p_ext_description			= @ext_description
																						 ,@p_ext_tax_number				= @ext_tax_number
																						 ,@p_ext_sale_type				= @ext_sale_type
																						 ,@p_ext_tax_date				= @ext_tax_date
																						 --(+)CR NITKU Raffy
																						 ,@p_ext_nitku					= @ext_nitku
																						 ,@p_ext_npwp_ho				= @ext_npwp_ho
																						 ,@p_cre_date					= @p_cre_date		
																						 ,@p_cre_by						= @p_cre_by			
																						 ,@p_cre_ip_address				= @p_cre_ip_address
																						 ,@p_mod_date					= @p_mod_date		
																						 ,@p_mod_by						= @p_mod_by			
																						 ,@p_mod_ip_address				= @p_mod_ip_address
				end

				--- jika nilai positif masuk debit dan negatif ke credit
					if (@orig_amount < 0) --
					begin
						set @orig_amount_db = 0;
						set @base_amount_db =  0;
						set @orig_amount_cr = abs(@orig_amount);
						set @base_amount_cr = abs(@base_amount);
					end											
					else										
					begin										
						set @orig_amount_db = abs(@orig_amount);
						set @base_amount_db = abs(@base_amount);
						set @orig_amount_cr = 0;
						set @base_amount_cr = 0;
					end

					exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
																						 ,@p_gl_link_transaction_code	= @gl_link_transaction_code
																						 ,@p_branch_code				= @branch_code_detail
																						 ,@p_branch_name				= @branch_name_detail
																						 ,@p_gl_link_code				= @gl_link_code
																						 ,@p_contra_gl_link_code		= null
																						 ,@p_agreement_no				= @agreement_no
																						 ,@p_orig_currency_code			= @orig_currency_code
																						 ,@p_orig_amount_db				= @orig_amount_db
																						 ,@p_orig_amount_cr				= @orig_amount_cr
																						 ,@p_exch_rate					= @exch_rate
																						 ,@p_base_amount_db				= @base_amount_db
																						 ,@p_base_amount_cr				= @base_amount_cr
																						 ,@p_remarks					= @remarks
																						 ,@p_division_code				= @division_code
																						 ,@p_division_name				= @division_name
																						 ,@p_department_code			= @department_code
																						 ,@p_department_name			= @department_name
																						 ,@p_ext_pph_type				= @ext_pph_type
																						 ,@p_ext_vendor_code			= @ext_vendor_code
																						 ,@p_ext_vendor_name			= @ext_vendor_name
																						 ,@p_ext_vendor_npwp			= @ext_vendor_npwp
																						 ,@p_ext_vendor_address			= @ext_vendor_address
																						 ,@p_ext_vendor_type			= @ext_vendor_type
																						 ,@p_ext_income_type			= @ext_income_type
																						 ,@p_ext_income_bruto_amount	= @ext_income_bruto_amount
																						 ,@p_ext_tax_rate_pct			= @ext_tax_rate_pct
																						 ,@p_ext_pph_amount				= @ext_pph_amount
																						 ,@p_ext_description			= @ext_description
																						 ,@p_ext_tax_number				= @ext_tax_number
																						 ,@p_ext_sale_type				= @ext_sale_type
																						 ,@p_ext_tax_date				= @ext_tax_date
																						 --(+)CR NITKU Raffy
																						 ,@p_ext_nitku					= @ext_nitku
																						 ,@p_ext_npwp_ho				= @ext_npwp_ho
																						 ,@p_cre_date					= @p_cre_date		
																						 ,@p_cre_by						= @p_cre_by			
																						 ,@p_cre_ip_address				= @p_cre_ip_address
																						 ,@p_mod_date					= @p_mod_date		
																						 ,@p_mod_by						= @p_mod_by			
																						 ,@p_mod_ip_address				= @p_mod_ip_address

			
					--jika data dari insurance type claim n terminate
					if exists (select 1 from dbo.received_request where received_source in ('CLAIM','TERMINATE') and code = @p_code)
					begin
					
						exec dbo.xsp_fin_interface_agreement_deposit_history_insert @p_id						= 0
																					,@p_branch_code				= @branch_code   
																					,@p_branch_name				= @branch_name   
																					,@p_agreement_no			= @agreement_no  
																					,@p_agreement_deposit_code	= NULL
																					,@p_deposit_type			= 'INSURANCE' 
																					,@p_transaction_date		= @p_cre_date
																					,@p_orig_amount				= @orig_amount  
																					,@p_orig_currency_code		= @orig_currency_code 
																					,@p_exch_rate				= @exch_rate     
																					,@p_base_amount				= @base_amount   
																					,@p_source_reff_module		= 'IFINFIN'
																					,@p_source_reff_code		= @p_code
																					,@p_source_reff_name		= 'RECEIVED'
																					,@p_cre_date				= @p_cre_date		
																					,@p_cre_by					= @p_cre_by			
																					,@p_cre_ip_address			= @p_cre_ip_address
																					,@p_mod_date				= @p_mod_date		
																					,@p_mod_by					= @p_mod_by			
																					,@p_mod_ip_address			= @p_mod_ip_address     
																					
						--SELECT * FROM dbo.FIN_INTERFACE_AGREEMENT_DEPOSIT_HISTORY ORDER BY CRE_DATE DESC              
					end
                    
			if exists (select 1 from dbo.received_request where code = @received_request_code and received_status <> 'PAID')
			begin
				update	dbo.received_request
				set		received_status		= 'PAID'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @received_request_code

				update	dbo.fin_interface_received_request
				set		received_status			= 'PAID'
						,process_date			= @received_value_date
						,process_reff_no		= @p_code
						,process_reff_name		= 'RECEIVED CONFIRM'
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @received_request_code
			end

			fetch next from cur_received_transaction_detail 
			into	@received_request_code
					,@remarks
					,@exch_rate
					,@orig_amount
					,@base_amount
					,@division_code
					,@division_name
					,@department_code
					,@department_name
					,@orig_currency_code
					,@agreement_no
					,@gl_link_code
					,@ext_pph_type			
					,@ext_vendor_code		
					,@ext_vendor_name		
					,@ext_vendor_npwp		
					,@ext_vendor_address	
					,@ext_vendor_type		
					,@ext_income_type		
					,@ext_income_bruto_amount
					,@ext_tax_rate_pct		
					,@ext_pph_amount		
					,@ext_description		
					,@ext_tax_number		
					,@ext_sale_type
					,@ext_tax_date
					,@branch_code_detail
					,@branch_name_detail
					,@ext_nitku	
					,@ext_npwp_ho
			
			end
			close cur_received_transaction_detail
			deallocate cur_received_transaction_detail

		 --EXEC INSERT BANK_MUTATION_HISTORY ( DI SP INI MENG INSERT HISTORY DAN MENAMBAG/MENGURANGI BALANCE BANK MUTATION)
			select	*
				from	dbo.fin_interface_journal_gl_link_transaction_detail
				where	gl_link_transaction_code = @gl_link_transaction_code

			if	(isnull(@gl_link_transaction_code,'') <> '')
			begin
				select	@base_amount_cr = sum(base_amount_cr) 
						,@base_amount_db = sum(base_amount_db) 
				from	dbo.fin_interface_journal_gl_link_transaction_detail
				where	gl_link_transaction_code = @gl_link_transaction_code
	
				--+ validasi : total detail =  payment_amount yang di header

				if (@base_amount_db <> @base_amount_cr)
				begin
					set @msg = 'Journal does not balance';
    				raiserror(@msg, 16, -1) ;
				end

				update dbo.fin_interface_journal_gl_link_transaction
				set		transaction_status	= 'HOLD'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @gl_link_transaction_code
			end

			update	dbo.received_transaction
			set		received_status		= 'PAID'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
		end
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_received_transaction_paid] TO [ims-raffyanda]
    AS [dbo];


--created by, Rian at /06/2023 

CREATE PROCEDURE dbo.xsp_payment_request_proceed
(
	@p_code							nvarchar(50)
	,@p_rate						decimal(18, 6)
	,@p_branch_bank_code			nvarchar(50) = ''
	,@p_branch_bank_name			nvarchar(250) = ''
	,@p_branch_bank_account_no		nvarchar(250) = ''
	,@p_payment_orig_currency_code	nvarchar(3) = ''
	,@p_bank_gl_link_code			nvarchar(50) = ''
	--,@p_cre_date				datetime
	--,@p_approval_reff				nvarchar(250)
	--,@p_approval_remark			nvarchar(4000)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg					   nvarchar(max)
			,@payment_transaction_code nvarchar(50)
			,@tax_payer_reff_code	   nvarchar(50)
			,@system_date			   datetime		  = dbo.xfn_get_system_date()
			,@branch_code			   nvarchar(50)
			,@branch_name			   nvarchar(250)
			,@payment_amount		   decimal(18, 2)
			,@base_amount			   decimal(18, 2)
			,@to_bank_name			   nvarchar(250)
			,@to_bank_account_no	   nvarchar(50)
			,@to_bank_account_name	   nvarchar(250)
			,@payment_remarks		   nvarchar(4000)
			,@payment_currency_code	   nvarchar(3)
			,@tax_file_no			   nvarchar(50)
			,@tax_type				   nvarchar(10)
			,@id_request			   bigint
			,@output_amount			   decimal(18, 2) = 0
			,@output_percent		   decimal(9, 6)  = 0
			,@orig_amount_detail	   decimal(18, 2) = 0
			,@code					   nvarchar(50)
			,@default_bank			   nvarchar(50)
			-- (+) Ari 2023-11-03
			,@get_time				   time
			,@start_transaction		   time
			,@end_transaction	       TIME
            ,@bank_code				nvarchar(50)

	begin try

		--select	@default_bank = value
		--from	dbo.sys_global_param
		--where	code = 'BANK' ;

		if (isnull(@p_branch_bank_code, '') = '')
		begin
			set	@msg = 'Please Select Bank First.'
			raiserror (@msg, 16, -1)
		end

		-- (+) Ari 2023-11-03
		set @get_time = cast(getdate() as time)
		set @start_transaction = cast('23:59:59' as time)

		select	@end_transaction = value + ':00:00'
		from	dbo.sys_global_param
		where	code = 'MTPS'

		----sepria 22092025: tutup sementara lagi sit
		---- (+) Ari 2023-11-03 ket : validasi jika batas pembayaran host to host sudah melebihi
		--if(@get_time between @end_transaction and @start_transaction and @p_bank_gl_link_code = 'MUFG168')
		--begin
		--	set @msg = 'Cannot Proceed Payment because Payment Host to Host Closed at ' + cast(@end_transaction as nvarchar(8)) + ' WIB'
		--	raiserror(@msg, 16, -1)
		--end

		-- (+) Ari 2023-11-03 ket : validasi jika limit sudah max
		if exists
		(
			select	1
			from	dbo.bank_mutation_history 
			outer	apply (
							select	cast(replace(replace(value,'.',''),',','') as decimal(18,2)) 'value'
							from	dbo.sys_global_param 
							where	code = 'MBTD'
							) limit
			outer	apply (
							select	isnull(sum(payment_amount),0) 'amount'
							from	payment_request 
							where	mod_date > cast(dbo.xfn_get_system_date() as datetime)
							and		payment_status in ('ON PROCESS')
						  ) onpay
			where	source_reff_name = 'Payment Confirm'
			and		transaction_date = dbo.xfn_get_system_date()
			and		bank_mutation_code in (select code from dbo.bank_mutation where branch_bank_name = 'MUFG' and gl_link_code = 'MUFG168')
			group	by	limit.value
						,onpay.amount
			having	((limit.value + isnull(sum(orig_amount),0)) - onpay.amount) <= 0
		)
		begin
			set @msg = 'Cannot Continue Payment because Payment has reached the Limit'
			raiserror(@msg, 16, -1)
		end

		select	@bank_code = sbb.master_bank_code
		from	ifinsys.dbo.sys_branch_bank sbb
		where	sbb.code = @p_branch_bank_code

		select @to_bank_name = to_bank_name from dbo.payment_request
		where code = @p_code

		-- imont:2505000165 sepria 02062025
		if(@bank_code = '042' AND @to_bank_name LIKE '%MUFG%')
		begin
		    set @msg = 'Cannot Payment Form MUFG to MUFG'
			raiserror(@msg, 16, -1)
		end
		
		-- (+) Ari 2023-11-03
		if exists
		(
			select	1
			from	dbo.payment_request
			where	code			   = @p_code
					and payment_status <> 'HOLD'
		)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed() ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.payment_request
			where	code									 = @p_code
					and isnull(payment_transaction_code, '') <> ''
		)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed() ;

			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin
			select	@payment_currency_code		= payment_currency_code
					,@payment_amount			= payment_amount
					,@branch_code				= branch_code
					,@branch_name				= branch_name
					,@to_bank_name				= to_bank_name
					,@to_bank_account_name		= to_bank_account_name
					,@to_bank_account_no		= to_bank_account_no
					,@payment_remarks			= payment_remarks
					,@tax_file_no				= tax_file_no
					,@tax_type					= tax_type
					,@tax_payer_reff_code		= tax_payer_reff_code --nomor entity
			from	dbo.payment_request 
			where   code						= @p_code


			if not exists	(
								select	1 
								from	dbo.payment_transaction 
								where	payment_status = 'HOLD' 
										and payment_orig_currency_code = @payment_currency_code 
										and branch_code				   = @branch_code
										and to_bank_name			   = @to_bank_name
										and to_bank_account_no		   = @to_bank_account_no
										and to_bank_account_name	   = @to_bank_account_name
							)
			begin
					exec dbo.xsp_payment_transaction_insert @p_code							= @payment_transaction_code output 
															,@p_branch_code					= @branch_code
															,@p_branch_name					= @branch_name
															,@p_payment_status				= N'HOLD' 
															,@p_payment_transaction_date	= @system_date
															,@p_payment_value_date			= @system_date
															,@p_payment_orig_amount			= 0
															,@p_payment_orig_currency_code	= @p_payment_orig_currency_code
															,@p_payment_exch_rate			= @p_rate
															,@p_payment_base_amount			= 0
															,@p_payment_type				= N'TRANSFER'
															,@p_payment_remarks				= @payment_remarks
															,@p_branch_bank_code			= @p_branch_bank_code
															,@p_branch_bank_name			= @p_branch_bank_name
															,@p_branch_bank_account_no		= @p_branch_bank_account_no
															,@p_bank_gl_link_code			= @p_bank_gl_link_code
															,@p_pdc_code					= null
															,@p_pdc_no						= null
															,@p_to_bank_name				= @to_bank_name			
															,@p_to_bank_account_name		= @to_bank_account_name
															,@p_to_bank_account_no			= @to_bank_account_no	
															,@p_is_reconcile				= N'F'
															,@p_reconcile_date				= null
															,@p_reversal_code				= null
															,@p_reversal_date				= null
															,@p_cre_date					= @p_cre_date		
															,@p_cre_by						= @p_cre_by			
															,@p_cre_ip_address				= @p_cre_ip_address
															,@p_mod_date					= @p_mod_date		
															,@p_mod_by						= @p_mod_by			
															,@p_mod_ip_address				= @p_mod_ip_address
					
			end
			else
			begin
			    select	@payment_transaction_code	= code 
				from	dbo.payment_transaction 
				where	payment_status = 'HOLD' 
						and payment_orig_currency_code = @payment_currency_code
						and branch_code				   = @branch_code
						and to_bank_name			   = @to_bank_name
						and to_bank_account_no		   = @to_bank_account_no
						and to_bank_account_name	   = @to_bank_account_name
			end

			set @output_amount = 0 ;
			--untuk mendapatkan detail payment_request yg dikenakan pajak
			declare	c_tax_amount cursor fast_forward for
			select	id
					,isnull(sum(orig_amount),0)
			from	dbo.payment_request_detail 
			where	payment_request_code = @p_code
			and     is_taxable	= '1'
			group by orig_amount,id

	
			open	c_tax_amount
			fetch	c_tax_amount
			into	@id_request
					,@orig_amount_detail
		
			while	@@fetch_status = 0
			begin
				set @base_amount = @orig_amount_detail * @p_rate
				set @output_amount = 0

				if @base_amount > 0 
				begin 
					exec dbo.xsp_tax_history_calculate @p_trx_reff_no	  = @p_code
													   ,@p_trx_amount	  = @base_amount
													   ,@p_trx_date		  = @p_cre_date
													   ,@p_reff_no		  = @tax_payer_reff_code --nomor entity
													   ,@p_tax_type		  = @tax_type
													   ,@p_tax_file_no    = @tax_file_no
													   ,@p_cre_by		  = @p_cre_by
													   ,@p_cre_date		  = @p_cre_date
													   ,@p_cre_ip_address = @p_cre_ip_address
													   ,@p_output_amount  = @output_amount output
													   ,@p_output_percent = @output_percent output 

				end
			
				update dbo.payment_request_detail
				set    tax_amount	= @output_amount
					   ,tax_pct		= @output_percent
				where  id = @id_request
				and    is_taxable = '1'
			
				fetch	c_tax_amount
				into	@id_request
						,@orig_amount_detail

			end
			close		c_tax_amount
			deallocate	c_tax_amount

			 select	@output_amount = isnull(sum(tax_amount),0)
			 from	dbo.payment_request_detail
			 where	payment_request_code = @p_code

			exec dbo.xsp_payment_transaction_detail_insert @p_id						= 0
														   ,@p_payment_transaction_code = @payment_transaction_code
														   ,@p_payment_request_code		= @p_code
														   ,@p_orig_curr_code			= @payment_currency_code
														   ,@p_orig_amount				= @payment_amount
														   ,@p_exch_rate				= @p_rate
														   ,@p_base_amount				= @base_amount
														   ,@p_tax_amount				= @output_amount
														   ,@p_cre_date					= @p_cre_date		
														   ,@p_cre_by					= @p_cre_by			
														   ,@p_cre_ip_address			= @p_cre_ip_address
														   ,@p_mod_date					= @p_mod_date		
														   ,@p_mod_by					= @p_mod_by			
														   ,@p_mod_ip_address			= @p_mod_ip_address

			if ((
					select	count(1)
					from	dbo.payment_transaction_detail
					where	payment_transaction_code = @payment_transaction_code
				) > 1
				)
			begin
				select	@payment_remarks = stuff((
														select distinct
															',' + payment_source
														from	payment_request
														where	code in
				(
					select	payment_request_code
					from	dbo.payment_transaction_detail
					where	payment_transaction_code = @payment_transaction_code
				)
														for xml path('')
													), 1, 1, ''
												) ;
			end ;

			update	dbo.payment_transaction
			set		payment_remarks = @payment_remarks
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @payment_transaction_code ;

			update	dbo.payment_request
			set		payment_status				= 'ON PROCESS'
					,payment_transaction_code	= @payment_transaction_code
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code
			
			--if @default_bank = @p_branch_bank_name
			--begin
			--	exec dbo.xsp_payment_transaction_automatic_proceed @p_cre_date = @p_cre_date -- datetime
			--													   ,@p_cre_by = @p_cre_by -- nvarchar(50)
			--													   ,@p_cre_ip_address = @p_cre_ip_address -- nvarchar(50)
			--end ;
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


/*
	created : arif / 12 des 2022
*/

CREATE PROCEDURE dbo.xsp_vat_payment_proceed
(
	@p_invoice_no			   nvarchar(50)
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(50)
			,@status					nvarchar(10)
			,@remark					nvarchar(4000)
			,@total_pph_amount			int
			,@vat_code					nvarchar(50)
			,@date						datetime
			,@invoice_no				nvarchar(50)
			,@total_ppn_amount			int
			,@year						nvarchar(4)
			,@month						nvarchar(2)
			,@code						nvarchar(50)
			,@total						decimal(18,2)
			,@credit_ppn_amount			int
			,@hasil						decimal(18,2)
			,@currency_code				nvarchar(3)
			,@tax_bank_name				nvarchar(50)
			,@tax_bank_account_name		nvarchar(50)
			,@tax_bank_account_no		nvarchar(50)
			,@faktur_no					nvarchar(50);

	begin try
		set @date = dbo.xfn_get_system_date();

		--select data tax bank dan branch dari global param
		select	@tax_bank_name = value
		from	dbo.sys_global_param
		where	code = 'TAXBANK' ;

		select	@tax_bank_account_name = value
		from	dbo.sys_global_param
		where	code = 'TAXTBANKNAME' ;

		select	@tax_bank_account_no = value
		from	dbo.sys_global_param
		where	code = 'TAXBANKNO' ;

		select	@branch_code	= value
				,@branch_name	= description
		from	dbo.sys_global_param
		where	code = 'HO'


		-- data tidak bisa di proceed jika tidak ada faktur no
		select	@faktur_no	= faktur_no
		from	dbo.invoice  
	 	where invoice_no = @p_invoice_no

		if (isnull(@faktur_no, '') = '')
		begin
			set @msg = 'Please allocate Faktur No before proceed'
			raiserror(@msg, 16, -1) ;
		end

		--select data dari tabel invoice
		select @total_ppn_amount		= total_ppn_amount
			  ,@total_pph_amount		= total_pph_amount
			  ,@credit_ppn_amount		= credit_ppn_amount
			  ,@currency_code			= currency_code
		from dbo.invoice 
		where invoice_no = @p_invoice_no

		set @hasil = @total_ppn_amount - @credit_ppn_amount
		if exists
		(
			select	1
			from	invoice_vat_payment
			where	status	 = 'HOLD'
			and		currency_code = @currency_code
		)
		begin
			select	@vat_code = code
			from	invoice_vat_payment
			where	status = 'HOLD'
			and		currency_code = @currency_code

			exec dbo.xsp_invoice_vat_payment_detail_insert @p_id				 = 0
															,@p_tax_payment_code = @vat_code
															,@p_invoice_no		 = @p_invoice_no
															,@p_ppn_amount		 = @hasil
															--
															,@p_cre_date		 = @p_cre_date
															,@p_cre_by			 = @p_cre_by
															,@p_cre_ip_address	 = @p_cre_ip_address
															,@p_mod_date		 = @p_mod_date
															,@p_mod_by			 = @p_mod_by
															,@p_mod_ip_address	 = @p_mod_ip_address ;
			update	dbo.invoice
			set		payment_ppn_code	= @vat_code
					,payment_ppn_date	= @date
					--
					,cre_date			= @p_cre_date
					,cre_by				= @p_cre_by
					,cre_ip_address		= @p_cre_ip_address
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	invoice_no			= @p_invoice_no ;

			select @total = sum(ppn_amount)
			from dbo.invoice_vat_payment_detail
			where tax_payment_code = @vat_code

			update	dbo.invoice_vat_payment
			set		total_ppn_amount = @total
			where	code = @vat_code
		end ;
		else
		begin
			set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
			set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

			exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
														,@p_branch_code			= @branch_code
														,@p_sys_document_code	= N''
														,@p_custom_prefix		= N'IVT'
														,@p_year				= @year 
														,@p_month				= @month 
														,@p_table_name			= N'INVOICE_VAT_PAYMENT' 
														,@p_run_number_length	= 6 
														,@p_delimiter			= '.'
														,@p_run_number_only		= N'0'

			exec dbo.xsp_invoice_vat_payment_insert @p_code						= @code
													,@p_branch_code				= @branch_code
													,@p_branch_name				= @branch_name
													,@p_status					= 'HOLD'
													,@p_date					= @date
													,@p_remark					= ''
													,@p_total_ppn_amount		= @hasil
													,@p_currency_code			= @currency_code
													,@p_tax_bank_name			= @tax_bank_name
													,@p_tax_bank_account_name	= @tax_bank_account_name
													,@p_tax_bank_account_no		= @tax_bank_account_no
													--
													,@p_cre_by					= @p_cre_by
													,@p_cre_date				= @p_cre_date
													,@p_cre_ip_address			= @p_cre_ip_address
													,@p_mod_date				= @p_mod_date
													,@p_mod_by					= @p_mod_by
													,@p_mod_ip_address			= @p_mod_ip_address

			exec dbo.xsp_invoice_vat_payment_detail_insert @p_id				 = 0
															,@p_tax_payment_code = @code
															,@p_invoice_no		 = @p_invoice_no
															,@p_ppn_amount		 = @hasil
															--
															,@p_cre_date		 = @p_cre_date
															,@p_cre_by			 = @p_cre_by
															,@p_cre_ip_address	 = @p_cre_ip_address
															,@p_mod_date		 = @p_mod_date
															,@p_mod_by			 = @p_mod_by
															,@p_mod_ip_address	 = @p_mod_ip_address ;

			update	dbo.invoice
			set		payment_ppn_code	= @code
					,payment_ppn_date	= @date
					--
					,cre_date			= @p_cre_date
					,cre_by				= @p_cre_by
					,cre_ip_address		= @p_cre_ip_address
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	invoice_no			= @p_invoice_no ;

			select @total = sum(ppn_amount)
			from dbo.invoice_vat_payment_detail
			where tax_payment_code = @vat_code

			update	dbo.invoice_vat_payment
			set		total_ppn_amount = @total
			where	code = @vat_code
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

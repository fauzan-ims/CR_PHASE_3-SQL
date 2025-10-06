

CREATE PROCEDURE dbo.xsp_invoice_insert
(
	@p_invoice_no							nvarchar(50)	output
	,@p_branch_code							nvarchar(50)
	,@p_branch_name							nvarchar(250)
	,@p_invoice_type						nvarchar(10)
	,@p_invoice_date						datetime
	,@p_invoice_due_date					datetime
	,@p_invoice_name						nvarchar(250)
	,@p_invoice_status						nvarchar(10)
	,@p_client_no							nvarchar(50)
	,@p_client_name							nvarchar(250)
	,@p_client_address						nvarchar(4000)
	,@p_client_area_phone_no				nvarchar(4)
	,@p_client_phone_no						nvarchar(15)
	,@p_client_npwp							nvarchar(50)
	,@p_currency_code						nvarchar(3)
	,@p_total_billing_amount				decimal(18, 2)
	,@p_total_discount_amount				decimal(18, 2)
	,@p_total_ppn_amount					decimal(18, 2)--(+) sepria 06032025: cr dpp ppn 12% coretax
	,@p_total_pph_amount					decimal(18, 2)--(+) sepria 06032025: cr dpp ppn 12% coretax
	,@p_total_amount						decimal(18, 2)
	,@p_faktur_no							nvarchar(50)
	,@p_generate_code						nvarchar(50)
	,@p_scheme_code							nvarchar(50)
	,@p_received_reff_no					nvarchar(50)
	,@p_received_reff_date					nvarchar(50)
	,@p_additional_invoice_code				nvarchar(50)	= null
	,@p_billing_to_faktur_type				nvarchar(3)
	,@p_is_invoice_deduct_pph				nvarchar(1)
	,@p_is_receipt_deduct_pph				nvarchar(1)
	,@p_billing_date						datetime -- Louis Senin, 05 Februari 2024 09.53.22 -- digunakan untuk generate invoice no
	--(+) Raffy 2025/02/01 CR NITKU
	,@p_client_nitku						NVARCHAR(50) = ''
	--
	,@p_cre_date							datetime
	,@p_cre_by								nvarchar(15)
	,@p_cre_ip_address						nvarchar(15)
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare		@invoice_no				nvarchar(50)
				,@invoice_externa_no	nvarchar(50)
				,@invoice_kwitansi_no	NVARCHAR(50)
				,@year					nvarchar(4)
				,@years					nvarchar(4)
				,@month					nvarchar(2)
				,@msg					nvarchar(max) ;

	begin try
		--set @year = substring(cast(datepart(year, @p_invoice_date) as nvarchar), 3, 2) ;
		--set @years = (cast(datepart(year, @p_invoice_date) as nvarchar)) ;
		--set @month = replace(str(cast(datepart(month, @p_invoice_date) as nvarchar), 2, 0), ' ', '0') ;

		-- Louis Selasa, 06 Februari 2024 10.47.39 --untuk invoice no di generate berdasarkan billing date
		set @year = substring(cast(datepart(year, @p_billing_date) as nvarchar), 3, 2) ;
		set @years = (cast(datepart(year, @p_billing_date) as nvarchar)) ;
		set @month = replace(str(cast(datepart(month, @p_billing_date) as nvarchar), 2, 0), ' ', '0') ;

		--exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @invoice_no output
		--											,@p_branch_code			= @p_branch_code
		--											,@p_sys_document_code	= N''
		--											,@p_custom_prefix		= N'INV'
		--											,@p_year				= @year 
		--											,@p_month				= @month 
		--											,@p_table_name			= N'INVOICE' 
		--											,@p_run_number_length	= 6 
		--											,@p_delimiter			= '.'
		--											,@p_run_number_only		= N'0'
		
		exec dbo.xsp_generate_auto_number	@p_unique_code					= @invoice_no output
											,@p_branch_code					= @p_branch_code
											,@p_year						= @years
											,@p_month						= @month
											,@p_opl_code					= N'INV'
											,@p_run_number_length			= 5 
											,@p_delimiter					= N'.' 
											,@p_tabel_name					= N'INVOICE' 
											,@p_column_name					= N'INVOICE_NO' 

		set	@invoice_externa_no = replace(@invoice_no, '.', '/')


		exec dbo.xsp_generate_auto_number	@p_unique_code					= @invoice_kwitansi_no output
											,@p_branch_code					= @p_branch_code
											,@p_year						= @years
											,@p_month						= @month
											,@p_opl_code					= N'KWT'
											,@p_run_number_length			= 5 
											,@p_delimiter					= N'/' 
											,@p_tabel_name					= N'INVOICE' 
											,@p_column_name					= N'KWITANSI_NO' 

		--EXEC dbo.xsp_generate_auto_number_kwitansi @p_unique_code			= @invoice_kwitansi_no OUTPUT, -- nvarchar(50)
		--                                           @p_branch_code			= @p_branch_code,                   -- nvarchar(10)
		--                                           @p_year					= @years,                          -- nvarchar(4)
		--                                           @p_month					= @month,                         -- nvarchar(2)
		--                                           @p_opl_code				= N'KWT',                      -- nvarchar(250)
		--										   @p_jkn					= N'JKN',
		--                                           @p_run_number_length		= 5,               -- int
		--                                           @p_delimiter				= N'/',                     -- nvarchar(1)
		--                                           @p_table_name			= N'INVOICE',                    -- nvarchar(250)
		--                                           @p_column_name			= N'KWITANSI_NO'                    -- nvarchar(250)
		
		insert into dbo.invoice
		(
			invoice_no
			,invoice_external_no
			,branch_code
			,branch_name
			,invoice_type
			,invoice_date
			,invoice_due_date
			,invoice_name
			,client_no
			,client_name
			,client_address
			,client_area_phone_no
			,client_phone_no
			,client_npwp
			,currency_code
			,total_billing_amount
			,total_discount_amount
			,total_ppn_amount
			,total_pph_amount
			,total_amount
			,faktur_no
			,generate_code
			,scheme_code
			,received_reff_no
			,received_reff_date
			,invoice_status
			,additional_invoice_code
			,kwitansi_no
			,new_invoice_date -- Hari - 15.jul.2023 03:24 pm --	
			,billing_to_faktur_type
			,is_invoice_deduct_pph
			,is_receipt_deduct_pph
			--(+) Raffy 2025/02/01 CR NITKU
			,client_nitku
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@invoice_no
			,@invoice_externa_no
			,@p_branch_code
			,@p_branch_name
			,@p_invoice_type
			,@p_invoice_date
			,@p_invoice_due_date
			,@p_invoice_name
			,@p_client_no
			,@p_client_name
			,@p_client_address
			,@p_client_area_phone_no
			,@p_client_phone_no
			,@p_client_npwp
			,@p_currency_code
			,@p_total_billing_amount
			,@p_total_discount_amount
			,@p_total_ppn_amount
			,@p_total_pph_amount
			,@p_total_amount
			,@p_faktur_no
			,@p_generate_code
			,@p_scheme_code
			,@p_received_reff_no
			,@p_received_reff_date
			,@p_invoice_status
			,@p_additional_invoice_code
			,@invoice_kwitansi_no
			,@p_billing_date--@p_invoice_date -- Louis Selasa, 06 Februari 2024 10.47.07 -- new invoice date diambil dari billing date
			,@p_billing_to_faktur_type
			,@p_is_invoice_deduct_pph
			,@p_is_receipt_deduct_pph
			,@p_client_nitku
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		set @p_invoice_no = @invoice_no
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


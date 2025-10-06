

CREATE PROCEDURE dbo.xsp_quotation_review_vendor_update
(
	@p_id									bigint
	,@p_supplier_code						nvarchar(50)
	,@p_supplier_name						nvarchar(250)
	,@p_supplier_address					nvarchar(4000)
	,@p_supplier_npwp						nvarchar(50)	= ''
	,@p_tax_code							nvarchar(50)
	,@p_tax_name							nvarchar(250)
	,@p_tax_ppn_pct							decimal(9, 6)
	,@p_tax_pph_pct							decimal(9, 6)
	,@p_warranty_month						int
	,@p_warranty_part_month					int
	,@p_price_amount						decimal(18,2)
	,@p_discount_amount						decimal(18,2)
	,@p_nett_price							decimal(18,2)
	,@p_offering							nvarchar(250)	= ''
	,@p_quotation_date						datetime
	,@p_quotation_expired_date				datetime
	,@p_unit_available_status				nvarchar(50)
	,@p_indent_days							int				= 0
	--(+) Raffy 2025/02/01 CR NITKU
	,@p_supplier_nitku					nvarchar(50) = ''
	,@p_supplier_npwp_pusat				nvarchar(50) = ''
	--
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@nett_price	bigint--nvarchar(50)

	begin try
		if @p_nett_price < 0
		begin
			set @msg = 'Nett price must be greater than 0.'
			raiserror (@msg, 16, 1)
		end ;

		SET @nett_price		= @p_nett_price

		if(@p_unit_available_status = 'READY')
		begin
			set @p_indent_days = 0
		end

		update dbo.quotation_review_vendor
		set		supplier_code			= @p_supplier_code
				,supplier_name			= @p_supplier_name
				,supplier_address		= @p_supplier_address
				,supplier_npwp			= @p_supplier_npwp
				,tax_code				= @p_tax_code
				,tax_name				= @p_tax_name
				,tax_ppn_pct			= @p_tax_ppn_pct
				,tax_pph_pct			= @p_tax_pph_pct
				,warranty_month			= @p_warranty_month
				,warranty_part_month	= @p_warranty_part_month
				,price_amount			= @p_price_amount
				,discount_amount		= @p_discount_amount
				,nett_price				= @nett_price --@p_nett_price
				,offering				= @p_offering
				,total_amount			= @nett_price --@p_nett_price
				,quotation_date			= @p_quotation_date
				,quotation_expired_date	= @p_quotation_expired_date
				,unit_available_status	= @p_unit_available_status
				,indent_days			= @p_indent_days
				,supplier_nitku			= @p_supplier_nitku
				,supplier_npwp_pusat	= @p_supplier_npwp_pusat
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where id = @p_id
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

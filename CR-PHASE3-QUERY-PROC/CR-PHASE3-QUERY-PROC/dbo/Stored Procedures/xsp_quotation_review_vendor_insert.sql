CREATE PROCEDURE [dbo].[xsp_quotation_review_vendor_insert]
(
	 @p_id									bigint	= 0 output
	,@p_quotation_review_code				nvarchar(50)
	,@p_supplier_code						nvarchar(50)
	,@p_supplier_name						nvarchar(250)
	,@p_supplier_address					nvarchar(4000)
	,@p_supplier_npwp						nvarchar(50)	= ''
	,@p_tax_code							nvarchar(50)
	,@p_tax_name							nvarchar(250)
	,@p_tax_ppn_pct							decimal(9, 6)
	,@p_tax_pph_pct							decimal(9, 6)
	,@p_warranty_month						int				= 0
	,@p_warranty_part_month					int				= 0
	,@p_price_amount						decimal(18,2)
	,@p_discount_amount						decimal(18,2)
	,@p_nett_price							decimal(18,2)
	,@p_total_amount						decimal(18,2)
	,@p_offering							nvarchar(250)	= ''
	,@p_quotation_date						datetime		= ''
	,@p_quotation_expired_date				datetime		= ''
	,@p_unit_available_status				nvarchar(50)	= ''
	,@p_indent_days							int				= 0
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
	declare @msg	nvarchar(max);

	begin try


	insert into dbo.quotation_review_vendor
	(
		quotation_review_code
		,supplier_code
		,supplier_name
		,supplier_address
		,supplier_npwp
		,tax_code
		,tax_name
		,tax_ppn_pct
		,tax_pph_pct
		,warranty_month
		,warranty_part_month
		,price_amount
		,discount_amount
		,nett_price
		,total_amount
		,offering
		,quotation_date
		,quotation_expired_date
		,unit_available_status
		,indent_days
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
		@p_quotation_review_code
		,@p_supplier_code
		,@p_supplier_name
		,@p_supplier_address
		,@p_supplier_npwp
		,@p_tax_code
		,@p_tax_name
		,@p_tax_ppn_pct
		,@p_tax_pph_pct
		,@p_warranty_month
		,@p_warranty_part_month
		,@p_price_amount
		,@p_discount_amount
		,@p_nett_price
		,@p_nett_price--@p_total_amount
		,@p_offering
		,@p_quotation_date
		,@p_quotation_expired_date
		,@p_unit_available_status
		,@p_indent_days
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	) 
	
	set @p_id = @@IDENTITY

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


CREATE PROCEDURE dbo.xsp_invoice_detail_insert
(
	@p_id					bigint	= 0 output
	,@p_invoice_no			nvarchar(50)
	,@p_agreement_no		nvarchar(50)
	,@p_asset_no			nvarchar(50)
	,@p_billing_no			int
	,@p_description			nvarchar(4000)
	,@p_quantity			int
	,@p_billing_amount		decimal(18, 2)
	,@p_discount_amount		decimal(18, 2)
	,@p_ppn_amount			int
	,@p_pph_amount			int
	,@p_total_amount		decimal(18, 2)
	,@p_tax_scheme_code		nvarchar(50)
	,@p_tax_scheme_name		nvarchar(250)
	,@p_ppn_pct				decimal(9,6)
	,@p_pph_pct				decimal(9,6)
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

	declare @msg nvarchar(max) ;

	begin try

	insert into invoice_detail
	(
		invoice_no
		,agreement_no
		,asset_no
		,billing_no
		,description
		,quantity
		,tax_scheme_code
		,tax_scheme_name
		,billing_amount
		,discount_amount
		,ppn_pct
		,ppn_amount
		,pph_pct
		,pph_amount
		,total_amount
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
		@p_invoice_no
		,@p_agreement_no
		,@p_asset_no
		,@p_billing_no
		,@p_description
		,@p_quantity
		,@p_tax_scheme_code
		,@p_tax_scheme_name
		,@p_billing_amount
		,@p_discount_amount
		,@p_ppn_pct
		,@p_ppn_amount
		,@p_pph_pct
		,@p_pph_amount
		,@p_total_amount
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	)

	set @p_id = @@identity

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

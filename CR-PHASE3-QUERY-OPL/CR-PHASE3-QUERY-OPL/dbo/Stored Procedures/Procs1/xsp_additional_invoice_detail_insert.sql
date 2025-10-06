CREATE procedure [dbo].[xsp_additional_invoice_detail_insert]
(
	@p_id								bigint		   = 0 output
	,@p_additional_invoice_code			nvarchar(50)
	,@p_agreement_no					nvarchar(50)
	,@p_asset_no						nvarchar(50)
	,@p_tax_scheme_code					nvarchar(50)   = ''
	,@p_tax_scheme_name					nvarchar(250)  = ''
	,@p_billing_no						int
	,@p_description						nvarchar(4000)
	,@p_quantity						int
	,@p_billing_amount					decimal(18,2) = 0
	,@p_discount_amount					decimal(18,2) = 0
	,@p_ppn_pct							decimal(9, 6)  = 0
	,@p_ppn_amount						decimal(18,2)			   = 0
	,@p_pph_pct							decimal(9, 6)  = 0
	,@p_pph_amount						decimal(18,2)			   = 0
	,@p_total_amount					decimal(18,2) = 0
	,@p_reff_code						nvarchar(50)   = null
	,@p_reff_name						nvarchar(250)  = null
	,@p_additional_invoice_request_code nvarchar(50)   = null
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@total_billing_amount	int = 0
			,@total_discount_amount int = 0
			,@total_ppn_amount		int = 0
			,@total_pph_amount		int = 0
			,@total_amount			int = 0 ;

	begin try

		insert into additional_invoice_detail
		(
			additional_invoice_code
			,agreement_no
			,asset_no
			,tax_scheme_code
			,tax_scheme_name
			,billing_no
			,description
			,quantity
			,billing_amount
			,discount_amount
			,ppn_pct
			,ppn_amount
			,pph_pct
			,pph_amount
			,total_amount
			,reff_code
			,reff_name
			,additional_invoice_request_code
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_additional_invoice_code
			,@p_agreement_no
			,@p_asset_no
			,@p_tax_scheme_code
			,@p_tax_scheme_name
			,@p_billing_no
			,@p_description
			,@p_quantity
			,@p_billing_amount
			,@p_discount_amount
			,@p_ppn_pct
			,@p_ppn_amount
			,@p_pph_pct
			,@p_pph_amount
			,@p_total_amount
			,@p_reff_code
			,@p_reff_name
			,@p_additional_invoice_request_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		select	@total_billing_amount	= sum(billing_amount)
				,@total_discount_amount = sum(discount_amount)
				,@total_ppn_amount		= sum(ppn_amount)
				,@total_pph_amount		= sum(pph_amount)
				,@total_amount			= sum(total_amount)
		from	additional_invoice_detail
		where	additional_invoice_code = @p_additional_invoice_code ;

		update	dbo.additional_invoice
		set		total_billing_amount	= isnull(@total_billing_amount, 0)	
				,total_discount_amount  = isnull(@total_discount_amount, 0) 
				,total_ppn_amount		= isnull(@total_ppn_amount, 0)		
				,total_pph_amount		= isnull(@total_pph_amount, 0)		
				,total_amount			= isnull(@total_amount, 0)			
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_additional_invoice_code ;

		set @p_id = @@identity ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;






CREATE PROCEDURE dbo.xsp_additional_invoice_detail_update
(
	@p_id							bigint
	,@p_additional_invoice_code		nvarchar(50)
	,@p_agreement_no				nvarchar(50)
	,@p_asset_no					nvarchar(50)
	,@p_tax_scheme_code				nvarchar(50)	= ''
	,@p_tax_scheme_name				nvarchar(250)	= ''
	,@p_billing_no					int
	,@p_description					nvarchar(4000)
	,@p_quantity					int
	,@p_billing_amount				int=0
	,@p_discount_amount				int=0
	,@p_ppn_pct						decimal(9, 6)=0
	,@p_ppn_amount					int=0
	,@p_pph_pct						decimal(9, 6)=0
	,@p_pph_amount					int=0
	,@p_total_amount				decimal(18, 2)=0
		--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@is_invoice_deduct_pph nvarchar(1)
			,@total_billing_amount	int
			,@total_discount_amount int
			,@total_ppn_amount		int
			,@total_pph_amount		int
			,@total_amount			int ;

	begin try 
		select	 @is_invoice_deduct_pph = aa.is_invoice_deduct_pph
		from	dbo.additional_invoice_detail aid
				inner join dbo.agreement_asset aa on aa.asset_no = aid.asset_no
		where	aid.id = @p_id ;
	 
		update	additional_invoice_detail
		set		additional_invoice_code		= @p_additional_invoice_code
				,agreement_no				= @p_agreement_no
				,asset_no					= @p_asset_no
				,tax_scheme_code			= @p_tax_scheme_code
				,tax_scheme_name			= @p_tax_scheme_name
				,billing_no					= @p_billing_no
				,description				= @p_description
				,quantity					= @p_quantity
				,billing_amount				= @p_billing_amount
				,discount_amount			= @p_discount_amount
				,ppn_pct					= @p_ppn_pct
				,ppn_amount					= @p_ppn_amount
				,pph_pct					= @p_pph_pct
				,pph_amount					= @p_pph_amount
				,total_amount				= case @is_invoice_deduct_pph 
													when '1' then (isnull(@p_billing_amount, 0) - isnull(@p_discount_amount, 0) + isnull(@p_ppn_amount, 0) -isnull(@p_pph_amount, 0))
													else   (isnull(@p_billing_amount, 0) - isnull(@p_discount_amount, 0) + isnull(@p_ppn_amount, 0))
												end
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id	= @p_id

		select	@total_billing_amount	 = isnull(sum(billing_amount), 0)
				, @total_discount_amount = isnull(sum(discount_amount), 0)
				, @total_ppn_amount		 = isnull(sum(ppn_amount), 0)
				, @total_pph_amount		 = isnull(sum(pph_amount), 0)
				, @total_amount			 = case @is_invoice_deduct_pph 
												when '1' then (isnull(sum(billing_amount), 0) - isnull(sum(discount_amount), 0) + isnull(sum(ppn_amount), 0) -isnull(sum(pph_amount), 0))
												else   (isnull(sum(billing_amount), 0) - isnull(sum(discount_amount), 0) + isnull(sum(ppn_amount), 0) )
											end 
		from	dbo.additional_invoice_detail
		where	additional_invoice_code = @p_additional_invoice_code ;

		update	dbo.additional_invoice
		set		total_billing_amount	= @total_billing_amount
				, total_discount_amount = @total_discount_amount
				, total_ppn_amount		= @total_ppn_amount
				, total_pph_amount		= @total_pph_amount
				, total_amount			= @total_amount
		where	code					= @p_additional_invoice_code ;

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

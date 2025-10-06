
create function dbo.temp_xfn_invoice_detail_get_billing_amount
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @total_amount		 decimal(18, 2)
			,@first_payment_type nvarchar(3) ;

	select	@first_payment_type = aa.first_payment_type
	from	dbo.agreement_asset aa
			inner join dbo.invoice_detail id on (id.asset_no = aa.asset_no)
	where	id = @p_id ;

	--untuk mendapatkan PENDAPATAN SEWA DITANGUHKAN
	if (@first_payment_type = 'ADV')
	begin
		select	@total_amount = (isnull(invd.billing_amount, 0) - isnull(cnd.adjustment_amount, 0) - isnull(invd.discount_amount, 0))
		from	dbo.invoice_detail invd
				left join dbo.credit_note cn on (
													cn.invoice_no					  = invd.invoice_no
													and cn.status					  = 'POST'
												)
				left join dbo.credit_note_detail cnd on (
															cnd.credit_note_code	  = cn.code
															and cnd.invoice_detail_id = invd.id
														)
		where	invd.id = @p_id ;
	end ;
	else
	begin
		set @total_amount = 0 ;
	end ;

	return isnull(@total_amount, 0) ;
end ;

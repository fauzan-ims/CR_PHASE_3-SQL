
create function dbo.temp_xfn_invoice_detail_get_ar_wapu
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	--digunakan untuk mengambil nilai ppn invoice WAPU <> '01'
	declare @total_amount			 decimal(18, 2)
			,@billing_to_faktur_type nvarchar(3) ;

	select	@billing_to_faktur_type = aa.billing_to_faktur_type
	from	dbo.invoice aa
			inner join dbo.invoice_detail id on (id.invoice_no = aa.invoice_no)
	where	id = @p_id ;

	if (@billing_to_faktur_type <> '01')
	begin
		select	@total_amount = (isnull(invd.ppn_amount, 0) - case
																  when isnull(cnd.adjustment_amount, 0) > 0 then (isnull(invd.ppn_amount, 0) - isnull(cnd.new_ppn_amount, 0))
																  else 0
															  end
								) --ppn_amount
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

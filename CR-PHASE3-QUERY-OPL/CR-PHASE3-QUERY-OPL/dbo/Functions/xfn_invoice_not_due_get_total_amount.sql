
CREATE function dbo.xfn_invoice_not_due_get_total_amount
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @total_amount			 decimal(18, 2)
			,@billing_to_faktur_type nvarchar(3) ;

	select	@billing_to_faktur_type = aa.billing_to_faktur_type
	from	dbo.invoice aa
			inner join dbo.invoice_detail id on (id.invoice_no = aa.invoice_no)
	where	id = @p_id ;

	if (@billing_to_faktur_type = '01')
	begin
		select	@total_amount = (isnull(invd.billing_amount, 0) - isnull(cnd.adjustment_amount, 0) - isnull(invd.discount_amount, 0)) + (isnull(invd.ppn_amount, 0) - case
																																										  when isnull(cnd.adjustment_amount, 0) > 0 then (isnull(invd.ppn_amount, 0) - isnull(cnd.new_ppn_amount, 0))
																																										  else 0
																																									  end
																																		) --+ isnull(ppn_amount, 0)  
		from	dbo.invoice_detail invd
				inner join dbo.invoice inv on (
												  inv.invoice_no					  = invd.invoice_no
												  and  inv.is_journal				  = '0'
											  )
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
		select	@total_amount = (isnull(invd.billing_amount, 0) - isnull(cnd.adjustment_amount, 0) - isnull(invd.discount_amount, 0))
		from	dbo.invoice_detail invd
				inner join dbo.invoice inv on (
												  inv.invoice_no					  = invd.invoice_no
												  and  inv.is_journal				  = '0'
											  )
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

	return isnull(@total_amount, 0) ;
end ;

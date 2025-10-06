
create function dbo.temp_xfn_invoice_detail_get_ppn
(
	@p_id bigint
)
returns int
as
begin
	declare @total_amount int ;

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

	return isnull(@total_amount, 0) ;
end ;

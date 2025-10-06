CREATE FUNCTION dbo.xfn_credit_note_detail_get_total_amount
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
		select	@total_amount = isnull(cnd.new_rental_amount, 0) + isnull(cnd.new_ppn_amount, 0)
		from	dbo.credit_note_detail cnd
				inner join dbo.credit_note cn on (cn.code = cnd.credit_note_code)
		where	invoice_detail_id		 = @p_id
				and cn.status			 = 'ON PROCESS'
				and cnd.new_total_amount > 0 ;
	end ;
	else
	begin
		select	@total_amount = isnull(cnd.new_rental_amount, 0)
		from	dbo.credit_note_detail cnd
				inner join dbo.credit_note cn on (cn.code = cnd.credit_note_code)
		where	invoice_detail_id		 = @p_id
				and cn.status			 = 'ON PROCESS'
				and cnd.new_total_amount > 0 ;
	end ;

	return isnull(@total_amount, 0) ;
end ;

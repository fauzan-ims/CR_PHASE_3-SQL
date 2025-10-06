CREATE FUNCTION dbo.xfn_credit_note_get_ar_wapu
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
--digunakan untuk mengambil nilai ppn invoice WAPU <> '01'
	declare @total_amount			 decimal(18, 2)
			,@billing_to_faktur_type nvarchar(3) 
			,@is_journal_ppn_wapu	 nvarchar(1)

	select	@billing_to_faktur_type = aa.billing_to_faktur_type
			,@is_journal_ppn_wapu = aa.is_journal_ppn_wapu
	from	dbo.invoice aa
			inner join dbo.invoice_detail id on (id.invoice_no = aa.invoice_no)
	where	id = @p_id ;

	if (@billing_to_faktur_type <> '01' and @is_journal_ppn_wapu = '0')
	begin 
		select	@total_amount = invd.ppn_amount - cnd.new_ppn_amount
		from	dbo.credit_note_detail cnd
				inner join dbo.credit_note cn on (cn.code = cnd.credit_note_code)
				inner join dbo.invoice_detail invd on (invd.id = cnd.invoice_detail_id)
		where	invoice_detail_id		 = @p_id
				and cn.status			 = 'ON PROCESS'
				--and cnd.new_total_amount > 0 ;
				and cnd.adjustment_amount > 0 ;
	end ;
	else
	begin
		set @total_amount = 0 ;
	end ;

	return isnull(@total_amount, 0) ;
end ;

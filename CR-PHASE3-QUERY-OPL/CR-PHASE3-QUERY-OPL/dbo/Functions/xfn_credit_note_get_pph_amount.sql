

CREATE FUNCTION dbo.xfn_credit_note_get_pph_amount
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @pph_amount decimal(18, 2) ;

	select	@pph_amount = case iv.settlement_type
                             when 'pkp' then
                                 cnd.new_pph_amount
                             else
                                 0
                         end
	from	dbo.credit_note_detail cnd
			inner join dbo.credit_note cn on (cn.code = cnd.credit_note_code)
		    inner join dbo.invoice_pph iv on (iv.invoice_no = cnd.invoice_no)
	where	invoice_detail_id		 = @p_id
			and cn.status			 = 'ON PROCESS'
			and cnd.new_total_amount > 0 ;

	return isnull(@pph_amount, 0) ;
end ;

/*
exec dbo.xsp_withholding_settlement_audit_getrow @p_code = N'' -- nvarchar(50)
*/
-- Louis Jumat, 02 Juni 2023 16.08.28 -- 
CREATE procedure [dbo].[xsp_withholding_settlement_audit_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @total_pph_amount decimal(18, 2) = 0
			,@year			  int ;

	select	@year = year
	from	withholding_settlement_audit
	where	code = @p_code ;

	select	@total_pph_amount = sum(invp.total_pph_amount)
	from	invoice inv
			inner join dbo.invoice_pph invp on (invp.invoice_no = inv.invoice_no)
	where	year(inv.invoice_date)				 = @year
			and isnull(invp.payment_reff_no, '') = '' ;

	select	code
			,branch_code
			,branch_name
			,date
			,year
			,remark
			,status
			,@total_pph_amount 'total_pph_amount'
	from	withholding_settlement_audit
	where	code = @p_code ;
end ;

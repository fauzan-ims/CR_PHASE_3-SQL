CREATE PROCEDURE dbo.xsp_deposit_revenue_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare	@count	int;
	
	select @count = count(1) 
	from	dbo.deposit_revenue_detail
	where	deposit_revenue_code = @p_code

	select	dr.code
			,dr.branch_code
			,dr.branch_name
			,dr.revenue_status
			,dr.revenue_date
			,dr.revenue_amount
			,dr.revenue_remarks
			,dr.agreement_no
			,dr.currency_code
			,dr.exch_rate
			,am.agreement_external_no
			,am.client_name
			,@count 'count'
	from	deposit_revenue dr
			inner join dbo.agreement_main am on (am.agreement_no = dr.agreement_no)
	where	code = @p_code ;
end ;

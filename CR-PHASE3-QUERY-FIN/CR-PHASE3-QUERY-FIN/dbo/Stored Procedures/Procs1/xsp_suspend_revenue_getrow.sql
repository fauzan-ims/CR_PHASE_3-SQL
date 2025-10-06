CREATE PROCEDURE dbo.xsp_suspend_revenue_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare	@count	int;
	
	select @count = count(1) 
	from	dbo.suspend_revenue_detail
	where	suspend_revenue_code = @p_code

	select	code
			,branch_code
			,branch_name
			,revenue_status
			,revenue_date
			,revenue_amount
			,revenue_remarks
			,currency_code
			,exch_rate
			,@count 'count'
	from	suspend_revenue
	where	code = @p_code ;
end ;

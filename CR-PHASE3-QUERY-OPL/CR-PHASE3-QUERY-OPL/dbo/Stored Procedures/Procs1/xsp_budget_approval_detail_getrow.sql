
CREATE PROCEDURE dbo.xsp_budget_approval_detail_getrow
(
	@p_id bigint
)
as
begin
	select	budget_approval_code
		   ,cost_code
		   ,cost_type
		   ,cost_amount_monthly
		   ,cost_amount_yearly 
	from	budget_approval_detail
	where	id = @p_id ;
end ;

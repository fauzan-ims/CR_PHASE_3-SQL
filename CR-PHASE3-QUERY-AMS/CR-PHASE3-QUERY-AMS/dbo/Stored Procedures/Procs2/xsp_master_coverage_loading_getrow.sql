
CREATE procedure [dbo].[xsp_master_coverage_loading_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,loading_name
			,loading_type
			,age_from
			,age_to
			,rate_type
			,buy_amount
			,sell_amount
			,buy_rate_pct
			,sale_rate_pct
			,is_active
	from	master_coverage_loading
	where	code = @p_code ;
end ;



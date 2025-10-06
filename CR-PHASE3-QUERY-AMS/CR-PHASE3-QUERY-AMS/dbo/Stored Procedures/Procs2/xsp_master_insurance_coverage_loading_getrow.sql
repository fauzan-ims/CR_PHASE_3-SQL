CREATE PROCEDURE [dbo].[xsp_master_insurance_coverage_loading_getrow]
(
	@p_id bigint
)
as
begin
	select	micl.id
			,micl.insurance_coverage_code
			,micl.loading_code
			,micl.age_from
			,micl.age_to
			,micl.rate_type
			,micl.rate_pct
			,micl.rate_amount
			,micl.loading_type
			,micl.buy_rate_pct
			,micl.buy_rate_amount
			,micl.is_active
			,mcl.loading_name
	from	master_insurance_coverage_loading micl
			inner join dbo.master_coverage_loading mcl on (mcl.code = micl.loading_code)
	where	id = @p_id ;
end ;



--created by, Rian at 11/05/2023 

CREATE PROCEDURE dbo.xsp_master_budget_detail_getrow
(
	@p_id			bigint
	,@p_budget_code nvarchar(50)
)
as
begin
	select	id
			,budget_code
			,eff_date
			,budget_rate
			,base_calculate
			,cycle
	from	dbo.master_budget_detail
	where	id				= @p_id
			and budget_code = @p_budget_code ;
end ;

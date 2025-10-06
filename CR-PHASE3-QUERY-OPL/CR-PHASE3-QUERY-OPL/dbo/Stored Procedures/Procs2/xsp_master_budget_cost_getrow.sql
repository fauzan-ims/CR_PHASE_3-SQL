CREATE procedure [dbo].[xsp_master_budget_cost_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,cost_type
			,bill_periode
			,class_code
			,class_description
			,is_subject_to_purchase
			,exp_date
			,is_active
			,item_code
			,item_description
	from	master_budget_cost
	where	code = @p_code ;
end ;

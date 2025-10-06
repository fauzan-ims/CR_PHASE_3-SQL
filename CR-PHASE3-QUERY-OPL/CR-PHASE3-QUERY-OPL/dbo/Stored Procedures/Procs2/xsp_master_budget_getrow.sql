--created by, Rian at 11/05/2023 

CREATE PROCEDURE dbo.xsp_master_budget_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,type
			,class_code
			,class_description
			,exp_date
			,is_active
	from	dbo.master_budget
	where	code = @p_code ;
end ;

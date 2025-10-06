
--created by, Rian at 11/05/2023 

CREATE PROCEDURE [dbo].[xsp_master_other_budget_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
		   ,description
		   ,class_code
		   ,class_description
		   ,exp_date
		   ,is_subject_to_purchase
		   ,is_active 
	from	dbo.master_other_budget
	where	code = @p_code ;
end ;

CREATE PROCEDURE [dbo].[xsp_master_insurance_branch_getrow_for_lookup_db]
(
	@p_insurance_code nvarchar(50)
)
as
begin
	select		id
				,branch_code
				,branch_name
	from		master_insurance_branch
	where	insurance_code = @p_insurance_code ;
end ;


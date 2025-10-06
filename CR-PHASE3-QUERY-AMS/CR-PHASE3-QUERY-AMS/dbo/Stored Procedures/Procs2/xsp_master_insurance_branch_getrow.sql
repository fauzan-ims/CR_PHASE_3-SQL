
CREATE procedure [dbo].[xsp_master_insurance_branch_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,insurance_code
			,branch_code
			,branch_name
	from	master_insurance_branch
	where	id = @p_id ;
end ;



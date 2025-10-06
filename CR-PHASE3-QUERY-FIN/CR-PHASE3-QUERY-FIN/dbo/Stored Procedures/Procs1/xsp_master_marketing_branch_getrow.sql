
create procedure xsp_master_marketing_branch_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,marketing_code
			,branch_code
			,branch_name
	from	master_marketing_branch
	where	id = @p_id ;
end ;


create procedure xsp_master_approval_dimension_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,approval_code
			,reff_dimension_code
			,reff_dimension_name
			,dimension_code
	from	master_approval_dimension
	where	id = @p_id ;
end ;

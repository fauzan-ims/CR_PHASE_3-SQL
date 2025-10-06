
create procedure xsp_master_cashier_priority_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,is_default
	from	master_cashier_priority
	where	code = @p_code ;
end ;

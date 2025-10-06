create procedure xsp_master_row_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,row_name
			,drawer_code
			,is_active
	from	master_row
	where	code = @p_code ;
end ;

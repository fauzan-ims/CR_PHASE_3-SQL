create procedure xsp_master_courier_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,courier_name
			,is_active
	from	master_courier
	where	code = @p_code ;
end ;

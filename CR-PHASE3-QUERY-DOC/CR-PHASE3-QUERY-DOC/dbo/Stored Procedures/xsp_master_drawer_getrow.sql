CREATE PROCEDURE dbo.xsp_master_drawer_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,drawer_name
			,locker_code
			,is_active
	from	master_drawer
	where	code = @p_code ;
end ;

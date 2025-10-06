CREATE PROCEDURE dbo.xsp_master_locker_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
		   ,branch_code
		   ,branch_name
		   ,locker_name
		   ,is_active 'is_active'
	from	master_locker
	where	code = @p_code ;
end ;

CREATE PROCEDURE [dbo].[xsp_audit_trail_getrow]
(
	@p_name	nvarchar(4000)
)
as
begin
	select	replace(name, 'Z_AUDIT_', '') as 'name'	
	from	sys.tables
	where	name = @p_name
end ;

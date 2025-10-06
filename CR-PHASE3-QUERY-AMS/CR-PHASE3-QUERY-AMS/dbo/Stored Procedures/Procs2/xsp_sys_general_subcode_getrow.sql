CREATE PROCEDURE dbo.xsp_sys_general_subcode_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	sgs.code
			,sgs.general_code
			,sgs.order_key
			,sgs.description
			,sgs.is_active
	from	sys_general_subcode sgs
	where	sgs.code = @p_code ;
end ;

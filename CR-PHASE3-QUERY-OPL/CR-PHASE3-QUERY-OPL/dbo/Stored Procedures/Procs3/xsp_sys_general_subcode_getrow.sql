
CREATE procedure [dbo].[xsp_sys_general_subcode_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	sgs.code
			,sgs.description
			,sgs.general_code
			,sgs.ojk_code
			,sgs.order_key
			,sgs.is_active
			,sgc.is_editable
	from	sys_general_subcode sgs
			inner join dbo.sys_general_code sgc on (sgc.code = sgs.general_code)
	where	sgs.code = @p_code ;
end ;

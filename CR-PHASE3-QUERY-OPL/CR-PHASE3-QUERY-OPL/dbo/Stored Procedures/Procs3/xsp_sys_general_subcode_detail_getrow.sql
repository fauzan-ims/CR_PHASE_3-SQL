
CREATE procedure [dbo].[xsp_sys_general_subcode_detail_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	sgsd.code
			,sgsd.description
			,sgsd.general_subcode_code
			,sgsd.ojk_code
			,sgsd.order_key
			,sgsd.is_active
			,sgc.is_editable
	from	sys_general_subcode_detail sgsd
			inner join dbo.sys_general_subcode sgs on (sgs.code = sgsd.general_subcode_code)
			inner join dbo.sys_general_code sgc on (sgc.code	= sgs.general_code)
	where	sgsd.code = @p_code ;
end ;

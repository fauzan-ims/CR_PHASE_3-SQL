CREATE PROCEDURE [dbo].[xsp_sys_general_subcode_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	sgs.code
			,sgs.description
			,general_code
			,ojk_code
			,order_key
			,is_active
			,sgc.is_editable
	from	sys_general_subcode sgs
			INNER JOIN dbo.SYS_GENERAL_CODE sgc ON (sgc.CODE = sgs.GENERAL_CODE)
	where	sgs.code = @p_code ;
end ;


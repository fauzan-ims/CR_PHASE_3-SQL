CREATE PROCEDURE dbo.xsp_sys_document_group_getrow
(
	@p_code			 nvarchar(50)
)
as
begin
	select	sdg.code
			,sdg.company_code
			,sdg.description
			,type_code
			,sgs.description 'general_subcode_desc'
			,sdg.dim_count
			,sdg.is_active
	from	sys_document_group sdg
			left join dbo.sys_general_subcode sgs on (sdg.type_code = sgs.code) and (sgs.company_code = sdg.company_code)
	where	sdg.code			 = @p_code;
end ;

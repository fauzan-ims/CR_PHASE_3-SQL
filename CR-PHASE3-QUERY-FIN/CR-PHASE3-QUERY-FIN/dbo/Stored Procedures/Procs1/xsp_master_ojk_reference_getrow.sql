CREATE PROCEDURE dbo.xsp_master_ojk_reference_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	mor.code
			,mor.description
			,reference_type_code
			,sgs.description 'reference_type_name'
			,mor.ojk_code
			,mor.is_active
	from	master_ojk_reference mor
			inner join dbo.sys_general_subcode sgs on (sgs.code = mor.reference_type_code)
	where	mor.code = @p_code ;
end ;

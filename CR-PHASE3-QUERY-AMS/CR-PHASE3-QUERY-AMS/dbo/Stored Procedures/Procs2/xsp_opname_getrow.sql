CREATE PROCEDURE dbo.xsp_opname_getrow
(
	@p_code nvarchar(50)
)
as
begin

	select	op.code
			,op.company_code
			,opname_date
			,op.branch_code
			,op.branch_name
			,location_code
			,op.location_name
			,division_code	
			,division_name	
			,department_code
			,department_name
			,status
			,op.description
			,remark
			,pic_code
			,pic_name
	from	opname op
	where	op.code = @p_code ;
end ;

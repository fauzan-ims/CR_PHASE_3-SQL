CREATE PROCEDURE dbo.xsp_mutation_getrow
(
	@p_code nvarchar(50)
)
as
begin

	select	mt.code
			,mt.company_code
			,mutation_date
			,requestor_code
			,requestor_name
			--,scm.name 'requestor_name'
			,branch_request_code
			,branch_request_name
			,from_branch_code
			,from_branch_name
			,from_division_code
			,from_division_name
			,from_department_code
			,from_department_name
			,from_pic_code	
			,to_branch_code
			,to_branch_name
			,to_division_code
			,to_division_name
			,to_department_code
			,to_department_name
			,to_pic_code 
			,mt.status
			,remark
	from	mutation mt
	where	mt.code = @p_code ;
end ;

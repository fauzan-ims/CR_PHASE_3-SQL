
CREATE procedure xsp_opname_history_getrow
(
	@p_code			nvarchar(50)
) as
begin

	select	code
			,company_code
			,opname_date
			,branch_code
			,branch_name
			,location_code
			,division_code
			,division_name
			,department_code
			,department_name
			,status
			,description
			,remark
	from	opname_history
	where	code	= @p_code
end

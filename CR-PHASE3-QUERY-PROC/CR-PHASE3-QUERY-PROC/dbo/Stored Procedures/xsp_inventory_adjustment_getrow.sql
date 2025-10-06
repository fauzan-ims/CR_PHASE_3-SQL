
create procedure xsp_inventory_adjustment_getrow
(
	@p_code			nvarchar(50)
) as
begin

	select	 code
			,company_code
			,adjustment_date
			,branch_code
			,branch_name
			,division_code
			,division_name
			,department_code
			,department_name
			,sub_department_code
			,sub_department_name
			,units_code
			,units_name
			,reason
			,remark
			,status
	from	inventory_adjustment
	where	code	= @p_code
end

CREATE PROCEDURE [dbo].[xsp_supplier_selection_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,quotation_code
			,selection_date
			,branch_code
			,branch_name
			,division_code
			,division_name
			,department_code
			,department_name
			,status
			,remark
			,count_return
	from	supplier_selection
	where	code = @p_code ;
end ;

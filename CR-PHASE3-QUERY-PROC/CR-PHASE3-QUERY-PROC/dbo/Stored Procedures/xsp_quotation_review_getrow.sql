CREATE PROCEDURE dbo.xsp_quotation_review_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,quotation_review_date
			,expired_date
			,branch_code
			,branch_name
			,division_code
			,division_name
			,department_code
			,department_name
			,status
			,remark
			,unit_from
	from	quotation_review
	where	code = @p_code ;
end ;

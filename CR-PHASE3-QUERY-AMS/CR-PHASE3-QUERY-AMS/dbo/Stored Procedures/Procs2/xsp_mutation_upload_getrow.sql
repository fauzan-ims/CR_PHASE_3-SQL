CREATE procedure dbo.xsp_mutation_upload_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,mutation_date
			,requestor_code
			,branch_request_code
			,branch_request_name
			,from_branch_code
			,from_branch_name
			,from_division_code
			,from_division_name
			,from_department_code
			,from_department_name
			,from_sub_department_code
			,from_sub_department_name
			,from_units_code
			,from_units_name
			,from_location_code
			,from_pic_code
			,to_branch_code
			,to_branch_name
			,to_division_code
			,to_division_name
			,to_department_code
			,to_department_name
			,to_sub_department_code
			,to_sub_department_name
			,to_units_code
			,to_units_name
			,to_location_code
			,to_pic_code
			,status
			,remark
			,asset_code
			,description
	from	mutation_upload
	where	code = @p_code ;
end ;

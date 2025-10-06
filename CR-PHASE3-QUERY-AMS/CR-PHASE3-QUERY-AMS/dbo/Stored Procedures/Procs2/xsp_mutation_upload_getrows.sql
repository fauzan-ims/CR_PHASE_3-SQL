CREATE procedure dbo.xsp_mutation_upload_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	mutation_upload
	where	(
				code like '%' + @p_keywords + '%'
				or	company_code like '%' + @p_keywords + '%'
				or	mutation_date like '%' + @p_keywords + '%'
				or	requestor_code like '%' + @p_keywords + '%'
				or	branch_request_code like '%' + @p_keywords + '%'
				or	branch_request_name like '%' + @p_keywords + '%'
				or	from_branch_code like '%' + @p_keywords + '%'
				or	from_branch_name like '%' + @p_keywords + '%'
				or	from_division_code like '%' + @p_keywords + '%'
				or	from_division_name like '%' + @p_keywords + '%'
				or	from_department_code like '%' + @p_keywords + '%'
				or	from_department_name like '%' + @p_keywords + '%'
				or	from_sub_department_code like '%' + @p_keywords + '%'
				or	from_sub_department_name like '%' + @p_keywords + '%'
				or	from_units_code like '%' + @p_keywords + '%'
				or	from_units_name like '%' + @p_keywords + '%'
				or	from_location_code like '%' + @p_keywords + '%'
				or	from_pic_code like '%' + @p_keywords + '%'
				or	to_branch_code like '%' + @p_keywords + '%'
				or	to_branch_name like '%' + @p_keywords + '%'
				or	to_division_code like '%' + @p_keywords + '%'
				or	to_division_name like '%' + @p_keywords + '%'
				or	to_department_code like '%' + @p_keywords + '%'
				or	to_department_name like '%' + @p_keywords + '%'
				or	to_sub_department_code like '%' + @p_keywords + '%'
				or	to_sub_department_name like '%' + @p_keywords + '%'
				or	to_units_code like '%' + @p_keywords + '%'
				or	to_units_name like '%' + @p_keywords + '%'
				or	to_location_code like '%' + @p_keywords + '%'
				or	to_pic_code like '%' + @p_keywords + '%'
				or	status like '%' + @p_keywords + '%'
				or	remark like '%' + @p_keywords + '%'
				or	asset_code like '%' + @p_keywords + '%'
				or	description like '%' + @p_keywords + '%'
			) ;

	select		code
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
				,@rows_count 'rowcount'
	from		mutation_upload
	where		(
					code like '%' + @p_keywords + '%'
					or	company_code like '%' + @p_keywords + '%'
					or	mutation_date like '%' + @p_keywords + '%'
					or	requestor_code like '%' + @p_keywords + '%'
					or	branch_request_code like '%' + @p_keywords + '%'
					or	branch_request_name like '%' + @p_keywords + '%'
					or	from_branch_code like '%' + @p_keywords + '%'
					or	from_branch_name like '%' + @p_keywords + '%'
					or	from_division_code like '%' + @p_keywords + '%'
					or	from_division_name like '%' + @p_keywords + '%'
					or	from_department_code like '%' + @p_keywords + '%'
					or	from_department_name like '%' + @p_keywords + '%'
					or	from_sub_department_code like '%' + @p_keywords + '%'
					or	from_sub_department_name like '%' + @p_keywords + '%'
					or	from_units_code like '%' + @p_keywords + '%'
					or	from_units_name like '%' + @p_keywords + '%'
					or	from_location_code like '%' + @p_keywords + '%'
					or	from_pic_code like '%' + @p_keywords + '%'
					or	to_branch_code like '%' + @p_keywords + '%'
					or	to_branch_name like '%' + @p_keywords + '%'
					or	to_division_code like '%' + @p_keywords + '%'
					or	to_division_name like '%' + @p_keywords + '%'
					or	to_department_code like '%' + @p_keywords + '%'
					or	to_department_name like '%' + @p_keywords + '%'
					or	to_sub_department_code like '%' + @p_keywords + '%'
					or	to_sub_department_name like '%' + @p_keywords + '%'
					or	to_units_code like '%' + @p_keywords + '%'
					or	to_units_name like '%' + @p_keywords + '%'
					or	to_location_code like '%' + @p_keywords + '%'
					or	to_pic_code like '%' + @p_keywords + '%'
					or	status like '%' + @p_keywords + '%'
					or	remark like '%' + @p_keywords + '%'
					or	asset_code like '%' + @p_keywords + '%'
					or	description like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then company_code
													 when 3 then requestor_code
													 when 4 then branch_request_code
													 when 5 then branch_request_name
													 when 6 then from_branch_code
													 when 7 then from_branch_name
													 when 8 then from_division_code
													 when 9 then from_division_name
													 when 10 then from_department_code
													 when 11 then from_department_name
													 when 12 then from_sub_department_code
													 when 13 then from_sub_department_name
													 when 14 then from_units_code
													 when 15 then from_units_name
													 when 16 then from_location_code
													 when 17 then from_pic_code
													 when 18 then to_branch_code
													 when 19 then to_branch_name
													 when 20 then to_division_code
													 when 21 then to_division_name
													 when 22 then to_department_code
													 when 23 then to_department_name
													 when 24 then to_sub_department_code
													 when 25 then to_sub_department_name
													 when 26 then to_units_code
													 when 27 then to_units_name
													 when 28 then to_location_code
													 when 29 then to_pic_code
													 when 30 then status
													 when 31 then remark
													 when 32 then asset_code
													 when 33 then description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then company_code
													   when 3 then requestor_code
													   when 4 then branch_request_code
													   when 5 then branch_request_name
													   when 6 then from_branch_code
													   when 7 then from_branch_name
													   when 8 then from_division_code
													   when 9 then from_division_name
													   when 10 then from_department_code
													   when 11 then from_department_name
													   when 12 then from_sub_department_code
													   when 13 then from_sub_department_name
													   when 14 then from_units_code
													   when 15 then from_units_name
													   when 16 then from_location_code
													   when 17 then from_pic_code
													   when 18 then to_branch_code
													   when 19 then to_branch_name
													   when 20 then to_division_code
													   when 21 then to_division_name
													   when 22 then to_department_code
													   when 23 then to_department_name
													   when 24 then to_sub_department_code
													   when 25 then to_sub_department_name
													   when 26 then to_units_code
													   when 27 then to_units_name
													   when 28 then to_location_code
													   when 29 then to_pic_code
													   when 30 then status
													   when 31 then remark
													   when 32 then asset_code
													   when 33 then description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

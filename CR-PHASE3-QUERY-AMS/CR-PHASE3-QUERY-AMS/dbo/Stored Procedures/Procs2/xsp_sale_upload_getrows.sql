CREATE procedure dbo.xsp_sale_upload_getrows
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
	from	sale_upload
	where	(
				code like '%' + @p_keywords + '%'
				or	company_code like '%' + @p_keywords + '%'
				or	sale_date like '%' + @p_keywords + '%'
				or	description like '%' + @p_keywords + '%'
				or	branch_code like '%' + @p_keywords + '%'
				or	branch_name like '%' + @p_keywords + '%'
				or	location_code like '%' + @p_keywords + '%'
				or	buyer like '%' + @p_keywords + '%'
				or	buyer_phone_no like '%' + @p_keywords + '%'
				or	sale_amount like '%' + @p_keywords + '%'
				or	remark like '%' + @p_keywords + '%'
				or	status like '%' + @p_keywords + '%'
				or	asset_code like '%' + @p_keywords + '%'
				or	description_detail like '%' + @p_keywords + '%'
				or	sale_value like '%' + @p_keywords + '%'
			) ;

	select		code
				,company_code
				,sale_date
				,description
				,branch_code
				,branch_name
				,location_code
				,buyer
				,buyer_phone_no
				,sale_amount
				,remark
				,status
				,asset_code
				,description_detail
				,sale_value
				,@rows_count 'rowcount'
	from		sale_upload
	where		(
					code like '%' + @p_keywords + '%'
					or	company_code like '%' + @p_keywords + '%'
					or	sale_date like '%' + @p_keywords + '%'
					or	description like '%' + @p_keywords + '%'
					or	branch_code like '%' + @p_keywords + '%'
					or	branch_name like '%' + @p_keywords + '%'
					or	location_code like '%' + @p_keywords + '%'
					or	buyer like '%' + @p_keywords + '%'
					or	buyer_phone_no like '%' + @p_keywords + '%'
					or	sale_amount like '%' + @p_keywords + '%'
					or	remark like '%' + @p_keywords + '%'
					or	status like '%' + @p_keywords + '%'
					or	asset_code like '%' + @p_keywords + '%'
					or	description_detail like '%' + @p_keywords + '%'
					or	sale_value like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then company_code
													 when 3 then description
													 when 4 then branch_code
													 when 5 then branch_name
													 when 6 then location_code
													 when 7 then buyer
													 when 8 then buyer_phone_no
													 when 9 then remark
													 when 10 then status
													 when 11 then asset_code
													 when 12 then description_detail
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then company_code
													   when 3 then description
													   when 4 then branch_code
													   when 5 then branch_name
													   when 6 then location_code
													   when 7 then buyer
													   when 8 then buyer_phone_no
													   when 9 then remark
													   when 10 then status
													   when 11 then asset_code
													   when 12 then description_detail
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

CREATE PROCEDURE dbo.xsp_mutation_history_getrows
(
 	@p_keywords			nvarchar(50)
 	,@p_pagenumber		int
 	,@p_rowspage		int
 	,@p_order_by		int
 	,@p_sort_by			nvarchar(5)
 	,@p_company_code	nvarchar(50)
 	,@p_branch_code		nvarchar(50)
 	,@p_location_code	nvarchar(50)	= ''
 	,@p_status			nvarchar(20)
 )
 as
 begin
 	declare @rows_count int = 0 ;
 
 	select	@rows_count = count(1)
 	from	dbo.mutation_history mt
 	where	mt.from_branch_code = @p_branch_code
 	and		mt.from_location_code = case @p_location_code
 										when '' then mt.from_location_code
 									else @p_location_code
 								end
 	and		mt.status = case @p_status
 						when 'ALL' then mt.status
 						else @p_status
 					end
 	and		mt.company_code = @p_company_code
 	and		(
 				mt.code											 like '%' + @p_keywords + '%'
 				or	convert(nvarchar(30), mutation_date, 103)	 like '%' + @p_keywords + '%'
 				or	remark										 like '%' + @p_keywords + '%'
				or	mt.status										 like '%' + @p_keywords + '%'
 			) ;
 
 	SELECT	mt.code
 			,mt.company_code
 			,convert(nvarchar(30), mt.mutation_date, 103) 'mutation_date'
 			,mt.requestor_code
 			,mt.branch_request_code
 			,mt.branch_request_name
 			,mt.from_branch_code
 			,mt.from_branch_name
 			,mt.from_division_code
 			,mt.from_division_name
 			,mt.from_department_code
 			,mt.from_department_name
 			,mt.from_sub_department_code
 			,mt.from_sub_department_name
 			,mt.from_units_code
 			,mt.from_units_name
 			,mt.from_location_code
 			,mt.from_pic_code
 			,mt.to_branch_code
 			,mt.to_branch_name
 			,mt.to_division_code
 			,mt.to_division_name
 			,mt.to_department_code
 			,mt.to_department_name
 			,mt.to_sub_department_code
 			,mt.to_sub_department_name
 			,mt.to_units_code
 			,mt.to_units_name
 			,mt.to_location_code
 			,mt.to_pic_code
 			,mt.status
 			,mt.remark
 			,@rows_count 'rowcount'
 	from	dbo.mutation_history mt
 	where	mt.from_branch_code = @p_branch_code
 	and		mt.from_location_code = case @p_location_code
 										when '' then mt.from_location_code
 									else @p_location_code
 								end
 	and			mt.status = case @p_status
 						when 'ALL' then mt.status
 						else @p_status
 					end
 	and			mt.company_code = @p_company_code
 	and			(
 					mt.code											 like '%' + @p_keywords + '%'
 					or	convert(nvarchar(30), mutation_date, 103)	 like '%' + @p_keywords + '%'
 					or	remark										 like '%' + @p_keywords + '%'
					or	mt.status									 like '%' + @p_keywords + '%'
 				)
 	order by	case
 					when @p_sort_by = 'asc' then case @p_order_by
 													 when 1 then mt.code
 													 when 2 then cast(mutation_date as sql_variant)
 													 when 3 then remark
 													 when 4 then mt.status
 												 end
 				end asc
 				,case
 					 when @p_sort_by = 'desc' then case @p_order_by
 													  when 1 then mt.code
 													  when 2 then cast(mutation_date as sql_variant)
 													  when 3 then remark
 													  when 4 then mt.status
 												   end
 				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
 end ;

CREATE PROCEDURE dbo.xsp_mutation_getrows
 (
 	@p_keywords			nvarchar(50)
 	,@p_pagenumber		int
 	,@p_rowspage		int
 	,@p_order_by		int
 	,@p_sort_by			nvarchar(5)
 	,@p_company_code	nvarchar(50)
 	,@p_branch_code		nvarchar(50)	= ''
 	,@p_status			nvarchar(20)
 )
 as
 begin
 	declare @rows_count int = 0 ;

	--HO akan menampilkan semua branch
 	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

 	select	@rows_count = count(1)
 	from	mutation mt
 	where	mt.from_branch_code = case @p_branch_code
 										when 'ALL' then mt.from_branch_code
 									else @p_branch_code
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
				or	mt.status									 like '%' + @p_keywords + '%'
 			) ;
 
 	select	mt.code
 			,mt.company_code
 			,convert(nvarchar(30), mt.mutation_date, 103) 'mutation_date'
 			,mt.requestor_code
 			--,sem.name
 			,mt.branch_request_code
 			,mt.branch_request_name
 			,mt.from_branch_code
 			,mt.from_branch_name
 			,mt.from_division_code
 			,mt.from_division_name
 			,mt.from_department_code
 			,mt.from_department_name
 			,mt.from_pic_code
 			,mt.to_branch_code
 			,mt.to_branch_name
 			,mt.to_division_code
 			,mt.to_division_name
 			,mt.to_department_code
 			,mt.to_department_name
 			,mt.to_pic_code
 			,mt.status
 			,mt.remark
 			,@rows_count 'rowcount'
 	from	mutation mt
 	where	mt.from_branch_code = case @p_branch_code
 										when 'ALL' then mt.from_branch_code
 									else @p_branch_code
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

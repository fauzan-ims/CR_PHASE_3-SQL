CREATE PROCEDURE dbo.xsp_opname_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_status			nvarchar(20)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	opname op
	where	op.branch_code		  = case @p_branch_code
										when 'ALL' then op.branch_code
										else @p_branch_code
									end
	and		op.status = case @p_status
						when 'ALL' then op.status
						else @p_status
					end
	and		op.company_code = @p_company_code
	and		(
				op.code										 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), opname_date, 103)  like '%' + @p_keywords + '%'
				or	op.branch_name							 like '%' + @p_keywords + '%'
				or	op.description							 like '%' + @p_keywords + '%'
				or	op.status								 like '%' + @p_keywords + '%'
			) ;

	select		op.code
				,op.company_code
				,convert(nvarchar(30), opname_date, 103) 'opname_date'
				,op.branch_code
				,op.branch_name
				,location_code
				,op.location_name
				,op.status
				,op.description
				,op.remark
				,@rows_count 'rowcount'
	from		opname op
	where		op.branch_code		  = case @p_branch_code
											when 'ALL' then op.branch_code
											else @p_branch_code
										end
	and			op.status = case @p_status
							when 'ALL' then op.status
							else @p_status
						end
	and			op.company_code = @p_company_code
	and			(
					op.code										 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), opname_date, 103)  like '%' + @p_keywords + '%'
					or	op.branch_name							 like '%' + @p_keywords + '%'
					or	op.description							 like '%' + @p_keywords + '%'
					or	op.status								 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then op.code
													 when 2 then op.branch_name
													 when 3 then cast(op.opname_date as sql_variant)
													 when 4 then op.description
													 when 5 then op.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then op.code
													 when 2 then op.branch_name
													 when 3 then cast(op.opname_date as sql_variant)
													 when 4 then op.description
													 when 5 then op.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

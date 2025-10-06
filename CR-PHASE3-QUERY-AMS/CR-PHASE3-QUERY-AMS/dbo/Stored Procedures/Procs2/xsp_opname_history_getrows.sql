CREATE PROCEDURE dbo.xsp_opname_history_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)	
	,@p_location_code	nvarchar(50)	= ''
	,@p_company_code	nvarchar(50)
	--,@p_from_date		datetime
--	,@p_to_date			datetime
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
	from	opname_history op
			inner join dbo.opname_detail od on (od.opname_code = op.code)
			inner join dbo.asset ass on (od.asset_code = ass.code)
	where	op.branch_code		  = case @p_branch_code
										when 'ALL' then op.branch_code
										else @p_branch_code
									end
	--and		op.location_code	  = case @p_location_code
	--									when '' then op.location_code
	--									else @p_location_code
	--								end
--	and		op.opname_date between @p_from_date and @p_to_date
	and		op.company_code = @p_company_code
	and		(
				op.code										 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), opname_date, 103)  like '%' + @p_keywords + '%'
				or	op.branch_name							 like '%' + @p_keywords + '%'
				or	op.description							 like '%' + @p_keywords + '%'
				or	ass.item_name							 like '%' + @p_keywords + '%'
				or	od.condition_code						 like '%' + @p_keywords + '%'
				or	od.location_name						 like '%' + @p_keywords + '%'
			) ;

	select		op.code
				,op.company_code
				,convert(nvarchar(30), opname_date, 103) 'opname_date'
				,op.branch_code
				,op.branch_name
				,op.status
				,op.description
				,op.remark
				,ass.item_name
				,od.asset_code
				,od.location_name 'location_in'
				,op.status
				,od.condition_code 'condition_name'
				,@rows_count 'rowcount'
	from		opname_history op
				inner join dbo.opname_detail od on (od.opname_code = op.code)
				inner join dbo.asset ass on (od.asset_code = ass.code)
	where	op.branch_code		  = case @p_branch_code
										when 'ALL' then op.branch_code
										else @p_branch_code
									end
	--and		op.location_code	  = case @p_location_code
	--									when '' then op.location_code
	--									else @p_location_code
	--								end
--	and		op.opname_date between @p_from_date and @p_to_date
	and			op.company_code = @p_company_code
	and			(
					op.code										 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), opname_date, 103)  like '%' + @p_keywords + '%'
					or	op.branch_name							 like '%' + @p_keywords + '%'
					or	op.description							 like '%' + @p_keywords + '%'
					or	ass.item_name							 like '%' + @p_keywords + '%'
					or	od.condition_code						 like '%' + @p_keywords + '%'
					or	od.location_name						 like '%' + @p_keywords + '%'
				)
	order by case
			 when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then op.code + od.asset_code
													 when 2 then ass.item_name
													 when 3 then cast(op.opname_date as sql_variant)
													 when 4 then op.branch_name
													 when 5 then od.condition_code
													 when 6 then od.location_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then op.code + od.asset_code
													 when 2 then ass.item_name
													 when 3 then cast(op.opname_date as sql_variant)
													 when 4 then op.branch_name
													 when 5 then od.condition_code
													 when 6 then od.location_name
												   end
				 end desc 
				 offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

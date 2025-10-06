CREATE PROCEDURE dbo.xsp_change_category_getrows
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
	declare @rows_count int = 0 ;

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
	from	change_category cc
			inner join dbo.asset ass on (ass.code = cc.asset_code)
	where	cc.branch_code		  = case @p_branch_code
										when 'ALL' then cc.branch_code
										else @p_branch_code
									end
	and		cc.status = case @p_status
						when 'ALL' then cc.status
						else @p_status
					end
	and		cc.company_code = @p_company_code	
	and		(
					cc.code									 like '%' + @p_keywords + '%'
					or	convert(varchar(30),cc.date, 103)	 like '%' + @p_keywords + '%'
					or	cc.asset_code						 like '%' + @p_keywords + '%'
					or	cc.branch_name						 like '%' + @p_keywords + '%'
					or	cc.status							 like '%' + @p_keywords + '%'
					or  cc.to_item_name						 like '%' + @p_keywords + '%'
			) ;

	select		cc.code
				,cc.company_code
				,convert(varchar(30),cc.date, 103) 'date'
				,cc.asset_code
				,cc.branch_code
				,cc.branch_name
				,cc.description
				,cc.from_category_code
				,cc.to_category_code
				,cc.from_item_code
				,cc.from_item_name
				,cc.to_item_code
				,cc.to_item_name
				,cc.to_depre_category_fiscal_code
				,cc.to_depre_category_comm_code
				,cc.remarks
				,cc.status
				,@rows_count 'rowcount'
	from		change_category cc
				inner join dbo.asset ass on (ass.code = cc.asset_code)
	where		cc.branch_code		  = case @p_branch_code
										when 'ALL' then cc.branch_code
										else @p_branch_code
									end
	and		cc.status = case @p_status
						when 'ALL' then cc.status
						else @p_status
					end
	and		cc.company_code = @p_company_code
	and			(
					cc.code									 like '%' + @p_keywords + '%'
					or	convert(varchar(30),cc.date, 103)	 like '%' + @p_keywords + '%'
					or	cc.asset_code						 like '%' + @p_keywords + '%'
					or	cc.branch_name						 like '%' + @p_keywords + '%'
					or	cc.status							 like '%' + @p_keywords + '%'
					or  cc.to_item_name						 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cc.code
													 when 2 then cc.branch_name
													 when 3 then cast(cc.date as sql_variant)
													 when 4 then cc.asset_code
													 when 5 then cc.to_item_name
													 when 6 then cc.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then cc.code
													 when 2 then cc.branch_name
													 when 3 then cast(cc.date as sql_variant)
													 when 4 then cc.asset_code
													 when 5 then cc.to_item_name
													 when 6 then cc.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

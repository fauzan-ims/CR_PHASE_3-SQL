CREATE PROCEDURE dbo.xsp_maintenance_getrows_for_asset
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_asset_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	maintenance mn
			inner join dbo.asset ast on mn.asset_code = ast.code
	where	mn.asset_code = @p_asset_code
	and		mn.status = 'POST'
	and		(
				mn.code											 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30),transaction_date, 103)  like '%' + @p_keywords + '%'
				or	transaction_amount							 like '%' + @p_keywords + '%'
				or	mn.remark									 like '%' + @p_keywords + '%'
				or	mn.maintenance_by							 like '%' + @p_keywords + '%'
			) ;
			
	select		mn.code
				,mn.company_code
				,asset_code
				,convert(nvarchar(30), transaction_date, 103) 'transaction_date'
				,ast.barcode
				,mn.category_name
				,transaction_amount
				,mn.branch_code
				,mn.branch_name
				,mn.location_code
				,mn.requestor_code
				,mn.division_code
				,mn.division_name
				,mn.department_code
				,mn.department_name
				,mn.status
				,remark
				,case mn.maintenance_by
					when 'EXT' then 'External'
					when 'INT' then 'Internal'
					else mn.maintenance_by
				end 'maintenance_by'
				,@rows_count 'rowcount'
	from		maintenance mn
				inner join dbo.asset ast on mn.asset_code = ast.code
	where		mn.asset_code = @p_asset_code
	and			mn.status = 'POST'
	and			(
					mn.code											 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30),transaction_date, 103)  like '%' + @p_keywords + '%'
					or	transaction_amount							 like '%' + @p_keywords + '%'
					or	mn.remark									 like '%' + @p_keywords + '%'
					or	mn.maintenance_by							 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mn.code
													 when 2 then cast(mn.transaction_date as sql_variant)
													 when 3 then mn.maintenance_by
													 when 4 then cast(mn.transaction_amount as sql_variant)
													 when 5 then mn.remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then mn.code
													 when 2 then cast(mn.transaction_date as sql_variant)
													 when 3 then mn.maintenance_by
													 when 4 then cast(mn.transaction_amount as sql_variant)
													 when 5 then mn.remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

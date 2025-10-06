
CREATE PROCEDURE [dbo].[xsp_mutation_detail_history_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_mutation_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.mutation_detail_history md
			inner join dbo.asset ass on (ass.code = md.asset_code)
	where	mutation_code = @p_mutation_code
	and		(
				asset_code									 like '%' + @p_keywords + '%'
				or	ass.item_name							 like '%' + @p_keywords + '%'
				or	description								 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), receive_date, 103) like '%' + @p_keywords + '%'
				or	status_received							 like '%' + @p_keywords + '%'
				or	md.cost_center_code						 like '%' + @p_keywords + '%'
				or	ass.barcode								 like '%' + @p_keywords + '%'
				or	md.cost_center_name						 like '%' + @p_keywords + '%'
			) ;

	select		id
				,mutation_code
				,asset_code
				,ass.item_name
				,description
				,convert(nvarchar(30), receive_date, 103) 'receive_date'
				,remark_unpost
				,remark_return
				,status_received
				,ass.barcode
				,md.cost_center_code
				,md.cost_center_name
				,@rows_count 'rowcount'
	from		dbo.mutation_detail_history md
				inner join dbo.asset ass on (ass.code = md.asset_code)
	where		mutation_code = @p_mutation_code
	and			(
					asset_code									 like '%' + @p_keywords + '%'
					or	ass.item_name							 like '%' + @p_keywords + '%'
					or	description								 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), receive_date, 103) like '%' + @p_keywords + '%'
					or	status_received							 like '%' + @p_keywords + '%'
					or	md.cost_center_code						 like '%' + @p_keywords + '%'
					or	ass.barcode								 like '%' + @p_keywords + '%'
					or	md.cost_center_name						 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then cast(receive_date as sql_variant)
													 when 3 then description
													 when 4 then status_received
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then cast(receive_date as sql_variant)
													 when 3 then description
													 when 4 then status_received
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

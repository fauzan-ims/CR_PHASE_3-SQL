
CREATE PROCEDURE [dbo].[xsp_reverse_disposal_detail_history_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_reverse_disposal_code	nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	dbo.reverse_disposal_detail_history rdd
			inner join dbo.asset ass on ass.code = rdd.asset_code
	where	rdd.reverse_disposal_code = @p_reverse_disposal_code
	and		(
				rdd.id							like 	'%'+@p_keywords+'%'
				or	rdd.reverse_disposal_code	like 	'%'+@p_keywords+'%'
				or	rdd.asset_code				like 	'%'+@p_keywords+'%'
				or	ass.BARCODE					like 	'%'+@p_keywords+'%'
				or	rdd.cost_center_name		like 	'%'+@p_keywords+'%'
				or	rdd.description				like 	'%'+@p_keywords+'%'
			);

	select	rdd.id
			,rdd.reverse_disposal_code
			,rdd.asset_code 'asset'
			,rdd.description
			,ass.barcode
			,rdd.cost_center_code
			,rdd.cost_center_name
			,ass.item_name 'asset_code'
			,@rows_count	 'rowcount'
	from	dbo.reverse_disposal_detail_history rdd
			inner join dbo.asset ass on ass.code = rdd.asset_code
	where	rdd.reverse_disposal_code = @p_reverse_disposal_code
	and		(
				rdd.id							like 	'%'+@p_keywords+'%'
				or	rdd.reverse_disposal_code	like 	'%'+@p_keywords+'%'
				or	rdd.asset_code				like 	'%'+@p_keywords+'%'
				or	ass.barcode					like 	'%'+@p_keywords+'%'
				or	rdd.cost_center_name		like 	'%'+@p_keywords+'%'
				or	rdd.description				like 	'%'+@p_keywords+'%'
			)
	order BY
			case
				when @p_sort_by = 'asc' then case @p_order_by
												when 1	then rdd.asset_code
												when 2	then rdd.cost_center_name
												when 3	then rdd.description
											 end
				end asc
			 ,case
				when @p_sort_by = 'desc' then case @p_order_by
												when 1	then rdd.asset_code
												when 2	then rdd.cost_center_name
												when 3	then rdd.description
											 end
	end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end

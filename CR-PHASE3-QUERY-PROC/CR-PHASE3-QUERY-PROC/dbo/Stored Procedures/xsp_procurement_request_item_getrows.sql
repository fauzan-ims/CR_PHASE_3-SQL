CREATE PROCEDURE [dbo].[xsp_procurement_request_item_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		procurement_request_item pri
				--left join dbo.procurement prc on (prc.procurement_request_item_id = pri.id)
				left join ifinams.dbo.asset_vehicle av on (av.asset_code = pri.fa_code)
	where		pri.procurement_request_code = @p_code
				--and prc.STATUS not in
				--( 
				--	select		1
				--	from		procurement_request_item pri
				--				left join dbo.procurement prc on prc.procurement_request_item_id = pri.id
				--	where		pri.procurement_request_code = @p_code and prc.status = 'CANCEL'
				--)
				and (
						pri.item_name				like '%' + @p_keywords + '%'
						or	pri.uom_name			like '%' + @p_keywords + '%'
						or	pri.quantity_request	like '%' + @p_keywords + '%'
						or	pri.approved_quantity	like '%' + @p_keywords + '%'
						or	pri.specification		like '%' + @p_keywords + '%'
						or	pri.remark				like '%' + @p_keywords + '%'
						or	pri.fa_code				like '%' + @p_keywords + '%'
						or	av.plat_no				like '%' + @p_keywords + '%'
						or	pri.condition			like '%' + @p_keywords + '%'
					)

	select		pri.id
				,pri.procurement_request_code
				,pri.item_code
				,pri.item_name
				,pri.uom_code
				,pri.uom_name
				,pri.quantity_request
				,pri.approved_quantity
				,pri.specification
				,pri.remark
				,pri.fa_code
				,pri.fa_name
				,av.plat_no
				,pri.condition
				--,prc.status 'procurement_status'
				,@rows_count 'rowcount'
	from		procurement_request_item pri
				--left join dbo.procurement prc on prc.procurement_request_item_id = pri.id
				left join ifinams.dbo.asset_vehicle av on (av.asset_code = pri.fa_code)
	where		pri.procurement_request_code = @p_code
				--and prc.STATUS not in
				--( 
				--	select		1
				--	from		procurement_request_item pri
				--				left join dbo.procurement prc on prc.procurement_request_item_id = pri.id
				--	where		pri.procurement_request_code = @p_code and prc.status = 'CANCEL'
				--)
				and (
						pri.item_name				like '%' + @p_keywords + '%'
						or	pri.uom_name			like '%' + @p_keywords + '%'
						or	pri.quantity_request	like '%' + @p_keywords + '%'
						or	pri.approved_quantity	like '%' + @p_keywords + '%'
						or	pri.specification		like '%' + @p_keywords + '%'
						or	pri.remark				like '%' + @p_keywords + '%'
						or	pri.fa_code				like '%' + @p_keywords + '%'
						or	av.plat_no				like '%' + @p_keywords + '%'
						or	pri.condition			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then pri.item_name
													 when 2 then pri.fa_code
													 when 3 then cast(pri.quantity_request as sql_variant)
													 when 4 then pri.uom_name
													 when 5 then pri.condition
													 when 6 then pri.specification
													 when 7 then pri.remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then pri.item_name
													 when 2 then pri.fa_code
													 when 3 then cast(pri.quantity_request as sql_variant)
													 when 4 then pri.uom_name
													 when 5 then pri.condition
													 when 6 then pri.specification
													 when 7 then pri.remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

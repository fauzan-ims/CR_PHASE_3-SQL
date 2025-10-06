CREATE PROCEDURE dbo.xsp_po_object_info_lookup_for_grn_vhcl
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_po_code			nvarchar(50)
	,@p_item_code		nvarchar(50)
	,@p_id				bigint
)
as
begin
	
	declare @rows_count int = 0 ;

	select @rows_count = count(1) 
	from dbo.purchase_order_detail pod
	left join dbo.purchase_order_detail_object_info pob on (pod.id = pob.purchase_order_detail_id)
	left join dbo.good_receipt_note_detail grnd on (grnd.purchase_order_detail_id = pod.id)
	where pod.po_code = @p_po_code
	and pod.item_code = @p_item_code
	and grnd.id		  = @p_id
	and pob.good_receipt_note_detail_id = 0
	and (
					pod.item_name				like '%' + @p_keywords + '%'
					or	pob.plat_no				like '%' + @p_keywords + '%'
					or	pob.chassis_no			like '%' + @p_keywords + '%'
					or	pob.engine_no			like '%' + @p_keywords + '%'
	) ;
	
	select	pob.id
			,pod.item_code
			,pod.item_name
			,pob.plat_no
			,pob.engine_no
			,pob.chassis_no
			,pob.domain
			,pob.imei
			,@rows_count 'rowcount'
	from dbo.purchase_order_detail pod
	left join dbo.purchase_order_detail_object_info pob on (pod.id = pob.purchase_order_detail_id)
	left join dbo.good_receipt_note_detail grnd on (grnd.purchase_order_detail_id = pod.id)
	where pod.po_code = @p_po_code
	and pod.item_code = @p_item_code
	and grnd.id		  = @p_id
	and pob.good_receipt_note_detail_id = 0
	and (
					pod.item_name				like '%' + @p_keywords + '%'
					or	pob.plat_no				like '%' + @p_keywords + '%'
					or	pob.chassis_no			like '%' + @p_keywords + '%'
					or	pob.engine_no			like '%' + @p_keywords + '%'
	)
	order by case 
				when @p_sort_by = 'asc' then case @p_order_by
												when 1 then pod.item_name
												when 2 then pob.plat_no
												when 3 then pob.engine_no
												when 4 then pob.chassis_no
											 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then pod.item_name
														when 2 then pob.plat_no
														when 3 then pob.engine_no
														when 4 then pob.chassis_no
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

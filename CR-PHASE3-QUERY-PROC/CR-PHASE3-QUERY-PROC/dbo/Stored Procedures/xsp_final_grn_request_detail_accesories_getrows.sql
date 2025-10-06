
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_accesories_getrows]
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_final_grn_request_detail_id int
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.final_grn_request_detail_accesories					 frdk
			left join dbo.final_grn_request_detail					 frd on frd.id										  = frdk.final_grn_request_detail_id
			left join dbo.final_grn_request_detail_accesories_lookup frdkl on frdk.final_grn_request_detail_accesories_id = frdkl.id
			left join dbo.good_receipt_note_detail					 grnd on grnd.id									  = frd.grn_detail_id_asset
	--left join dbo.purchase_order_detail_object_info			 podoi on podoi.good_receipt_note_detail_id = grnd.id
	where	frdk.final_grn_request_detail_id = @p_final_grn_request_detail_id
			and
			(
				frdkl.po_no like '%' + @p_keywords + '%'
				or	frdkl.grn_code like '%' + @p_keywords + '%'
				or	frdkl.supplier_name like '%' + @p_keywords + '%'
				or	frdkl.item_name like '%' + @p_keywords + '%'
			) ;

	select		frdk.id
				,final_grn_request_detail_id
				,frdkl.po_no
				,frdkl.supplier_name
				,frdkl.grn_code
				,frdkl.item_name
				,grnd.item_name				'item_name_asset'
				,frd.plat_no
				,frd.engine_no
				,frd.chasis_no				'chassis_no'
				,frdk.application_no
				,frdkl.id					'id_accesories_lookup'
				,@rows_count				'rowcount'
	from		dbo.final_grn_request_detail_accesories					 frdk
				left join dbo.final_grn_request_detail					 frd on frd.id										  = frdk.final_grn_request_detail_id
				left join dbo.final_grn_request_detail_accesories_lookup frdkl on frdk.final_grn_request_detail_accesories_id = frdkl.id
				left join dbo.good_receipt_note_detail					 grnd on grnd.id									  = frd.grn_detail_id_asset
	--left join dbo.purchase_order_detail_object_info			 podoi on podoi.good_receipt_note_detail_id = grnd.id
	where		final_grn_request_detail_id = @p_final_grn_request_detail_id
				and
				(
					frdkl.po_no like '%' + @p_keywords + '%'
					or	frdkl.grn_code like '%' + @p_keywords + '%'
					or	frdkl.supplier_name like '%' + @p_keywords + '%'
					or	frdkl.item_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then frdkl.po_no
													 when 2 then frdkl.grn_code
													 when 3 then frdkl.supplier_name
													 when 4 then frdkl.item_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then frdkl.po_no
													   when 2 then frdkl.grn_code
													   when 3 then frdkl.supplier_name
													   when 4 then frdkl.item_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

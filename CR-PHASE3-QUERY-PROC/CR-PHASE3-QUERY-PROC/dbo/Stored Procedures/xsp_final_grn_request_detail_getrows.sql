
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_getrows]
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_final_grn_request_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.final_grn_request_detail					fr
			left join dbo.good_receipt_note_detail			grnd on fr.grn_detail_id_asset = grnd.id
			left join dbo.purchase_order_detail pod on pod.id = grnd.purchase_order_detail_id
			--left join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id = grnd.id
			outer apply
	(
		select	stuff((
						  select	', ' + frdkl.po_no + ' - ' + frdkl.item_name
						  from		dbo.final_grn_request_detail_karoseri				   frdk
									left join dbo.final_grn_request_detail_karoseri_lookup frdkl on frdkl.id = frdk.final_grn_request_detail_karoseri_id
						  where		frdk.final_grn_request_detail_id = fr.id
						  for xml path('')
					  ), 1, 1, ''
					 ) 'karoseri'
	)														karoseri
			outer apply
	(
		select	stuff((
						  select	', ' + frdkl.po_no + ' - ' + frdkl.item_name
						  from		dbo.final_grn_request_detail_accesories_lookup	  frdkl
									left join dbo.final_grn_request_detail_accesories frda on frdkl.id = frda.final_grn_request_detail_accesories_id
						  where		frda.final_grn_request_detail_id = fr.id
						  for xml path('')
					  ), 1, 1, ''
					 ) 'accesories'
	) accesories
	where	fr.final_grn_request_no = @p_final_grn_request_no
			and fr.status <> 'complete'
			and
			(
				fr.asset_no											like '%' + @p_keywords + '%'
				or	fr.year											like '%' + @p_keywords + '%'
				or	fr.colour										like '%' + @p_keywords + '%'
				or	fr.delivery_to									like '%' + @p_keywords + '%'
				or	fr.po_code_asset								like '%' + @p_keywords + '%'
				or	fr.grn_code_asset								like '%' + @p_keywords + '%'
				or	convert(nvarchar(6), grn_receive_date, 112)		like '%' + @p_keywords + '%'
				or	fr.supplier_name_asset							like '%' + @p_keywords + '%'
				or	grnd.item_name									like '%' + @p_keywords + '%'
				or	fr.plat_no										like '%' + @p_keywords + '%'
				or	fr.engine_no									like '%' + @p_keywords + '%'
				or	fr.chasis_no									like '%' + @p_keywords + '%'
				or	karoseri.karoseri								like '%' + @p_keywords + '%'
				or	accesories.accesories							like '%' + @p_keywords + '%'
				or	fr.status										like '%' + @p_keywords + '%'
				or	pod.bbn_name									like '%' + @p_keywords + '%'
			) ;

	select		fr.id
				,final_grn_request_no
				,asset_no
				,delivery_to
				,po_code_asset
				,grn_code_asset
				,supplier_name_asset
				,convert(nvarchar(6), grn_receive_date, 112) 'grn_receive_date'
				,colour
				,year
				,grnd.item_name
				,fr.plat_no
				,fr.engine_no
				,fr.chasis_no 'chassis_no'
				,karoseri.karoseri
				,accesories.accesories
				,fr.status
				,pod.bbn_name
				,pod.bbn_location
				,pod.bbn_address
				,fr.asset_code
				,@rows_count								 'rowcount'
	from		dbo.final_grn_request_detail					fr
				left join dbo.good_receipt_note_detail			grnd on fr.grn_detail_id_asset = grnd.id
				left join dbo.purchase_order_detail pod on pod.id = grnd.purchase_order_detail_id
				--left join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id = grnd.id
				outer apply
	(
		select	stuff((
						  select	', ' + frdkl.po_no + ' - ' + frdkl.item_name
						  from		dbo.final_grn_request_detail_karoseri				   frdk
									left join dbo.final_grn_request_detail_karoseri_lookup frdkl on frdkl.id = frdk.final_grn_request_detail_karoseri_id
						  where		frdk.final_grn_request_detail_id = fr.id
						  for xml path('')
					  ), 1, 1, ''
					 ) 'karoseri'
	)															karoseri
				outer apply
	(
		select	stuff((
						  select	', ' + frdkl.po_no + ' - ' + frdkl.item_name
						  from		dbo.final_grn_request_detail_accesories_lookup	  frdkl
									left join dbo.final_grn_request_detail_accesories frda on frdkl.id = frda.final_grn_request_detail_accesories_id
						  where		frda.final_grn_request_detail_id = fr.id
						  for xml path('')
					  ), 1, 1, ''
					 ) 'accesories'
	) accesories
	where		final_grn_request_no = @p_final_grn_request_no
				and fr.status <> 'complete'
				and
				(
					fr.asset_no											like '%' + @p_keywords + '%'
					or	fr.year											like '%' + @p_keywords + '%'
					or	fr.colour										like '%' + @p_keywords + '%'
					or	fr.delivery_to									like '%' + @p_keywords + '%'
					or	fr.po_code_asset								like '%' + @p_keywords + '%'
					or	fr.grn_code_asset								like '%' + @p_keywords + '%'
					or	convert(nvarchar(6), grn_receive_date, 112)		like '%' + @p_keywords + '%'
					or	fr.supplier_name_asset							like '%' + @p_keywords + '%'
					or	grnd.item_name									like '%' + @p_keywords + '%'
					or	fr.plat_no										like '%' + @p_keywords + '%'
					or	fr.engine_no									like '%' + @p_keywords + '%'
					or	fr.chasis_no									like '%' + @p_keywords + '%'
					or	karoseri.karoseri								like '%' + @p_keywords + '%'
					or	accesories.accesories							like '%' + @p_keywords + '%'
					or	fr.status										like '%' + @p_keywords + '%'
					or	pod.bbn_name									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													   when 1 then asset_no
													   when 2 then fr.delivery_to
													   when 3 then pod.bbn_name
													   when 4 then fr.po_code_asset
													   when 5 then grnd.item_name
													   when 6 then karoseri.karoseri
													   when 7 then ''
													   when 8 then accesories.accesories
													   when 9 then ''
													   when 10 then fr.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_no
													   when 2 then fr.delivery_to
													   when 3 then pod.bbn_name
													   when 4 then fr.po_code_asset
													   when 5 then grnd.item_name
													   when 6 then karoseri.karoseri
													   when 7 then ''
													   when 8 then accesories.accesories
													   when 9 then ''
													   when 10 then fr.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

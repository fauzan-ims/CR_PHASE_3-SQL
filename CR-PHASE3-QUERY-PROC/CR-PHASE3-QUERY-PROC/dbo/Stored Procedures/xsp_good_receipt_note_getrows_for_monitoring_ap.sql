-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_good_receipt_note_getrows_for_monitoring_ap]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_status	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if (@p_status = 'ON PROCESS')
	begin
		select	@rows_count = count(1)
		from		good_receipt_note								 grn
					inner join dbo.good_receipt_note_detail			 grnd on (grn.code = grnd.good_receipt_note_code) and grnd.receive_quantity <> 0
					left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
					outer apply ( 
								select	air.currency_code, air.code, air.invoice_date, air.due_date, air.status  
								from	dbo.ap_invoice_registration_detail aird
										inner join dbo.ap_invoice_registration air on air.code = aird.invoice_register_code
								where	grnd.purchase_order_detail_id = aird.purchase_order_id 
								and		grnd.good_receipt_note_code = aird.grn_code
								and		isnull(air.status,'')  not in ('cancel','reject')
								) air
					outer apply (
									select	status
									from	dbo.ap_payment_request_detail aprd
											inner join dbo.ap_payment_request apr on apr.code = aprd.payment_request_code
									where	isnull(apr.status,'') <>'PAID'
									and		aprd.invoice_register_code = air.code
								) apr
					--
					left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
					outer apply ( 
									select asv.engine_no, asv.chassis_no, asv.plat_no from 
									dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code	= pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.item_code = qrd.item_code)
									left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
									where ssd.id								  = pod.supplier_selection_detail_id
								)asv
		where		grn.status				  IN('APPROVE', 'POST')
					and grnd.receive_quantity <> 0
					and isnull(apr.status,'') <> 'PAID'
					and grn.code not in (select invoice_or_gnr_no from dbo.list_data_cleansing_invoice_dan_monitoring_ap_sebelum_crpriority_naik)
					and
					(
						grn.code																																like '%' + @p_keywords + '%'
						or	grn.purchase_order_code																												like '%' + @p_keywords + '%'
						or	convert(varchar(30), grn.receive_date, 103)																							like '%' + @p_keywords + '%'
						or	grn.supplier_name																													like '%' + @p_keywords + '%'
						or	(datediff(day, grn.receive_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	grn.remark																															like '%' + @p_keywords + '%'
						or	grnd.item_name																														like '%' + @p_keywords + '%'
						or	case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 								like '%' + @p_keywords + '%'
						or	case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 							like '%' + @p_keywords + '%'
						or	case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 						like '%' + @p_keywords + '%'
						or	podoi.asset_code																													like '%' + @p_keywords + '%'
						or	grnd. price_amount																													like '%' + @p_keywords + '%'
						or	grnd.ppn_amount																														like '%' + @p_keywords + '%'
						or	grnd.pph_amount																														like '%' + @p_keywords + '%'
						or	grnd.discount_amount																												like '%' + @p_keywords + '%'
						or	(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)	like '%' + @p_keywords + '%'
						or	air.code																															like '%' + @p_keywords + '%'
						or	(datediff(day, air.invoice_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.invoice_date, 103)																							like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.due_date, 103)																								like '%' + @p_keywords + '%'
					)

		select		grn.code
					,grn.company_code
					,grn.purchase_order_code
					,convert(varchar(30), grn.receive_date, 103)				  'receive_date'
					,grn.supplier_code
					,grn.supplier_name
					,grn.branch_code
					,grn.branch_name
					,grn.division_code
					,grn.division_name
					,grn.department_code
					,grn.department_name
					,grn.remark
					,grn.status													  'grn_status'
					,grn.cover_note_status
					,air.CODE													  'invoice_code'
					,convert(varchar(30), air.invoice_date, 103)				  'invoice_date'
					,convert(varchar(30), air.due_date, 103)					  'due_date'
					,air.status													  'invoice_status'
					,(datediff(day, grn.receive_date, dbo.xfn_get_system_date())) 'aging'
					,(datediff(day, air.invoice_date, dbo.xfn_get_system_date())) 'aging_invoice'
					,grnd.item_name
					,case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 'plat_no'
					,case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 'engine_no'
					,case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 'chassis_no'
					,podoi.asset_code
					,grnd.price_amount 'total_unit_price'--detail.total_unit_price
					,grnd.ppn_amount 'total_ppn'--detail.total_ppn
					,grnd.pph_amount 'total_pph'--detail.total_pph
					,grnd.discount_amount
					,convert(decimal(18,2), (grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)) 'total_grn' --detail.total_grn
					,podoi.id 'podoi_id'
					,@p_status 'status'
					,@rows_count												  'rowcount'
		from		good_receipt_note								 grn
					inner join dbo.good_receipt_note_detail			 grnd on (grn.code = grnd.good_receipt_note_code) and grnd.receive_quantity <> 0
					left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
					outer apply ( 
								select	air.currency_code, air.code, air.invoice_date, air.due_date, air.status  
								from	dbo.ap_invoice_registration_detail aird
										inner join dbo.ap_invoice_registration air on air.code = aird.invoice_register_code
								where	grnd.purchase_order_detail_id = aird.purchase_order_id 
								and		grnd.good_receipt_note_code = aird.grn_code
								and		isnull(air.status,'')  not in ('cancel','reject')
								) air
					outer apply (
									select	status
									from	dbo.ap_payment_request_detail aprd
											inner join dbo.ap_payment_request apr on apr.code = aprd.payment_request_code
									where	isnull(apr.status,'') <>'PAID'
									and		aprd.invoice_register_code = air.code
								) apr
					--
					left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
					outer apply ( 
									select asv.engine_no, asv.chassis_no, asv.plat_no from 
									dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code	= pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.item_code = qrd.item_code)
									left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
									where ssd.id								  = pod.supplier_selection_detail_id
								)asv
		where		grn.status				  IN('APPROVE', 'POST')
					and grnd.receive_quantity <> 0
					and isnull(apr.status,'') <> 'PAID'
					and grn.code not in (select invoice_or_gnr_no from dbo.list_data_cleansing_invoice_dan_monitoring_ap_sebelum_crpriority_naik)
					and
					(
						grn.code																																like '%' + @p_keywords + '%'
						or	grn.purchase_order_code																												like '%' + @p_keywords + '%'
						or	convert(varchar(30), grn.receive_date, 103)																							like '%' + @p_keywords + '%'
						or	grn.supplier_name																													like '%' + @p_keywords + '%'
						or	(datediff(day, grn.receive_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	grn.remark																															like '%' + @p_keywords + '%'
						or	grnd.item_name																														like '%' + @p_keywords + '%'
						or	case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 								like '%' + @p_keywords + '%'
						or	case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 							like '%' + @p_keywords + '%'
						or	case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 						like '%' + @p_keywords + '%'
						or	podoi.asset_code																													like '%' + @p_keywords + '%'
						or	grnd. price_amount																													like '%' + @p_keywords + '%'
						or	grnd.ppn_amount																														like '%' + @p_keywords + '%'
						or	grnd.pph_amount																														like '%' + @p_keywords + '%'
						or	grnd.discount_amount																												like '%' + @p_keywords + '%'
						or	(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)	like '%' + @p_keywords + '%'
						or	air.code																															like '%' + @p_keywords + '%'
						or	(datediff(day, air.invoice_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.invoice_date, 103)																							like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.due_date, 103)																								like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then grn.purchase_order_code
														 when 2 then cast(grn.receive_date as sql_variant)
														 when 3 then cast((datediff(day, grn.receive_date, dbo.xfn_get_system_date())) as sql_variant)
														 when 4 then grnd.item_name
														 when 5 then cast(isnull(grnd.price_amount,0) as sql_variant)
														 when 6 then grn.supplier_name
														 when 7 then grn.remark
														 when 8 then air.code
														 when 9 then cast(air.invoice_date as sql_variant)
														 when 10 then cast((datediff(day, air.invoice_date, dbo.xfn_get_system_date())) as sql_variant)
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														     when 1 then grn.purchase_order_code
															 when 2 then cast(grn.receive_date as sql_variant)
															 when 3 then cast((datediff(day, grn.receive_date, dbo.xfn_get_system_date())) as sql_variant)
															 when 4 then grnd.item_name
															 when 5 then cast(isnull(grnd.price_amount,0) as sql_variant)
															 when 6 then grn.supplier_name
															 when 7 then grn.remark
															 when 8 then air.code
															 when 9 then cast(air.invoice_date as sql_variant)
															 when 10 then cast((datediff(day, air.invoice_date, dbo.xfn_get_system_date())) as sql_variant)
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else if (@p_status = 'PAID')
	begin
		select	@rows_count = count(1)
		from		good_receipt_note								 grn
					inner join dbo.good_receipt_note_detail			 grnd on (grn.code = grnd.good_receipt_note_code)
					left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
					outer apply ( 
								select	air.currency_code, air.code, air.invoice_date, air.due_date, air.status  
								from	dbo.ap_invoice_registration_detail aird
										inner join dbo.ap_invoice_registration air on air.code = aird.invoice_register_code
								where	grnd.purchase_order_detail_id = aird.purchase_order_id 
								and		grnd.good_receipt_note_code = aird.grn_code
								and		isnull(air.status,'')  IN ('POST','APPROVE')
								) air
					outer apply (
									select	status
									from	dbo.ap_payment_request_detail aprd
											inner join dbo.ap_payment_request apr on apr.code = aprd.payment_request_code
									where	isnull(apr.status,'') = 'PAID'
									and		aprd.invoice_register_code = air.code
								) apr
					--
					left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
					outer apply ( 
									select asv.engine_no, asv.chassis_no, asv.plat_no from 
									dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code	= pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.item_code = qrd.item_code)
									left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
									where ssd.id								  = pod.supplier_selection_detail_id
								)asv
		where		grn.status				  IN('APPROVE', 'POST')
					and grnd.receive_quantity <> 0
					and isnull(apr.status,'') = 'PAID'
					and grn.code not in (select invoice_or_gnr_no from dbo.list_data_cleansing_invoice_dan_monitoring_ap_sebelum_crpriority_naik)
					and
					(
						grn.code																																like '%' + @p_keywords + '%'
						or	grn.purchase_order_code																												like '%' + @p_keywords + '%'
						or	convert(varchar(30), grn.receive_date, 103)																							like '%' + @p_keywords + '%'
						or	grn.supplier_name																													like '%' + @p_keywords + '%'
						or	(datediff(day, grn.receive_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	grn.remark																															like '%' + @p_keywords + '%'
						or	grnd.item_name																														like '%' + @p_keywords + '%'
						or	case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 								like '%' + @p_keywords + '%'
						or	case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 							like '%' + @p_keywords + '%'
						or	case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 						like '%' + @p_keywords + '%'
						or	podoi.asset_code																													like '%' + @p_keywords + '%'
						or	grnd. price_amount																													like '%' + @p_keywords + '%'
						or	grnd.ppn_amount																														like '%' + @p_keywords + '%'
						or	grnd.pph_amount																														like '%' + @p_keywords + '%'
						or	grnd.discount_amount																												like '%' + @p_keywords + '%'
						or	(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)	like '%' + @p_keywords + '%'
						or	air.code																															like '%' + @p_keywords + '%'
						or	(datediff(day, air.invoice_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.invoice_date, 103)																							like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.due_date, 103)																								like '%' + @p_keywords + '%'
					)

		select		grn.code
					,grn.company_code
					,grn.purchase_order_code
					,convert(varchar(30), grn.receive_date, 103)				  'receive_date'
					,grn.supplier_code
					,grn.supplier_name
					,grn.branch_code
					,grn.branch_name
					,grn.division_code
					,grn.division_name
					,grn.department_code
					,grn.department_name
					,grn.remark
					,grn.status													  'grn_status'
					,grn.cover_note_status
					,air.CODE													  'invoice_code'
					,convert(varchar(30), air.invoice_date, 103)				  'invoice_date'
					,convert(varchar(30), air.due_date, 103)					  'due_date'
					,air.status													  'invoice_status'
					,(datediff(day, grn.receive_date, dbo.xfn_get_system_date())) 'aging'
					,(datediff(day, air.invoice_date, dbo.xfn_get_system_date())) 'aging_invoice'
					,grnd.item_name
					,case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 'plat_no'
					,case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 'engine_no'
					,case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 'chassis_no'
					,podoi.asset_code
					,grnd.price_amount 'total_unit_price'--detail.total_unit_price
					,grnd.ppn_amount 'total_ppn'--detail.total_ppn
					,grnd.pph_amount 'total_pph'--detail.total_pph
					,grnd.discount_amount
					,convert(decimal(18,2),(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)) 'total_grn' --detail.total_grn
					,podoi.id 'podoi_id'
					,@p_status 'status'
					,@rows_count												  'rowcount'
		from		good_receipt_note								 grn
					inner join dbo.good_receipt_note_detail			 grnd on (grn.code = grnd.good_receipt_note_code)
					left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
					outer apply ( 
								select	air.currency_code, air.code, air.invoice_date, air.due_date, air.status  
								from	dbo.ap_invoice_registration_detail aird
										inner join dbo.ap_invoice_registration air on air.code = aird.invoice_register_code
								where	grnd.purchase_order_detail_id = aird.purchase_order_id 
								and		grnd.good_receipt_note_code = aird.grn_code
								and		isnull(air.status,'')  IN ('POST','APPROVE')
								) air
					outer apply (
									select	status
									from	dbo.ap_payment_request_detail aprd
											inner join dbo.ap_payment_request apr on apr.code = aprd.payment_request_code
									where	isnull(apr.status,'') = 'PAID'
									and		aprd.invoice_register_code = air.code
								) apr

					--
					left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
					outer apply ( 
									select asv.engine_no, asv.chassis_no, asv.plat_no from 
									dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code	= pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.item_code = qrd.item_code)
									left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
									where ssd.id								  = pod.supplier_selection_detail_id
								)asv
		where		grn.status				  IN('APPROVE', 'POST')
					and grnd.receive_quantity <> 0
					and isnull(apr.status,'') = 'PAID'
					and grn.code not in (select invoice_or_gnr_no from dbo.list_data_cleansing_invoice_dan_monitoring_ap_sebelum_crpriority_naik)
					and
					(
						grn.code																																like '%' + @p_keywords + '%'
						or	grn.purchase_order_code																												like '%' + @p_keywords + '%'
						or	convert(varchar(30), grn.receive_date, 103)																							like '%' + @p_keywords + '%'
						or	grn.supplier_name																													like '%' + @p_keywords + '%'
						or	(datediff(day, grn.receive_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	grn.remark																															like '%' + @p_keywords + '%'
						or	grnd.item_name																														like '%' + @p_keywords + '%'
						or	case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 								like '%' + @p_keywords + '%'
						or	case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 							like '%' + @p_keywords + '%'
						or	case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 						like '%' + @p_keywords + '%'
						or	podoi.asset_code																													like '%' + @p_keywords + '%'
						or	grnd. price_amount																													like '%' + @p_keywords + '%'
						or	grnd.ppn_amount																														like '%' + @p_keywords + '%'
						or	grnd.pph_amount																														like '%' + @p_keywords + '%'
						or	grnd.discount_amount																												like '%' + @p_keywords + '%'
						or	(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)	like '%' + @p_keywords + '%'
						or	air.code																															like '%' + @p_keywords + '%'
						or	(datediff(day, air.invoice_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.invoice_date, 103)																							like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.due_date, 103)																								like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														  when 1 then grn.purchase_order_code
														  when 2 then cast(grn.receive_date as sql_variant)
														  when 3 then cast((datediff(day, grn.receive_date, dbo.xfn_get_system_date())) as sql_variant)
														  when 4 then grnd.item_name
														  when 5 then cast(grnd.price_amount as sql_variant)
														  when 6 then grn.supplier_name
														  when 7 then air.code
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then grn.purchase_order_code
														   when 2 then cast(grn.receive_date as sql_variant)
														   when 3 then cast((datediff(day, grn.receive_date, dbo.xfn_get_system_date())) as sql_variant)
														   when 4 then grnd.item_name
														   when 5 then cast(grnd.price_amount as sql_variant)
														   when 6 then grn.supplier_name
														   when 7 then air.code
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end
	else if (@p_status = 'ALL')
	begin
		select	@rows_count = count(1)
		from		good_receipt_note								 grn
					inner join dbo.good_receipt_note_detail			 grnd on (grn.code = grnd.good_receipt_note_code)
					left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
					left join dbo.ap_invoice_registration_detail	 aird on (grnd.purchase_order_detail_id = aird.purchase_order_id and  grnd.good_receipt_note_code = aird.grn_code)
					outer apply ( 
								select air.currency_code, air.code, air.invoice_date, air.due_date, air.status  
								from	dbo.ap_invoice_registration_detail aird
										left join dbo.ap_invoice_registration air on air.code = aird.invoice_register_code
								where	grnd.purchase_order_detail_id = aird.purchase_order_id 
								and		grnd.good_receipt_note_code = aird.grn_code
								and		isnull(air.status,'')  not in ('cancel','reject')
								) air
					outer apply (
									select	status
									from	dbo.ap_payment_request_detail aprd
											inner join dbo.ap_payment_request apr on apr.code = aprd.payment_request_code
									where	isnull(apr.status,'') not in ('cancel', 'reject')
									and		aprd.invoice_register_code = air.code
								) apr
					--
					left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
					outer apply ( 
									select asv.engine_no, asv.chassis_no, asv.plat_no from 
									dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code	= pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.item_code = qrd.item_code)
									left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
									where ssd.id								  = pod.supplier_selection_detail_id
								)asv
		where		grn.status				  IN('APPROVE', 'POST')
					and grnd.receive_quantity <> 0
					and isnull(apr.status,'') not in ('CANCEL', 'REJECT')
					and grn.code not in (select invoice_or_gnr_no from dbo.list_data_cleansing_invoice_dan_monitoring_ap_sebelum_crpriority_naik)
					and
					(
						grn.code																																like '%' + @p_keywords + '%'
						or	grn.purchase_order_code																												like '%' + @p_keywords + '%'
						or	convert(varchar(30), grn.receive_date, 103)																							like '%' + @p_keywords + '%'
						or	grn.supplier_name																													like '%' + @p_keywords + '%'
						or	(datediff(day, grn.receive_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	grn.remark																															like '%' + @p_keywords + '%'
						or	grnd.item_name																														like '%' + @p_keywords + '%'
						or	case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 								like '%' + @p_keywords + '%'
						or	case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 							like '%' + @p_keywords + '%'
						or	case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 						like '%' + @p_keywords + '%'
						or	podoi.asset_code																													like '%' + @p_keywords + '%'
						or	grnd. price_amount																													like '%' + @p_keywords + '%'
						or	grnd.ppn_amount																														like '%' + @p_keywords + '%'
						or	grnd.pph_amount																														like '%' + @p_keywords + '%'
						or	grnd.discount_amount																												like '%' + @p_keywords + '%'
						or	(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)	like '%' + @p_keywords + '%'
						or	air.code																															like '%' + @p_keywords + '%'
						or	(datediff(day, air.invoice_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.invoice_date, 103)																							like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.due_date, 103)																								like '%' + @p_keywords + '%'
					)

		select		grn.code
					,grn.company_code
					,grn.purchase_order_code
					,convert(varchar(30), grn.receive_date, 103)				  'receive_date'
					,grn.supplier_code
					,grn.supplier_name
					,grn.branch_code
					,grn.branch_name
					,grn.division_code
					,grn.division_name
					,grn.department_code
					,grn.department_name
					,grn.remark
					,grn.status													  'grn_status'
					,grn.cover_note_status
					,air.CODE													  'invoice_code'
					,convert(varchar(30), air.invoice_date, 103)				  'invoice_date'
					,convert(varchar(30), air.due_date, 103)					  'due_date'
					,air.status													  'invoice_status'
					,(datediff(day, grn.receive_date, dbo.xfn_get_system_date())) 'aging'
					,(datediff(day, air.invoice_date, dbo.xfn_get_system_date())) 'aging_invoice'
					,grnd.item_name
					,case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 'plat_no'
					,case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 'engine_no'
					,case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 'chassis_no'
					,podoi.asset_code
					,grnd.price_amount 'total_unit_price'--detail.total_unit_price
					,grnd.ppn_amount 'total_ppn'--detail.total_ppn
					,grnd.pph_amount 'total_pph'--detail.total_pph
					,grnd.discount_amount
					,convert(decimal(18,2), (grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)) 'total_grn' --detail.total_grn
					,podoi.id 'podoi_id'
					--,@p_status 'status'
					,case when isnull(apr.status,'') = 'PAID' then 'PAID' 
						else (case when isnull(air.status,'') in ('HOLD','ON PROCESS','APPROVE') then 'ON PROCESS' 
								else 'PENDING'	end) 
					end 'status'
					,@rows_count												  'rowcount'
		from		good_receipt_note								 grn
					inner join dbo.good_receipt_note_detail			 grnd on (grn.code = grnd.good_receipt_note_code)
					left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
					outer apply ( 
								select air.currency_code, air.code, air.invoice_date, air.due_date, air.status  
								from	dbo.ap_invoice_registration_detail aird
										left join dbo.ap_invoice_registration air on air.code = aird.invoice_register_code
								where	grnd.purchase_order_detail_id = aird.purchase_order_id 
								and		grnd.good_receipt_note_code = aird.grn_code
								and		isnull(air.status,'')  not in ('cancel','reject')
								) air
					outer apply (
									select	status
									from	dbo.ap_payment_request_detail aprd
											inner join dbo.ap_payment_request apr on apr.code = aprd.payment_request_code
									where	isnull(apr.status,'') not in ('cancel', 'reject')
									and		aprd.invoice_register_code = air.code
								) apr
					--
					left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
					outer apply ( 
									select asv.engine_no, asv.chassis_no, asv.plat_no from 
									dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code	= pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.item_code = qrd.item_code)
									left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
									where ssd.id								  = pod.supplier_selection_detail_id
								)asv
		where		grn.status				  IN('APPROVE', 'POST')
					and grnd.receive_quantity <> 0
					and isnull(apr.status,'') not in ('CANCEL', 'REJECT')
					and grn.code not in (select invoice_or_gnr_no from dbo.list_data_cleansing_invoice_dan_monitoring_ap_sebelum_crpriority_naik)
					and
					(
						grn.code																																like '%' + @p_keywords + '%'
						or	grn.purchase_order_code																												like '%' + @p_keywords + '%'
						or	convert(varchar(30), grn.receive_date, 103)																							like '%' + @p_keywords + '%'
						or	grn.supplier_name																													like '%' + @p_keywords + '%'
						or	(datediff(day, grn.receive_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	grn.remark																															like '%' + @p_keywords + '%'
						or	grnd.item_name																														like '%' + @p_keywords + '%'
						or	case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 								like '%' + @p_keywords + '%'
						or	case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 							like '%' + @p_keywords + '%'
						or	case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 						like '%' + @p_keywords + '%'
						or	podoi.asset_code																													like '%' + @p_keywords + '%'
						or	grnd. price_amount																													like '%' + @p_keywords + '%'
						or	grnd.ppn_amount																														like '%' + @p_keywords + '%'
						or	grnd.pph_amount																														like '%' + @p_keywords + '%'
						or	grnd.discount_amount																												like '%' + @p_keywords + '%'
						or	(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)	like '%' + @p_keywords + '%'
						or	air.code																															like '%' + @p_keywords + '%'
						or	(datediff(day, air.invoice_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.invoice_date, 103)																							like '%' + @p_keywords + '%'
						or	convert(varchar(30), air.due_date, 103)																								like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														  when 1 then grn.purchase_order_code
														  when 2 then cast(grn.receive_date as sql_variant)
														  when 3 then cast((datediff(day, grn.receive_date, dbo.xfn_get_system_date())) as sql_variant)
														  when 4 then grnd.item_name
														  when 5 then cast(grnd.price_amount as sql_variant)
														  when 6 then grn.supplier_name
														  when 7 then air.code
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then grn.purchase_order_code
														   when 2 then cast(grn.receive_date as sql_variant)
														   when 3 then cast((datediff(day, grn.receive_date, dbo.xfn_get_system_date())) as sql_variant)
														   when 4 then grnd.item_name
														   when 5 then cast(grnd.price_amount as sql_variant)
														   when 6 then grn.supplier_name
														   when 7 then air.code
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end
	else if (@p_status = 'PENDING')
	begin
		select	@rows_count = count(1)
		from		good_receipt_note								 grn
					inner join dbo.good_receipt_note_detail			 grnd on (grn.code = grnd.good_receipt_note_code)
					left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
					--
					left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
					outer apply ( 
									select asv.engine_no, asv.chassis_no, asv.plat_no from 
									dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code	= pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.item_code = qrd.item_code)
									left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
									where ssd.id								  = pod.supplier_selection_detail_id
								)asv
		where		grn.status				  IN('APPROVE', 'POST')
					and grnd.receive_quantity <> 0
					and isnull(podoi.id,0) not in (select isnull(invf.purchase_order_detail_object_info_id,0) from dbo.ap_invoice_registration_detail_faktur invf inner join dbo.ap_invoice_registration_detail a on a.id = invf.invoice_registration_detail_id inner join dbo.ap_invoice_registration b on a.invoice_register_code = b.code and isnull(b.status,'')  not in ('cancel','reject'))
					and grn.code not in (select invoice_or_gnr_no from dbo.list_data_cleansing_invoice_dan_monitoring_ap_sebelum_crpriority_naik)
					and
					(
						grn.code																																like '%' + @p_keywords + '%'
						or	grn.purchase_order_code																												like '%' + @p_keywords + '%'
						or	convert(varchar(30), grn.receive_date, 103)																							like '%' + @p_keywords + '%'
						or	grn.supplier_name																													like '%' + @p_keywords + '%'
						or	(datediff(day, grn.receive_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	grn.remark																															like '%' + @p_keywords + '%'
						or	grnd.item_name																														like '%' + @p_keywords + '%'
						or	case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 								like '%' + @p_keywords + '%'
						or	case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 							like '%' + @p_keywords + '%'
						or	case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 						like '%' + @p_keywords + '%'
						or	podoi.asset_code																													like '%' + @p_keywords + '%'
						or	grnd. price_amount																													like '%' + @p_keywords + '%'
						or	grnd.ppn_amount																														like '%' + @p_keywords + '%'
						or	grnd.pph_amount																														like '%' + @p_keywords + '%'
						or	grnd.discount_amount																												like '%' + @p_keywords + '%'
						or	(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)	like '%' + @p_keywords + '%'
					)

		select		grn.code
					,grn.company_code
					,grn.purchase_order_code
					,convert(varchar(30), grn.receive_date, 103)				  'receive_date'
					,grn.supplier_code
					,grn.supplier_name
					,grn.branch_code
					,grn.branch_name
					,grn.division_code
					,grn.division_name
					,grn.department_code
					,grn.department_name
					--,grn.remark
					,grn.status													  'grn_status'
					,grn.cover_note_status
					,(datediff(day, grn.receive_date, dbo.xfn_get_system_date())) 'aging'
					,grnd.item_name
					,case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 'plat_no'
					,case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 'engine_no'
					,case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 'chassis_no'
					,podoi.asset_code
					,grnd.price_amount 'total_unit_price'--detail.total_unit_price
					,grnd.ppn_amount 'total_ppn'--detail.total_ppn
					,grnd.pph_amount 'total_pph'--detail.total_pph
					,grnd.discount_amount
					,convert(decimal(18,2),(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)) 'total_grn' --detail.total_grn
					,podoi.id 'podoi_id'
					,@p_status 'status'
					,@rows_count												  'rowcount'
		from		good_receipt_note								 grn
					inner join dbo.good_receipt_note_detail			 grnd on (grn.code = grnd.good_receipt_note_code)
					left join dbo.purchase_order_detail_object_info podoi on (podoi.good_receipt_note_detail_id = grnd.id)
					--
					left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
					outer apply ( 
									select asv.engine_no, asv.chassis_no, asv.plat_no from 
									dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code = pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.item_code = qrd.item_code)
									left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
									where ssd.id = pod.supplier_selection_detail_id
								)asv
		where		grn.status				  IN('APPROVE', 'POST')
					and grnd.receive_quantity <> 0
					and isnull(podoi.id,0) not in (select isnull(invf.purchase_order_detail_object_info_id,0) from dbo.ap_invoice_registration_detail_faktur invf inner join dbo.ap_invoice_registration_detail a on a.id = invf.invoice_registration_detail_id inner join dbo.ap_invoice_registration b on a.invoice_register_code = b.code and isnull(b.status,'')  not in ('cancel','reject'))
					and grn.code not in (select invoice_or_gnr_no from dbo.list_data_cleansing_invoice_dan_monitoring_ap_sebelum_crpriority_naik)

					and
					(
						grn.code																																like '%' + @p_keywords + '%'
						or	grn.purchase_order_code																												like '%' + @p_keywords + '%'
						or	convert(varchar(30), grn.receive_date, 103)																							like '%' + @p_keywords + '%'
						or	grn.supplier_name																													like '%' + @p_keywords + '%'
						or	(datediff(day, grn.receive_date, dbo.xfn_get_system_date()))																		like '%' + @p_keywords + '%'
						or	grn.remark																															like '%' + @p_keywords + '%'
						or	grnd.item_name																														like '%' + @p_keywords + '%'
						or	case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'')end 								like '%' + @p_keywords + '%'
						or	case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'')end 							like '%' + @p_keywords + '%'
						or	case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'')end 						like '%' + @p_keywords + '%'
						or	podoi.asset_code																													like '%' + @p_keywords + '%'
						or	grnd. price_amount																													like '%' + @p_keywords + '%'
						or	grnd.ppn_amount																														like '%' + @p_keywords + '%'
						or	grnd.pph_amount																														like '%' + @p_keywords + '%'
						or	grnd.discount_amount																												like '%' + @p_keywords + '%'
						or	(grnd.price_amount - grnd.discount_amount) + (grnd.ppn_amount / grnd.receive_quantity) - (grnd.pph_amount / grnd.receive_quantity)	like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then grn.purchase_order_code
														 when 2 then cast(grn.receive_date as sql_variant)
														 when 3 then cast((datediff(day, grn.receive_date, dbo.xfn_get_system_date())) as sql_variant)
														 when 4 then grnd.item_name
														 when 5 then cast(grnd.price_amount as sql_variant)
														 when 6 then grn.supplier_name
														 when 7 then grn.REFF_NO
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														    when 1 then grn.purchase_order_code
															when 2 then cast(grn.receive_date as sql_variant)
															when 3 then cast((datediff(day, grn.receive_date, dbo.xfn_get_system_date())) as sql_variant)
															when 4 then grnd.item_name
															when 5 then cast(grnd.price_amount as sql_variant)
															when 6 then grn.supplier_name
															when 7 then grn.REFF_NO
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;

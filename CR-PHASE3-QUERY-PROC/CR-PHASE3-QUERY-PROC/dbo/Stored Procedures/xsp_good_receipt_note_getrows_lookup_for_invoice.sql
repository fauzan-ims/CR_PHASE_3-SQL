CREATE PROCEDURE dbo.xsp_good_receipt_note_getrows_lookup_for_invoice
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--,@p_purchase_order_code nvarchar(50)
	,@p_supplier_code		nvarchar(50)
	,@p_invoice_register_code nvarchar(50)
)
as
begin
	declare @rows_count		int = 0 
			,@item_name	    nvarchar(4000)
			,@spesification nvarchar(4000)
			
	select		@rows_count = count(1)
	from		good_receipt_note grn
				inner join dbo.good_receipt_note_detail grnd on grnd.good_receipt_note_code = grn.code
				inner join dbo.purchase_order po on (grn.purchase_order_code = po.code)
				inner join dbo.purchase_order_detail pod on (pod.po_code = po.code and pod.id = grnd.purchase_order_detail_id)
				inner join dbo.purchase_order_detail_object_info podoi on (podoi.purchase_order_detail_id = pod.id and podoi.good_receipt_note_detail_id = grnd.id)
				----
				outer apply ( 
						select asv.engine_no, asv.chassis_no, asv.plat_no 
						FROM 	dbo.supplier_selection_detail		ssd 
						left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
						left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
						left join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
						left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.procurement_request_item_id = pri.id)
						left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
						where ssd.id = pod.supplier_selection_detail_id
				)asv
	where		grn.supplier_code = @p_supplier_code
	and			grn.status in ('POST','APPROVE')
	and			isnull(podoi.id,0) not in (	select	isnull(invdf.purchase_order_detail_object_info_id,0)
									from	dbo.ap_invoice_registration_detail_faktur invdf
											inner join dbo.ap_invoice_registration_detail invd on invd.id = invdf.invoice_registration_detail_id
											inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
									where	inv.status not in ('cancel','reject'))
				and (
						grn.code												like '%' + @p_keywords + '%'
						or	pod.item_name										like '%' + @p_keywords + '%'
						or	po.code												like '%' + @p_keywords + '%'
						or	podoi.engine_no										like '%' + @p_keywords + '%'
						or	podoi.chassis_no									like '%' + @p_keywords + '%'
						or	podoi.plat_no										like '%' + @p_keywords + '%'
					)

	select		grn.code
				,convert(nvarchar(30), grn.receive_date, 103) 'receive_date'
				,grn.purchase_order_code
				,pod.item_name
				,case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'') end	'engine_no'
				,case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'') end	'chassis_no'
				,case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'') end	'plat_no'
				,po.code	'po_code'
				,podoi.id	'id_po_object' -- sepria 16092025: tambah ini agar bisa bayar per id object info po
				,@rows_count 'rowcount'
	from		good_receipt_note grn
				inner join dbo.good_receipt_note_detail grnd on grnd.good_receipt_note_code = grn.code
				inner join dbo.purchase_order po on (grn.purchase_order_code = po.code)
				inner join dbo.purchase_order_detail pod on (pod.po_code = po.code and pod.id = grnd.purchase_order_detail_id)
				inner join dbo.purchase_order_detail_object_info podoi on (podoi.purchase_order_detail_id = pod.id and podoi.good_receipt_note_detail_id = grnd.id)
				----
				outer apply ( 
						select asv.engine_no, asv.chassis_no, asv.plat_no 
						FROM 	dbo.supplier_selection_detail		ssd 
						left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
						left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
						left join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
						left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code and prc.procurement_request_item_id = pri.id)
						left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
						where ssd.id = pod.supplier_selection_detail_id
				)asv
	where		grn.supplier_code = @p_supplier_code
	and			grn.status in ('POST','APPROVE')
	and			isnull(podoi.id,0) not in (	select	isnull(invdf.purchase_order_detail_object_info_id,0)
									from	dbo.ap_invoice_registration_detail_faktur invdf
											inner join dbo.ap_invoice_registration_detail invd on invd.id = invdf.invoice_registration_detail_id
											inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
									where	inv.status not in ('cancel','reject'))
				and (
						grn.code												like '%' + @p_keywords + '%'
						or	pod.item_name										like '%' + @p_keywords + '%'
						or	po.code												like '%' + @p_keywords + '%'
						or	podoi.engine_no										like '%' + @p_keywords + '%'
						or	podoi.chassis_no									like '%' + @p_keywords + '%'
						or	podoi.plat_no										like '%' + @p_keywords + '%'
					)
					
	order by	 case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then grn.code
													 when 2 then po.code
													 when 3 then pod.item_name
													 when 4 then podoi.plat_no	
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then grn.code
													 when 2 then po.code
													 when 3 then pod.item_name
													 when 4 then podoi.plat_no
												 end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only


	--declare @grnlist table (	
	--							code			nvarchar(100) collate latin1_general_ci_as
	--							--,item_name		nvarchar(250)
	--							--,spesification	nvarchar(4000)
	--							--,id				bigint
	--							,receive_date	datetime
	--							,po_code		nvarchar(100)
	--							,item_name		VARCHAR(8000)--(4000)

	--						) 

	--insert into @grnlist
	--(
	--	code
	--	,receive_date
	--	,po_code
	--	,item_name
	--)
	--select  grn.code
	--		,grn.receive_date
	--		,grn.purchase_order_code
	--				--,grnd.item_name
	--				--,grnd.spesification
	--				--,grnd.id
	--				,stuff((
	--			  select	', ' + isnull(item_name,'')
	--			  from		dbo.good_receipt_note_detail
	--			  where		good_receipt_note_code = grn.code
	--			  for xml path('')
	--		  ), 1, 1, ''
	--		 )
	--from		good_receipt_note grn
	--inner join dbo.purchase_order po on (grn.purchase_order_code = po.code)
	--where		
	--			--purchase_order_code = @p_purchase_order_code
				
	--			--and (grn.CODE = 'DSF.GRN.2312.000234' 
	--			--or grn.CODE = 'DSF.GRN.2312.000301'
	--			--or isnull(grn.reff_no,'') = case when po.unit_from = 'BUY' then ''
	--			--						else isnull(grn.reff_no,'')
	--			--					end
	--			--and grn.status			= 'POST'
	--			----and grnd.receive_quantity <> 0
	--			--and grn.code not in
	--			--(
	--			--	select	ird.grn_code
	--			--	from	dbo.ap_invoice_registration_detail	   ird
	--			--			inner join dbo.ap_invoice_registration ir on ir.code = ird.invoice_register_code
	--			--	where	ir.supplier_code		  = @p_supplier_code
	--			--			and ir.status <> 'CANCEL'
	--			--			and po.unit_from = 'BUY'
	--			--	union
	--			--	select	ird.grn_code
	--			--	from	dbo.ap_invoice_registration_detail	   ird
	--			--			inner join dbo.ap_invoice_registration ir on ir.code = ird.invoice_register_code
	--			--	where	ir.supplier_code		  = @p_supplier_code
	--			--			and ir.status = 'HOLD'
	--			--			and po.unit_from = 'RENT'
							
	--			--))

	--			and isnull(grn.reff_no,'') = case when po.unit_from = 'BUY' then ''
	--									else isnull(grn.reff_no,'')
	--								end
	--			and grn.status			  IN('APPROVE', 'POST')
	--			--and grnd.receive_quantity <> 0
	--			and grn.code not in
	--			(
	--				select	ird.grn_code
	--				from	dbo.ap_invoice_registration_detail	   ird
	--						inner join dbo.ap_invoice_registration ir on ir.code = ird.invoice_register_code
	--				where	ir.supplier_code		  = @p_supplier_code
	--						and ir.status <> 'CANCEL'
	--						and po.unit_from = 'BUY'
	--				union
	--				select	ird.grn_code
	--				from	dbo.ap_invoice_registration_detail	   ird
	--						inner join dbo.ap_invoice_registration ir on ir.code = ird.invoice_register_code
	--				where	ir.supplier_code		  = @p_supplier_code
	--						and ir.status = 'HOLD'
	--						and po.unit_from = 'RENT'
							
	--			)
	--order by grn.code


	--select	@rows_count = count(1)
	--from		@grnlist g
	--			--outer apply (select grn.purchase_order_code from dbo.good_receipt_note grn where grn.CODE = g.code ) data
	--			outer apply (select grn.supplier_code from dbo.good_receipt_note grn where grn.CODE = g.code ) data 
	--where		
	--			--purchase_order_code = @p_purchase_order_code
	--			data.supplier_code = @p_supplier_code
	--and			(
	--				g.code												like '%' + @p_keywords + '%'
	--				or	g.item_name										like '%' + @p_keywords + '%'
	--				or	convert(nvarchar(30), g.receive_date, 103) 		like '%' + @p_keywords + '%'
	--				or	g.po_code										like '%' + @p_keywords + '%'
	--			) ;

	--select		
	--			g.code
	--			,g.item_name
	--			,convert(nvarchar(30), g.receive_date, 103) 'receive_date'
	--			,g.po_code
	--			,@rows_count	'rowcount'
	--from		@grnlist g
	--			--outer apply (select purchase_order_code  from dbo.good_receipt_note grn where grn.CODE = g.code ) data
	--			outer apply (select grn.supplier_code  from dbo.good_receipt_note grn where grn.CODE = g.code ) data
	--where		
	--			--purchase_order_code = @p_purchase_order_code
	--			data.supplier_code = @p_supplier_code
	--			and (
	--					g.code												like '%' + @p_keywords + '%'
	--					or	g.item_name										like '%' + @p_keywords + '%'
	--					or	convert(nvarchar(30), g.receive_date, 103) 		like '%' + @p_keywords + '%'
	--					or	g.po_code										like '%' + @p_keywords + '%'
	--				)
					
	--order by	 case
	--				when @p_sort_by = 'asc' then case @p_order_by
	--												 when 1 then g.code
	--												 when 2 then cast(g.receive_date as sql_variant)
	--												 when 3 then g.po_code
	--												 when 4 then g.item_name
	--											 end
	--			end asc
	--			,case
	--				 when @p_sort_by = 'desc' then case @p_order_by
	--												 when 1 then g.code
	--												 when 2 then cast(g.receive_date as sql_variant)
	--												 when 3 then g.po_code
	--												 when 4 then g.item_name
	--											   end
	--			 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only
				 
				  
end ;
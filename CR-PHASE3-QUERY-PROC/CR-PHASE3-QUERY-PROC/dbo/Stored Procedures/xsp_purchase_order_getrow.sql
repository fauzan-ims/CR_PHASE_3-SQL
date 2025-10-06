CREATE procedure dbo.xsp_purchase_order_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare @print_po		   nvarchar(15)
			,@print_kuasa	   nvarchar(15)
			,@print_mobilisasi nvarchar(1) ;

	-- (+) Ari 2024-03-15 ket : penambahan, req ayub : jika terdapat type asset walau terdapat selain asset maka report yg tampil tetap report po
	if exists
	(
		select	isnull(pri.category_type, pri2.category_type)
		from	dbo.purchase_order_detail				pod
				left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.SUPPLIER_SELECTION_DETAIL_ID)
				left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
				left join dbo.procurement				prc on (prc.code collate latin1_general_ci_as = qrd.reff_no)
				left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
				left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
				left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
				left join dbo.procurement_request_item	pri on (pri.procurement_request_code		  = pr.code)
				left join dbo.procurement_request_item	pri2 on (pri2.procurement_request_code		  = pr2.code)
		where	pod.po_code = @p_code
				and isnull(pri.category_type, pri2.category_type) in
	(
		'ASSET'
	)
	)
	begin
		set @print_po = N'ASSET' ;
	end ;
	-- (+) Ari 2024-03-15
	else if exists
	(
		--select	1
		--from	purchase_order							po
		--		left join dbo.purchase_order_detail		pod on (pod.po_code							  = po.code)
		--		left join dbo.supplier_selection		ss on (ss.code								  = po.reff_no)
		--		--
		select	1
		from	dbo.purchase_order_detail				pod
				left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.SUPPLIER_SELECTION_DETAIL_ID)
				left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
				left join dbo.procurement				prc on (prc.code collate latin1_general_ci_as = qrd.reff_no)
				left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
				left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
				left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
				left join dbo.procurement_request_item	pri on (pri.procurement_request_code		  = pr.code)
				left join dbo.procurement_request_item	pri2 on (pri2.procurement_request_code		  = pr2.code)
		where	pod.po_code = @p_code
				and isnull(pri.category_type, pri2.category_type) in
		 (
			 'ACCESSORIES', 'KAROSERI', 'MOBILISASI'
		 )
	)
	begin
		set @print_po = N'KAROSERI' ;

		if exists
		(
			select	1
			from	dbo.purchase_order_detail				pod
					left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.SUPPLIER_SELECTION_DETAIL_ID)
					left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
					left join dbo.procurement				prc on (prc.code collate latin1_general_ci_as = qrd.reff_no)
					left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
					left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
					left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
					left join dbo.procurement_request_item	pri on (pri.procurement_request_code		  = pr.code)
					left join dbo.procurement_request_item	pri2 on (pri2.procurement_request_code		  = pr2.code)
			where	pod.po_code = @p_code
					and isnull(pri.category_type, pri2.category_type) in
		(
			'MOBILISASI'
		)
		)
		begin
			set @print_mobilisasi = N'1' ;
		end ;
		else
			set @print_mobilisasi = N'0' ;
	end ;
	else
	begin
		set @print_po = N'ASSET' ;
	end ;

	if exists
	(
		select	distinct
				1
		from	purchase_order						   po
				left join dbo.purchase_order_detail	   pod on (pod.po_code	= po.code)
				left join dbo.PROCUREMENT_REQUEST_ITEM pri on pri.ITEM_CODE = pod.ITEM_CODE
		where	po.code = @p_code
				and pri.CATEGORY_TYPE in
	(
		'ASSET'
	)
	)
	begin
		set @print_kuasa = N'1' ;
	end ;
	else
	begin
		set @print_kuasa = N'0' ;
	end ;

	select	distinct
			po.code
			,po.company_code
			,po.order_date
			,po.supplier_code
			,po.supplier_name
			,po.branch_code
			,po.branch_name
			,po.division_code
			,po.division_name
			,po.department_code
			,po.department_name
			,po.payment_methode_code
			,po.payment_methode_name
			,po.currency_code
			,po.currency_name
			,po.order_type_code
			,po.total_amount
			,po.ppn_amount
			,po.pph_amount
			,po.payment_by
			,po.receipt_by
			,po.is_termin
			,po.unit_from
			,po.flag_process
			,po.status
			,po.remark
			,po.reff_no
			,pod.order_remaining
			,pod.order_quantity
			,po.eta_date
			,po.supplier_address
			,ss.quotation_code
			,isnull(pr.procurement_type, pr2.procurement_type) 'procurement_type'
			,@print_po										   'print_type'
			,po.is_spesific_address
			,po.delivery_name
			,po.delivery_address
			,@print_kuasa									   'print_kuasa'
			,@print_mobilisasi								   'print_mobilisasi'
	from	purchase_order							po
			left join dbo.purchase_order_detail		pod on (pod.po_code							  = po.code)
			left join dbo.supplier_selection		ss on (ss.code								  = po.reff_no)
			--
			left join dbo.supplier_selection_detail ssd on (ssd.selection_code					  = ss.code)
			left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
			left join dbo.procurement				prc on (prc.code collate latin1_general_ci_as = qrd.reff_no)
			left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
			left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
			left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
	where	po.code = @p_code ;
end ;

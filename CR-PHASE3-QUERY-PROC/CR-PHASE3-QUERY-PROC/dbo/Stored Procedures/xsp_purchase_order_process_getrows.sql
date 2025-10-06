
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_purchase_order_process_getrows]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50)
	,@p_status		 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	supplier_selection ss
			left join dbo.supplier_selection_detail ssd on (ssd.selection_code	= ss.code)
			left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
			left join dbo.procurement				prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
			left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
			left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
			left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
	where	ss.company_code	   = @p_company_code
			--and ss.status	   = 'APPROVE'
			and	ssd.supplier_selection_detail_status = case @p_status
															when 'ALL' then ssd.supplier_selection_detail_status
															else @p_status
														end
			and ssd.SUPPLIER_SELECTION_DETAIL_STATUS in ('HOLD', 'POST', 'CANCEL')
			and (
					ss.code														like '%' + @p_keywords + '%'
					or	convert(varchar(30), ss.selection_date, 103)			like '%' + @p_keywords + '%'
					or	ssd.item_name											like '%' + @p_keywords + '%'
					or	ssd.supplier_name										like '%' + @p_keywords + '%'
					or	ssd.quantity											like '%' + @p_keywords + '%'
					or	ssd.amount												like '%' + @p_keywords + '%'
					or	ssd.total_amount										like '%' + @p_keywords + '%'
					or	ssd.pph_amount											like '%' + @p_keywords + '%'
					or	ssd.ppn_amount											like '%' + @p_keywords + '%'
					or	ssd.remark												like '%' + @p_keywords + '%'
					or	ssd.supplier_selection_detail_status					like '%' + @p_keywords + '%'
					or	ssd.discount_amount										like '%' + @p_keywords + '%'
					or	ssd.unit_from											like '%' + @p_keywords + '%'
					or	ssd.spesification										like '%' + @p_keywords + '%'
					or	isnull(pr.procurement_type, pr2.procurement_type)		like '%' + @p_keywords + '%'
					or	case 
							when isnull(pr.asset_no, pr2.asset_no) <> '' then 'OPL'
							else 'MANUAL'
						end														like '%' + @p_keywords + '%'
					or	ssd.bbn_name											like '%' + @p_keywords + '%'
					or	ssd.bbn_location										like '%' + @p_keywords + '%'
					or	ssd.bbn_address											like '%' + @p_keywords + '%'
					or	ssd.deliver_to_address									like '%' + @p_keywords + '%'
				) ;

	select		ss.code
				,ss.company_code
				,ss.quotation_code
				,convert(varchar(30), ss.selection_date, 103) 'selection_date'
				,ss.branch_code
				,ss.branch_name
				,ss.division_code
				,ss.division_name
				,ss.department_code
				,ss.department_name
				,ss.status
				,ssd.remark
				,ssd.id
				,ssd.quotation_quantity
				,ssd.quantity						'quantity_po'
				,ssd.amount							'price_amount'
				,ssd.supplier_code					'supplier_code_po'
				,ssd.supplier_name					'supplier_name_po'
				,ssd.item_name						'item_name_po'
				,ssd.total_amount					'total_amount'
				,ssd.pph_amount
				,ssd.ppn_amount
				,ssd.supplier_selection_detail_status
				,ssd.discount_amount 
				,ssd.unit_from
				,ssd.spesification
				,isnull(pr.procurement_type, pr2.procurement_type) 'procurement_type'
				,case 
					when isnull(pr.asset_no, pr2.asset_no) <> '' then 'OPL'
					else 'MANUAL'
				end 'manual_opl'
				,ssd.bbn_name
				,ssd.bbn_location
				,ssd.bbn_address
				,ssd.deliver_to_address
				,@rows_count 'rowcount'
	from		supplier_selection ss
				left join dbo.supplier_selection_detail ssd on (ssd.selection_code	= ss.code)
				left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
				left join dbo.procurement				prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
				left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
				left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
				left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
	where		ss.company_code	   = @p_company_code
				--and ss.status	   = 'APPROVE'
				and	ssd.supplier_selection_detail_status = case @p_status
															when 'ALL' then ssd.supplier_selection_detail_status
															else @p_status
														end
				and ssd.SUPPLIER_SELECTION_DETAIL_STATUS in ('HOLD', 'POST', 'CANCEL')
				and (
						ss.code														like '%' + @p_keywords + '%'
						or	convert(varchar(30), ss.selection_date, 103)			like '%' + @p_keywords + '%'
						or	ssd.item_name											like '%' + @p_keywords + '%'
						or	ssd.supplier_name										like '%' + @p_keywords + '%'
						or	ssd.quantity											like '%' + @p_keywords + '%'
						or	ssd.amount												like '%' + @p_keywords + '%'
						or	ssd.total_amount										like '%' + @p_keywords + '%'
						or	ssd.pph_amount											like '%' + @p_keywords + '%'
						or	ssd.ppn_amount											like '%' + @p_keywords + '%'
						or	ssd.remark												like '%' + @p_keywords + '%'
						or	ssd.supplier_selection_detail_status					like '%' + @p_keywords + '%'
						or	ssd.discount_amount										like '%' + @p_keywords + '%'
						or	ssd.unit_from											like '%' + @p_keywords + '%'
						or	ssd.spesification										like '%' + @p_keywords + '%'
						or	isnull(pr.procurement_type, pr2.procurement_type)		like '%' + @p_keywords + '%'
						or	case 
								when isnull(pr.asset_no, pr2.asset_no) <> '' then 'OPL'
								else 'MANUAL'
							end														like '%' + @p_keywords + '%'
						or	ssd.bbn_name											like '%' + @p_keywords + '%'
						or	ssd.bbn_location										like '%' + @p_keywords + '%'
						or	ssd.bbn_address											like '%' + @p_keywords + '%'
						or	ssd.deliver_to_address									like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ss.code
													 when 2 then cast(ss.selection_date as sql_variant)
													 when 3 then ssd.item_name
													 when 4 then ssd.quantity
													 when 5 then cast(ssd.amount as sql_variant) -- + cast(ssd.discount_amount as sql_variant)
													 when 6 then cast(ssd.pph_amount as sql_variant)
													 when 7 then ssd.remark
													 when 8 then ssd.bbn_name
													 when 9 then ssd.deliver_to_address
													 when 10 then ssd.supplier_selection_detail_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ss.code
													 when 2 then cast(ss.selection_date as sql_variant)
													 when 3 then ssd.item_name
													 when 4 then ssd.quantity
													 when 5 then cast(ssd.amount as sql_variant) -- + cast(ssd.discount_amount as sql_variant)
													 when 6 then cast(ssd.pph_amount as sql_variant)
													 when 7 then ssd.remark
													 when 8 then ssd.bbn_name
													 when 9 then ssd.deliver_to_address
													 when 10 then ssd.supplier_selection_detail_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

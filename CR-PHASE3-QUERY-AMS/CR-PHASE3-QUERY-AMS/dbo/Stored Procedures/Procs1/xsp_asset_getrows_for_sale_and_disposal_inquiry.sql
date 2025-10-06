CREATE PROCEDURE dbo.xsp_asset_getrows_for_sale_and_disposal_inquiry
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_branch_code			nvarchar(50)
	,@p_company_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	asset ass
			left join dbo.sys_general_subcode sgs on (ass.type_code = sgs.code) and (sgs.company_code = ass.company_code)
	where	ass.branch_code = case @p_branch_code
									when 'ALL' then ass.branch_code
									else @p_branch_code
								end
	and		ass.company_code = @p_company_code
	and		ass.status = 'STOCK'
	and		(
				ass.code					like '%' + @p_keywords + '%'
				or	ass.barcode				like '%' + @p_keywords + '%'
				or	ass.purchase_date		like '%' + @p_keywords + '%'
				or	ass.category_name		like '%' + @p_keywords + '%'
				or	item_name				like '%' + @p_keywords + '%'
				or	sgs.description			like '%' + @p_keywords + '%'
				or	ass.branch_name			like '%' + @p_keywords + '%'
				or	ass.pic_name			like '%' + @p_keywords + '%'
				or	ass.status				like '%' + @p_keywords + '%'
				or	ass.fisical_status		like '%' + @p_keywords + '%'
			) ;

	select ass.code
				,ass.company_code
				,item_code
				,item_name
				,barcode
				,ass.status
				,po_no
				,requestor_code
				,requestor_name
				,vendor_code
				,vendor_name
				,type_code
				,sgs.description 'description_type'
				,category_code
				,convert(nvarchar(30), purchase_date, 103) 'purchase_date'
				,purchase_price
				,invoice_no
				,invoice_date
				,original_price
				,sale_amount
				,sale_date
				,disposal_date
				,ass.branch_code
				,ass.branch_name
				,division_code
				,division_name
				,department_code
				,department_name
				,pic_code
				,ass.pic_name
				,residual_value
				,depre_category_comm_code
				,total_depre_comm
				,depre_period_comm
				,net_book_value_comm
				,depre_category_fiscal_code
				,total_depre_fiscal
				,depre_period_fiscal
				,net_book_value_fiscal
				,remarks
				,ass.category_code
				,ass.category_name
				,ass.fisical_status
				,ass.rental_status
				,ass.is_permit_to_sell
				,@rows_count 'rowcount'
	from		asset ass
				left join dbo.sys_general_subcode sgs on (ass.type_code = sgs.code) and (sgs.company_code = ass.company_code)
	where		ass.branch_code = case @p_branch_code
									when 'ALL' then ass.branch_code
									else @p_branch_code
								end
	and			ass.company_code = @p_company_code
	and			ass.status = 'STOCK'
	and				(
						ass.code											like '%' + @p_keywords + '%'
						or	ass.branch_name									like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), purchase_date, 103)		like '%' + @p_keywords + '%'
						or	ass.category_name								like '%' + @p_keywords + '%'
						or	item_name										like '%' + @p_keywords + '%'
						or	sgs.description									like '%' + @p_keywords + '%'
						or	ass.status										like '%' + @p_keywords + '%'
						or	ass.fisical_status								like '%' + @p_keywords + '%'
						or	ass.rental_status								like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.branch_name
													 when 3 then cast(ass.purchase_date as sql_variant)
													 when 4 then ass.category_name
													 when 5 then ass.item_name
													 when 6 then sgs.description
													 when 7 then status
													 when 8 then ass.fisical_status
													 when 9 then ass.rental_status
												 end
				end ASC
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.branch_name
													 when 3 then cast(ass.purchase_date as sql_variant)
													 when 4 then ass.category_name
													 when 5 then ass.item_name
													 when 6 then sgs.description
													 when 7 then status
													 when 8 then ass.fisical_status
													 when 9 then ass.rental_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

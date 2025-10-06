
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_asset_getrows]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)
	,@p_status				nvarchar(20)
	,@p_company_code		nvarchar(50)
	,@p_type_code			nvarchar(15)
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
	left join dbo.asset_vehicle vhcl on (ass.code = vhcl.asset_code)
	where	ass.branch_code = case @p_branch_code
									when 'ALL' then ass.branch_code
									else @p_branch_code
								end	
	and     status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		ass.type_code = case @p_type_code
								when 'ALL' then	ass.type_code
								else @p_type_code
							end 
	and		ass.company_code = @p_company_code
	and		isnull(ass.is_final_grn,'1') = '1' -- (14042025: sepria - tambah kondisi ini jika asset terbentuk dari grn tp belum fgrn
	and		(
				ass.code											like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), purchase_date, 103)		like '%' + @p_keywords + '%'
				or	ass.item_name									like '%' + @p_keywords + '%'
				or	ass.branch_name									like '%' + @p_keywords + '%'
				or	ass.pic_name									like '%' + @p_keywords + '%'
				or	ass.status										like '%' + @p_keywords + '%'
				or	ass.fisical_status								like '%' + @p_keywords + '%'
				or	ass.rental_status								like '%' + @p_keywords + '%'
				or	ass.remarks										like '%' + @p_keywords + '%'
				or	ass.agreement_external_no						like '%' + @p_keywords + '%'
				or	ass.client_name									like '%' + @p_keywords + '%'
				or	ass.process_status								like '%' + @p_keywords + '%'
				or	vhcl.engine_no									like '%' + @p_keywords + '%'
				or	vhcl.plat_no									like '%' + @p_keywords + '%'
				or	vhcl.chassis_no									like '%' + @p_keywords + '%'
				or	vhcl.built_year									like '%' + @p_keywords + '%'
				or	vhcl.colour										like '%' + @p_keywords + '%'
				or	ass.last_meter									like '%' + @p_keywords + '%'
				or	ass.parking_location							like '%' + @p_keywords + '%'
				or	ass.unit_city_name								like '%' + @p_keywords + '%'
				or	ass.posting_date								like '%' + @p_keywords + '%'
			) ;

	select ass.code
				,ass.company_code
				,item_code
				,item_name
				,barcode
				,case ass.STATUS	
					when 'AVAILABLEONREPAIR' then 'AVAILABLE - ONREPAIR'
					when 'INVALIDEXPENSE' then 'INVALID - EXPENSE'
					when 'INVALIDINVENTORY' then 'INVALID - INVENTORY'
					else ass.status
				end 'status'
				,po_no
				,requestor_code
				,requestor_name
				,vendor_code
				,vendor_name
				,type_code
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
				,ass.asset_purpose
				,ass.agreement_external_no 'agreement_no'
				,ass.client_name
				,vhcl.plat_no
				,vhcl.engine_no
				,vhcl.chassis_no
				,ass.process_status
				,vhcl.built_year
				,vhcl.colour
				,ass.last_meter
				,ass.parking_location
				,ass.unit_city_name
				,convert(nvarchar(30), posting_date, 103) 'posting_date'
				,@rows_count 'rowcount'
	from		asset ass
	left join dbo.asset_vehicle vhcl on (ass.code = vhcl.asset_code)
	where		ass.branch_code = case @p_branch_code
									when 'ALL' then ass.branch_code
									else @p_branch_code
								end	
	and			status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and			ass.type_code = case @p_type_code
									when 'ALL' then	ass.type_code
									else @p_type_code
								end 
	and			ass.company_code = @p_company_code
	and			isnull(ass.is_final_grn,'1') = '1' -- (14042025: sepria - tambah kondisi ini jika asset terbentuk dari grn tp belum fgrn
	and				(
						ass.code											like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), purchase_date, 103)		like '%' + @p_keywords + '%'
						or	ass.item_name									like '%' + @p_keywords + '%'
						or	ass.branch_name									like '%' + @p_keywords + '%'
						or	ass.pic_name									like '%' + @p_keywords + '%'
						or	ass.status										like '%' + @p_keywords + '%'
						or	ass.fisical_status								like '%' + @p_keywords + '%'
						or	ass.rental_status								like '%' + @p_keywords + '%'
						or	ass.remarks										like '%' + @p_keywords + '%'
						or	ass.agreement_external_no						like '%' + @p_keywords + '%'
						or	ass.client_name									like '%' + @p_keywords + '%'
						or	ass.process_status								like '%' + @p_keywords + '%'
						or	vhcl.engine_no									like '%' + @p_keywords + '%'
						or	vhcl.plat_no									like '%' + @p_keywords + '%'
						or	vhcl.chassis_no									like '%' + @p_keywords + '%'
						or	vhcl.built_year									like '%' + @p_keywords + '%'
						or	vhcl.colour										like '%' + @p_keywords + '%'
						or	ass.last_meter									like '%' + @p_keywords + '%'
						or	ass.parking_location							like '%' + @p_keywords + '%'
						or	ass.unit_city_name								like '%' + @p_keywords + '%'
						or	ass.posting_date								like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.code + ass.branch_name
													 when 3 then cast(ass.purchase_date as sql_variant)
													 when 4 then ass.item_name + vhcl.colour + vhcl.built_year
													 when 5 then vhcl.plat_no + vhcl.engine_no + vhcl.chassis_no + ass.last_meter
													 when 6 then ass.agreement_external_no + ass.client_name
													 when 7 then status
													 when 8 then ass.rental_status
													 when 9 then ass.parking_location + ass.unit_city_name
													 when 10 then ass.remarks
												 end
				end ASC
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then ass.code
													when 2 then ass.code + ass.branch_name
													when 3 then cast(ass.purchase_date as sql_variant)
													when 4 then ass.item_name + vhcl.colour + vhcl.built_year
													when 5 then vhcl.plat_no + vhcl.engine_no + vhcl.chassis_no + ass.last_meter
													when 6 then ass.agreement_external_no + ass.client_name
													when 7 then status
													when 8 then ass.rental_status
													when 9 then ass.parking_location + ass.unit_city_name
													when 10 then ass.remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

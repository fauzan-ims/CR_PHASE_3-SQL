CREATE PROCEDURE dbo.xsp_efam_interface_asset_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)
	,@p_location_code		nvarchar(50)
	,@p_status				nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	efam_interface_asset ass
	left join dbo.sys_general_subcode sgs on (ass.type_code = sgs.code)
	where	ass.branch_code		  = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end
	and		ass.location_code	  = case @p_location_code
										when 'ALL' then ass.location_code
										else @p_location_code
									end
	and		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		(
				ass.code						 like '%' + @p_keywords + '%'
				or	ass.company_code			 like '%' + @p_keywords + '%'
				or	item_code					 like '%' + @p_keywords + '%'
				or	item_name					 like '%' + @p_keywords + '%'
				or	ass.barcode					 like '%' + @p_keywords + '%'
				or	ass.location_code			 like '%' + @p_keywords + '%'
				or	ass.branch_name				 like '%' + @p_keywords + '%'
				or	status						 like '%' + @p_keywords + '%'
				or	po_no						 like '%' + @p_keywords + '%'
				or	type_code					 like '%' + @p_keywords + '%'
				or	sgs.description				 like '%' + @p_keywords + '%'
			) ;

	select		ass.code
				,ass.company_code
				,item_code
				,item_name
				,barcode
				,status
				,po_no
				,requestor_code
				,requestor_name
				,vendor_code
				,vendor_name
				,type_code
				,sgs.description 'description_type'
				,category_code
				,purchase_date
				,purchase_price
				,invoice_no
				,invoice_date
				,original_price
				,sale_amount
				,sale_date
				,disposal_date
				,ass.branch_code
				,ass.branch_name
				,location_code
				,division_code
				,division_name
				,department_code
				,department_name
				,sub_department_code
				,sub_department_name
				,units_code
				,units_name
				,pic_code
				,residual_value
				,depre_category_comm_code
				,total_depre_comm
				,depre_period_comm
				,net_book_value_comm
				,depre_category_fiscal_code
				,total_depre_fiscal
				,depre_period_fiscal
				,net_book_value_fiscal
				,contractor_name
				,contractor_address
				,contractor_email
				,contractor_pic
				,contractor_pic_phone
				,contractor_start_date
				,contractor_end_date
				,warranty
				,warranty_start_date
				,warranty_end_date
				,remarks_warranty
				,case is_maintenance
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_maintenance'
				,maintenance_time
				,maintenance_type
				,maintenance_cycle_time
				,maintenance_start_date
				,remarks
				,@rows_count 'rowcount'
	from		efam_interface_asset ass
	left join dbo.sys_general_subcode sgs on (ass.type_code = sgs.code)
	where		ass.branch_code		  = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end
	and		ass.location_code	  = case @p_location_code
										when 'ALL' then ass.location_code
										else @p_location_code
									end
	and		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and			(
					ass.code						 like '%' + @p_keywords + '%'
					or	ass.company_code			 like '%' + @p_keywords + '%'
					or	item_code					 like '%' + @p_keywords + '%'
					or	item_name					 like '%' + @p_keywords + '%'
					or	ass.branch_name				 like '%' + @p_keywords + '%'
					or	ass.barcode					 like '%' + @p_keywords + '%'
					or	ass.location_code			 like '%' + @p_keywords + '%'
					or	status						 like '%' + @p_keywords + '%'
					or	po_no						 like '%' + @p_keywords + '%'
					or	type_code					 like '%' + @p_keywords + '%'
					or	sgs.description				 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then item_code
													 when 3 then po_no
													 when 4 then type_code
													 when 5 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then item_code
													 when 3 then po_no
													 when 4 then type_code
													 when 5 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

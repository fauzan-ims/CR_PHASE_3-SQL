CREATE PROCEDURE dbo.xsp_asset_history_getrows
(
	@p_keywords	nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by	nvarchar(5)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	asset_history
	where	(
		code		like 	'%'+@p_keywords+'%'
	or	company_code		like 	'%'+@p_keywords+'%'
	or	item_code		like 	'%'+@p_keywords+'%'
	or	item_name		like 	'%'+@p_keywords+'%'
	or	condition		like 	'%'+@p_keywords+'%'
	or	barcode		like 	'%'+@p_keywords+'%'
	or	cost_center_code		like 	'%'+@p_keywords+'%'
	or	cost_center_name		like 	'%'+@p_keywords+'%'
	or	status		like 	'%'+@p_keywords+'%'
	or	po_no		like 	'%'+@p_keywords+'%'
	or	requestor_code		like 	'%'+@p_keywords+'%'
	or	requestor_name		like 	'%'+@p_keywords+'%'
	or	vendor_code		like 	'%'+@p_keywords+'%'
	or	vendor_name		like 	'%'+@p_keywords+'%'
	or	type_code		like 	'%'+@p_keywords+'%'
	or	category_code		like 	'%'+@p_keywords+'%'
	or	category_name		like 	'%'+@p_keywords+'%'
	or	po_date		like 	'%'+@p_keywords+'%'
	or	purchase_date		like 	'%'+@p_keywords+'%'
	or	purchase_price		like 	'%'+@p_keywords+'%'
	or	invoice_no		like 	'%'+@p_keywords+'%'
	or	invoice_date		like 	'%'+@p_keywords+'%'
	or	original_price		like 	'%'+@p_keywords+'%'
	or	sale_amount		like 	'%'+@p_keywords+'%'
	or	sale_date		like 	'%'+@p_keywords+'%'
	or	disposal_date		like 	'%'+@p_keywords+'%'
	or	branch_code		like 	'%'+@p_keywords+'%'
	or	branch_name		like 	'%'+@p_keywords+'%'
	or	location_code		like 	'%'+@p_keywords+'%'
	or	location_name		like 	'%'+@p_keywords+'%'
	or	division_code		like 	'%'+@p_keywords+'%'
	or	division_name		like 	'%'+@p_keywords+'%'
	or	department_code		like 	'%'+@p_keywords+'%'
	or	department_name		like 	'%'+@p_keywords+'%'
	or	sub_department_code		like 	'%'+@p_keywords+'%'
	or	sub_department_name		like 	'%'+@p_keywords+'%'
	or	units_code		like 	'%'+@p_keywords+'%'
	or	units_name		like 	'%'+@p_keywords+'%'
	or	pic_code		like 	'%'+@p_keywords+'%'
	or	pic_name		like 	'%'+@p_keywords+'%'
	or	residual_value		like 	'%'+@p_keywords+'%'
		or	 case is_depre
			 when '1' then 'YES'
			 else 'NO'
		 end 		like 	'%'+@p_keywords+'%'

	or	depre_category_comm_code		like 	'%'+@p_keywords+'%'
	or	total_depre_comm		like 	'%'+@p_keywords+'%'
	or	depre_period_comm		like 	'%'+@p_keywords+'%'
	or	net_book_value_comm		like 	'%'+@p_keywords+'%'
	or	depre_category_fiscal_code		like 	'%'+@p_keywords+'%'
	or	total_depre_fiscal		like 	'%'+@p_keywords+'%'
	or	depre_period_fiscal		like 	'%'+@p_keywords+'%'
	or	net_book_value_fiscal		like 	'%'+@p_keywords+'%'
		or	 case is_rental
			 when '1' then 'YES'
			 else 'NO'
		 end 		like 	'%'+@p_keywords+'%'

	or	opl_code		like 	'%'+@p_keywords+'%'
	or	rental_date		like 	'%'+@p_keywords+'%'
	or	contractor_name		like 	'%'+@p_keywords+'%'
	or	contractor_address		like 	'%'+@p_keywords+'%'
	or	contractor_email		like 	'%'+@p_keywords+'%'
	or	contractor_pic		like 	'%'+@p_keywords+'%'
	or	contractor_pic_phone		like 	'%'+@p_keywords+'%'
	or	contractor_start_date		like 	'%'+@p_keywords+'%'
	or	contractor_end_date		like 	'%'+@p_keywords+'%'
	or	warranty		like 	'%'+@p_keywords+'%'
	or	warranty_start_date		like 	'%'+@p_keywords+'%'
	or	warranty_end_date		like 	'%'+@p_keywords+'%'
	or	remarks_warranty		like 	'%'+@p_keywords+'%'
		or	 case is_maintenance
			 when '1' then 'YES'
			 else 'NO'
		 end 		like 	'%'+@p_keywords+'%'

	or	maintenance_time		like 	'%'+@p_keywords+'%'
	or	maintenance_type		like 	'%'+@p_keywords+'%'
	or	maintenance_cycle_time		like 	'%'+@p_keywords+'%'
	or	maintenance_start_date		like 	'%'+@p_keywords+'%'
	or	use_life		like 	'%'+@p_keywords+'%'
	or	last_meter		like 	'%'+@p_keywords+'%'
	or	last_service_date		like 	'%'+@p_keywords+'%'
	or	pph		like 	'%'+@p_keywords+'%'
	or	ppn		like 	'%'+@p_keywords+'%'
	or	remarks		like 	'%'+@p_keywords+'%'
	or	last_so_date		like 	'%'+@p_keywords+'%'
	or	last_so_condition		like 	'%'+@p_keywords+'%'
	or	regional_code		like 	'%'+@p_keywords+'%'
	or	regional_name		like 	'%'+@p_keywords+'%'
	or	last_used_by_code		like 	'%'+@p_keywords+'%'
	or	last_used_by_name		like 	'%'+@p_keywords+'%'
	or	last_location_code		like 	'%'+@p_keywords+'%'
	or	last_location_name		like 	'%'+@p_keywords+'%'
		);
		select	code
			,company_code
			,item_code
			,item_name
			,condition
			,barcode
			,cost_center_code
			,cost_center_name
			,status
			,po_no
			,requestor_code
			,requestor_name
			,vendor_code
			,vendor_name
			,type_code
			,category_code
			,category_name
			,po_date
			,purchase_date
			,purchase_price
			,invoice_no
			,invoice_date
			,original_price
			,sale_amount
			,sale_date
			,disposal_date
			,branch_code
			,branch_name
			,location_code
			,location_name
			,division_code
			,division_name
			,department_code
			,department_name
			,sub_department_code
			,sub_department_name
			,units_code
			,units_name
			,pic_code
			,pic_name
			,residual_value
				 ,case is_depre
				 when '1' then 'YES'
				 else 'NO'
			 end 	'is_depre'
			,depre_category_comm_code
			,total_depre_comm
			,depre_period_comm
			,net_book_value_comm
			,depre_category_fiscal_code
			,total_depre_fiscal
			,depre_period_fiscal
			,net_book_value_fiscal
				 ,case is_rental
				 when '1' then 'YES'
				 else 'NO'
			 end 	'is_rental'
			,opl_code
			,rental_date
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
			 end 	'is_maintenance'
			,maintenance_time
			,maintenance_type
			,maintenance_cycle_time
			,maintenance_start_date
			,use_life
			,last_meter
			,last_service_date
			,pph
			,ppn
			,remarks
			,last_so_date
			,last_so_condition
			,regional_code
			,regional_name
			,last_used_by_code
			,last_used_by_name
			,last_location_code
			,last_location_name
			,@rows_count	 'rowcount'
		from	asset_history
		where	(
		code		like 	'%'+@p_keywords+'%'
	or	company_code		like 	'%'+@p_keywords+'%'
	or	item_code		like 	'%'+@p_keywords+'%'
	or	item_name		like 	'%'+@p_keywords+'%'
	or	condition		like 	'%'+@p_keywords+'%'
	or	barcode		like 	'%'+@p_keywords+'%'
	or	cost_center_code		like 	'%'+@p_keywords+'%'
	or	cost_center_name		like 	'%'+@p_keywords+'%'
	or	status		like 	'%'+@p_keywords+'%'
	or	po_no		like 	'%'+@p_keywords+'%'
	or	requestor_code		like 	'%'+@p_keywords+'%'
	or	requestor_name		like 	'%'+@p_keywords+'%'
	or	vendor_code		like 	'%'+@p_keywords+'%'
	or	vendor_name		like 	'%'+@p_keywords+'%'
	or	type_code		like 	'%'+@p_keywords+'%'
	or	category_code		like 	'%'+@p_keywords+'%'
	or	category_name		like 	'%'+@p_keywords+'%'
	or	po_date		like 	'%'+@p_keywords+'%'
	or	purchase_date		like 	'%'+@p_keywords+'%'
	or	purchase_price		like 	'%'+@p_keywords+'%'
	or	invoice_no		like 	'%'+@p_keywords+'%'
	or	invoice_date		like 	'%'+@p_keywords+'%'
	or	original_price		like 	'%'+@p_keywords+'%'
	or	sale_amount		like 	'%'+@p_keywords+'%'
	or	sale_date		like 	'%'+@p_keywords+'%'
	or	disposal_date		like 	'%'+@p_keywords+'%'
	or	branch_code		like 	'%'+@p_keywords+'%'
	or	branch_name		like 	'%'+@p_keywords+'%'
	or	location_code		like 	'%'+@p_keywords+'%'
	or	location_name		like 	'%'+@p_keywords+'%'
	or	division_code		like 	'%'+@p_keywords+'%'
	or	division_name		like 	'%'+@p_keywords+'%'
	or	department_code		like 	'%'+@p_keywords+'%'
	or	department_name		like 	'%'+@p_keywords+'%'
	or	sub_department_code		like 	'%'+@p_keywords+'%'
	or	sub_department_name		like 	'%'+@p_keywords+'%'
	or	units_code		like 	'%'+@p_keywords+'%'
	or	units_name		like 	'%'+@p_keywords+'%'
	or	pic_code		like 	'%'+@p_keywords+'%'
	or	pic_name		like 	'%'+@p_keywords+'%'
	or	residual_value		like 	'%'+@p_keywords+'%'
		or	 case is_depre
			 when '1' then 'YES'
			 else 'NO'
		 end 		like 	'%'+@p_keywords+'%'

	or	depre_category_comm_code		like 	'%'+@p_keywords+'%'
	or	total_depre_comm		like 	'%'+@p_keywords+'%'
	or	depre_period_comm		like 	'%'+@p_keywords+'%'
	or	net_book_value_comm		like 	'%'+@p_keywords+'%'
	or	depre_category_fiscal_code		like 	'%'+@p_keywords+'%'
	or	total_depre_fiscal		like 	'%'+@p_keywords+'%'
	or	depre_period_fiscal		like 	'%'+@p_keywords+'%'
	or	net_book_value_fiscal		like 	'%'+@p_keywords+'%'
		or	 case is_rental
			 when '1' then 'YES'
			 else 'NO'
		 end 		like 	'%'+@p_keywords+'%'

	or	opl_code		like 	'%'+@p_keywords+'%'
	or	rental_date		like 	'%'+@p_keywords+'%'
	or	contractor_name		like 	'%'+@p_keywords+'%'
	or	contractor_address		like 	'%'+@p_keywords+'%'
	or	contractor_email		like 	'%'+@p_keywords+'%'
	or	contractor_pic		like 	'%'+@p_keywords+'%'
	or	contractor_pic_phone		like 	'%'+@p_keywords+'%'
	or	contractor_start_date		like 	'%'+@p_keywords+'%'
	or	contractor_end_date		like 	'%'+@p_keywords+'%'
	or	warranty		like 	'%'+@p_keywords+'%'
	or	warranty_start_date		like 	'%'+@p_keywords+'%'
	or	warranty_end_date		like 	'%'+@p_keywords+'%'
	or	remarks_warranty		like 	'%'+@p_keywords+'%'
		or	 case is_maintenance
			 when '1' then 'YES'
			 else 'NO'
		 end 		like 	'%'+@p_keywords+'%'

	or	maintenance_time		like 	'%'+@p_keywords+'%'
	or	maintenance_type		like 	'%'+@p_keywords+'%'
	or	maintenance_cycle_time		like 	'%'+@p_keywords+'%'
	or	maintenance_start_date		like 	'%'+@p_keywords+'%'
	or	use_life		like 	'%'+@p_keywords+'%'
	or	last_meter		like 	'%'+@p_keywords+'%'
	or	last_service_date		like 	'%'+@p_keywords+'%'
	or	pph		like 	'%'+@p_keywords+'%'
	or	ppn		like 	'%'+@p_keywords+'%'
	or	remarks		like 	'%'+@p_keywords+'%'
	or	last_so_date		like 	'%'+@p_keywords+'%'
	or	last_so_condition		like 	'%'+@p_keywords+'%'
	or	regional_code		like 	'%'+@p_keywords+'%'
	or	regional_name		like 	'%'+@p_keywords+'%'
	or	last_used_by_code		like 	'%'+@p_keywords+'%'
	or	last_used_by_name		like 	'%'+@p_keywords+'%'
	or	last_location_code		like 	'%'+@p_keywords+'%'
	or	last_location_name		like 	'%'+@p_keywords+'%'
			)
	
	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then code 
													when 2	then company_code
													when 3	then item_code
													when 4	then item_name
													when 5	then condition
													when 6	then barcode
													when 7	then cost_center_code
													when 8	then cost_center_name
													when 9	then status
													when 10	then po_no
													when 11	then requestor_code
													when 12	then requestor_name
													when 13	then vendor_code
													when 14	then vendor_name
													when 15	then type_code
													when 16	then category_code
													when 17	then category_name
													when 18	then invoice_no
													when 19	then branch_code
													when 20	then branch_name
													when 21	then location_code
													when 22	then location_name
													when 23	then division_code
													when 24	then division_name
													when 25	then department_code
													when 26	then department_name
													when 27	then sub_department_code
													when 28	then sub_department_name
													when 29	then units_code
													when 30	then units_name
													when 31	then pic_code
													when 32	then pic_name
													when 33	then is_depre
													when 34	then depre_category_comm_code
													when 35	then depre_period_comm
													when 36	then depre_category_fiscal_code
													when 37	then depre_period_fiscal
													when 38	then is_rental
													when 39	then opl_code
													when 40	then contractor_name
													when 41	then contractor_address
													when 42	then contractor_email
													when 43	then contractor_pic
													when 44	then contractor_pic_phone
													when 45	then remarks_warranty
													when 46	then is_maintenance
													when 47	then maintenance_type
													when 48	then use_life
													when 49	then last_meter
													when 50	then remarks
													when 51	then last_so_condition
													when 52	then regional_code
													when 53	then regional_name
													when 54	then last_used_by_code
													when 55	then last_used_by_name
													when 56	then last_location_code
													when 57	then last_location_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1	then code 
													when 2	then company_code
													when 3	then item_code
													when 4	then item_name
													when 5	then condition
													when 6	then barcode
													when 7	then cost_center_code
													when 8	then cost_center_name
													when 9	then status
													when 10	then po_no
													when 11	then requestor_code
													when 12	then requestor_name
													when 13	then vendor_code
													when 14	then vendor_name
													when 15	then type_code
													when 16	then category_code
													when 17	then category_name
													when 18	then invoice_no
													when 19	then branch_code
													when 20	then branch_name
													when 21	then location_code
													when 22	then location_name
													when 23	then division_code
													when 24	then division_name
													when 25	then department_code
													when 26	then department_name
													when 27	then sub_department_code
													when 28	then sub_department_name
													when 29	then units_code
													when 30	then units_name
													when 31	then pic_code
													when 32	then pic_name
													when 33	then is_depre
													when 34	then depre_category_comm_code
													when 35	then depre_period_comm
													when 36	then depre_category_fiscal_code
													when 37	then depre_period_fiscal
													when 38	then is_rental
													when 39	then opl_code
													when 40	then contractor_name
													when 41	then contractor_address
													when 42	then contractor_email
													when 43	then contractor_pic
													when 44	then contractor_pic_phone
													when 45	then remarks_warranty
													when 46	then is_maintenance
													when 47	then maintenance_type
													when 48	then use_life
													when 49	then last_meter
													when 50	then remarks
													when 51	then last_so_condition
													when 52	then regional_code
													when 53	then regional_name
													when 54	then last_used_by_code
													when 55	then last_used_by_name
													when 56	then last_location_code
													when 57	then last_location_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end

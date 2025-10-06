
create procedure xsp_ifinams_interface_additional_request_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	ifinams_interface_additional_request
	where	(
				id like '%' + @p_keywords + '%'
				or	agreement_no like '%' + @p_keywords + '%'
				or	asset_no like '%' + @p_keywords + '%'
				or	branch_code like '%' + @p_keywords + '%'
				or	branch_name like '%' + @p_keywords + '%'
				or	invoice_type like '%' + @p_keywords + '%'
				or	invoice_date like '%' + @p_keywords + '%'
				or	invoice_name like '%' + @p_keywords + '%'
				or	client_no like '%' + @p_keywords + '%'
				or	client_name like '%' + @p_keywords + '%'
				or	client_address like '%' + @p_keywords + '%'
				or	client_area_phone_no like '%' + @p_keywords + '%'
				or	client_phone_no like '%' + @p_keywords + '%'
				or	client_npwp like '%' + @p_keywords + '%'
				or	currency_code like '%' + @p_keywords + '%'
				or	tax_scheme_code like '%' + @p_keywords + '%'
				or	tax_scheme_name like '%' + @p_keywords + '%'
				or	billing_no like '%' + @p_keywords + '%'
				or	description like '%' + @p_keywords + '%'
				or	quantity like '%' + @p_keywords + '%'
				or	billing_amount like '%' + @p_keywords + '%'
				or	discount_amount like '%' + @p_keywords + '%'
				or	ppn_pct like '%' + @p_keywords + '%'
				or	ppn_amount like '%' + @p_keywords + '%'
				or	pph_pct like '%' + @p_keywords + '%'
				or	pph_amount like '%' + @p_keywords + '%'
				or	total_amount like '%' + @p_keywords + '%'
				or	request_status like '%' + @p_keywords + '%'
				or	reff_code like '%' + @p_keywords + '%'
				or	reff_name like '%' + @p_keywords + '%'
				or	settle_date like '%' + @p_keywords + '%'
				or	job_status like '%' + @p_keywords + '%'
				or	failed_remarks like '%' + @p_keywords + '%'
			) ;

	select		id
				,agreement_no
				,asset_no
				,branch_code
				,branch_name
				,invoice_type
				,invoice_date
				,invoice_name
				,client_no
				,client_name
				,client_address
				,client_area_phone_no
				,client_phone_no
				,client_npwp
				,currency_code
				,tax_scheme_code
				,tax_scheme_name
				,billing_no
				,description
				,quantity
				,billing_amount
				,discount_amount
				,ppn_pct
				,ppn_amount
				,pph_pct
				,pph_amount
				,total_amount
				,request_status
				,reff_code
				,reff_name
				,settle_date
				,job_status
				,failed_remarks
				,@rows_count 'rowcount'
	from		ifinams_interface_additional_request
	where		(
					id like '%' + @p_keywords + '%'
					or	agreement_no like '%' + @p_keywords + '%'
					or	asset_no like '%' + @p_keywords + '%'
					or	branch_code like '%' + @p_keywords + '%'
					or	branch_name like '%' + @p_keywords + '%'
					or	invoice_type like '%' + @p_keywords + '%'
					or	invoice_date like '%' + @p_keywords + '%'
					or	invoice_name like '%' + @p_keywords + '%'
					or	client_no like '%' + @p_keywords + '%'
					or	client_name like '%' + @p_keywords + '%'
					or	client_address like '%' + @p_keywords + '%'
					or	client_area_phone_no like '%' + @p_keywords + '%'
					or	client_phone_no like '%' + @p_keywords + '%'
					or	client_npwp like '%' + @p_keywords + '%'
					or	currency_code like '%' + @p_keywords + '%'
					or	tax_scheme_code like '%' + @p_keywords + '%'
					or	tax_scheme_name like '%' + @p_keywords + '%'
					or	billing_no like '%' + @p_keywords + '%'
					or	description like '%' + @p_keywords + '%'
					or	quantity like '%' + @p_keywords + '%'
					or	billing_amount like '%' + @p_keywords + '%'
					or	discount_amount like '%' + @p_keywords + '%'
					or	ppn_pct like '%' + @p_keywords + '%'
					or	ppn_amount like '%' + @p_keywords + '%'
					or	pph_pct like '%' + @p_keywords + '%'
					or	pph_amount like '%' + @p_keywords + '%'
					or	total_amount like '%' + @p_keywords + '%'
					or	request_status like '%' + @p_keywords + '%'
					or	reff_code like '%' + @p_keywords + '%'
					or	reff_name like '%' + @p_keywords + '%'
					or	settle_date like '%' + @p_keywords + '%'
					or	job_status like '%' + @p_keywords + '%'
					or	failed_remarks like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agreement_no
													 when 2 then asset_no
													 when 3 then branch_code
													 when 4 then branch_name
													 when 5 then invoice_type
													 when 6 then invoice_name
													 when 7 then client_no
													 when 8 then client_name
													 when 9 then client_address
													 when 10 then client_area_phone_no
													 when 11 then client_phone_no
													 when 12 then client_npwp
													 when 13 then currency_code
													 when 14 then tax_scheme_code
													 when 15 then tax_scheme_name
													 when 16 then description
													 when 17 then request_status
													 when 18 then reff_code
													 when 19 then reff_name
													 when 20 then job_status
													 when 21 then failed_remarks
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then agreement_no
													   when 2 then asset_no
													   when 3 then branch_code
													   when 4 then branch_name
													   when 5 then invoice_type
													   when 6 then invoice_name
													   when 7 then client_no
													   when 8 then client_name
													   when 9 then client_address
													   when 10 then client_area_phone_no
													   when 11 then client_phone_no
													   when 12 then client_npwp
													   when 13 then currency_code
													   when 14 then tax_scheme_code
													   when 15 then tax_scheme_name
													   when 16 then description
													   when 17 then request_status
													   when 18 then reff_code
													   when 19 then reff_name
													   when 20 then job_status
													   when 21 then failed_remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

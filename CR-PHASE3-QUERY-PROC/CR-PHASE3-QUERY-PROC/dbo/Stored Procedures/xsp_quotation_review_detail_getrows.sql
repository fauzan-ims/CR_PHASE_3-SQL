
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_quotation_review_detail_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_quotation_review_code	nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	quotation_review_detail qrd 
	where	quotation_review_code = @p_quotation_review_code
			and qrd.type = 'NEW'
			and (
					convert(varchar(30), quotation_review_date, 103)	like 	'%'+@p_keywords+'%'
					or	item_name										like 	'%'+@p_keywords+'%'
					or	quantity										like 	'%'+@p_keywords+'%'
					or	qrd.uom_name									like 	'%'+@p_keywords+'%'
					or	price_amount									like 	'%'+@p_keywords+'%'
					or	qrd.tax_name									like 	'%'+@p_keywords+'%'
					or	qrd.supplier_name								like 	'%'+@p_keywords+'%'
					or	qrd.remark										like 	'%'+@p_keywords+'%'
					or	qrd.reff_no										like 	'%'+@p_keywords+'%'
					or	qrd.spesification								like 	'%'+@p_keywords+'%'
					or	qrd.bbn_name									like 	'%'+@p_keywords+'%'
					or	qrd.bbn_location								like 	'%'+@p_keywords+'%'
					or	qrd.bbn_address									like 	'%'+@p_keywords+'%'
					or	qrd.deliver_to_address							like 	'%'+@p_keywords+'%'
			);

	select		id
				,quotation_review_code
				,convert(varchar(30), quotation_review_date, 103) 'quotation_review_date'
				,qrd.reff_no
				,branch_code
				,branch_name
				,currency_code
				,currency_name
				,payment_methode_code
				,item_code
				,item_name
				,supplier_code
				,qrd.supplier_name
				,tax_code
				,qrd.tax_name
				,warranty_month
				,warranty_part_month
				,quantity
				,approved_quantity
				,uom_code
				,qrd.uom_name
				,price_amount
				,discount_amount
				,requestor_code
				,qrd.spesification
				,qrd.remark
				,qrd.unit_from
				,qrd.unit_available_status
				-- (+) Ari 2024-01-17 ket : add net price, total_amount, offering  
				,qrd.nett_price	'net_price_amount'
				,qrd.total_amount
				,qrd.offering
				,qrd.bbn_name
				,qrd.bbn_location
				,qrd.bbn_address
				,qrd.deliver_to_address
				,@rows_count 'rowcount'
		from	quotation_review_detail qrd 
		where	quotation_review_code = @p_quotation_review_code 
		and qrd.type = 'NEW'
		and		(
					convert(varchar(30), quotation_review_date, 103)	like 	'%'+@p_keywords+'%'
					or	qrd.spesification								like 	'%'+@p_keywords+'%'
					or	item_name										like 	'%'+@p_keywords+'%'
					or	quantity										like 	'%'+@p_keywords+'%'
					or	qrd.uom_name									like 	'%'+@p_keywords+'%'
					or	price_amount									like 	'%'+@p_keywords+'%'
					or	qrd.tax_name									like 	'%'+@p_keywords+'%'
					or	qrd.supplier_name								like 	'%'+@p_keywords+'%'
					or	qrd.remark										like 	'%'+@p_keywords+'%'
					or	qrd.reff_no										like 	'%'+@p_keywords+'%'
					or	qrd.unit_available_status						like 	'%'+@p_keywords+'%'
					or	qrd.bbn_name									like 	'%'+@p_keywords+'%'
					or	qrd.bbn_location								like 	'%'+@p_keywords+'%'
					or	qrd.bbn_address									like 	'%'+@p_keywords+'%'
					or	qrd.deliver_to_address							like 	'%'+@p_keywords+'%'
				)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
							when 1	then qrd.reff_no
							when 2	then item_name
							when 3	then cast(qrd.quantity as sql_variant)
							when 4  then qrd.bbn_name
							when 5	then qrd.deliver_to_address
							when 6	then qrd.spesification
							when 7	then qrd.remark
						end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
							when 1	then qrd.reff_no
							when 2	then item_name
							when 3	then cast(qrd.quantity as sql_variant)
							when 4  then qrd.bbn_name
							when 5	then qrd.deliver_to_address
							when 6	then qrd.spesification
							when 7	then qrd.remark
						 end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

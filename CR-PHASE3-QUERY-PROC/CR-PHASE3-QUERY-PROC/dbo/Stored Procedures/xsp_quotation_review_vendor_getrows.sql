CREATE PROCEDURE [dbo].[xsp_quotation_review_vendor_getrows]
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_quotation_review_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.quotation_review_vendor
	where	quotation_review_code = @p_quotation_review_code
			and
			(
				supplier_name						like '%' + @p_keywords + '%'
				or	tax_name						like '%' + @p_keywords + '%'
				or	warranty_month					like '%' + @p_keywords + '%'
				or	warranty_part_month				like '%' + @p_keywords + '%'
				or	price_amount					like '%' + @p_keywords + '%'
				or	discount_amount					like '%' + @p_keywords + '%'
				or	nett_price						like '%' + @p_keywords + '%'
			) ;

	select		id
				,quotation_review_code
				,supplier_code
				,supplier_name
				,supplier_address
				,supplier_npwp
				,tax_code
				,tax_name
				,tax_ppn_pct
				,tax_pph_pct
				,warranty_month
				,warranty_part_month
				,price_amount
				,discount_amount
				,nett_price
				,total_amount
				,offering
				,@rows_count 'rowcount'
	from		dbo.quotation_review_vendor
	where		quotation_review_code = @p_quotation_review_code
				and
				(
					supplier_name					like '%' + @p_keywords + '%'
					or	tax_name					like '%' + @p_keywords + '%'
					or	warranty_month				like '%' + @p_keywords + '%'
					or	warranty_part_month			like '%' + @p_keywords + '%'
					or	price_amount				like '%' + @p_keywords + '%'
					or	discount_amount				like '%' + @p_keywords + '%'
					or	nett_price					like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then supplier_name
													 when 2 then tax_name
													 when 3 then warranty_month
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then supplier_name
														when 2 then tax_name
														when 3 then warranty_month
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

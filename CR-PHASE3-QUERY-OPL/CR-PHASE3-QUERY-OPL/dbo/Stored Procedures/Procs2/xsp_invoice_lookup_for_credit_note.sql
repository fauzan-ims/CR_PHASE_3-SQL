CREATE PROCEDURE [dbo].[xsp_invoice_lookup_for_credit_note]
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
	from	dbo.invoice inv with (nolock)
			outer apply
			(
				select	top 1
						invd.ppn_pct
						,invd.pph_pct
				from	dbo.invoice_detail invd with (nolock)
				where	invd.invoice_no = inv.invoice_no
			) invd
	where	credit_billing_amount = 0
			and invoice_status	  = 'POST'
			and
			(
				invoice_no like '%' + @p_keywords + '%'
				or	invoice_external_no like '%' + @p_keywords + '%'
				or	invoice_name like '%' + @p_keywords + '%'
			) ;

	select		invoice_no
				,invoice_external_no
				,invoice_name
				,invoice_type
				,invoice_status
				,invoice_date
				,invoice_due_date
				,client_name
				,client_area_phone_no
				,client_phone_no
				,client_npwp
				,client_address
				,currency_code
				,total_billing_amount
				,total_discount_amount
				,total_ppn_amount
				,total_pph_amount
				,total_amount
				,invd.ppn_pct
				,invd.pph_pct
				,@rows_count 'rowcount'
	from		dbo.invoice inv with (nolock)
				outer apply
				(
					select	top 1
							invd.ppn_pct
							,invd.pph_pct
					from	dbo.invoice_detail invd with (nolock)
					where	invd.invoice_no = inv.invoice_no
				) invd
	where		credit_billing_amount = 0
				and invoice_status	  = 'POST'
				and
				(
					invoice_no like '%' + @p_keywords + '%'
					or	invoice_external_no like '%' + @p_keywords + '%'
					or	invoice_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then invoice_external_no
													 when 2 then invoice_name
													 when 3 then client_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then invoice_external_no
													   when 2 then invoice_name
													   when 3 then client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

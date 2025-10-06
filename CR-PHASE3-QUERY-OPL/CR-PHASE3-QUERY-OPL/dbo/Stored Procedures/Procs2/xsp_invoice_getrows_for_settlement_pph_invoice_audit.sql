CREATE PROCEDURE [dbo].[xsp_invoice_getrows_for_settlement_pph_invoice_audit]
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	-- 
	,@p_settlement_status nvarchar(10)
	,@p_year			  int
	,@p_audit_code		  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	invoice inv
			inner join dbo.invoice_pph invp on (invp.invoice_no = inv.invoice_no)
	where	invp.settlement_status			 = case @p_settlement_status
													   when 'ALL' then invp.settlement_status
													   else @p_settlement_status
												   end
			and year(inv.invoice_date)			 = @p_year
			and isnull(invp.payment_reff_no, '') = ''
			and invp.audit_code = @p_audit_code
			and (
					inv.invoice_no											like '%' + @p_keywords + '%'
					or inv.invoice_external_no								like '%' + @p_keywords + '%'
					or inv.client_name										like '%' + @p_keywords + '%'
					or inv.faktur_no										like '%' + @p_keywords + '%'
					or convert(varchar(30), inv.invoice_date, 103) 			like '%' + @p_keywords + '%'
					or inv.invoice_name										like '%' + @p_keywords + '%'
					or inv.invoice_status									like '%' + @p_keywords + '%'
					or inv.currency_code									like '%' + @p_keywords + '%'
					or inv.total_pph_amount									like '%' + @p_keywords + '%'
					or invp.settlement_status								like '%' + @p_keywords + '%'
					or invp.payment_reff_no									like '%' + @p_keywords + '%'
					or convert(varchar(30),invp.payment_reff_date, 103)		like '%' + @p_keywords + '%'
				) ;

	select		invp.id
				,inv.invoice_external_no
				,inv.invoice_no
				,inv.client_name
				,inv.faktur_no
				,convert(varchar(30), inv.invoice_date, 103) 'invoice_date'
				,inv.invoice_name
				,inv.invoice_status
				,inv.currency_code
				,invp.total_pph_amount 'total_amount'
				,invp.settlement_status
				,invp.payment_reff_no
				,invp.file_path
				,isnull(invp.file_name, '') 'file_name'
				,convert(varchar(30), invp.payment_reff_date, 103) 'payment_reff_date'
				,@rows_count 'rowcount'
	from		invoice inv
				inner join dbo.invoice_pph invp on (invp.invoice_no = inv.invoice_no)
	where		invp.settlement_status			 = case @p_settlement_status
														   when 'ALL' then invp.settlement_status
														   else @p_settlement_status
													   end
				and year(inv.invoice_date)			 = @p_year
				and isnull(invp.payment_reff_no, '') = ''
				and invp.audit_code = @p_audit_code
				and (
						inv.invoice_no											like '%' + @p_keywords + '%'
						or inv.invoice_external_no								like '%' + @p_keywords + '%'
						or inv.client_name										like '%' + @p_keywords + '%'
						or inv.faktur_no										like '%' + @p_keywords + '%'
						or convert(varchar(30), inv.invoice_date, 103) 			like '%' + @p_keywords + '%'
						or inv.invoice_name										like '%' + @p_keywords + '%'
						or inv.invoice_status									like '%' + @p_keywords + '%'
						or inv.currency_code									like '%' + @p_keywords + '%'
						or inv.total_pph_amount									like '%' + @p_keywords + '%'
						or invp.settlement_status								like '%' + @p_keywords + '%'
						or invp.payment_reff_no									like '%' + @p_keywords + '%'
						or convert(varchar(30),invp.payment_reff_date, 103)		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then inv.invoice_external_no
													 when 2 then inv.faktur_no
													 when 3 then cast(inv.invoice_date as sql_variant)
													 when 4 then inv.invoice_name
													 when 5 then cast(inv.total_pph_amount as sql_variant)
													 when 6 then inv.invoice_status
													 when 7 then invp.payment_reff_no
													 when 8 then cast(invp.payment_reff_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then inv.invoice_external_no
													   when 2 then inv.faktur_no
													   when 3 then cast(inv.invoice_date as sql_variant)
													   when 4 then inv.invoice_name
													   when 5 then cast(inv.total_pph_amount as sql_variant)
													   when 6 then inv.invoice_status
													   when 7 then invp.payment_reff_no
													   when 8 then cast(invp.payment_reff_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

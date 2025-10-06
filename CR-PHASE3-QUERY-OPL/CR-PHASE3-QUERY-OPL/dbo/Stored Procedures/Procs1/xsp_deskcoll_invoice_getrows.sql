CREATE PROCEDURE dbo.xsp_deskcoll_invoice_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_deskcoll_main_id bigint
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		dbo.deskcoll_invoice   a
				inner join dbo.invoice b on a.invoice_no = b.invoice_no
				outer apply (	select	top 1 agp.payment_date 'payment_date'
							from	dbo.invoice_detail invd
									inner join dbo.agreement_invoice ainv on ainv.agreement_no = invd.agreement_no and ainv.asset_no = invd.asset_no and ainv.billing_no = invd.billing_no and ainv.invoice_no = invd.invoice_no 
									left join dbo.agreement_invoice_payment agp on agp.agreement_invoice_code = ainv.code
							where	invd.invoice_no = b.invoice_no
							and		agp.payment_amount > 0
							order by agp.cre_date desc
						) agp
	where		deskcoll_main_id = @p_deskcoll_main_id
				and
				(
					replace(a.invoice_no, '.', '/')						like '%' + @p_keywords + '%'
					or	a.invoice_type									like '%' + @p_keywords + '%'
					or	convert(varchar(30), billing_date, 103)			like '%' + @p_keywords + '%'
					or	convert(varchar(30), billing_due_date, 103)		like '%' + @p_keywords + '%'
					or	total_billing_amount							like '%' + @p_keywords + '%'
					or	ovd_days										like '%' + @p_keywords + '%'
					or	invoice_status									like '%' + @p_keywords + '%'
					or	convert(varchar(30), agp.payment_date, 103)		like '%' + @p_keywords + '%'
				)

	select		a.id
				,convert(varchar(30), billing_date, 103)		'billing_date'
				,replace(a.invoice_no, '.', '/')				'invoice_no'
				,a.invoice_type
				,convert(varchar(30), billing_due_date, 103)	'billing_due_date'
				,b.total_billing_amount
				,b.total_ppn_amount
				,b.total_pph_amount
				,a.ovd_days
				,b.invoice_status
				,convert(varchar(30), agp.payment_date, 103)	'paid_date'
				,@rows_count									'rowcount'
	from		dbo.deskcoll_invoice   a
				inner join dbo.invoice b on a.invoice_no = b.invoice_no
				outer apply (	select	top 1 agp.payment_date 'payment_date'
							from	dbo.invoice_detail invd
									inner join dbo.agreement_invoice ainv on ainv.agreement_no = invd.agreement_no and ainv.asset_no = invd.asset_no and ainv.billing_no = invd.billing_no and ainv.invoice_no = invd.invoice_no 
									left join dbo.agreement_invoice_payment agp on agp.agreement_invoice_code = ainv.code
							where	invd.invoice_no = b.invoice_no
							and		agp.payment_amount > 0
							order by agp.cre_date desc
						) agp
	where		deskcoll_main_id = @p_deskcoll_main_id
				and
				(
					replace(a.invoice_no, '.', '/')						like '%' + @p_keywords + '%'
					or	a.invoice_type									like '%' + @p_keywords + '%'
					or	convert(varchar(30), billing_date, 103)			like '%' + @p_keywords + '%'
					or	convert(varchar(30), billing_due_date, 103)		like '%' + @p_keywords + '%'
					or	total_billing_amount							like '%' + @p_keywords + '%'
					or	ovd_days										like '%' + @p_keywords + '%'
					or	invoice_status									like '%' + @p_keywords + '%'
					or	convert(varchar(30), agp.payment_date, 103)		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													   when 1 then replace(a.invoice_no, '.', '/')
													   when 2 then a.invoice_type
													   when 3 then convert(varchar(30), billing_date, 103)		
													   when 4 then convert(varchar(30), billing_due_date, 103)
													   when 5 then cast(b.total_billing_amount as sql_variant)
													   when 6 then a.ovd_days
													   when 7 then b.invoice_status
													   when 8 then agp.payment_date
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then replace(a.invoice_no, '.', '/')
													   when 2 then a.invoice_type
													   when 3 then convert(varchar(30), billing_date, 103)		
													   when 4 then convert(varchar(30), billing_due_date, 103)
													   when 5 then cast(b.total_billing_amount as sql_variant)
													   when 6 then a.ovd_days
													   when 7 then b.invoice_status
													   when 8 then agp.payment_date
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

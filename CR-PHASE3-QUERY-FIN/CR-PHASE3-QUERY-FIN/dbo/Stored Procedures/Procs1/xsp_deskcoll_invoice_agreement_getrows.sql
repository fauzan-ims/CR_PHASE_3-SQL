CREATE PROCEDURE [dbo].[xsp_deskcoll_invoice_agreement_getrows]
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	--
	,@p_id				 bigint
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.deskcoll_invoice						a
			inner join dbo.invoice_detail				b on a.invoice_no	  = b.invoice_no
			inner join dbo.agreement_asset				c on b.asset_no		  = c.asset_no
			inner join dbo.agreement_asset_amortization d on d.INVOICE_NO		  = b.INVOICE_NO
			inner join dbo.agreement_main				e on e.agreement_no	  = c.agreement_no
	where	a.id = @p_id
			and
			(
				d.billing_amount	like '%' + @p_keywords + '%'
				or	b.asset_no		like '%' + @p_keywords + '%'
			) ;

	select		e.agreement_external_no
				,b.asset_no
				,c.asset_name
				,b.billing_no
				,d.billing_amount
				,d.description
				,c.monthly_rental_rounded_amount
				,b.ppn_amount
				,b.pph_amount
				,@rows_count 'rowcount'
	from		dbo.deskcoll_invoice						a
				inner join dbo.invoice_detail				b on a.invoice_no	  = b.invoice_no
				inner join dbo.agreement_asset				c on b.asset_no		  = c.asset_no
				inner join dbo.agreement_asset_amortization d on d.INVOICE_NO		  = b.INVOICE_NO
				inner join dbo.agreement_main				e on e.agreement_no	  = c.agreement_no
	where		a.id = @p_id
				and
				(
					d.billing_amount	like '%' + @p_keywords + '%'
					or	b.asset_no		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then e.agreement_external_no
													 when 2 then b.asset_no
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then e.agreement_external_no
													   when 2 then b.asset_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

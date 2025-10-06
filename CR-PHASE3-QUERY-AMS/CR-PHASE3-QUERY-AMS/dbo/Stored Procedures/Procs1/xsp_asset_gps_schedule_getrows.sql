CREATE PROCEDURE [dbo].[xsp_asset_gps_schedule_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_fa_code			NVARCHAR(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.ASSET_GPS_SCHEDULE ags
			left JOIN dbo.GPS_REALIZATION_SUBCRIBE grs ON grs.FA_CODE = ags.FA_CODE
	where	ags.FA_CODE = @p_fa_code
	AND		(
				grs.INVOICE_NO					LIKE '%' + @p_keywords + '%'
				OR ags.installment_no			like '%' + @p_keywords + '%'
				or ags.fa_code					like '%' + @p_keywords + '%'
				or ags.subcribe_amount_month	like '%' + @p_keywords + '%'
				or ags.periode					like '%' + @p_keywords + '%'
				or ags.due_date					like '%' + @p_keywords + '%'
				or ags.next_billing_date		like '%' + @p_keywords + '%'
			) ;

	select		grs.INVOICE_NO
				,ags.installment_no
				,ags.fa_code
				,ags.subcribe_amount_month
				,convert(nvarchar(30), ags.periode, 103) 'payment_date'
				,convert(nvarchar(30), ags.due_date, 103) 'paid_date'
				,convert(nvarchar(30), ags.next_billing_date, 103)	'next_billing'
				,ags.status
				,@rows_count 'rowcount'
	from	dbo.ASSET_GPS_SCHEDULE ags
			left JOIN dbo.GPS_REALIZATION_SUBCRIBE grs ON grs.FA_CODE = ags.FA_CODE
	where	ags.FA_CODE = @p_fa_code
	AND			(
					grs.INVOICE_NO					LIKE '%' + @p_keywords + '%'
					OR ags.installment_no			like '%' + @p_keywords + '%'
					or ags.fa_code					like '%' + @p_keywords + '%'
					or ags.subcribe_amount_month	like '%' + @p_keywords + '%'
					or ags.periode					like '%' + @p_keywords + '%'
					or ags.due_date					like '%' + @p_keywords + '%'
					or ags.next_billing_date		like '%' + @p_keywords + '%'
				)	
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ags.INSTALLMENT_NO
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ags.INSTALLMENT_NO
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

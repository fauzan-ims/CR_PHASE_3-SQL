CREATE PROCEDURE dbo.xsp_agreement_asset_amortization_getrows_for_stop_billing
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_agreement_no	nvarchar(50)
	,@p_asset_no		nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		agreement_asset_amortization am
				left join	dbo.invoice inv on (inv.invoice_no = am.invoice_no)
				outer apply
				(
					select	max(payment_date) 'paid_date'
					from	dbo.agreement_invoice_payment
					where	agreement_no	= am.agreement_no
					and		asset_no		= am.asset_no
					and		invoice_no		= am.invoice_no
				)aaa
	where		agreement_no = @p_agreement_no
	and			asset_no = @p_asset_no
	and			(
					am.billing_no										like '%' + @p_keywords + '%'
					or	convert(varchar(20), am.due_date, 103) 			like '%' + @p_keywords + '%'
					or	convert(varchar(20), am.billing_date, 103)		like '%' + @p_keywords + '%'
					or	am.billing_amount								like '%' + @p_keywords + '%'
					or	inv.invoice_external_no							like '%' + @p_keywords + '%'
					or	am.hold_billing_status							like '%' + @p_keywords + '%'
					or	convert(varchar(20),am.hold_date,103)			like '%' + @p_keywords + '%'
				)

	select		am.agreement_no
				,am.billing_no
				,am.asset_no
				,convert(varchar(20), am.due_date, 103) 'due_date'
				,convert(varchar(20), am.billing_date, 103) 'billing_date'
				,am.billing_amount
				,am.invoice_no
				,am.hold_billing_status
				,convert(varchar(20), am.hold_date, 103) 'hold_date'
				,case
					 when am.due_date < dbo.xfn_get_system_date() then 'red'
					  when am.billing_date < dbo.xfn_get_system_date() then 'yellow'
					 else 'false'
				 end 'is_due_date'
				 ,convert(varchar(20), aaa.paid_date, 103) 'paid_date'
				,@rows_count 'rowcount'
	from		agreement_asset_amortization am
				left join	dbo.invoice inv on (inv.invoice_no = am.invoice_no)
				outer apply
				(
					select	max(payment_date) 'paid_date'
					from	dbo.agreement_invoice_payment
					where	agreement_no	= am.agreement_no
					and		asset_no		= am.asset_no
					and		invoice_no		= am.invoice_no
				)aaa
	where		agreement_no = @p_agreement_no
	and			asset_no = @p_asset_no
	and			(
					am.billing_no										like '%' + @p_keywords + '%'
					or	convert(varchar(20), am.due_date, 103) 			like '%' + @p_keywords + '%'
					or	convert(varchar(20), am.billing_date, 103)		like '%' + @p_keywords + '%'
					or	am.billing_amount								like '%' + @p_keywords + '%'
					or	inv.invoice_external_no							like '%' + @p_keywords + '%'
					or	am.hold_billing_status							like '%' + @p_keywords + '%'
					or	convert(varchar(20),am.hold_date,103)			like '%' + @p_keywords + '%'
				)
	order by	case 
					when @p_sort_by='asc' then case @p_order_by
													when 1 then am.billing_no
													when 2 then cast(am.due_date as sql_variant)
													when 3 then cast(am.billing_date as sql_variant)
													when 4 then cast(am.billing_amount as sql_variant)
													when 5 then inv.invoice_external_no
													when 6 then am.hold_billing_status
													when 7 then cast(aaa.paid_date as sql_variant)

												end
					end asc,
				case 
					when @p_sort_by='desc' then case @p_order_by 
													when 1 then am.billing_no
													when 2 then cast(am.due_date as sql_variant)
													when 3 then cast(am.billing_date as sql_variant)
													when 4 then cast(am.billing_amount as sql_variant)
													when 5 then inv.invoice_external_no
													when 6 then am.hold_billing_status
													when 7 then cast(aaa.paid_date as sql_variant)
												end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only;

end ;

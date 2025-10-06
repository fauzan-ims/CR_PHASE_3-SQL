CREATE PROCEDURE dbo.xsp_agreement_asset_amortization_getrows_for_pending_billing
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

	select	@rows_count = count(1)
	from	agreement_asset_amortization am
			left join dbo.invoice iv on (iv.invoice_no = am.invoice_no)
			left join dbo.agreement_main agm on (agm.agreement_no = am.agreement_no)
			outer apply
			(
				select	max(payment_date) 'paid_date'
				from	dbo.agreement_invoice_payment
				where	agreement_no	= am.agreement_no
				and		asset_no		= am.asset_no
				and		invoice_no		= am.invoice_no
			)aaa
	where	am.agreement_no = @p_agreement_no
	and		asset_no = @p_asset_no
	and		(
				billing_no										like '%' + @p_keywords + '%'
				or	convert(varchar(20), due_date, 103) 		like '%' + @p_keywords + '%'
				or	convert(varchar(20), billing_date, 103)		like '%' + @p_keywords + '%'
				or	billing_amount								like '%' + @p_keywords + '%'
				or	am.invoice_no								like '%' + @p_keywords + '%'
				or	iv.invoice_status							like '%' + @p_keywords + '%'
				or	iv.invoice_external_no						like '%' + @p_keywords + '%'
				or	hold_billing_status							like '%' + @p_keywords + '%'
				or	convert(varchar(20),aaa.paid_date,103)		like '%' + @p_keywords + '%'
			)

	select	am.agreement_no
			,am.billing_no
			,am.asset_no
			,convert(varchar(20), am.due_date, 103) 'due_date'
			,convert(varchar(20), am.billing_date, 103) 'billing_date'
			,am.billing_amount
			,am.invoice_no
			,isnull(am.hold_billing_status, '') 'hold_billing_status'
			,convert(varchar(20), am.hold_date, 103) 'hold_date'
			,case
				 when am.due_date < dbo.xfn_get_system_date() then 'true'
				 else 'false'
			 end 'is_due_date'
			 ,iv.invoice_status
			 ,iv.invoice_external_no
			 ,convert(varchar(20), aaa.paid_date, 103) 'paid_date'
			 ,agm.agreement_status
			,@rows_count 'rowcount'
	from	agreement_asset_amortization am
			left join dbo.invoice iv on (iv.invoice_no = am.invoice_no)
			left join dbo.agreement_main agm on (agm.agreement_no = am.agreement_no)
			outer apply
			(
				select	max(payment_date) 'paid_date'
				from	dbo.agreement_invoice_payment
				where	agreement_no	= am.agreement_no
				and		asset_no		= am.asset_no
				and		invoice_no		= am.invoice_no
			)aaa
	where	am.agreement_no = @p_agreement_no
	and		asset_no = @p_asset_no
	and		(
				billing_no										like '%' + @p_keywords + '%'
				or	convert(varchar(20), due_date, 103) 		like '%' + @p_keywords + '%'
				or	convert(varchar(20), billing_date, 103)		like '%' + @p_keywords + '%'
				or	billing_amount								like '%' + @p_keywords + '%'
				or	am.invoice_no								like '%' + @p_keywords + '%'
				or	iv.invoice_status							like '%' + @p_keywords + '%'
				or	iv.invoice_external_no						like '%' + @p_keywords + '%'
				or	hold_billing_status							like '%' + @p_keywords + '%'
				or	convert(varchar(20),aaa.paid_date,103)		like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by='asc' then case @p_order_by
													when 1 then billing_no
													when 2 then cast(due_date as sql_variant)
													when 3 then cast(billing_date as sql_variant)
													when 4 then cast(billing_amount as sql_variant)
													when 5 then iv.invoice_external_no
													when 6 then iv.invoice_status
													when 7 then cast(aaa.paid_date as sql_variant)
													when 8 then hold_billing_status

												end
					end asc,
				case 
					when @p_sort_by='desc' then case @p_order_by 
													when 1 then billing_no
													when 2 then cast(due_date as sql_variant)
													when 3 then cast(billing_date as sql_variant)
													when 4 then cast(billing_amount as sql_variant)
													when 5 then iv.invoice_external_no
													when 6 then iv.invoice_status
													when 7 then cast(aaa.paid_date as sql_variant)
													when 8 then hold_billing_status
												end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only;

end ;

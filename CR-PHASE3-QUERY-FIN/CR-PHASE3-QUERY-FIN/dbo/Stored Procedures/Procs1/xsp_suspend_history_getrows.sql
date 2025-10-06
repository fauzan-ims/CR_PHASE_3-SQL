CREATE PROCEDURE [dbo].[xsp_suspend_history_getrows]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_suspend_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	suspend_history sh with (nolock)
			left join dbo.agreement_main am on (am.agreement_no = sh.agreement_no)
			outer apply
	(
		select	top 1 allocation_value_date
				,invoice_name
				,invoice_type
				,inv.invoice_external_no
		from	dbo.suspend_allocation da with (nolock) --on (da.code = sh.source_reff_code)
				left join dbo.suspend_allocation_detail dad with (nolock) on (dad.suspend_allocation_code = da.code)
				left join dbo.cashier_received_request crr2 with (nolock) on (crr2.code					  = dad.received_request_code)
				left join ifinopl.dbo.invoice inv with (nolock) on (inv.invoice_no						  = crr2.invoice_no)
		where	da.code						  = sh.source_reff_code
				and dad.is_paid = '1' order by dad.base_amount desc
	) da
			outer apply
	(
		select	cashier_value_date
				,invoice_name
				,invoice_type
				,inv.invoice_external_no
		from	dbo.cashier_transaction ct --with (nolock) on (ct.code = sh.source_reff_code) 
				left join dbo.cashier_received_request crr with (nolock) on (crr.process_reff_code = ct.code)
				left join ifinopl.dbo.invoice inv with (nolock) on (inv.invoice_no				   = crr.invoice_no)
		where	ct.code = sh.source_reff_code
	) ct
			left join dbo.suspend_merger sm with (nolock) on (sm.code				= sh.source_reff_code)
			left join dbo.payment_request pr with (nolock) on (pr.payment_source_no = sh.source_reff_code)
			left join dbo.payment_transaction pt with (nolock) on (pt.code			= pr.payment_transaction_code)
			left join dbo.suspend_revenue srv on (srv.code							= sh.source_reff_code)
	where	sh.suspend_code = @p_suspend_code
			and
			(
				convert(varchar(30), sh.transaction_date, 103)																															like '%' + @p_keywords + '%'
				or am.agreement_external_no																																				like '%' + @p_keywords + '%'
				or am.client_name																																						like '%' + @p_keywords + '%'
				or sh.orig_amount																																						like '%' + @p_keywords + '%'
				or sh.orig_currency_code																																				like '%' + @p_keywords + '%'
				or sh.exch_rate																																							like '%' + @p_keywords + '%'
				or sh.base_amount																																						like '%' + @p_keywords + '%'
				or sh.source_reff_code																																					like '%' + @p_keywords + '%'
				or sh.source_reff_name																																					like '%' + @p_keywords + '%'
				or isnull(ct.invoice_external_no,da.invoice_external_no)																												like '%' + @p_keywords + '%'
				or isnull(ct.invoice_name,da.invoice_name)																																like '%' + @p_keywords + '%'
				or isnull(ct.invoice_type, da.invoice_type)																																like '%' + @p_keywords + '%'
				or convert(varchar(30), isnull(da.allocation_value_date, isnull(ct.cashier_value_date, isnull(sm.merger_date, isnull(pt.payment_value_date, srv.revenue_date)))), 103)	like '%' + @p_keywords + '%'
			) ;

	select		sh.id
				,convert(varchar(30), sh.transaction_date, 103) 'transaction_date'
				,convert(varchar(30), isnull(da.allocation_value_date, isnull(ct.cashier_value_date, isnull(sm.merger_date, isnull(pt.payment_value_date, srv.revenue_date)))), 103) 'value_date'
				,am.agreement_external_no
				,am.client_name
				,sh.orig_amount
				,sh.orig_currency_code
				,sh.exch_rate
				,sh.base_amount
				,sh.source_reff_code
				,sh.source_reff_name
				,isnull(ct.invoice_external_no, da.invoice_external_no) 'invoice_external_no'
				,isnull(ct.invoice_name, da.invoice_name) 'invoice_name'
				,isnull(ct.invoice_type, da.invoice_type) 'invoice_type'
				,@rows_count 'rowcount'
	from		suspend_history sh with (nolock)
				left join dbo.agreement_main am on (am.agreement_no = sh.agreement_no)
				outer apply
	(
		select	top 1 allocation_value_date
				,invoice_name
				,invoice_type
				,inv.invoice_external_no
		from	dbo.suspend_allocation da with (nolock) --on (da.code = sh.source_reff_code)
				left join dbo.suspend_allocation_detail dad with (nolock) on (dad.suspend_allocation_code = da.code)
				left join dbo.cashier_received_request crr2 with (nolock) on (crr2.code					  = dad.received_request_code)
				left join ifinopl.dbo.invoice inv with (nolock) on (inv.invoice_no						  = crr2.invoice_no)
		where	da.code						  = sh.source_reff_code
				and dad.is_paid = '1' order by dad.base_amount desc
	) da
				outer apply
	(
		select	cashier_value_date
				,invoice_name
				,invoice_type
				,inv.invoice_external_no
		from	dbo.cashier_transaction ct --with (nolock) on (ct.code = sh.source_reff_code) 
				left join dbo.cashier_received_request crr with (nolock) on (crr.process_reff_code = ct.code)
				left join ifinopl.dbo.invoice inv with (nolock) on (inv.invoice_no				   = crr.invoice_no)
		where	ct.code = sh.source_reff_code
	) ct
				left join dbo.suspend_merger sm with (nolock) on (sm.code				= sh.source_reff_code)
				left join dbo.payment_request pr with (nolock) on (pr.payment_source_no = sh.source_reff_code)
				left join dbo.payment_transaction pt with (nolock) on (pt.code			= pr.payment_transaction_code)
				left join dbo.suspend_revenue srv on (srv.code							= sh.source_reff_code)
	where		sh.suspend_code = @p_suspend_code
				and
				(
					convert(varchar(30), sh.transaction_date, 103)																															like '%' + @p_keywords + '%'
					or am.agreement_external_no																																				like '%' + @p_keywords + '%'
					or am.client_name																																						like '%' + @p_keywords + '%'
					or sh.orig_amount																																						like '%' + @p_keywords + '%'
					or sh.orig_currency_code																																				like '%' + @p_keywords + '%'
					or sh.exch_rate																																							like '%' + @p_keywords + '%'
					or sh.base_amount																																						like '%' + @p_keywords + '%'
					or sh.source_reff_code																																					like '%' + @p_keywords + '%'
					or sh.source_reff_name																																					like '%' + @p_keywords + '%'
					or isnull(ct.invoice_external_no,da.invoice_external_no)																												like '%' + @p_keywords + '%'
					or isnull(ct.invoice_name,da.invoice_name)																																like '%' + @p_keywords + '%'
					or isnull(ct.invoice_type, da.invoice_type)																																like '%' + @p_keywords + '%'
					or convert(varchar(30), isnull(da.allocation_value_date, isnull(ct.cashier_value_date, isnull(sm.merger_date, isnull(pt.payment_value_date, srv.revenue_date)))), 103)	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(sh.transaction_date as sql_variant)
													 when 2 then cast(isnull(da.allocation_value_date, isnull(ct.cashier_value_date, isnull(sm.merger_date, isnull(pt.payment_value_date, srv.revenue_date)))) as sql_variant)
													 when 3 then sh.source_reff_code
													 when 4 then am.agreement_external_no
													 when 5 then cast(sh.orig_amount as sql_variant)
													 when 6 then sh.orig_currency_code
													 when 7 then cast(sh.base_amount as sql_variant)
													 when 8 then isnull(ct.invoice_external_no, da.invoice_external_no)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then cast(sh.transaction_date as sql_variant)
													   when 2 then cast(isnull(da.allocation_value_date, isnull(ct.cashier_value_date, isnull(sm.merger_date, isnull(pt.payment_value_date, srv.revenue_date)))) as sql_variant)
													   when 3 then sh.source_reff_code
													   when 4 then am.agreement_external_no
													   when 5 then cast(sh.orig_amount as sql_variant)
													   when 6 then sh.orig_currency_code
													   when 7 then cast(sh.base_amount as sql_variant)
													   when 8 then isnull(ct.invoice_external_no, da.invoice_external_no)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

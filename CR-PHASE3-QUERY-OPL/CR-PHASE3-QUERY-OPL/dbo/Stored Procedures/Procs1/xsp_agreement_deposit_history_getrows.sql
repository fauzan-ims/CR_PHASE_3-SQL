CREATE PROCEDURE [dbo].[xsp_agreement_deposit_history_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_agreement_deposit_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

			select	@rows_count = count(1)
			from	dbo.agreement_deposit_history dh with (nolock)
			left join dbo.agreement_main am with (nolock) on (am.agreement_no = dh.agreement_no)
			outer apply
			(
				select	cashier_value_date
						,invoice_name
						,invoice_type
						,inv.invoice_external_no
				from	ifinfin.dbo.cashier_transaction ct --with (nolock) on (ct.code = sh.source_reff_code) 
						left join ifinfin.dbo.cashier_received_request crr with (nolock) on (crr.process_reff_code = ct.code)
						left join ifinopl.dbo.invoice inv with (nolock) on (inv.invoice_no						   = crr.invoice_no)
				where	ct.code = dh.source_reff_code
			) ct
			outer apply
			(
				select		top 1
							allocation_value_date
							,invoice_name
							,invoice_type
							,inv.invoice_external_no
				from		ifinfin.dbo.deposit_allocation da with (nolock) --on (da.code = sh.source_reff_code)
							left join ifinfin.dbo.deposit_allocation_detail dad with (nolock) on (dad.deposit_allocation_code = da.code)
							left join ifinfin.dbo.cashier_received_request crr2 with (nolock) on (crr2.code					  = dad.received_request_code)
							left join ifinopl.dbo.invoice inv with (nolock) on (inv.invoice_no								  = crr2.invoice_no)
				where		da.code			= dh.source_reff_code
							and dad.is_paid = '1'
				order by	dad.base_amount desc
			) da
			--left join ifinfin.dbo.cashier_transaction ct with (nolock) on (ct.code = dh.source_reff_code)
			--left join ifinfin.dbo.cashier_received_request crr with (nolock) on (crr.process_reff_code = ct.code)
			--left join dbo.invoice inv with (nolock) on (inv.invoice_no = crr.invoice_no)
			--left join ifinfin.dbo.deposit_allocation da with (nolock) on (da.code = dh.source_reff_code)
			--left join ifinfin.dbo.deposit_allocation_detail dad with (nolock) on (dad.deposit_allocation_code = da.code)
			--left join ifinfin.dbo.cashier_received_request crr2 with (nolock) on (crr2.code = dad.received_request_code)
			--left join dbo.invoice inv2 with (nolock) on (inv2.invoice_no = crr2.invoice_no)
			left join ifinfin.dbo.deposit_move dmv with (nolock)  on (dmv.code = dh.source_reff_code) 
			left join ifinfin.dbo.payment_request pr with (nolock) on (pr.payment_source_no = dh.source_reff_code)
			left join ifinfin.dbo.payment_transaction pt with (nolock) on (pt.code = pr.payment_transaction_code)
			left join ifinfin.dbo.deposit_revenue drv with (nolock) on (drv.code = dh.source_reff_code)
	where	dh.agreement_deposit_code = @p_agreement_deposit_code
			and (
					convert(varchar(30), dh.transaction_date, 103)																								like '%' + @p_keywords + '%'
					or am.agreement_external_no																													like '%' + @p_keywords + '%'
					or am.client_name																															like '%' + @p_keywords + '%'
					or dh.orig_amount																															like '%' + @p_keywords + '%'
					or dh.orig_currency_code																													like '%' + @p_keywords + '%'
					or dh.exch_rate																																like '%' + @p_keywords + '%'
					or dh.base_amount																															like '%' + @p_keywords + '%'
					or dh.source_reff_code																														like '%' + @p_keywords + '%'
					or dh.source_reff_name																														like '%' + @p_keywords + '%'
					or isnull(ct.invoice_external_no,da.invoice_external_no)																					like '%' + @p_keywords + '%'
					or isnull(ct.invoice_name,da.invoice_name)																						like '%' + @p_keywords + '%'
					or isnull(ct.invoice_type, da.invoice_type)																				like '%' + @p_keywords + '%'
					or convert(varchar(30), isnull(da.allocation_value_date,isnull(ct.cashier_value_date, isnull(dmv.move_date,isnull(pt.payment_value_date, drv.revenue_date)))), 103)	like '%' + @p_keywords + '%'
			) ;
			 
		select		convert(varchar(30), dh.transaction_date, 103) 'transaction_date'
					,convert(varchar(30), isnull(da.allocation_value_date,isnull(ct.cashier_value_date, isnull(dmv.move_date,isnull(pt.payment_value_date, drv.revenue_date)))), 103) 'value_date'
					,am.agreement_external_no 
					,am.client_name			
					,dh.orig_amount			
					,dh.orig_currency_code	
					,dh.exch_rate				
					,dh.base_amount			
					,dh.source_reff_code		
					,dh.source_reff_name
					,isnull(ct.invoice_external_no,da.invoice_external_no) 'invoice_external_no'
					,isnull(ct.invoice_name,da.invoice_name) 'invoice_name'
					,isnull(ct.invoice_type, da.invoice_type) 'invoice_type'
					,@rows_count 'rowcount'
			from	dbo.agreement_deposit_history dh with (nolock)
			left join dbo.agreement_main am with (nolock) on (am.agreement_no = dh.agreement_no)
			outer apply
			(
				select	cashier_value_date
						,invoice_name
						,invoice_type
						,inv.invoice_external_no
				from	ifinfin.dbo.cashier_transaction ct --with (nolock) on (ct.code = sh.source_reff_code) 
						left join ifinfin.dbo.cashier_received_request crr with (nolock) on (crr.process_reff_code = ct.code)
						left join ifinopl.dbo.invoice inv with (nolock) on (inv.invoice_no						   = crr.invoice_no)
				where	ct.code = dh.source_reff_code
			) ct
			outer apply
			(
				select		top 1
							allocation_value_date
							,invoice_name
							,invoice_type
							,inv.invoice_external_no
				from		ifinfin.dbo.deposit_allocation da with (nolock) --on (da.code = sh.source_reff_code)
							left join ifinfin.dbo.deposit_allocation_detail dad with (nolock) on (dad.deposit_allocation_code = da.code)
							left join ifinfin.dbo.cashier_received_request crr2 with (nolock) on (crr2.code					  = dad.received_request_code)
							left join ifinopl.dbo.invoice inv with (nolock) on (inv.invoice_no								  = crr2.invoice_no)
				where		da.code			= dh.source_reff_code
							and dad.is_paid = '1'
				order by	dad.base_amount desc
			) da
			--left join ifinfin.dbo.cashier_transaction ct with (nolock) on (ct.code = dh.source_reff_code)
			--left join ifinfin.dbo.cashier_received_request crr with (nolock) on (crr.process_reff_code = ct.code)
			--left join dbo.invoice inv with (nolock) on (inv.invoice_no = crr.invoice_no)
			--left join ifinfin.dbo.deposit_allocation da with (nolock) on (da.code = dh.source_reff_code)
			--left join ifinfin.dbo.deposit_allocation_detail dad with (nolock) on (dad.deposit_allocation_code = da.code)
			--left join ifinfin.dbo.cashier_received_request crr2 with (nolock) on (crr2.code = dad.received_request_code)
			--left join dbo.invoice inv2 with (nolock) on (inv2.invoice_no = crr2.invoice_no)
			left join ifinfin.dbo.deposit_move dmv with (nolock)  on (dmv.code = dh.source_reff_code) 
			left join ifinfin.dbo.payment_request pr with (nolock) on (pr.payment_source_no = dh.source_reff_code)
			left join ifinfin.dbo.payment_transaction pt with (nolock) on (pt.code = pr.payment_transaction_code)
			left join ifinfin.dbo.deposit_revenue drv with (nolock) on (drv.code = dh.source_reff_code)
	where	dh.agreement_deposit_code = @p_agreement_deposit_code
			and (
					convert(varchar(30), dh.transaction_date, 103)																								like '%' + @p_keywords + '%'
					or am.agreement_external_no																													like '%' + @p_keywords + '%'
					or am.client_name																															like '%' + @p_keywords + '%'
					or dh.orig_amount																															like '%' + @p_keywords + '%'
					or dh.orig_currency_code																													like '%' + @p_keywords + '%'
					or dh.exch_rate																																like '%' + @p_keywords + '%'
					or dh.base_amount																															like '%' + @p_keywords + '%'
					or dh.source_reff_code																														like '%' + @p_keywords + '%'
					or dh.source_reff_name																														like '%' + @p_keywords + '%'
					or isnull(ct.invoice_external_no,da.invoice_external_no)																					like '%' + @p_keywords + '%'
					or isnull(ct.invoice_name,da.invoice_name)																						like '%' + @p_keywords + '%'
					or isnull(ct.invoice_type, da.invoice_type)																				like '%' + @p_keywords + '%'
					or convert(varchar(30), isnull(da.allocation_value_date,isnull(ct.cashier_value_date, isnull(dmv.move_date,isnull(pt.payment_value_date, drv.revenue_date)))), 103)	like '%' + @p_keywords + '%'
			)
		order by case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(dh.transaction_date as sql_variant)
													when 2 then cast(isnull(da.allocation_value_date,isnull(ct.cashier_value_date, isnull(dmv.move_date,isnull(pt.payment_value_date, drv.revenue_date)))) as sql_variant)
													when 3 then dh.source_reff_code
													when 4 then am.agreement_external_no
													when 5 then cast(dh.orig_amount as sql_variant)
													when 6 then dh.orig_currency_code
													when 7 then cast(dh.base_amount as sql_variant)
													when 8 then isnull(ct.invoice_external_no,da.invoice_external_no)	
												 end
					end asc,
					case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(dh.transaction_date as sql_variant)
														when 2 then cast(isnull(da.allocation_value_date,isnull(ct.cashier_value_date, isnull(dmv.move_date,isnull(pt.payment_value_date, drv.revenue_date)))) as sql_variant)
														when 3 then dh.source_reff_code
														when 4 then am.agreement_external_no
														when 5 then cast(dh.orig_amount as sql_variant)
														when 6 then dh.orig_currency_code
														when 7 then cast(dh.base_amount as sql_variant)
														when 8 then isnull(ct.invoice_external_no,da.invoice_external_no)	
													 end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

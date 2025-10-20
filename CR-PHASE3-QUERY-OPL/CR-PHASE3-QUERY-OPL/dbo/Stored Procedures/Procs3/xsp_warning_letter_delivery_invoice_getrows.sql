CREATE PROCEDURE dbo.xsp_warning_letter_delivery_invoice_getrows
(
	@p_keywords nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage int
	,@p_order_by int
	,@p_sort_by nvarchar(5)
	,@p_code nvarchar(50)
)
as
begin
	declare @rows_count		int = 0 

	select	@rows_count		= COUNT(1)
	from	dbo.warning_letter_delivery wld
			inner join dbo.invoice inv on inv.client_no = wld.client_no
			outer apply (	select	top 1 agp.payment_date 'payment_date'
							from	dbo.invoice_detail invd
									inner join dbo.agreement_invoice ainv on ainv.agreement_no = invd.agreement_no and ainv.asset_no = invd.asset_no and ainv.billing_no = invd.billing_no and ainv.invoice_no = invd.invoice_no 
									left join dbo.agreement_invoice_payment agp on agp.agreement_invoice_code = ainv.code
							where	invd.invoice_no = inv.invoice_no
							and		agp.payment_amount > 0
							order by agp.cre_date desc
						) agp
	where	wld.code = @p_code 
	and		inv.invoice_status = 'POST'
	and		cast(inv.invoice_due_date as date) <= cast(wld.letter_date as date) -- ambil hanya hingga tanggal sp di terbitkan
	and		(
				inv.invoice_external_no									like '%' + @p_keywords + '%'
				or	inv.invoice_type									like '%' + @p_keywords + '%'
				or	convert(varchar(15), inv.invoice_date, 102)			like '%' + @p_keywords + '%'
				or	convert(varchar(15), inv.invoice_due_date, 102)		like '%' + @p_keywords + '%'
				or	inv.total_amount									like '%' + @p_keywords + '%'
				or	datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())	like '%' + @p_keywords + '%'
				--or	case when inv.invoice_status = 'post' then (case when cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date) then datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) else 0 end)
				--				when inv.invoice_status = 'paid' then (case when cast(inv.invoice_due_date as date) < cast(agp.payment_date as date) then datediff(day, inv.invoice_due_date, agp.payment_date) else 0 end)
				--				else 0 end								like '%' + @p_keywords + '%'
				or	inv.invoice_status									like '%' + @p_keywords + '%'
				or	 convert(varchar(15), agp.payment_date, 102)		like '%' + @p_keywords + '%'
				--or	 convert(varchar(15), promise_date, 102)	like '%' + @p_keywords + '%'
			)

	select	inv.invoice_external_no							'invoice_no'
			,inv.invoice_type								'invoice_type'
			,FORMAT(inv.invoice_date, 'yyyy/MM/dd')			'billing_date'
			,FORMAT(inv.invoice_due_date, 'yyyy/MM/dd')		'billing_due_date'
			,inv.total_amount								'os_invoice_amount'
			,datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) 'ovd_days' 
			--,case when inv.invoice_status = 'post' then (case when cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date) then datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) else 0 end)
			--	when inv.invoice_status = 'paid' then (case when cast(inv.invoice_due_date as date) < cast(agp.payment_date as date) then datediff(day, inv.invoice_due_date, agp.payment_date) else 0 end)
			--	else 0 end									'ovd_days' 
			,inv.invoice_status								'invoice_status'
			,FORMAT(agp.payment_date, 'yyyy/MM/dd')			'invoice_due_date'
			,0												'total_ppn_amount'
			,0												'total_pph_amount'
			,NULL											'promise_date'
			,@rows_count									'rowcount'
	from	dbo.warning_letter_delivery wld
			inner join dbo.invoice inv on inv.client_no = wld.client_no
			outer apply (	select	top 1 agp.payment_date 'payment_date'
							from	dbo.invoice_detail invd
									inner join dbo.agreement_invoice ainv on ainv.agreement_no = invd.agreement_no and ainv.asset_no = invd.asset_no and ainv.billing_no = invd.billing_no and ainv.invoice_no = invd.invoice_no 
									left join dbo.agreement_invoice_payment agp on agp.agreement_invoice_code = ainv.code
							where	invd.invoice_no = inv.invoice_no
							and		agp.payment_amount > 0
							order by agp.cre_date desc
						) agp
	where	wld.code = @p_code 
	and		inv.invoice_status = 'POST'
	and		cast(inv.invoice_due_date as date) <= cast(wld.letter_date as date) -- ambil hanya hingga tanggal sp di terbitkan
	and		(
				inv.invoice_external_no									like '%' + @p_keywords + '%'
				or	inv.invoice_type									like '%' + @p_keywords + '%'
				or	convert(varchar(15), inv.invoice_date, 102)			like '%' + @p_keywords + '%'
				or	convert(varchar(15), inv.invoice_due_date, 102)		like '%' + @p_keywords + '%'
				or	inv.total_amount									like '%' + @p_keywords + '%'
				or	datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())	like '%' + @p_keywords + '%'
				--OR	case when inv.invoice_status = 'post' then (case when cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date) then datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) else 0 end)
				--				when inv.invoice_status = 'paid' then (case when cast(inv.invoice_due_date as date) < cast(agp.payment_date as date) then datediff(day, inv.invoice_due_date, agp.payment_date) else 0 end)
				--				else 0 end								like '%' + @p_keywords + '%'
				or	inv.invoice_status									like '%' + @p_keywords + '%'
				or	 convert(varchar(15), agp.payment_date, 102)		like '%' + @p_keywords + '%'
				--or	 convert(varchar(15), promise_date, 102)	like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then inv.invoice_external_no
													when 2 then inv.invoice_type
													when 3 then cast(inv.invoice_date as sql_variant)
													when 4 then cast(inv.invoice_due_date as sql_variant)
													when 5 then cast(inv.total_amount as sql_variant)
													when 6 then CAST(datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) AS SQL_VARIANT)
																--CAST(case when inv.invoice_status = 'post' then (case when cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date) then datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) else 0 end)
																--when inv.invoice_status = 'paid' then (case when cast(inv.invoice_due_date as date) < cast(agp.payment_date as date) then datediff(day, inv.invoice_due_date, agp.payment_date) else 0 end)
																--else 0 end as sql_variant)
													when 7 then inv.invoice_status
													when 8 then cast(agp.payment_date as sql_variant)
													--when 9 then cast(promise_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then inv.invoice_external_no
													when 2 then inv.invoice_type
													when 3 then cast(inv.invoice_date as sql_variant)
													when 4 then cast(inv.invoice_due_date as sql_variant)
													when 5 then cast(inv.total_amount as sql_variant)
													when 6 then CAST(datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) AS SQL_VARIANT)
																--CAST(case when inv.invoice_status = 'post' then (case when cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date) then datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) else 0 end)
																--when inv.invoice_status = 'paid' then (case when cast(inv.invoice_due_date as date) < cast(agp.payment_date as date) then datediff(day, inv.invoice_due_date, agp.payment_date) else 0 end)
																--else 0 end as sql_variant)
													when 7 then inv.invoice_status
													when 8 then cast(agp.payment_date as sql_variant)
													--when 9 then cast(promise_date as sql_variant)
												 end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;
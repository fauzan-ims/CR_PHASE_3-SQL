CREATE PROCEDURE dbo.xsp_invoice_getrows_for_settlement_pph_invoice_backup
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	-- 
	,@p_settlement_status nvarchar(10)
	,@p_overdue_days	  nvarchar(15) = 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	invoice inv with (nolock)
			outer apply
	(
		select	top 1
				am.agreement_external_no
				,aa.billing_to_npwp
				,aa.npwp_name -- (+) Ari 2023-09-29 ket : add npwp name
		from	dbo.invoice_detail invd with (nolock)
				left join dbo.agreement_main am with (nolock) on (am.agreement_no	   = invd.agreement_no)
				left join dbo.agreement_asset aa with (nolock) on (
																	  aa.agreement_no  = invd.agreement_no
																	  and  aa.asset_no = invd.asset_no
																  )
		where	invd.invoice_no = inv.invoice_no
	) invd
			inner join dbo.invoice_pph invp with (nolock) on (invp.invoice_no = inv.invoice_no)
	where	invp.settlement_type	   = 'PKP'
			and invp.settlement_status = case @p_settlement_status
											 when 'ALL' then invp.settlement_status
											 else @p_settlement_status
										 end
			and inv.invoice_status	   = 'PAID'
			and case
					when @p_overdue_days = 'ALL' then 'ALL'
					when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
						 < 1 then 'LESS THAN 1'
					when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
						 between 1 and 30 then '1-30'
					when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
						 between 31 and 60 then '31-60'
					when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
						 between 61 and 90 then '61-90'
					when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) > 90 then 'MORE THAN 90'
				end					   = @p_overdue_days
			and
			(
				inv.invoice_no														like '%' + @p_keywords + '%'
				or inv.invoice_external_no											like '%' + @p_keywords + '%'
				or inv.client_name													like '%' + @p_keywords + '%'
				or inv.faktur_no													like '%' + @p_keywords + '%'
				or convert(varchar(30), inv.invoice_due_date, 103) 					like '%' + @p_keywords + '%'
				or inv.invoice_name													like '%' + @p_keywords + '%'
				or inv.invoice_status												like '%' + @p_keywords + '%'
				or inv.currency_code												like '%' + @p_keywords + '%'
				or inv.total_pph_amount												like '%' + @p_keywords + '%'
				or invp.settlement_status											like '%' + @p_keywords + '%'
				or invp.payment_reff_no												like '%' + @p_keywords + '%'
				or convert(varchar(30),invp.payment_reff_date, 103)					like '%' + @p_keywords + '%'
				or invd.agreement_external_no										like '%' + @p_keywords + '%'
				or invd.billing_to_npwp												like '%' + @p_keywords + '%'
				or invd.npwp_name													like '%' + @p_keywords + '%'
				or datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())	like '%' + @p_keywords + '%'
			) ;

	select		invp.id
				,inv.invoice_no
				,inv.invoice_external_no
				,inv.client_name
				,inv.faktur_no
				,convert(varchar(30), inv.invoice_due_date, 103) 'invoice_date'
				,inv.invoice_name
				,inv.invoice_status
				,inv.currency_code
				,invp.total_pph_amount 'total_amount'
				,invp.settlement_status
				,invp.payment_reff_no
				,invp.file_path
				,isnull(invp.file_name, '') 'file_name'
				,convert(varchar(30), invp.payment_reff_date, 103) 'payment_reff_date'
				,invd.agreement_external_no
				,invd.billing_to_npwp
				,invd.npwp_name -- (+) ari 2023-09-29 ket : add npwp name
				,inv.invoice_name
				,datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) 'aging_days'
				,case
					 when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
						  between 1 and 30 then '#ACD793'
					 when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
						  between 31 and 60 then '#FFC96F'
					 when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
						  between 61 and 90 then '#FFA62F'
					 when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) > 90 then '#EE4E4E'
					 when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) < 1 then '#A3FFD6'
				 end 'color'
				,@rows_count 'rowcount'
	from		invoice inv with (nolock)
				outer apply
	(
		select	top 1
				am.agreement_external_no
				,aa.billing_to_npwp
				,aa.npwp_name -- (+) Ari 2023-09-29 ket : add npwp name
		from	dbo.invoice_detail invd with (nolock)
				left join dbo.agreement_main am with (nolock) on (am.agreement_no	   = invd.agreement_no)
				left join dbo.agreement_asset aa with (nolock) on (
																	  aa.agreement_no  = invd.agreement_no
																	  and  aa.asset_no = invd.asset_no
																  )
		where	invd.invoice_no = inv.invoice_no
	) invd
				inner join dbo.invoice_pph invp with (nolock) on (invp.invoice_no = inv.invoice_no)
	where		invp.settlement_type	   = 'PKP'
				and invp.settlement_status = case @p_settlement_status
												 when 'ALL' then invp.settlement_status
												 else @p_settlement_status
											 end
				and inv.invoice_status	   = 'PAID'
				and case
						when @p_overdue_days = 'ALL' then 'ALL'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
							 < 1 then 'LESS THAN 1'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
							 between 1 and 30 then '1-30'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
							 between 31 and 60 then '31-60'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())
							 between 61 and 90 then '61-90'
						when datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) > 90 then 'MORE THAN 90'
					end					   = @p_overdue_days
				and
				(
					inv.invoice_no														like '%' + @p_keywords + '%'
					or inv.invoice_external_no											like '%' + @p_keywords + '%'
					or inv.client_name													like '%' + @p_keywords + '%'
					or inv.faktur_no													like '%' + @p_keywords + '%'
					or convert(varchar(30), inv.invoice_due_date, 103) 					like '%' + @p_keywords + '%'
					or inv.invoice_name													like '%' + @p_keywords + '%'
					or inv.invoice_status												like '%' + @p_keywords + '%'
					or inv.currency_code												like '%' + @p_keywords + '%'
					or inv.total_pph_amount												like '%' + @p_keywords + '%'
					or invp.settlement_status											like '%' + @p_keywords + '%'
					or invp.payment_reff_no												like '%' + @p_keywords + '%'
					or convert(varchar(30),invp.payment_reff_date, 103)					like '%' + @p_keywords + '%'
					or invd.agreement_external_no										like '%' + @p_keywords + '%'
					or invd.billing_to_npwp												like '%' + @p_keywords + '%'
					or invd.npwp_name													like '%' + @p_keywords + '%'
					or datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date())	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then inv.invoice_external_no
													 when 2 then inv.faktur_no
													 when 3 then invd.billing_to_npwp
													 when 4 then cast(inv.total_pph_amount as sql_variant)
													 when 5 then invp.file_path
													 when 7 then invp.payment_reff_no
													 when 8 then cast(invp.payment_reff_date as sql_variant)
													 when 9 then invp.settlement_status
													 when 10 then cast(datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then inv.invoice_external_no
													   when 2 then inv.faktur_no
													   when 3 then invd.billing_to_npwp
													   when 4 then cast(inv.total_pph_amount as sql_variant)
													   when 5 then invp.file_path
													   when 7 then invp.payment_reff_no
													   when 8 then cast(invp.payment_reff_date as sql_variant)
													   when 9 then invp.settlement_status
													   when 10 then cast(datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

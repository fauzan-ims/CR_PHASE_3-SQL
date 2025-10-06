CREATE PROCEDURE dbo.xsp_cashier_transaction_detail_lookup_agreement
(
	@p_keywords					 nvarchar(50)
	,@p_pagenumber				 int
	,@p_rowspage				 int
	,@p_order_by				 int
	,@p_sort_by					 nvarchar(5)
	,@p_cashier_transaction_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	ifinopl.dbo.agreement_main am with (nolock)
	left join ifinopl.dbo.agreement_deposit_main adm on am.agreement_no = adm.agreement_no
	where	am.client_no in 
			(
				select	client_no 
				from	dbo.cashier_transaction 
				where	code = @p_cashier_transaction_code
			) 
			--AND am.agreement_status = 'GO LIVE'
			--and isnull(ctd.agreement_no, '') <> ''
			--and transaction_code is null
			and (
					adm.agreement_no						LIKE '%' + @p_keywords + '%'
					or	isnull(adm.deposit_amount,0)		like '%' + @p_keywords + '%'
				) ;

	select	am.agreement_external_no 'agreement_no'
			,isnull(adm.deposit_amount,0) 'orig_amount'
			,@rows_count 'rowcount'
	from	ifinopl.dbo.agreement_main am with (nolock)
	left join ifinopl.dbo.agreement_deposit_main adm on am.agreement_no = adm.agreement_no
	where	am.client_no in 
			(
				select	client_no 
				from	dbo.cashier_transaction 
				where	code = @p_cashier_transaction_code
			) 
			--AND am.agreement_status = 'GO LIVE'
			--and isnull(ctd.agreement_no, '') <> ''
			--and transaction_code is null
			and (
					adm.agreement_no						LIKE '%' + @p_keywords + '%'
					or	isnull(adm.deposit_amount,0)		like '%' + @p_keywords + '%'
				) 
	order by	
				case  when @p_sort_by = 'asc' then case @p_order_by
														when 1 then am.agreement_external_no
														when 2 then cast(adm.deposit_amount as sql_variant)			 
													end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then am.agreement_external_no
														when 2 then cast(adm.deposit_amount as sql_variant)
											end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


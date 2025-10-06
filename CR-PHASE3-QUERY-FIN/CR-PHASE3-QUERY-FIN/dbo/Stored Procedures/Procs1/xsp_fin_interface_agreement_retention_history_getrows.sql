CREATE PROCEDURE dbo.xsp_fin_interface_agreement_retention_history_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	fin_interface_agreement_retention_history far
	inner join dbo.agreement_main am on (am.agreement_no = far.agreement_no)
	where	(
				far.branch_name											like '%' + @p_keywords + '%'
				or	far.agreement_no									like '%' + @p_keywords + '%'
				or	am.client_name										like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), far.transaction_date, 103)	like '%' + @p_keywords + '%'
				or	far.orig_amount										like '%' + @p_keywords + '%'
				or	orig_currency_code									like '%' + @p_keywords + '%'
			) ;

	select		id
				,far.branch_name
				,far.agreement_no
				,am.client_name
				,convert(nvarchar(30), far.transaction_date, 103) 'transaction_date'
				,orig_amount
				,orig_currency_code
				,@rows_count 'rowcount'
	from		fin_interface_agreement_retention_history far
	inner join dbo.agreement_main am on (am.agreement_no = far.agreement_no)
	where		(
					far.branch_name											like '%' + @p_keywords + '%'
					or	far.agreement_no									like '%' + @p_keywords + '%'
					or	am.client_name										like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), far.transaction_date, 103)	like '%' + @p_keywords + '%'
					or	far.orig_amount										like '%' + @p_keywords + '%'
					or	orig_currency_code									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then far.branch_name
													 when 2 then far.agreement_no
													 when 3 then cast(far.transaction_date as date)
													 when 4 then cast(far.orig_amount as sql_variant)
													 when 5 then far.orig_currency_code
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then far.branch_name
													 when 2 then far.agreement_no
													 when 3 then cast(far.transaction_date as date)
													 when 4 then cast(far.orig_amount as sql_variant)
													 when 5 then far.orig_currency_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

CREATE PROCEDURE dbo.xsp_fin_interface_agreement_amortization_payment_getrows
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
	from	fin_interface_agreement_amortization_payment fiaap
			left join dbo.agreement_main am on (am.agreement_no = fiaap.agreement_no)
	where	(
				am.agreement_external_no							like '%' + @p_keywords + '%'
				or	am.client_name									like '%' + @p_keywords + '%'
				or	installment_no									like '%' + @p_keywords + '%'
				or	convert(varchar(30), payment_date, 103)			like '%' + @p_keywords + '%'
				or	payment_source_no								like '%' + @p_keywords + '%'
				or	payment_amount									like '%' + @p_keywords + '%'
				or	principal_amount								like '%' + @p_keywords + '%'
				or	interest_amount									like '%' + @p_keywords + '%'
			) ;

		select		id
					,am.agreement_no
					,am.agreement_external_no
					,client_name
					,installment_no
					,convert(varchar(30), payment_date, 103) 'payment_date'
					,value_date
					,payment_source_type
					,payment_source_no
					,payment_amount
					,principal_amount
					,interest_amount
					,@rows_count 'rowcount'
		from	fin_interface_agreement_amortization_payment fiaap
				left join dbo.agreement_main am on (am.agreement_no = fiaap.agreement_no)
		where	(
					am.agreement_external_no							like '%' + @p_keywords + '%'
					or	am.client_name									like '%' + @p_keywords + '%'
					or	installment_no									like '%' + @p_keywords + '%'
					or	convert(varchar(30), payment_date, 103)			like '%' + @p_keywords + '%'
					or	payment_source_no								like '%' + @p_keywords + '%'
					or	payment_amount									like '%' + @p_keywords + '%'
					or	principal_amount								like '%' + @p_keywords + '%'
					or	interest_amount									like '%' + @p_keywords + '%'
				)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then agreement_external_no + client_name
														when 2 then cast(installment_no as sql_variant)
														when 3 then cast(payment_date as sql_variant)
														when 4 then payment_source_no
														when 5 then cast(payment_amount as sql_variant)
														when 6 then cast(principal_amount as sql_variant)
														when 7 then cast(interest_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then agreement_external_no + client_name
														when 2 then cast(installment_no as sql_variant)
														when 3 then cast(payment_date as sql_variant)
														when 4 then payment_source_no
														when 5 then cast(payment_amount as sql_variant)
														when 6 then cast(principal_amount as sql_variant)
														when 7 then cast(interest_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

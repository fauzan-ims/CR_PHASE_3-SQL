CREATE PROCEDURE dbo.xsp_fin_interface_agreement_obligation_payment_getrows
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
	from	fin_interface_agreement_obligation_payment fiaop
			left join dbo.agreement_main am on (am.agreement_no = fiaop.agreement_no)
	where	(
				code										like '%' + @p_keywords + '%'
				or	am.agreement_external_no				like '%' + @p_keywords + '%'
				or	am.client_name							like '%' + @p_keywords + '%'
				or	installment_no							like '%' + @p_keywords + '%'
				or	payment_source_type						like '%' + @p_keywords + '%'
				or	payment_source_no						like '%' + @p_keywords + '%'
				or	payment_amount							like '%' + @p_keywords + '%'
				or	payment_remarks							like '%' + @p_keywords + '%'
			) ;

		select		id
					,code
					,am.agreement_external_no	
					,am.client_name	
					,installment_no	
					,payment_source_type + ' - ' + payment_source_no 'payment'
					,payment_amount		
					,payment_remarks
					,@rows_count 'rowcount'
		from	fin_interface_agreement_obligation_payment fiaop
				left join dbo.agreement_main am on (am.agreement_no = fiaop.agreement_no)
		where	(
					code										like '%' + @p_keywords + '%'
					or	am.agreement_external_no				like '%' + @p_keywords + '%'
					or	am.client_name							like '%' + @p_keywords + '%'
					or	installment_no							like '%' + @p_keywords + '%'
					or	payment_source_type						like '%' + @p_keywords + '%'
					or	payment_source_no						like '%' + @p_keywords + '%'
					or	payment_amount							like '%' + @p_keywords + '%'
					or	payment_remarks							like '%' + @p_keywords + '%'
				) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then am.agreement_external_no + am.client_name
														when 3 then fiaop.installment_no
														when 4 then payment_source_type + ' - ' + payment_source_no
														when 5 then cast(payment_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then am.agreement_external_no + am.client_name
														when 3 then fiaop.installment_no
														when 4 then payment_source_type + ' - ' + payment_source_no
														when 5 then cast(payment_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

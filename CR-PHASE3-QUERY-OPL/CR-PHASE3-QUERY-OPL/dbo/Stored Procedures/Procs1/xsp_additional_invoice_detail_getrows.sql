CREATE PROCEDURE dbo.xsp_additional_invoice_detail_getrows
(
	@p_keywords							nvarchar(50)
	,@p_pagenumber						int
	,@p_rowspage						int
	,@p_order_by						int
	,@p_sort_by							nvarchar(5)
	--
	,@p_additional_invoice_code			nvarchar(50)
)
as
begin
	
	declare 	@rows_count int = 0 ;

	select 		@rows_count = count(1)
	from		additional_invoice_detail aid
	left join	dbo.agreement_main am on (am.agreement_no = aid.agreement_no)
	where		aid.additional_invoice_code = @p_additional_invoice_code
	and			(
						aid.agreement_no				like 	'%'+@p_keywords+'%'
					or	aid.description					like 	'%'+@p_keywords+'%'
					or	aid.billing_amount				like 	'%'+@p_keywords+'%'
					or	aid.discount_amount				like 	'%'+@p_keywords+'%'
					or	aid.quantity					like 	'%'+@p_keywords+'%'
					or	aid.ppn_amount					like 	'%'+@p_keywords+'%'
					or	aid.pph_amount					like 	'%'+@p_keywords+'%'
					or	aid.total_amount				like 	'%'+@p_keywords+'%'
					or	am.agreement_external_no		like 	'%'+@p_keywords+'%'
				);

		select		aid.id
					,aid.agreement_no	
					,aid.description		
					,aid.billing_amount	
					,aid.discount_amount	
					,aid.quantity		
					,aid.ppn_amount		
					,aid.pph_amount		
					,aid.total_amount	
					,am.agreement_external_no
					,@rows_count	 'rowcount'
		from		additional_invoice_detail aid
		left join	dbo.agreement_main am on (am.agreement_no = aid.agreement_no)
		where		aid.additional_invoice_code = @p_additional_invoice_code
		and			(
							aid.agreement_no				like 	'%'+@p_keywords+'%'
						or	aid.description					like 	'%'+@p_keywords+'%'
						or	aid.billing_amount				like 	'%'+@p_keywords+'%'
						or	aid.discount_amount				like 	'%'+@p_keywords+'%'
						or	aid.quantity					like 	'%'+@p_keywords+'%'
						or	aid.ppn_amount					like 	'%'+@p_keywords+'%'
						or	aid.pph_amount					like 	'%'+@p_keywords+'%'
						or	aid.total_amount				like 	'%'+@p_keywords+'%'
						or	am.agreement_external_no		like 	'%'+@p_keywords+'%'
					)
		order by	 case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1	then am.agreement_external_no
															when 2	then aid.description
															when 3	then cast(aid.billing_amount as sql_variant)
															when 4	then cast(aid.discount_amount as sql_variant)
															when 5	then cast(aid.quantity as sql_variant)
															when 6	then cast(aid.ppn_amount as sql_variant)
															when 7	then cast(aid.pph_amount as sql_variant)
															when 8	then cast(aid.total_amount as sql_variant)
														end
					end asc
					,case
						when @p_sort_by = 'desc' then case @p_order_by
															when 1	then am.agreement_external_no
															when 2	then aid.description
															when 3	then cast(aid.billing_amount as sql_variant)
															when 4	then cast(aid.discount_amount as sql_variant)
															when 5	then cast(aid.quantity as sql_variant)
															when 6	then cast(aid.ppn_amount as sql_variant)
															when 7	then cast(aid.pph_amount as sql_variant)
															when 8	then cast(aid.total_amount as sql_variant)
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end

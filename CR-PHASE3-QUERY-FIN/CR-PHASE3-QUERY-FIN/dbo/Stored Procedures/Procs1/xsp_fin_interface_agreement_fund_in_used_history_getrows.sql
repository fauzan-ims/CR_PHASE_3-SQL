CREATE PROCEDURE dbo.xsp_fin_interface_agreement_fund_in_used_history_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.fin_interface_agreement_fund_in_used_history fiafiuh
			left join dbo.agreement_main am on (am.agreement_no = fiafiuh.agreement_no)
			inner join dbo.master_transaction mt on (mt.code = fiafiuh.charges_type)
	where	(
					am.agreement_external_no		like '%' + @p_keywords + '%'
					or	am.client_name				like '%' + @p_keywords + '%'
					or	transaction_no				like '%' + @p_keywords + '%'
					or	mt.transaction_name			like '%' + @p_keywords + '%'
					or  charges_amount				like '%' + @p_keywords + '%'
					or  source_reff_remarks			like '%' + @p_keywords + '%'

				) ;

		select		id
                    ,agreement_external_no
					,client_name
                    ,charges_date
                    ,charges_type
                    ,transaction_no
                    ,mt.transaction_name
                    ,charges_amount
                    ,source_reff_module
                    ,source_reff_remarks
					,@rows_count 'rowcount'
		from	dbo.fin_interface_agreement_fund_in_used_history fiafiuh
				left join dbo.agreement_main am on (am.agreement_no = fiafiuh.agreement_no)
				inner join dbo.master_transaction mt on (mt.code = fiafiuh.charges_type)
		where	(
						am.agreement_external_no		like '%' + @p_keywords + '%'
						or	am.client_name				like '%' + @p_keywords + '%'
						or	transaction_no				like '%' + @p_keywords + '%'
						or	mt.transaction_name			like '%' + @p_keywords + '%'
						or  charges_amount				like '%' + @p_keywords + '%'
						or  source_reff_remarks			like '%' + @p_keywords + '%'

					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then agreement_external_no + am.client_name
														when 2 then transaction_no
														when 3 then mt.transaction_name
														when 4 then cast(charges_amount as sql_variant)
														when 5 then source_reff_remarks
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then agreement_external_no + am.client_name
														when 2 then transaction_no
														when 3 then mt.transaction_name
														when 4 then cast(charges_amount as sql_variant)
														when 5 then source_reff_remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

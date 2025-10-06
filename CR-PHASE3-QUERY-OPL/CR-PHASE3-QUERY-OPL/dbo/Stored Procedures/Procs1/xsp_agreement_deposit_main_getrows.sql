/*
	to module core
*/
CREATE procedure dbo.xsp_agreement_deposit_main_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_agreement_no		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.agreement_deposit_main dm
			left join dbo.agreement_main am on (am.agreement_no = dm.agreement_no)
	where	dm.agreement_no = @p_agreement_no
			and (
					code						                        like '%' + @p_keywords + '%'
					or	dm.branch_code									like '%' + @p_keywords + '%'
					or	dm.branch_name									like '%' + @p_keywords + '%'
					or	am.agreement_external_no						like '%' + @p_keywords + '%'
					or	am.client_name									like '%' + @p_keywords + '%'
					or	deposit_type			                        like '%' + @p_keywords + '%'
					or	deposit_currency_code			                like '%' + @p_keywords + '%'
					or	deposit_amount									like '%' + @p_keywords + '%'
			) ;

	
		select		code
					,dm.branch_code
					,dm.branch_name
					,agreement_external_no 
					,am.client_name
					,deposit_type
					,deposit_currency_code
					,deposit_amount	
					,@rows_count 'rowcount'
		from		dbo.agreement_deposit_main dm
					left join dbo.agreement_main am on (am.agreement_no = dm.agreement_no)
		where		dm.agreement_no = @p_agreement_no
					and (
							code						                        like '%' + @p_keywords + '%'
							or	dm.branch_code									like '%' + @p_keywords + '%'
							or	dm.branch_name									like '%' + @p_keywords + '%'
							or	am.agreement_external_no						like '%' + @p_keywords + '%'
							or	am.client_name									like '%' + @p_keywords + '%'
							or	deposit_type			                        like '%' + @p_keywords + '%'
							or	deposit_currency_code			                like '%' + @p_keywords + '%'
							or	deposit_amount									like '%' + @p_keywords + '%'
					)
		order by	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code			                    
														when 2 then dm.branch_name						
														when 3 then	am.agreement_external_no + am.client_name
														when 4 then deposit_type
														when 5 then deposit_currency_code
														when 6 then cast(deposit_amount as sql_variant)
													 end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then code			                    
															when 2 then dm.branch_name						
															when 3 then	am.agreement_external_no + am.client_name
															when 4 then deposit_type
															when 5 then deposit_currency_code
															when 6 then cast(deposit_amount as sql_variant)
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

CREATE PROCEDURE [dbo].[xsp_asset_expense_ledger_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_asset_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset_expense_ledger ael
	left join ifinopl.dbo.agreement_main agm on (ael.agreement_no = agm.agreement_no)
	where	asset_code = @p_asset_code
	and		(
				convert(nvarchar(30), date, 103)		like '%' + @p_keywords + '%'
				or	reff_code							like '%' + @p_keywords + '%'
				or	reff_name							like '%' + @p_keywords + '%'
				or	reff_remark							like '%' + @p_keywords + '%'
				or	expense_amount						like '%' + @p_keywords + '%'
				or	agm.agreement_external_no			like '%' + @p_keywords + '%'
				or	ael.client_name						like '%' + @p_keywords + '%'
			) ;

	select		asset_code
				,convert(nvarchar(30), date, 103) 'date'
				,ael.client_name
				,ael.agreement_no
				,agm.agreement_external_no
				,reff_code
				,reff_name
				,reff_remark
				,expense_amount
				,@rows_count 'rowcount'
	from		dbo.asset_expense_ledger ael
	left join ifinopl.dbo.agreement_main agm on (ael.agreement_no = agm.agreement_no)
	where		asset_code = @p_asset_code
	and			(
					convert(nvarchar(30), date, 103)		like '%' + @p_keywords + '%'
					or	reff_code							like '%' + @p_keywords + '%'
					or	reff_name							like '%' + @p_keywords + '%'
					or	reff_remark							like '%' + @p_keywords + '%'
					or	expense_amount						like '%' + @p_keywords + '%'
					or	agm.agreement_external_no			like '%' + @p_keywords + '%'
					or	ael.client_name						like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then reff_code
													 when 2 then reff_name
													 when 3 then cast(ael.date as sql_variant)
													 when 4 then agm.agreement_external_no
													 when 5 then reff_remark
													 when 6 then cast(expense_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then reff_code
													  when 2 then reff_name
													  when 3 then cast(ael.date as sql_variant)
													  when 4 then agm.agreement_external_no
													  when 5 then reff_remark
													  when 6 then cast(expense_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

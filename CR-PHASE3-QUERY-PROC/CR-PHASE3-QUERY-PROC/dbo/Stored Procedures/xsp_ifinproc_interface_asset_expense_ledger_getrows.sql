CREATE PROCEDURE dbo.xsp_ifinproc_interface_asset_expense_ledger_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.ifinproc_interface_asset_expense_ledger
	where(
				asset_code									like '%' + @p_keywords + '%'
				or	convert(varchar(30), date, 103)			like '%' + @p_keywords + '%'
				or	reff_code								like '%' + @p_keywords + '%'
				or	reff_name								like '%' + @p_keywords + '%'
				or	agreement_no							like '%' + @p_keywords + '%'
				or	client_name								like '%' + @p_keywords + '%'
				or	reff_remark								like '%' + @p_keywords + '%'
				or	expense_amount							like '%' + @p_keywords + '%'
			) ;

	select		id
				,asset_code
				,convert(varchar(30), date, 103) 'date'
				,reff_code
				,reff_name
				,reff_remark
				,expense_amount
				,agreement_no
				,client_name
				,@rows_count 'rowcount'
	from		dbo.ifinproc_interface_asset_expense_ledger
	where		(
					asset_code									like '%' + @p_keywords + '%'
					or	convert(varchar(30), date, 103)			like '%' + @p_keywords + '%'
					or	reff_code								like '%' + @p_keywords + '%'
					or	reff_name								like '%' + @p_keywords + '%'
					or	agreement_no							like '%' + @p_keywords + '%'
					or	client_name								like '%' + @p_keywords + '%'
					or	reff_remark								like '%' + @p_keywords + '%'
					or	expense_amount							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then reff_code
													 when 3 then cast(date as sql_variant)
													 when 4 then agreement_no
													 when 5 then client_name
													 when 6 then reff_remark
													 when 7 then cast(expense_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then asset_code
														when 2 then reff_code
														when 3 then cast(date as sql_variant)
														when 4 then agreement_no
														when 5 then client_name
														when 6 then reff_remark
														when 7 then cast(expense_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

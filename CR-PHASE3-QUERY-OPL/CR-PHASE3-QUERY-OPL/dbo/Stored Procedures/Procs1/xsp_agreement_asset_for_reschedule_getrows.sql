create PROCEDURE dbo.xsp_agreement_asset_for_reschedule_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_agreement_no nvarchar(50)
	,@p_asset_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_asset ast
			inner join dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
	where	ast.agreement_no	 = @p_agreement_no
			and ast.asset_status = @p_asset_status
			and (
					am.agreement_external_no						like '%' + @p_keywords + '%'
					or	am.client_name								like '%' + @p_keywords + '%'
					or	ast.asset_no								like '%' + @p_keywords + '%'
					or	ast.asset_name								like '%' + @p_keywords + '%'
					or	ast.asset_year								like '%' + @p_keywords + '%'
					or	ast.lease_round_amount						like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), ast.return_date, 103)	like '%' + @p_keywords + '%'
					or	ast.asset_status							like '%' + @p_keywords + '%'
				) ;

	select		ast.asset_no
				,ast.asset_name
				,ast.asset_year
				,ast.asset_condition
				,ast.lease_round_amount
				,ast.net_margin_amount
				,convert(nvarchar(15), ast.return_date, 103) 'return_date'
				,ast.asset_status
				,am.agreement_external_no
				,am.client_name
				,@rows_count 'rowcount'
	from		agreement_asset ast
				inner join dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
	where		ast.agreement_no	 = @p_agreement_no
				and ast.asset_status = @p_asset_status
				and (
						am.agreement_external_no						like '%' + @p_keywords + '%'
						or	am.client_name								like '%' + @p_keywords + '%'
						or	ast.asset_no								like '%' + @p_keywords + '%'
						or	ast.asset_name								like '%' + @p_keywords + '%'
						or	ast.asset_year								like '%' + @p_keywords + '%'
						or	ast.lease_round_amount						like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), ast.return_date, 103)	like '%' + @p_keywords + '%'
						or	ast.asset_status							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then ast.asset_no + ast.asset_name
													 when 3 then ast.asset_year
													 when 4 then cast(ast.lease_round_amount as sql_variant)
													 when 5 then cast(ast.return_date as sql_variant)
													 when 6 then ast.asset_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then ast.asset_no + ast.asset_name
													 when 3 then ast.asset_year
													 when 4 then cast(ast.lease_round_amount as sql_variant)
													 when 5 then cast(ast.return_date as sql_variant)
													 when 6 then ast.asset_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

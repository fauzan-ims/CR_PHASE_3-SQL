CREATE PROCEDURE dbo.xsp_budget_approval_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_status	   nvarchar(50) = 'All'
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	budget_approval ba
			inner join dbo.application_asset aa on (aa.asset_no		 = ba.asset_no)
			inner join dbo.application_main am on (am.application_no = aa.application_no)
			inner join dbo.client_main cm on (cm.code				 = am.client_code)
	where	ba.status = case @p_status
							when 'ALL' then ba.status
							else @p_status
						end
			and (
					am.application_external_no				like '%' + @p_keywords + '%'
					or	cm.client_name						like '%' + @p_keywords + '%'
					or	am.marketing_name					like '%' + @p_keywords + '%'
					or	aa.asset_no							like '%' + @p_keywords + '%'
					or	aa.asset_name						like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), ba.date, 103) like '%' + @p_keywords + '%'
					or	ba.status							like '%' + @p_keywords + '%'
				) ;

	select		ba.code
				,am.application_external_no						
				,cm.client_name						
				,am.marketing_name					
				,aa.asset_no							
				,aa.asset_name						
				,convert(nvarchar(15), ba.date, 103) 'date'
				,ba.status							
				,@rows_count 'rowcount'
	from		budget_approval ba
				inner join dbo.application_asset aa on (aa.asset_no		 = ba.asset_no)
				inner join dbo.application_main am on (am.application_no = aa.application_no)
				inner join dbo.client_main cm on (cm.code				 = am.client_code)
	where		ba.status = case @p_status
								when 'all' then ba.status
								else @p_status
							end
				and (
						am.application_external_no				like '%' + @p_keywords + '%'
						or	cm.client_name						like '%' + @p_keywords + '%'
						or	am.marketing_name					like '%' + @p_keywords + '%'
						or	aa.asset_no							like '%' + @p_keywords + '%'
						or	aa.asset_name						like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), ba.date, 103) like '%' + @p_keywords + '%'
						or	ba.status							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.application_external_no + cm.client_name
													 when 2 then am.marketing_name
													 when 3 then aa.asset_no + aa.asset_name
													 when 4 then cast(ba.date as sql_variant)
													 when 5 then ba.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then am.application_external_no + cm.client_name
													   when 2 then am.marketing_name
													   when 3 then aa.asset_no + aa.asset_name
													   when 4 then cast(ba.date as sql_variant)
													   when 5 then ba.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

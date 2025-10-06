CREATE PROCEDURE dbo.xsp_purchase_request_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_branch_code	   nvarchar(50)
	,@p_request_status nvarchar(10) = 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	purchase_request pr
			left join dbo.application_asset aa on (aa.asset_no = pr.asset_no)
			left join dbo.application_main am on (am.application_no = aa.application_no)
			left join dbo.client_main cm on (cm.code				 = am.client_code)
	where	pr.branch_code		  = case @p_branch_code
										when 'ALL' then pr.branch_code
										else @p_branch_code
									end
			and pr.request_status = case @p_request_status
										when 'ALL' then pr.request_status
										else @p_request_status
									end
			and	pr.categori_type = 'ASSET'
			and (
					pr.code											like '%' + @p_keywords + '%'
					or pr.branch_name								like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), pr.request_date, 103) like '%' + @p_keywords + '%'
					or	pr.request_status							like '%' + @p_keywords + '%'
					or	pr.description								like '%' + @p_keywords + '%'
					or	pr.result_fa_name							like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), pr.result_date, 103)  like '%' + @p_keywords + '%'
					or	am.application_external_no					like '%' + @p_keywords + '%'
					or	cm.client_name								like '%' + @p_keywords + '%'
					or	aa.asset_no									like '%' + @p_keywords + '%'
					or	aa.asset_name								like '%' + @p_keywords + '%'
				) ;

	select		pr.code
				,pr.branch_name
				,convert(nvarchar(15), pr.request_date, 103) 'request_date'
				,pr.request_status
				,pr.description
				,pr.result_fa_name
				,convert(nvarchar(15), pr.result_date, 103) 'result_date'
				,am.application_external_no
				,cm.client_name
				,aa.asset_no
				,aa.asset_name
				,pr.unit_from
				,@rows_count 'rowcount'
	from		purchase_request pr
				left join dbo.application_asset aa on (aa.asset_no = pr.asset_no)
				left join dbo.application_main am on (am.application_no = aa.application_no)
				left join dbo.client_main cm on (cm.code				 = am.client_code)
	where		pr.branch_code		  = case @p_branch_code
											when 'ALL' then pr.branch_code
											else @p_branch_code
										end
				and pr.request_status = case @p_request_status
											when 'ALL' then pr.request_status
											else @p_request_status
										end
				and	pr.categori_type = 'ASSET'
				and (
						pr.code											like '%' + @p_keywords + '%'
						or  pr.branch_name								like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), pr.request_date, 103) like '%' + @p_keywords + '%'
						or	pr.request_status							like '%' + @p_keywords + '%'
						or	pr.description								like '%' + @p_keywords + '%'
						or	pr.result_fa_name							like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), pr.result_date, 103)  like '%' + @p_keywords + '%'
						or	am.application_external_no					like '%' + @p_keywords + '%'
						or	cm.client_name								like '%' + @p_keywords + '%'
						or	aa.asset_no									like '%' + @p_keywords + '%'
						or	aa.asset_name								like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.application_external_no + cm.client_name
													 when 2 then aa.asset_no + aa.asset_name
													 when 3 then pr.code
													 when 4 then pr.branch_name
													 when 5 then cast(pr.request_date as sql_variant)
													 when 6 then pr.request_status
													 when 7 then pr.description
													 when 8 then pr.result_fa_name 
													 when 9 then cast(pr.result_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then am.application_external_no + cm.client_name
														when 2 then aa.asset_no + aa.asset_name
														when 3 then pr.code
														when 4 then pr.branch_name
														when 5 then cast(pr.request_date as sql_variant)
														when 6 then pr.request_status
														when 7 then pr.description
														when 8 then pr.result_fa_name 
														when 9 then cast(pr.result_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

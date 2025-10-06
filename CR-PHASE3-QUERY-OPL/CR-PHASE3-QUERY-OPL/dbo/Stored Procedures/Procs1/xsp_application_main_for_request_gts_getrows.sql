CREATE PROCEDURE dbo.xsp_application_main_for_request_gts_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_marketing_code	 nvarchar(50) 
	,@p_branch_code		 nvarchar(50) 
)
as
begin
	declare @rows_count int = 0
			,@status	nvarchar(max) ;

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
	from	application_main ap
			inner join dbo.client_main cm on (cm.code	 = ap.client_code)
			left join dbo.master_facility mf on (mf.code = ap.facility_code)
			left join dbo.master_workflow mw on (mw.code = ap.level_status)
			outer apply
				(
					select	count(aps.asset_no) 'count_asset'
							,max(datediff(day, aps.request_delivery_date, aps.estimate_po_date)) 'po_aging_day'
					from	dbo.application_asset aps
					where	aps.application_no = ap.application_no
					and		isnull(aps.fa_code, '') = ''
				) apas
	where	ap.branch_code			  = case @p_branch_code
											when 'ALL' then ap.branch_code
											else @p_branch_code
										end
			--and ap.marketing_code			= @p_marketing_code
			and ap.application_status	= 'GO LIVE'
			and	ap.level_status			= 'ALLOCATION'
			--and apas.po_aging_day		is not null
			and (
					ap.application_external_no									like '%' + @p_keywords + '%'
					or cm.client_name											like '%' + @p_keywords + '%'
					or ap.branch_name											like '%' + @p_keywords + '%'
					or convert(varchar(30), ap.application_date, 103)			like '%' + @p_keywords + '%'
					or mf.description											like '%' + @p_keywords + '%' 
					or ap.marketing_name										like '%' + @p_keywords + '%' 
					or ap.application_status									like '%' + @p_keywords + '%' 
					or ap.level_status											like '%' + @p_keywords + '%' 
					or apas.count_asset											like '%' + @p_keywords + '%' 
					or convert(varchar,cast(ap.rental_amount as money), 1)		like '%' + @p_keywords + '%' 
				) ;

	select		ap.application_no
				,ap.application_external_no
				,cm.client_name
				,ap.branch_name
				,convert(varchar(30), ap.application_date, 103) 'application_date'
				,mf.description 'facility_desc'
				,ap.application_status
				,ap.level_status 'level_code'
				,isnull(mw.description, ap.level_status) 'level_status'
				,ap.return_count
				,ap.agreement_external_no
				,ap.rental_amount
				,ap.currency_code
				,ap.marketing_name
				,apas.count_asset
				,apas.po_aging_day
				,@rows_count 'rowcount'
	from		application_main ap
				inner join dbo.client_main cm on (cm.code	 = ap.client_code)
				left join dbo.master_facility mf on (mf.code = ap.facility_code)
				left join dbo.master_workflow mw on (mw.code = ap.level_status)
				outer apply
				(
					select	count(aps.asset_no) 'count_asset'
							,max(datediff(day, aps.request_delivery_date, aps.estimate_po_date)) 'po_aging_day'
					from	dbo.application_asset aps
					where	aps.application_no = ap.application_no
					and		isnull(aps.fa_code, '') = ''
				) apas
	where		ap.branch_code			  = case @p_branch_code
											when 'ALL' then ap.branch_code
											else @p_branch_code
										end
				--and ap.marketing_code			= @p_marketing_code
				and ap.application_status	= 'GO LIVE'
				and	ap.level_status			= 'ALLOCATION'
				--and apas.po_aging_day		is not null
				and (
						ap.application_external_no									like '%' + @p_keywords + '%'
						or cm.client_name											like '%' + @p_keywords + '%'
						or ap.branch_name											like '%' + @p_keywords + '%'
						or convert(varchar(30), ap.application_date, 103)			like '%' + @p_keywords + '%'
						or mf.description											like '%' + @p_keywords + '%' 
						or ap.marketing_name										like '%' + @p_keywords + '%' 
						or ap.application_status									like '%' + @p_keywords + '%' 
						or ap.level_status											like '%' + @p_keywords + '%' 
						or apas.count_asset											like '%' + @p_keywords + '%' 
						or convert(varchar,cast(ap.rental_amount as money), 1)		like '%' + @p_keywords + '%' 
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ap.application_external_no + cm.client_name
													 when 2 then ap.branch_name
													 when 3 then cast(ap.application_date as sql_variant)
													 when 4 then apas.count_asset
													 when 5 then apas.po_aging_day
													 when 6 then ap.currency_code
													 when 7 then cast(ap.rental_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ap.application_external_no + cm.client_name
													 when 2 then ap.branch_name
													 when 3 then cast(ap.application_date as sql_variant)
													 when 4 then apas.count_asset
													 when 5 then apas.po_aging_day
													 when 6 then ap.currency_code
													 when 7 then cast(ap.rental_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

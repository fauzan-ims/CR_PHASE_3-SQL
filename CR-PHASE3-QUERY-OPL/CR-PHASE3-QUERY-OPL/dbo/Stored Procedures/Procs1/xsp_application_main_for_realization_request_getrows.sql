CREATE PROCEDURE [dbo].[xsp_application_main_for_realization_request_getrows]
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
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
			left join dbo.client_main cm on (cm.code	 = ap.client_code)
			left join dbo.application_asset aa on (aa.application_no = ap.application_no) 
	where	ap.branch_code			  = case @p_branch_code
											when 'ALL' then ap.branch_code
											else @p_branch_code
										end
			--and (aa.fa_code is not null or aa.replacement_fa_code is not null)
			and aa.realization_code is null
			and (aa.purchase_status = 'REALIZATION' or aa.purchase_gts_status = 'REALIZATION')
			and (
					ap.application_external_no									like '%' + @p_keywords + '%'
					or cm.client_name											like '%' + @p_keywords + '%'
					or ap.branch_name											like '%' + @p_keywords + '%'
					or convert(varchar(30), ap.application_date, 103)			like '%' + @p_keywords + '%' 
					or aa.asset_no												like '%' + @p_keywords + '%' 
					or aa.asset_name											like '%' + @p_keywords + '%' 
					or aa.deliver_to_name										like '%' + @p_keywords + '%' 
					or aa.deliver_to_area_no + ' ' + aa.deliver_to_phone_no		like '%' + @p_keywords + '%' 
					or aa.deliver_to_address									like '%' + @p_keywords + '%' 
					or isnull(aa.fa_code, aa.replacement_fa_code)				like '%' + @p_keywords + '%' 
					or isnull(aa.fa_name, aa.replacement_fa_name)				like '%' + @p_keywords + '%' 
					or isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)	like '%' + @p_keywords + '%' 
				);

	select		ap.application_no
				,ap.application_external_no
				,cm.client_name
				,ap.branch_name
				,convert(varchar(30), ap.application_date, 103) 'application_date'
				,ap.application_status
				,ap.return_count
				,ap.agreement_external_no
				,ap.rental_amount
				,ap.currency_code
				,ap.marketing_name
				,aa.asset_no
				,aa.asset_name
				,isnull(aa.fa_code, aa.replacement_fa_code) 'fa_code'
				,isnull(aa.fa_name, aa.replacement_fa_name)	+ ' - ' + isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)	'fa_name'
				,'Name : ' + aa.deliver_to_name 'deliver_to_name'
				,'Phone : ' + aa.deliver_to_area_no + ' ' + aa.deliver_to_phone_no 'deliver_phone_no'
				,'Address : ' + aa.deliver_to_address 'deliver_to_address'
				,@rows_count 'rowcount'
	from		application_main ap
				left join dbo.client_main cm on (cm.code	 = ap.client_code)
				left join dbo.application_asset aa on (aa.application_no = ap.application_no) 
	where		ap.branch_code			  = case @p_branch_code
												when 'ALL' then ap.branch_code
												else @p_branch_code
											end
				--and (aa.fa_code is not null or aa.replacement_fa_code is not null)
				and aa.realization_code is null
				and (aa.purchase_status = 'REALIZATION' or aa.purchase_gts_status = 'REALIZATION')
				and (
						ap.application_external_no									like '%' + @p_keywords + '%'
						or cm.client_name											like '%' + @p_keywords + '%'
						or ap.branch_name											like '%' + @p_keywords + '%'
						or convert(varchar(30), ap.application_date, 103)			like '%' + @p_keywords + '%' 
						or aa.asset_no												like '%' + @p_keywords + '%' 
						or aa.asset_name											like '%' + @p_keywords + '%' 
						or aa.deliver_to_name										like '%' + @p_keywords + '%' 
						or aa.deliver_to_area_no + ' ' + aa.deliver_to_phone_no		like '%' + @p_keywords + '%' 
						or aa.deliver_to_address									like '%' + @p_keywords + '%' 
						or isnull(aa.fa_code, aa.replacement_fa_code)				like '%' + @p_keywords + '%' 
						or isnull(aa.fa_name, aa.replacement_fa_name)				like '%' + @p_keywords + '%' 
						or isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)	like '%' + @p_keywords + '%' 
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ap.application_external_no + cm.client_name
													 when 2 then ap.branch_name
													 when 3 then cast(ap.application_date as sql_variant)
													 when 4 then aa.asset_no + aa.asset_name
													 when 5 then aa.deliver_to_name
													 when 6 then isnull(aa.fa_code, aa.replacement_fa_code)	+ isnull(aa.fa_name, aa.replacement_fa_name) + isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ap.application_external_no + cm.client_name
													 when 2 then ap.branch_name
													 when 3 then cast(ap.application_date as sql_variant)
													 when 4 then aa.asset_no + aa.asset_name
													 when 5 then aa.deliver_to_name
													 when 6 then isnull(aa.fa_code, aa.replacement_fa_code)	+ isnull(aa.fa_name, aa.replacement_fa_name) + isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

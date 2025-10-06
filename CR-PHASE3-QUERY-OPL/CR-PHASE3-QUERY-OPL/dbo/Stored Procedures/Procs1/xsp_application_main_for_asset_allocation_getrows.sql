
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_application_main_for_asset_allocation_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
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
	from	application_main ap with (nolock)
			--inner join dbo.client_main cm on (cm.code = ap.client_code)
			left join dbo.master_facility mf with (nolock) on (mf.code = ap.facility_code)
			left join dbo.master_workflow mw with (nolock) on (mw.code = ap.level_status)
			--outer apply
			--(
			--	select	count(1) 'realization_count'
			--	from	dbo.application_asset aa 
			--	where	aa.application_no	   = ap.application_no
			--			and aa.purchase_status = 'AGREEMENT'
			--) aa
			outer apply
			(
				select	count(aa.is_request_gts) 'request_gts_count'
				from	dbo.application_asset aa with (nolock) 
				where	aa.application_no	   = ap.application_no
						and aa.is_request_gts = '1'
						and aa.purchase_gts_status = 'NONE'
			)gts
	where	ap.branch_code			  = case @p_branch_code
											when 'ALL' then ap.branch_code
											else @p_branch_code
										end
			and ap.application_status = 'GO LIVE'
			and ap.level_status		  = 'ALLOCATION'
			--and realization_count	  = 0
			and ap.is_simulation	  =	0
			--AND ap.APPLICATION_NO IN (
			--	SELECT APPLICATION_NO FROM dbo.APPLICATION_ASSET WHERE PURCHASE_STATUS = 'NONE')
			and (
					ap.application_external_no									like '%' + @p_keywords + '%'
					or ap.client_name											like '%' + @p_keywords + '%'
					or ap.branch_name											like '%' + @p_keywords + '%'
					or ap.currency_code											like '%' + @p_keywords + '%'
					or convert(varchar(30), ap.application_date, 103)			like '%' + @p_keywords + '%'
					or mf.description											like '%' + @p_keywords + '%' 
					or ap.marketing_name										like '%' + @p_keywords + '%' 
					or ap.application_status									like '%' + @p_keywords + '%' 
					or ap.level_status											like '%' + @p_keywords + '%' 
					or gts.request_gts_count									like '%' + @p_keywords + '%' 
					or convert(varchar,cast(ap.rental_amount as money), 1)		LIKE '%' + @p_keywords + '%'
				) ;

	select		ap.application_no
				,ap.application_external_no
				,ap.client_name
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
				,isnull(gts.request_gts_count, 0) 'request_gts_count'
				,@rows_count 'rowcount'
	from		application_main ap with (nolock)
				--inner join dbo.client_main cm on (cm.code	 = ap.client_code)
				left join dbo.master_facility mf with (nolock) on (mf.code = ap.facility_code)
				left join dbo.master_workflow mw with (nolock) on (mw.code = ap.level_status)
				--outer apply
				--(
				--	select	count(1) 'realization_count'
				--	from	dbo.application_asset aa 
				--	where	aa.application_no	   = ap.application_no
				--			and aa.purchase_status = 'AGREEMENT'
				--) aa
				outer apply
				(
					select	count(1) 'request_gts_count'
					from	dbo.application_asset aa with (nolock) 
					where	aa.application_no	   = ap.application_no
							and aa.is_request_gts = '1'
							and aa.purchase_gts_status = 'NONE'
				)gts
	where		ap.application_status = 'GO LIVE'
				and ap.level_status		  = 'ALLOCATION'
				--and realization_count	  = 0
				and ap.is_simulation	  =	0
				--AND ap.APPLICATION_NO IN (
				--SELECT APPLICATION_NO FROM dbo.APPLICATION_ASSET WHERE PURCHASE_STATUS = 'NONE')
				and ap.branch_code			  = case @p_branch_code
												when 'ALL' then ap.branch_code
												else @p_branch_code
											end
				and (
						ap.application_external_no									like '%' + @p_keywords + '%'
						or ap.client_name											like '%' + @p_keywords + '%'
						or ap.branch_name											like '%' + @p_keywords + '%'
						or ap.currency_code											like '%' + @p_keywords + '%'
						or convert(varchar(30), ap.application_date, 103)			like '%' + @p_keywords + '%'
						or mf.description											like '%' + @p_keywords + '%' 
						or ap.marketing_name										like '%' + @p_keywords + '%' 
						or ap.application_status									like '%' + @p_keywords + '%' 
						or ap.level_status											like '%' + @p_keywords + '%' 
						or convert(varchar,cast(ap.rental_amount as money), 1)		LIKE '%' + @p_keywords + '%'
						or gts.request_gts_count									like '%' + @p_keywords + '%' 
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ap.application_external_no + ap.client_name
													 when 2 then ap.branch_name
													 when 3 then cast(ap.application_date as sql_variant)
													 when 4 then ap.currency_code
													 when 5 then cast(gts.request_gts_count as sql_variant)
													 when 6 then cast(ap.rental_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ap.application_external_no + ap.client_name
													   when 2 then ap.branch_name
													   when 3 then cast(ap.application_date as sql_variant)
													   when 4 then ap.currency_code
													   when 5 then cast(gts.request_gts_count as sql_variant)
													   when 6 then cast(ap.rental_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

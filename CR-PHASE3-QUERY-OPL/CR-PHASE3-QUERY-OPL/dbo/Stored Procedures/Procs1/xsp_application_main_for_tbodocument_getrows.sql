CREATE PROCEDURE [dbo].[xsp_application_main_for_tbodocument_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_cre_by		nvarchar(50)
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
			inner join dbo.client_main cm on (cm.code = ap.client_code)
			inner join dbo.master_facility mf on (mf.code = ap.facility_code)
			left join dbo.master_workflow mw on (mw.code = ap.level_status)
			outer apply
			(
				select top 1
						promise_date
				from	dbo.application_doc ad
				where	ad.application_no = ap.application_no 
						and ad.promise_date is not null
			) ad
			outer apply
			(
				select isnull(count(ad.id), 0) 'waive_status'
				from	dbo.application_doc ad
				where	ad.promise_date is not null
					and ad.application_no = ap.application_no
					and ad.waive_status = 'REQUEST'
			) ad_waive
	where	ap.branch_code = case @p_branch_code
								 when 'ALL' then ap.branch_code
								 else @p_branch_code
							 end
			and  ad.promise_date is not null
			and ap.application_status not in ('CANCEL' , 'HOLD')
			--and ap.marketing_code = @p_cre_by
			and (
					ap.application_external_no							like '%' + @p_keywords + '%'
					or cm.client_name									like '%' + @p_keywords + '%'
					or ap.branch_name									like '%' + @p_keywords + '%'
					or convert(varchar(30), ap.application_date, 103)	like '%' + @p_keywords + '%'
					or mf.description									like '%' + @p_keywords + '%' 
					or ap.application_status							like '%' + @p_keywords + '%'
					or mw.description									like '%' + @p_keywords + '%'
				) 
				

	select		ap.application_no 
				,ap.application_external_no
				,cm.client_name
				,ap.branch_name
				,convert(varchar(30), ap.application_date, 103) 'application_date'
				,mf.description 'facility_desc' 
				,ap.application_status
				,isnull(mw.description, ap.level_status) 'level_status'
				,waive_status
				,@rows_count 'rowcount'
	from		application_main ap
				inner join dbo.client_main cm on (cm.code = ap.client_code)
				inner join dbo.master_facility mf on (mf.code = ap.facility_code)
				left join dbo.master_workflow mw on (mw.code = ap.level_status)
				outer apply
				(
					select top 1
							promise_date
					from	dbo.application_doc ad
					where	ad.application_no = ap.application_no 
							and ad.promise_date is not null
				) ad
				outer apply
				(
					select isnull(count(ad.id), 0) 'waive_status'
					from	dbo.application_doc ad
					where	ad.promise_date is not null
						and ad.application_no = ap.application_no
						and ad.waive_status = 'REQUEST'
				) ad_waive
	where		ap.branch_code = case @p_branch_code
										when 'ALL' then ap.branch_code
										else @p_branch_code
									end
				and ad.promise_date is not null
				and ap.application_status not in ('CANCEL', 'HOLD')
				--and ap.marketing_code = @p_cre_by
				and (
						ap.application_external_no							like '%' + @p_keywords + '%'
						or cm.client_name									like '%' + @p_keywords + '%'
						or ap.branch_name									like '%' + @p_keywords + '%'
						or convert(varchar(30), ap.application_date, 103)	like '%' + @p_keywords + '%'
						or mf.description									like '%' + @p_keywords + '%' 
						or ap.application_status							like '%' + @p_keywords + '%'
						or mw.description									like '%' + @p_keywords + '%'
					)
			
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ap.application_external_no + cm.client_name
														when 2 then ap.branch_name
														when 3 then cast(ap.application_date as sql_variant)
														when 4 then mf.description 
														when 5 then ap.application_status + isnull(mw.description, ap.level_status)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ap.application_external_no + cm.client_name
														when 2 then ap.branch_name
														when 3 then cast(ap.application_date as sql_variant)
														when 4 then mf.description 
														when 5 then ap.application_status + isnull(mw.description, ap.level_status)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;


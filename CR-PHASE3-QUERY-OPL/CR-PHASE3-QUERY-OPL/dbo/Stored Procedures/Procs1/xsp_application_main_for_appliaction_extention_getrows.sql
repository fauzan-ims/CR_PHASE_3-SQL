
--created by, Rian at 22/05/2023 

CREATE PROCEDURE dbo.xsp_application_main_for_appliaction_extention_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_branch_code			nvarchar(50)
	,@p_marketing_code		nvarchar(50)
	,@p_is_valid			nvarchar(3)	 = 'ALL'
)
as
begin
	declare @rows_count int = 0

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
			inner join dbo.master_facility mf on (mf.code = ap.facility_code)
			left join dbo.master_workflow mw on (mw.code = ap.level_status)
			left join dbo.application_extention ae on (ae.application_no = ap.application_no)
	where	ap.branch_code = case @p_branch_code
									when 'ALL' then ap.branch_code
									else @p_branch_code
								end
			and ap.application_status in ('GO LIVE', 'APPROVE')
			and	ap.level_status	in ('ALLOCATION', 'REALIZATION', 'GO LIVE')
			--and ap.application_no not in (select application_no from dbo.agreement_main with (nolock))
			and isnull(ae.is_valid, '0') = case @p_is_valid
											 when 'ALL' then isnull(ae.is_valid, '0')
											 else @p_is_valid
										 end
			and (
					ap.application_external_no											 like '%' + @p_keywords + '%'
					or ae.main_contract_no												 like '%' + @p_keywords + '%'
					or ap.client_name													 like '%' + @p_keywords + '%'
					or ap.branch_name													 like '%' + @p_keywords + '%'
					or convert(varchar(30), ap.application_date, 103)					 like '%' + @p_keywords + '%'
					or mf.description													 like '%' + @p_keywords + '%' 
					or ap.application_status											 like '%' + @p_keywords + '%'
					or mw.description													 like '%' + @p_keywords + '%'
					or	case when isnull(ae.is_valid, '') = '1' then 'Yes' else 'No' end like '%' + @p_keywords + '%'
				) 
				

	select		ap.application_no 
				,ap.application_external_no
				,ap.client_name
				,ap.branch_name
				,convert(varchar(30), ap.application_date, 103) 'application_date'
				,mf.description 'facility_desc' 
				,ap.application_status
				,isnull(mw.description, ap.level_status) 'level_status'
				,ap.marketing_name
				,ae.main_contract_no
			    ,case when isnull(ae.is_valid, '') = '1' then 'Yes' else 'No' end 'is_valid'
				,@rows_count 'rowcount'
	from		application_main ap
				inner join dbo.master_facility mf on (mf.code = ap.facility_code)
				left join dbo.master_workflow mw on (mw.code = ap.level_status)
				left join dbo.application_extention ae on (ae.application_no = ap.application_no)
	where		ap.branch_code = case @p_branch_code
										when 'ALL' then ap.branch_code
										else @p_branch_code
									end
				and ap.application_status in ('GO LIVE', 'APPROVE')
				and	ap.level_status	in ('ALLOCATION', 'REALIZATION', 'GO LIVE')
				--and ap.application_no not in (select application_no from dbo.agreement_main with (nolock))
				and isnull(ae.is_valid, '0') = case @p_is_valid
												 when 'ALL' then isnull(ae.is_valid, '0')
												 else @p_is_valid
											 end
				and (
						ap.application_external_no											 like '%' + @p_keywords + '%'
						or ae.main_contract_no												 like '%' + @p_keywords + '%'
						or ap.client_name													 like '%' + @p_keywords + '%'
						or ap.branch_name													 like '%' + @p_keywords + '%'
						or convert(varchar(30), ap.application_date, 103)					 like '%' + @p_keywords + '%'
						or mf.description													 like '%' + @p_keywords + '%' 
						or ap.application_status											 like '%' + @p_keywords + '%'
						or mw.description													 like '%' + @p_keywords + '%'
						or	case when isnull(ae.is_valid, '') = '1' then 'Yes' else 'No' end like '%' + @p_keywords + '%'
					)
			
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ap.application_external_no + ap.client_name
														when 2 then ae.main_contract_no
														when 3 then ap.branch_name
														when 4 then cast(ap.application_date as sql_variant)
														when 5 then mf.description 
														when 6 then ap.marketing_name
														when 7 then ap.application_status + isnull(mw.description, ap.level_status)
														when 8 then case when isnull(ae.is_valid, '') = '1' then 'Yes' else 'No' end
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ap.application_external_no + ap.client_name
														when 2 then ae.main_contract_no
														when 3 then ap.branch_name
														when 4 then cast(ap.application_date as sql_variant)
														when 5 then mf.description 
														when 6 then ap.marketing_name
														when 7 then ap.application_status + isnull(mw.description, ap.level_status)
														when 8 then case when isnull(ae.is_valid, '') = '1' then 'Yes' else 'No' end
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;


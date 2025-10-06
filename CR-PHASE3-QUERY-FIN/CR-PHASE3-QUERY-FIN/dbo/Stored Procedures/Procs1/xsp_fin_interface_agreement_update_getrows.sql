CREATE PROCEDURE dbo.xsp_fin_interface_agreement_update_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_job_status nvarchar(10)
	,@p_status	   nvarchar(10) = 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.fin_interface_agreement_update au
			left join dbo.agreement_main am on (am.agreement_no = au.agreement_no)
	where	au.job_status = case @p_job_status
								when 'ALL' then au.job_status
								else @p_job_status
							end
			and (
					am.agreement_external_no							like '%' + @p_keywords + '%'
					or	convert(varchar(30), au.termination_date, 103)	like '%' + @p_keywords + '%'
					or	au.agreement_sub_status							like '%' + @p_keywords + '%'
					or	au.termination_status							like '%' + @p_keywords + '%'
					or	am.client_name									like '%' + @p_keywords + '%'
				) ;

	select		au.id as id
				,am.agreement_external_no
				,convert(varchar(30), au.termination_date, 103) 'termination_date'
				,au.agreement_status
				,au.agreement_sub_status
				,am.client_name
				,au.agreement_no
				,au.termination_status
				,au.job_status 
				,@rows_count 'rowcount'
	from		fin_interface_agreement_update au
				left join dbo.agreement_main am on (am.agreement_no = au.agreement_no)
	where		au.job_status = case @p_job_status
									when 'ALL' then au.job_status
									else @p_job_status
								end
				and (
						am.agreement_external_no							like '%' + @p_keywords + '%'
						or	convert(varchar(30), au.termination_date, 103)	like '%' + @p_keywords + '%'
						or	au.agreement_sub_status							like '%' + @p_keywords + '%'
						or	au.termination_status							like '%' + @p_keywords + '%'
						or	am.client_name									like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agreement_external_no + am.client_name
													 when 2 then cast(au.termination_date as sql_variant)
													 when 3 then au.agreement_sub_status
													 when 4 then au.termination_status
													 when 5 then au.job_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then agreement_external_no + am.client_name
														when 2 then cast(au.termination_date as sql_variant)
														when 3 then au.agreement_sub_status
														when 4 then au.termination_status
														when 5 then au.job_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

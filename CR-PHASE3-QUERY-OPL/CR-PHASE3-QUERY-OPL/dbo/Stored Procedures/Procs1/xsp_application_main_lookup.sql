CREATE procedure [dbo].[xsp_application_main_lookup]
(
	@p_keywords			   nvarchar(50)
	,@p_pagenumber		   int
	,@p_rowspage		   int
	,@p_order_by		   int
	,@p_sort_by			   nvarchar(5)
	,@p_branch_code		   nvarchar(50)
	,@p_application_status nvarchar(10) = 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_main ap
			inner join dbo.client_main cm on (cm.code = ap.client_code)
	where	ap.application_status = case @p_application_status
										when 'ALL' then ap.application_status
										else @p_application_status
									end
			and ap.branch_code	  = case @p_branch_code
										when 'ALL' then ap.branch_code
										else @p_branch_code
									end
			and (
					ap.application_external_no	like '%' + @p_keywords + '%'
					or client_name				like '%' + @p_keywords + '%'
					or branch_name				like '%' + @p_keywords + '%'
					or ap.application_status	like '%' + @p_keywords + '%'
				) ;

	select		application_no
				,ap.application_external_no
				,client_name
				,branch_name
				,application_status
				,@rows_count 'rowcount'
	from		application_main ap
				inner join dbo.client_main cm on (cm.code = ap.client_code)
	where		ap.application_status = case @p_application_status
											when 'ALL' then ap.application_status
											else @p_application_status
										end
				and ap.branch_code	  = case @p_branch_code
											when 'ALL' then ap.branch_code
											else @p_branch_code
										end
				and (
						ap.application_external_no	like '%' + @p_keywords + '%'
						or client_name				like '%' + @p_keywords + '%'
						or branch_name				like '%' + @p_keywords + '%'
						or ap.application_status	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ap.application_external_no
													 when 2 then client_name
													 when 3 then branch_name
													 when 4 then application_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ap.application_external_no
													   when 2 then client_name
													   when 3 then branch_name
													   when 4 then application_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


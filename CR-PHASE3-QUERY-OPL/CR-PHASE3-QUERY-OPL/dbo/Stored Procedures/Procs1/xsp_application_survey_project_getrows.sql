--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_application_survey_project_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_application_survey_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_survey_project asp
	where	asp.application_survey_code = @p_application_survey_code
			and (
					asp.id				like '%' + @p_keywords + '%'
					or asp.project_owner			like '%' + @p_keywords + '%'
					or asp.main_kontraktor			like '%' + @p_keywords + '%'
					or asp.main_kompetitor			like '%' + @p_keywords + '%'
					or asp.sub_kontraktor			like '%' + @p_keywords + '%'
					or asp.sub_kompetitor			like '%' + @p_keywords + '%'
					or asp.sub_sub_kontraktor		like '%' + @p_keywords + '%'
					or asp.sub_sub_kompetitor		like '%' + @p_keywords + '%'
				) ;

	select		asp.id
				,asp.application_survey_code
				,asp.project_name
				,asp.project_owner
				,asp.main_kontraktor
				,asp.sub_kontraktor
				,asp.sub_sub_kontraktor
				,asp.main_kompetitor
				,asp.sub_kompetitor
				,asp.sub_sub_kompetitor
				,asp.cre_date
				,asp.cre_by
				,asp.cre_ip_address
				,asp.mod_date
				,asp.mod_by
				,asp.mod_ip_address
			   ,@rows_count 'rowcount'
	from		dbo.application_survey_project asp
	where		asp.application_survey_code = @p_application_survey_code
				and (
						asp.id				like '%' + @p_keywords + '%'
						or asp.project_owner			like '%' + @p_keywords + '%'
						or asp.main_kontraktor			like '%' + @p_keywords + '%'
						or asp.main_kompetitor			like '%' + @p_keywords + '%'
						or asp.sub_kontraktor			like '%' + @p_keywords + '%'
						or asp.sub_kompetitor			like '%' + @p_keywords + '%'
						or asp.sub_sub_kontraktor		like '%' + @p_keywords + '%'
						or asp.sub_sub_kompetitor		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asp.project_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then asp.project_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

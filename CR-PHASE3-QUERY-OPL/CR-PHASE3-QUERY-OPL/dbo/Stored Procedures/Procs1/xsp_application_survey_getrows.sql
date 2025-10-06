--created by, Rian at 11/05/2023	

CREATE procedure dbo.xsp_application_survey_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_application_no	   nvarchar(15)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_survey aps
	where	aps.application_no = @p_application_no
			and (
					aps.code					like '%' + @p_keywords + '%'
					or	aps.application_no		like '%' + @p_keywords + '%'
					or	aps.nama				like '%' + @p_keywords + '%'
					or	aps.group_name			like '%' + @p_keywords + '%'
				) ;

	select		aps.code
				,aps.application_no
				,aps.nama
				,aps.group_name
				,@rows_count 'rowcount'
	from		dbo.application_survey aps
	where		aps.application_no = @p_application_no
				and (
						aps.code					like '%' + @p_keywords + '%'
						or	aps.application_no		like '%' + @p_keywords + '%'
						or	aps.nama				like '%' + @p_keywords + '%'
						or	aps.group_name			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then aps.code
													 when 2 then aps.application_no
													 when 3 then aps.nama
													 when 4 then aps.group_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then aps.code
														when 2 then aps.application_no
														when 3 then aps.nama
														when 4 then aps.group_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

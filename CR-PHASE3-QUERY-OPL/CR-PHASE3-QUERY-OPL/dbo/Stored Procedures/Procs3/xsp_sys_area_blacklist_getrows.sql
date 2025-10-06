--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_sys_area_blacklist_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_area_blacklist
	where	(
				code				like '%' + @p_keywords + '%'
				or	status			like '%' + @p_keywords + '%'
				or	source			like '%' + @p_keywords + '%'
				or	zip_code		like '%' + @p_keywords + '%'
				or	sub_district	like '%' + @p_keywords + '%'
				or	village			like '%' + @p_keywords + '%'
				or	entry_date		like '%' + @p_keywords + '%'
				or	entry_reason	like '%' + @p_keywords + '%'
				or	exit_date		like '%' + @p_keywords + '%'
				or	exit_reason		like '%' + @p_keywords + '%'
			) ;

		select		code
					,@rows_count 'rowcount'
		from		sys_area_blacklist
		where		(
						code				like '%' + @p_keywords + '%'
						or	status			like '%' + @p_keywords + '%'
						or	source			like '%' + @p_keywords + '%'
						or	zip_code		like '%' + @p_keywords + '%'
						or	sub_district	like '%' + @p_keywords + '%'
						or	village			like '%' + @p_keywords + '%'
						or	entry_date		like '%' + @p_keywords + '%'
						or	entry_reason	like '%' + @p_keywords + '%'
						or	exit_date		like '%' + @p_keywords + '%'
						or	exit_reason		like '%' + @p_keywords + '%'
					)

		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then status
														when 3 then source
														when 4 then zip_code
														when 5 then sub_district
														when 6 then village
														when 7 then entry_reason
														when 8 then exit_reason
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then status
														when 3 then source
														when 4 then zip_code
														when 5 then sub_district
														when 6 then village
														when 7 then entry_reason
														when 8 then exit_reason
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

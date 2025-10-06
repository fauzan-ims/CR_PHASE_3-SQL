--created by, Rian at 16/05/2023 

CREATE procedure dbo.xsp_area_blacklist_history_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_area_blacklist_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	area_blacklist_history abh
			inner join dbo.sys_general_subcode sgs on (sgs.code = abh.source)
	where	abh.area_blacklist_code = @p_area_blacklist_code
			and (
					sgs.description									like '%' + @p_keywords + '%'
					or	convert(varchar(30), abh.history_date, 103)	like '%' + @p_keywords + '%'
					or	abh.history_remarks							like '%' + @p_keywords + '%'
				) ;

		select		id
					,sgs.description 'source'
					,convert(varchar(30), abh.history_date, 103) 'history_date'
					,abh.history_remarks							
					,@rows_count 'rowcount'
		from		area_blacklist_history abh
					inner join dbo.sys_general_subcode sgs on (sgs.code = abh.source)
		where		abh.area_blacklist_code = @p_area_blacklist_code
					and (
							sgs.description									like '%' + @p_keywords + '%'
							or	convert(varchar(30), abh.history_date, 103)	like '%' + @p_keywords + '%'
							or	abh.history_remarks							like '%' + @p_keywords + '%'
						)

		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cast(history_date as sql_variant) 
														when 2 then sgs.description
														when 3 then abh.history_remarks
														when 4 then cast(abh.mod_date as sql_variant) 
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(history_date as sql_variant) 
														when 2 then sgs.description
														when 3 then abh.history_remarks
														when 4 then cast(abh.mod_date as sql_variant)
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

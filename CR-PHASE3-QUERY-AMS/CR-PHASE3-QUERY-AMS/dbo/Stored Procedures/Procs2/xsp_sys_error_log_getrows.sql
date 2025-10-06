CREATE PROCEDURE dbo.xsp_sys_error_log_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_date	   datetime
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sys_error_log
	where	cast(log_date as date) = cast(@p_date as date)
			and (
				sp_name									like '%' + @p_keywords + '%'
				or	convert(varchar(30), log_date, 103) like '%' + @p_keywords + '%'
			) ;

	select		sp_name
				,convert(varchar(30), log_date, 103) 'log_date'
				,parameter
				,log_message 'error'
				,@rows_count 'rowcount'
	from		dbo.sys_error_log
	where		cast(log_date as date) = cast(@p_date as date)
				and (
					sp_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), log_date, 103) like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													   when 1 then cast(mod_date as sql_variant)
													   when 2 then sp_name
													   when 3 then cast(log_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then cast(mod_date as sql_variant)
													   when 2 then sp_name
													   when 3 then cast(log_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

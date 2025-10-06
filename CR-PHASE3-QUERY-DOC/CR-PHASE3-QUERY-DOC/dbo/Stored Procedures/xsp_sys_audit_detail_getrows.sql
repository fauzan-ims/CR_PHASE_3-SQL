CREATE PROCEDURE dbo.xsp_sys_audit_detail_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_audit_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_audit_detail
	where	audit_code = @p_audit_code
			and (
					convert(varchar(30), date, 103)	like '%' + @p_keywords + '%'
					or	progress					like '%' + @p_keywords + '%'
					or	remark						like '%' + @p_keywords + '%'
				) ;

	select		id
				,audit_code
				,date
				,progress
				,remark
				,file_name
				,paths
				,@rows_count 'rowcount'
	from		sys_audit_detail
	where		audit_code = @p_audit_code
				and (
						convert(varchar(30), date, 103)	like '%' + @p_keywords + '%'
						or	progress					like '%' + @p_keywords + '%'
						or	remark						like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(date as sql_variant)
													 when 2 then progress
													 when 3 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then cast(date as sql_variant)
													   when 2 then progress
													   when 3 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

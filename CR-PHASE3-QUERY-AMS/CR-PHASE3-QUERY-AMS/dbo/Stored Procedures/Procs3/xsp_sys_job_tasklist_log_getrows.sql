--created by, Rian at 20/02/2023 

CREATE procedure dbo.xsp_sys_job_tasklist_log_getrows
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
	from	sys.tables
	where	(
				name			like '%' + @p_keywords + '%'
			) ;

	select	replace(name, 'Z_AUDIT_', '') as 'name'	
			,@rows_count 'rowcount'
	from	sys.tables
	where	(name like 'Z_AUDIT_%') 
			and name <> 'sysdiagrams'		
			and (
					name			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then name
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then name
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

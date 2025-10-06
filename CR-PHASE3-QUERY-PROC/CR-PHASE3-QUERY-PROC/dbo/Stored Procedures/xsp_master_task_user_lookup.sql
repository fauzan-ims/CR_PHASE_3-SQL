CREATE PROCEDURE dbo.xsp_master_task_user_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	
	select	@rows_count = count(*)
	from	dbo.master_task_user
	where	company_code = @p_company_code
	and		is_active = '1' 
	--and		sys_code not in ('MTU210900001', 'MTU210900002') -- not in super admin dan vendor user
	and		(
				code			like '%' + @p_keywords + '%'
				or description	like '%' + @p_keywords + '%'
			) ;

	select		code
				,description
				,@rows_count 'rowcount'
	from		master_task_user
	where		company_code = @p_company_code
	and			is_active = '1'
	--and			sys_code not in ('MTU210900001', 'MTU210900002') -- not in super admin dan vendor user
	and			(
					code			like '%' + @p_keywords + '%'
					or	description	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then description			
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by		
														when 1 then description		
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		
end ;


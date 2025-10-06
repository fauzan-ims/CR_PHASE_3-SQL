CREATE PROCEDURE dbo.xsp_sys_role_group_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_main_task_user_code	nvarchar(50)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_role_group srg
	where	srg.company_code = @p_company_code
	and		code  not in
			(
				select	role_group_code
				from	dbo.master_task_user_detail
				where	role_group_code	= role_group_code
				and		company_code = @p_company_code
				and		main_task_user_code = @p_main_task_user_code
			)

	and		(
				code					like '%' + @p_keywords + '%'
				or	name				like '%' + @p_keywords + '%'
				or	application_code	like '%' + @p_keywords + '%'
			) ;

	select		code
				,name
				,application_code
				,scumgc.role_group_code
				,@rows_count as 'rowcount'
	from		sys_role_group srg
				left join dbo.sys_company_user_main_group_sec scumgc on srg.code = scumgc.role_group_code collate Latin1_General_CI_AS
	where		srg.company_code = @p_company_code
	and			code  not in
				(
					select	role_group_code
					from	dbo.master_task_user_detail
					where	role_group_code	= role_group_code
					and		company_code = @p_company_code
					and		main_task_user_code = @p_main_task_user_code
				)	

	and			(
					code					like '%' + @p_keywords + '%'
					or	name				like '%' + @p_keywords + '%'
					or	application_code	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then name
														when 3 then application_code
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by				
														when 1 then code
														when 2 then name
														when 3 then application_code
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;

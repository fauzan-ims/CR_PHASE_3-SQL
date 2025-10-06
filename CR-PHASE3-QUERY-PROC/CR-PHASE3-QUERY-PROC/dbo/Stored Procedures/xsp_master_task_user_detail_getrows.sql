CREATE PROCEDURE dbo.xsp_master_task_user_detail_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_main_task_user_code	nvarchar(50)
	,@p_company_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_task_user_detail mtud
			inner join dbo.sys_role_group srg on srg.code = mtud.role_group_code --and srg.company_code = mtud.company_code
	where	main_task_user_code = @p_main_task_user_code
	and		mtud.company_code = @p_company_code
	and		(
				main_task_user_code like '%' + @p_keywords + '%'
				or	role_group_code like '%' + @p_keywords + '%'
			) ;

	select		mtud.code
				,main_task_user_code
				,role_group_code
				,srg.name 'role_group_name'
				,@rows_count 'rowcount'
	from		master_task_user_detail mtud
				inner join dbo.sys_role_group srg on srg.code = mtud.role_group_code --and srg.company_code = mtud.company_code
	where		main_task_user_code = @p_main_task_user_code
	and			mtud.company_code = @p_company_code
	and			(
					main_task_user_code like '%' + @p_keywords + '%'
					or	role_group_code like '%' + @p_keywords + '%'
				)
	order by	case
				 	when @p_sort_by = 'asc' then case @p_order_by			
														when 1 then main_task_user_code
														when 2 then role_group_code
				 									end
				end asc
				,case
				 	when @p_sort_by = 'desc' then case @p_order_by					
														when 1 then main_task_user_code
														when 2 then role_group_code
				 									end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;

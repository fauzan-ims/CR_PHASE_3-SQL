CREATE PROCEDURE dbo.xsp_sys_company_user_main_group_sec_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_user_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_company_user_main_group_sec scg
			inner join dbo.sys_role_group srg on srg.code = scg.role_group_code
	where	user_code = @p_user_code
	and		(
				role_group_code like '%' + @p_keywords + '%'
				or	user_code	like '%' + @p_keywords + '%'
				or	srg.name	like '%' + @p_keywords + '%'
			) ;

	select		role_group_code
				,user_code
				,srg.name 'role_group_name'
				,@rows_count 'rowcount'
	from		sys_company_user_main_group_sec scg
				inner join dbo.sys_role_group srg on srg.code = scg.role_group_code
	where		user_code = @p_user_code
	and			(
					role_group_code like '%' + @p_keywords + '%'
					or	user_code	like '%' + @p_keywords + '%'
					or	srg.name	like '%' + @p_keywords + '%'
				)
	order by	case
				 	when @p_sort_by = 'asc' then case @p_order_by
				 										when 1 then srg.name
														when 2 then user_code
				 									end
				end asc
				,case
				 	when @p_sort_by = 'desc' then case @p_order_by							
				 										when 1 then srg.name
														when 2 then user_code
				 									end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;

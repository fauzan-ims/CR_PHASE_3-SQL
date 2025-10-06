CREATE PROCEDURE dbo.xsp_sys_company_user_login_log_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_user_code	nvarchar(50)
	,@p_from_date	datetime
	,@p_to_date		datetime
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_company_user_login_log
	where	user_code = @p_user_code
	and		cast(login_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
	and		(
				user_code		like '%' + @p_keywords + '%'
				or	login_date	like '%' + @p_keywords + '%'
				or	flag_code	like '%' + @p_keywords + '%'
				or	session_id	like '%' + @p_keywords + '%'
			) ;

	select		id
				,user_code
				,format(cast(login_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us') 'login_date' 
				,flag_code
				,session_id
				,@rows_count 'rowcount'
	from		sys_company_user_login_log
	where		user_code = @p_user_code
	and			cast(login_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
	and			(
					user_code		like '%' + @p_keywords + '%'
					or	login_date	like '%' + @p_keywords + '%'
					or	flag_code	like '%' + @p_keywords + '%'
					or	session_id	like '%' + @p_keywords + '%'
				)
	order by	case
				 	when @p_sort_by = 'asc' then case @p_order_by
				 										when 1 then cast(login_date as sql_variant)
														when 2 then flag_code
														when 3 then session_id
				 									end
				end asc
				,case
				 		when @p_sort_by = 'desc' then case @p_order_by			
				 										when 1 then cast(login_date as sql_variant)
														when 2 then flag_code
														when 3 then session_id
				 									end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;

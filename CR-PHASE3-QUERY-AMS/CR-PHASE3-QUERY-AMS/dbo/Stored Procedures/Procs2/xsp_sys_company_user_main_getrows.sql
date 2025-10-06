CREATE PROCEDURE dbo.xsp_sys_company_user_main_getrows	
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

	select	@rows_count = count(1)
	from	sys_company_user_main scu
			left join dbo.master_task_user mtu on mtu.code = scu.main_task_code and mtu.company_code = scu.company_code
	where	scu.company_code = @p_company_code
	and		(
				scu.code					like '%' + @p_keywords + '%'
				or	scu.name				like '%' + @p_keywords + '%'
				or	scu.username			like '%' + @p_keywords + '%'
				or	mtu.description			like '%' + @p_keywords + '%'
				or	case scu.is_active
						when '1' then 'Yes'
						else 'No'
					end						like '%' + @p_keywords + '%'
			);

	select		scu.code
				,scu.company_code
				,scu.upass
				,scu.upassapproval
				,scu.name
				,scu.username
				,scu.main_task_code 
				,scu.email
				,scu.phone_no
				,scu.province_code
				,scu.city_code
				,scu.last_login_date
				,scu.last_fail_count
				,scu.next_change_pass
				,scu.file_name
				,scu.paths
				,mtu.description 'main_task'
				,case scu.is_active
						when '1' then 'Yes'
						else 'No'
					end 'is_active'
				,@rows_count 'rowcount'
	from		sys_company_user_main scu
				left join dbo.master_task_user mtu on mtu.code = scu.main_task_code and mtu.company_code = scu.company_code
	where		scu.company_code = @p_company_code
	and			(
					scu.code					like '%' + @p_keywords + '%'
					or	scu.name				like '%' + @p_keywords + '%'
					or	scu.username			like '%' + @p_keywords + '%'
					or	mtu.description			like '%' + @p_keywords + '%'
					or	case scu.is_active
							when '1' then 'Yes'
							else 'No'
						end						like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
					 									when 1 then scu.code
														when 2 then scu.name
														when 3 then scu.username
														when 4 then mtu.description
														when 5 then case scu.is_active
																		when '1' then 'Yes'
																		else 'No'
																	end	
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by		
					 									when 1 then scu.code
														when 2 then scu.name
														when 3 then scu.username
														when 4 then mtu.description
														when 5 then case scu.is_active
																		when '1' then 'Yes'
																		else 'No'
																	end	
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

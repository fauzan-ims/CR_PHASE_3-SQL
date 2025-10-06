
CREATE PROCEDURE dbo.xsp_sys_company_user_main_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_module			nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_company_user_main scu 
			left join dbo.sys_general_subcode sgc on sgc.code = scu.main_task_code collate Latin1_General_CI_AS and sgc.company_code = scu.company_code collate Latin1_General_CI_AS
	where	scu.company_code = @p_company_code 
	and		scu.is_active = '1'
	and		scu.module = case @p_module
							when 'ALL' then scu.module
							else @p_module
						 end
	--or		(scu.module = 'ALL' and scu.company_code = @p_company_code) 
	and		(
				scu.code					like '%' + @p_keywords + '%'
				or	scu.name				like '%' + @p_keywords + '%'
			);

	select		scu.code 'code'
				,scu.name 'name'
				,@rows_count 'rowcount'
	from		sys_company_user_main scu 
				left join dbo.sys_general_subcode sgc on sgc.code = scu.main_task_code collate Latin1_General_CI_AS and sgc.company_code = scu.company_code collate Latin1_General_CI_AS
	where		scu.company_code = @p_company_code
	and			scu.is_active = '1'
	and			scu.module = case @p_module
								when 'ALL' then scu.module
								else @p_module
							 end
	--or			(scu.module = 'ALL' and scu.company_code = @p_company_code)
	and			(
					scu.code					like '%' + @p_keywords + '%'
					or	scu.name				like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
					 									when 1 then scu.code
														when 2 then scu.name
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by		
					 									when 1 then scu.code
														when 2 then scu.name
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

CREATE PROCEDURE dbo.xsp_master_workflow_lookup_for_master_application_flow_detail
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_application_flow_code   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_workflow
	where	is_active = '1'
			and code not in (
					select	workflow_code
					from	dbo.master_application_flow_detail
					where	workflow_code = code
							and application_flow_code = @p_application_flow_code
			)
			and (
				code				like '%' + @p_keywords + '%'
				or	description		like '%' + @p_keywords + '%'
			) ;

		select		code
					,description
					,@rows_count 'rowcount'
		from		master_workflow
		where		is_active = '1'
					and code not in (
							select	workflow_code
							from	dbo.master_application_flow_detail
							where	workflow_code = code
									and application_flow_code = @p_application_flow_code
					)
					and (
						code				like '%' + @p_keywords + '%'
						or	description		like '%' + @p_keywords + '%'
					)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then description
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then description
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

CREATE PROCEDURE dbo.xsp_master_workflow_position_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_workflow_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_workflow_position mwp
			left join master_workflow mwf on (mwp.workflow_code = mwf.code)
	where	mwf.code = @p_workflow_code
			and	(
					id					like '%' + @p_keywords + '%'
					or	workflow_code	like '%' + @p_keywords + '%'
					or	position_code	like '%' + @p_keywords + '%'
					or	position_name	like '%' + @p_keywords + '%'
				) ;

		select		mwp.id
					,mwp.workflow_code
					,mwp.position_code
					,mwp.position_name
					,@rows_count 'rowcount'
		from		master_workflow_position mwp
					left join master_workflow mwf on (mwp.workflow_code = mwf.code)
		where		mwf.code = @p_workflow_code
					and	(
							id					like '%' + @p_keywords + '%'
							or	workflow_code	like '%' + @p_keywords + '%'
							or	position_code	like '%' + @p_keywords + '%'
							or	position_name	like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then position_code
													when 2 then position_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then position_code
														when 2 then position_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

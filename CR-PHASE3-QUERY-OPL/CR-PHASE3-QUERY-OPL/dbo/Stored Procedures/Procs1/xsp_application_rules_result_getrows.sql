CREATE PROCEDURE dbo.xsp_application_rules_result_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_rules_result prr
			inner join master_rules mr on (mr.code = prr.rules_code)
	where	application_no = @p_application_no
			and (
					mr.description				like '%' + @p_keywords + '%'
					or	prr.rules_result		like '%' + @p_keywords + '%'
				) ;

		select		prr.id
					,mr.description 'rules_desc'
					,prr.rules_result	
					,@rows_count 'rowcount'
		from		application_rules_result prr
					inner join master_rules mr on (mr.code = prr.rules_code)
		where		application_no = @p_application_no
					and (
							mr.description				like '%' + @p_keywords + '%'
							or	prr.rules_result		like '%' + @p_keywords + '%'
						)

	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mr.description
													when 2 then prr.rules_result
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mr.description
														when 2 then prr.rules_result
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


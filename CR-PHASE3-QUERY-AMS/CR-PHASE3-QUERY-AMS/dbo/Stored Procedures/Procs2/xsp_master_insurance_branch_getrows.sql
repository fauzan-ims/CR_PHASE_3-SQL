CREATE PROCEDURE dbo.xsp_master_insurance_branch_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_insurance_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance_branch
	where	insurance_code = @p_insurance_code
			and (
					branch_code		like '%' + @p_keywords + '%'
					or	branch_name		like '%' + @p_keywords + '%'
				) ;

		select		id
					,insurance_code
					,branch_code
					,branch_name
					,@rows_count 'rowcount'
		from		master_insurance_branch
		where		insurance_code = @p_insurance_code
					and (
							branch_code		like '%' + @p_keywords + '%'
							or	branch_name		like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then branch_code
													when 2 then branch_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then branch_code
													when 2 then branch_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;



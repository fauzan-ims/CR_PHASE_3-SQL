CREATE PROCEDURE dbo.xsp_client_reference_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_reference
	where	client_code = @p_client_code
			and (
					reference_type_code		like '%' + @p_keywords + '%'
					or	reference_full_name like '%' + @p_keywords + '%'
					or	relationship		like '%' + @p_keywords + '%'
				) ;

		select		id
					,reference_type_code
					,reference_full_name
					,relationship
					,@rows_count 'rowcount'
		from		client_reference
		where		client_code = @p_client_code
					and (
							reference_type_code		like '%' + @p_keywords + '%'
							or	reference_full_name like '%' + @p_keywords + '%'
							or	relationship		like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then reference_type_code
													when 2 then reference_full_name
													when 3 then relationship
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then reference_type_code
														when 2 then reference_full_name
														when 3 then relationship
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


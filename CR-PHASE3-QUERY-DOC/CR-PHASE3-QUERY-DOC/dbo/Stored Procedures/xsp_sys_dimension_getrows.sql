
CREATE PROCEDURE dbo.xsp_sys_dimension_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	sys_dimension
	where	(
				description					like 	'%'+@p_keywords+'%'
				or	type					like 	'%'+@p_keywords+'%'
				or	case is_active
						when '1' then 'Yes'
						else 'No'
					end 					like 	'%'+@p_keywords+'%'
			);

		select	code
				,description
				,type
				,case is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
		from	sys_dimension
		where	(
					description					like 	'%'+@p_keywords+'%'
					or	type					like 	'%'+@p_keywords+'%'
					or	case is_active
						 when '1' then 'Yes'
						 else 'No'
						end 					like 	'%'+@p_keywords+'%'

				)

	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then description
													when 2	then type
													when 3	then is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1	then description
														when 2	then type
														when 3	then is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end

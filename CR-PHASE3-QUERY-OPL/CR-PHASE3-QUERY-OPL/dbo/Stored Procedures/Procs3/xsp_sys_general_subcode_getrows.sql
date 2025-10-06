CREATE PROCEDURE dbo.xsp_sys_general_subcode_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_general_code NVARCHAR(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	sys_general_subcode 
	where	general_code = @p_general_code
	and		is_active = (case(@p_general_code) when 'PLPRO' then '1' else is_active END)
			and(
				code								like 	'%'+@p_keywords+'%'
				or	description						like 	'%'+@p_keywords+'%'
				or	ojk_code						like 	'%'+@p_keywords+'%'
				or	order_key						like 	'%'+@p_keywords+'%'
				or	case is_active
					when '1' then 'Yes'
					else 'No'
					
				end									like 	'%'+@p_keywords+'%'
			);

	select	code
			,description
			,ojk_code
			,order_key
			,case is_active
				when '1' then 'Yes'
				else 'No'
					
			end 'is_active'			
			,@rows_count	 'rowcount'
	from	sys_general_subcode 
	where	general_code = @p_general_code
	and		is_active = (case(@p_general_code) when 'PLPRO' then '1' else is_active END)
			and(
				code								like 	'%'+@p_keywords+'%'
				or	description						like 	'%'+@p_keywords+'%'
				or	ojk_code						like 	'%'+@p_keywords+'%'
				or	order_key						like 	'%'+@p_keywords+'%'
				or	case is_active
					when '1' then 'Yes'
					else 'No'
						
				end									like 	'%'+@p_keywords+'%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code	
														when 2 then description
														when 3 then ojk_code
														when 4 then cast(order_key as sql_variant) 		
														when 5 then is_active 		
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code	
														when 2 then description
														when 3 then ojk_code
														when 4 then cast(order_key as sql_variant) 		
														when 5 then is_active 		
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end

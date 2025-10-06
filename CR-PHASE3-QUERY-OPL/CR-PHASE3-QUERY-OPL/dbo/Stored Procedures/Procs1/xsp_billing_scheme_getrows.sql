
CREATE procedure xsp_billing_scheme_getrows
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
	from	billing_scheme
	where	(
					code			like 	'%'+@p_keywords+'%'
				or	scheme_name		like 	'%'+@p_keywords+'%'
				or	client_no		like 	'%'+@p_keywords+'%'
				or	client_name		like 	'%'+@p_keywords+'%'
					or	 case is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 			like 	'%'+@p_keywords+'%'

			);

	select	code
			,scheme_name
			,client_no
			,client_name
				 ,case is_active
				 when '1' then 'Yes'
				 else 'No'
			 end 	'is_active'
			,@rows_count	 'rowcount'
	from	billing_scheme
	where	(
					code			like 	'%'+@p_keywords+'%'
				or	scheme_name		like 	'%'+@p_keywords+'%'
				or	client_no		like 	'%'+@p_keywords+'%'
				or	client_name		like 	'%'+@p_keywords+'%'
					or	 case is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 			like 	'%'+@p_keywords+'%'

			)
		order by	 case
				when @p_sort_by = 'asc' then case @p_order_by
				when 1	then code
				when 2	then scheme_name
				when 3	then client_no
				when 4	then client_name
				when 5	then is_active
	end
		end asc
			 ,case
				when @p_sort_by = 'desc' then case @p_order_by
				when 1	then code
				when 2	then scheme_name
				when 3	then client_no
				when 4	then client_name
				when 5	then is_active
	end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end

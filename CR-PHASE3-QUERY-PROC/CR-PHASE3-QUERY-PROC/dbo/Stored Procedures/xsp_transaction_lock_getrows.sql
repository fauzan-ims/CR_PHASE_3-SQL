CREATE PROCEDURE [dbo].[xsp_transaction_lock_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	transaction_lock
	where	(
				user_name									 like '%' + @p_keywords + '%'
				or	reff_name								 like '%' + @p_keywords + '%'
				or	reff_code								 like '%' + @p_keywords + '%'
				or	convert(varchar(30),access_date, 103)	 like '%' + @p_keywords + '%'
				or	case is_active
						when '1' then 'Yes'
						else 'No'
					end										 like '%' + @p_keywords + '%'
			) ;

	select		id
				,user_id
				,user_name
				,reff_name
				,reff_code
				,convert(varchar(30),access_date, 103) 'access_date'
				,case is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		transaction_lock
	where		(
					user_name									 like '%' + @p_keywords + '%'
					or	reff_name								 like '%' + @p_keywords + '%'
					or	reff_code								 like '%' + @p_keywords + '%'
					or	convert(varchar(30),access_date, 103)	 like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end										 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then user_name
													 when 2 then reff_name
													 when 3 then reff_code
													 when 4 then cast(access_date as sql_variant)
													 when 5 then is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then user_name
													 when 2 then reff_name
													 when 3 then reff_code
													 when 4 then cast(access_date as sql_variant)
													 when 5 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


create procedure [dbo].[xsp_transaction_lock_history_getrows]
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
	from	transaction_lock_history
	where	(
				id like '%' + @p_keywords + '%'
				or	user_id like '%' + @p_keywords + '%'
				or	user_name like '%' + @p_keywords + '%'
				or	reff_name like '%' + @p_keywords + '%'
				or	reff_code like '%' + @p_keywords + '%'
				or	access_date like '%' + @p_keywords + '%'
				or	case is_active
						when '1' then 'ACTIVE'
						else 'INACTIVE'
					end like '%' + @p_keywords + '%'
			) ;

	select		id
				,user_id
				,user_name
				,reff_name
				,reff_code
				,access_date
				,case is_active
					 when '1' then 'ACTIVE'
					 else 'INACTIVE'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		transaction_lock_history
	where		(
					id like '%' + @p_keywords + '%'
					or	user_id like '%' + @p_keywords + '%'
					or	user_name like '%' + @p_keywords + '%'
					or	reff_name like '%' + @p_keywords + '%'
					or	reff_code like '%' + @p_keywords + '%'
					or	access_date like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'ACTIVE'
							else 'INACTIVE'
						end like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then user_id
													 when 2 then user_name
													 when 3 then reff_name
													 when 4 then reff_code
													 when 5 then is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then user_id
													   when 2 then user_name
													   when 3 then reff_name
													   when 4 then reff_code
													   when 5 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

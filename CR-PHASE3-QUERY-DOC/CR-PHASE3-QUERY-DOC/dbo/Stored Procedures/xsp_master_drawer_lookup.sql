CREATE PROCEDURE dbo.xsp_master_drawer_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_locker_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_drawer
	where	is_active = '1'
			and locker_code = @p_locker_code
			and	(
					code							like '%' + @p_keywords + '%'
					or	drawer_name					like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				) ;

		select		code
					,drawer_name
					,case is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		master_drawer
		where		is_active = '1'
					and locker_code = @p_locker_code
					and	(
							code							like '%' + @p_keywords + '%'
							or	drawer_name					like '%' + @p_keywords + '%'
							or	case is_active
									when '1' then 'Yes'
									else 'No'
								end							like '%' + @p_keywords + '%'
						)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then drawer_name
													when 3 then is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then drawer_name
														when 3 then is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

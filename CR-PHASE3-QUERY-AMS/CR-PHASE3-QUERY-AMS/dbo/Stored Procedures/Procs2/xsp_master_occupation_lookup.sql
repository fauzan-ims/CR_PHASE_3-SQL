CREATE PROCEDURE [dbo].[xsp_master_occupation_lookup]
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
	from	master_occupation
	where	is_active = '1'
			and (
					occupation_name like '%' + @p_keywords + '%'
				) ;

	if @p_sort_by = 'asc'
	begin
		select		code
					,occupation_code
					,occupation_name
					,@rows_count 'rowcount'
		from		master_occupation
		where		is_active = '1'
					and (
							occupation_name like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then occupation_name
					end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select		code
					,occupation_code
					,occupation_name
					,@rows_count 'rowcount'
		from		master_occupation
		where		is_active = '1'
					and (
							occupation_name like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then occupation_name
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;


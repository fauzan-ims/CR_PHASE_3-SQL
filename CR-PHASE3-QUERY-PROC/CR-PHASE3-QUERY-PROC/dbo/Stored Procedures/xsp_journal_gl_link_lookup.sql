create PROCEDURE dbo.xsp_journal_gl_link_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
)
as
BEGIN
	
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.journal_gl_link
	where	is_active = '1'
			and (
					code				like '%' + @p_keywords + '%'
					or	gl_link_name	like '%' + @p_keywords + '%'
				) ;
	
		select		code
					,gl_link_name 'gl_link_name'
					,@rows_count 'rowcount'
		from		dbo.journal_gl_link
		where		is_active = '1'
					and (
						code					like '%' + @p_keywords + '%'
						or	gl_link_name		like '%' + @p_keywords + '%'
					)
		order by case 
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then gl_link_name
												 end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then code
															when 2 then gl_link_name
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

CREATE procedure dbo.xsp_journal_gl_link_lookup_for_bank
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
	from	journal_gl_link
	where	is_bank = '1'
			and (
					name like '%' + @p_keywords + '%'
				) ;

	select		code
				,name
				,case is_bank
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_bank'
				,@rows_count 'rowcount'
	from		journal_gl_link
	where		is_bank = '1'
				and (
					name like '%' + @p_keywords + '%'
					) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

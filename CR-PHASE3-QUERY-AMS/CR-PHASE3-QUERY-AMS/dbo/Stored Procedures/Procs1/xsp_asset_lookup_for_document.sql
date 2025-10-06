CREATE procedure dbo.xsp_asset_lookup_for_document
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
	from	dbo.asset 
	where	agreement_no is not null
			and (
					agreement_no	like '%' + @p_keywords + '%'
					or	client_name like '%' + @p_keywords + '%'
				) ;

	select		code
				,agreement_no
				,client_name
				,@rows_count 'rowcount'
	from		dbo.asset
	where		agreement_no is not null
				and (
						agreement_no	like '%' + @p_keywords + '%'
						or	client_name like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agreement_no
													 when 2 then client_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then agreement_no
													   when 2 then client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

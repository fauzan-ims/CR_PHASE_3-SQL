CREATE PROCEDURE [dbo].[xsp_invoice_getrows_for_lookup]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	invoice inv with (nolock)
		
	where	(	
					 inv.client_no								like '%' + @p_keywords + '%'
				or	 inv.client_name							like '%' + @p_keywords + '%'
			) ;

	select	 inv.client_no
			,inv.client_name
			,@rows_count 'rowcount'
	from	invoice inv with (nolock)
	where		(	
					 inv.client_no								like '%' + @p_keywords + '%'
				or	 inv.client_name							like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then  inv.client_no
														when 2 then  inv.client_name

												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then  inv.client_no
														when 2 then  inv.client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

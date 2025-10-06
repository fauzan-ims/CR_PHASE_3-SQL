

CREATE PROCEDURE dbo.xsp_client_getrows_for_lookup_invoice
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
	from	 (select distinct inv.client_no, inv.CLIENT_NAME from invoice inv with (nolock)) cm
	where	(	
					 cm.client_no							like '%' + @p_keywords + '%'
				or	 cm.client_name							like '%' + @p_keywords + '%'
			) ;

	select	 cm.client_no
			,cm.client_name
			,@rows_count 'rowcount'
	from	 (select distinct inv.client_no, inv.client_name from invoice inv with (nolock)) cm
	where (	
					 cm.client_no								like '%' + @p_keywords + '%'
				or	 cm.client_name							like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then  cm.client_no
														when 2 then  cm.client_name

												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then  cm.client_no
														when 2 then  cm.client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

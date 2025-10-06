CREATE PROCEDURE [dbo].[xsp_client_kyc_detail_getrows]
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_kyc_detail
	where	client_code = @p_client_code
			and ( 
					member_type		 like '%' + @p_keywords + '%' 
					or	member_name	 like '%' + @p_keywords + '%' 
					or	remarks		 like '%' + @p_keywords + '%'
				) ;

	select		id
				,client_code
				,member_type
				,member_code
				,member_name 
				,remarks
				,@rows_count 'rowcount'
	from		client_kyc_detail
	where		client_code = @p_client_code
				and ( 
						member_type		 like '%' + @p_keywords + '%' 
						or	member_name	 like '%' + @p_keywords + '%' 
						or	remarks		 like '%' + @p_keywords + '%'
					) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then member_name
													 when 2 then member_type
													 when 3 then remarks 
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then member_name
													 when 2 then member_type
													 when 3 then remarks 
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


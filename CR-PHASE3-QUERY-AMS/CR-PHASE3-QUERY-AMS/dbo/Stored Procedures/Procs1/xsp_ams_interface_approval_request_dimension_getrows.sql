create PROCEDURE dbo.xsp_ams_interface_approval_request_dimension_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_request_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.ams_interface_approval_dimension
	where	request_code = @p_request_code
			and (
					dimension_code		like '%' + @p_keywords + '%'
					or	dimension_value like '%' + @p_keywords + '%'
				) ;

	select		id
				,request_code
				,dimension_code
				,dimension_value
				,@rows_count 'rowcount'
	from		dbo.ams_interface_approval_dimension
	where		request_code = @p_request_code
				and (
						dimension_code		like '%' + @p_keywords + '%'
						or	dimension_value like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then dimension_code
														when 2 then dimension_value
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then dimension_code
														when 2 then dimension_value
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

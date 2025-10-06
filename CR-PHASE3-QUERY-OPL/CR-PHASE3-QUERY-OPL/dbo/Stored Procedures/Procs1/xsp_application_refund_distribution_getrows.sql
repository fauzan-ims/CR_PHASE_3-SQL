CREATE PROCEDURE [dbo].[xsp_application_refund_distribution_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_application_refund_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_refund_distribution
	where	application_refund_code = @p_application_refund_code
			and (
					staff_name				like '%' + @p_keywords + '%'
					or	staff_position_name like '%' + @p_keywords + '%'
					or	refund_pct			like '%' + @p_keywords + '%'
					or	distribution_amount like '%' + @p_keywords + '%'
				) ;

	select		id
				,staff_name
				,staff_position_name
				,refund_pct			
				,distribution_amount
				,@rows_count 'rowcount'
	from		application_refund_distribution
	where		application_refund_code = @p_application_refund_code
				and (
						staff_name				like '%' + @p_keywords + '%'
						or	staff_position_name like '%' + @p_keywords + '%'
						or	refund_pct			like '%' + @p_keywords + '%'
						or	distribution_amount like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then staff_name
														when 2 then staff_position_name
														when 3 then cast(refund_pct as sql_variant)			
														when 4 then cast(distribution_amount as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then staff_name
														when 2 then staff_position_name
														when 3 then cast(refund_pct as sql_variant)			
														when 4 then cast(distribution_amount as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;   
end ;



CREATE PROCEDURE [dbo].[xsp_master_rounding_detail_lookup]
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_rounding_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_rounding_detail
	where	rounding_code = @p_rounding_code
			and (
					rounding_code		like '%' + @p_keywords + '%'
					or	rounding_amount like '%' + @p_keywords + '%'
				) ;
 
		select		id
					,rounding_code
					,facility_code
					,rounding_type
					,rounding_amount
					,@rows_count 'rowcount'
		from		master_rounding_detail
		where		rounding_code = @p_rounding_code
					and (
							rounding_code		like '%' + @p_keywords + '%'
							or	rounding_amount like '%' + @p_keywords + '%'
						)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then rounding_code
														when 2 then cast(rounding_amount as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rounding_code
														when 2 then cast(rounding_amount as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

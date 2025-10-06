CREATE PROCEDURE dbo.xsp_deposit_release_detail_getrows
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_deposit_release_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	deposit_release_detail drd
	where	deposit_release_code = @p_deposit_release_code
			and (
					drd.deposit_type			like '%' + @p_keywords + '%'
					or	drd.deposit_amount		like '%' + @p_keywords + '%'
					or	drd.release_amount		like '%' + @p_keywords + '%'
				) ;

		select		id
					,drd.deposit_type
					,drd.deposit_code
					,drd.deposit_amount
					,drd.release_amount
					,@rows_count 'rowcount'
		from		deposit_release_detail drd
		where		deposit_release_code = @p_deposit_release_code
					and (
							drd.deposit_type			like '%' + @p_keywords + '%'
							or	drd.deposit_amount		like '%' + @p_keywords + '%'
							or	drd.release_amount		like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then drd.deposit_type
														when 2 then cast(drd.deposit_amount as sql_variant)
														when 3 then cast(drd.release_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then drd.deposit_type
														when 2 then cast(drd.deposit_amount as sql_variant)
														when 3 then cast(drd.release_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

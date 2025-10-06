CREATE PROCEDURE dbo.xsp_due_date_change_transaction_getrows
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_due_date_change_code nvarchar(50)
	,@p_is_transaction		 nvarchar(1)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	due_date_change_transaction rt
			left join dbo.master_transaction mt on (mt.code = rt.transaction_code)
	where	rt.is_transaction			= @p_is_transaction
			and rt.due_date_change_code = @p_due_date_change_code
			and (
					mt.transaction_name			like '%' + @p_keywords + '%'
					or	rt.transaction_amount	like '%' + @p_keywords + '%'
					or	rt.disc_pct				like '%' + @p_keywords + '%'
					or	rt.disc_amount			like '%' + @p_keywords + '%'
					or	rt.total_amount			like '%' + @p_keywords + '%'
				) ;

	select		rt.id
				,mt.transaction_name
				,rt.transaction_amount
				,rt.disc_pct
				,rt.disc_amount
				,rt.total_amount
				,rt.is_amount_editable
				,rt.is_discount_editable
				,@rows_count 'rowcount'
	from		due_date_change_transaction rt
				left join dbo.master_transaction mt on (mt.code = rt.transaction_code)
	where		rt.is_transaction			= @p_is_transaction
				and rt.due_date_change_code = @p_due_date_change_code
				and (
						mt.transaction_name like '%' + @p_keywords + '%'
						or	rt.transaction_amount like '%' + @p_keywords + '%'
						or	rt.disc_pct				like '%' + @p_keywords + '%'
						or	rt.disc_amount			like '%' + @p_keywords + '%'
						or	rt.total_amount			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 0 then rt.order_key
													 when 1 then mt.transaction_name
													 when 2 then cast(rt.transaction_amount as sql_variant)
													 when 3 then cast(rt.disc_pct as sql_variant)
													 when 4 then cast(rt.disc_amount as sql_variant)
													 when 5 then cast(rt.total_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 0 then rt.order_key
													 when 1 then mt.transaction_name
													 when 2 then cast(rt.transaction_amount as sql_variant)
													 when 3 then cast(rt.disc_pct as sql_variant)
													 when 4 then cast(rt.disc_amount as sql_variant)
													 when 5 then cast(rt.total_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

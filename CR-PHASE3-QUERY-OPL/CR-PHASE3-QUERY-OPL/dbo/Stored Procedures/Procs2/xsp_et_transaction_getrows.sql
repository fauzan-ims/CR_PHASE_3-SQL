CREATE PROCEDURE dbo.xsp_et_transaction_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_et_code		   nvarchar(50)
	,@p_is_transaction nvarchar(1)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	et_transaction et
			left join dbo.master_transaction mt on (mt.code = et.transaction_code)
	where	et.is_transaction = @p_is_transaction
			and et.et_code	  = @p_et_code
			and (
					et.id						like '%' + @p_keywords + '%'
					or	mt.transaction_name		like '%' + @p_keywords + '%'
					or	et.transaction_amount	like '%' + @p_keywords + '%'
					or	et.disc_pct				like '%' + @p_keywords + '%'
					or	et.disc_amount			like '%' + @p_keywords + '%'
					or	et.total_amount			like '%' + @p_keywords + '%'
				) ;

	select		et.id
				,mt.transaction_name
				,et.transaction_amount
				,et.disc_pct
				,et.disc_amount
				,et.total_amount
				,et.is_amount_editable
				,et.is_discount_editable
				,@rows_count 'rowcount'
	from		et_transaction et
				left join dbo.master_transaction mt on (mt.code = et.transaction_code)
	where		et.is_transaction = @p_is_transaction
				and et.et_code	  = @p_et_code
				and (
						et.id						like '%' + @p_keywords + '%'
						or	mt.transaction_name		like '%' + @p_keywords + '%'
						or	et.transaction_amount	like '%' + @p_keywords + '%'
						or	et.disc_pct				like '%' + @p_keywords + '%'
						or	et.disc_amount			like '%' + @p_keywords + '%'
						or	et.total_amount			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 0 then	et.order_key
													when 1 then mt.transaction_name
													when 2 then cast(et.transaction_amount as sql_variant)
													when 3 then cast(et.disc_pct as sql_variant)
													when 4 then cast(et.disc_amount as sql_variant)
													when 5 then cast(et.total_amount as sql_variant)
											end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
													when 0 then	et.order_key
													when 1 then mt.transaction_name
													when 2 then cast(et.transaction_amount as sql_variant)
													when 3 then cast(et.disc_pct as sql_variant)
													when 4 then cast(et.disc_amount as sql_variant)
													when 5 then cast(et.total_amount as sql_variant)
												end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

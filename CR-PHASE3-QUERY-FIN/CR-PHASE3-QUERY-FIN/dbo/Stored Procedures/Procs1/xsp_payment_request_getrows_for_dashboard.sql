CREATE PROCEDURE dbo.xsp_payment_request_getrows_for_dashboard
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
)
as
begin
	declare @rows_count int = 0
			,@rate int = 0  ;

	select	@rows_count = count(1)
	from		(
					select distinct
								pr.payment_source
								,sum(pr.payment_amount) 'payment_amount'
								,count(payment_source) 'count_payment_source'
					from		payment_request pr
					where		pr.payment_status = 'HOLD'
					group by	pr.payment_source
				)prq
	where		(
					prq.payment_source				like '%' + @p_keywords + '%'
					or	prq.payment_amount			like '%' + @p_keywords + '%'
					or	prq.count_payment_source	like '%' + @p_keywords + '%'
				)

		select		@rows_count 'rowcount'
					,prq.payment_source
					,prq.payment_amount
					,prq.count_payment_source
		from		(
						select distinct
									pr.payment_source
									,sum(pr.payment_amount) 'payment_amount'
									,count(payment_source) 'count_payment_source'
						from		payment_request pr
						where		pr.payment_status = 'HOLD'
						group by	pr.payment_source
					)prq
		where		(
						prq.payment_source				like '%' + @p_keywords + '%'
						or	prq.payment_amount			like '%' + @p_keywords + '%'
						or	prq.count_payment_source	like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then prq.payment_source
														when 2 then cast(prq.count_payment_source as sql_variant)
														when 3 then cast(prq.payment_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then prq.payment_source
														when 2 then cast(prq.count_payment_source as sql_variant)
														when 3 then cast(prq.payment_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

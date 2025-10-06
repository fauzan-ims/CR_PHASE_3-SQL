CREATE PROCEDURE [dbo].[xsp_application_refund_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_refund af
			inner join dbo.application_main am on (am.application_no = af.application_no)
			inner join master_refund mf on (mf.code = af.refund_code)
			outer apply ( select isnull(sum(ard.distribution_amount), 0) 'distribution_amount' from application_refund_distribution ard where ard.application_refund_code = af.code) refundDistributed
	where	af.application_no = @p_application_no
			and (
					mf.description								like '%' + @p_keywords + '%'
					or	af.refund_rate							like '%' + @p_keywords + '%'
					or	af.refund_amount						like '%' + @p_keywords + '%'
					or	af.currency_code						like '%' + @p_keywords + '%'
					or	refundDistributed.distribution_amount	like '%' + @p_keywords + '%'
				) ;

		select		af.code
					,mf.description 'refund_desc'
					,af.refund_rate	
					,af.refund_amount
					,af.currency_code
					,refundDistributed.distribution_amount 'distribution_amount'
					,@rows_count 'rowcount'
		from		application_refund af
					inner join dbo.application_main am on (am.application_no = af.application_no)
					inner join master_refund mf on (mf.code = af.refund_code)
					outer apply ( select isnull(sum(ard.distribution_amount), 0) 'distribution_amount' from application_refund_distribution ard where ard.application_refund_code = af.code) refundDistributed
		where		af.application_no = @p_application_no
					and (
							mf.description								like '%' + @p_keywords + '%'
							or	af.refund_rate							like '%' + @p_keywords + '%'
							or	af.refund_amount						like '%' + @p_keywords + '%'
							or	af.currency_code						like '%' + @p_keywords + '%'
							or	refundDistributed.distribution_amount	like '%' + @p_keywords + '%'
						)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then mf.description
														when 1 then af.currency_code
														when 2 then cast(af.refund_rate as sql_variant)	
														when 3 then cast(af.refund_amount as sql_variant)
														when 4 then cast(refundDistributed.distribution_amount as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mf.description
														when 1 then af.currency_code
														when 2 then cast(af.refund_rate as sql_variant)	
														when 3 then cast(af.refund_amount as sql_variant)
														when 4 then cast(refundDistributed.distribution_amount as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;


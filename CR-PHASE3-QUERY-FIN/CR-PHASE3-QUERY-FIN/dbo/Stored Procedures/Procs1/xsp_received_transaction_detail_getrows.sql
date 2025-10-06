CREATE PROCEDURE dbo.xsp_received_transaction_detail_getrows
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_received_request_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	received_transaction_detail rtd
			inner join dbo.received_request rr on (rr.code = rtd.received_request_code)
	where	rtd.received_transaction_code  = @p_received_request_code
			and (
					rtd.received_request_code		like '%' + @p_keywords + '%'
					or	rtd.orig_curr_code			like '%' + @p_keywords + '%'
					or	rtd.base_amount				like '%' + @p_keywords + '%'
					or	rtd.orig_amount				like '%' + @p_keywords + '%'
					or	rtd.exch_rate				like '%' + @p_keywords + '%'
					or	rr.received_remarks			like '%' + @p_keywords + '%'
				) ;

		select		id
					,rr.received_transaction_code
					,received_request_code
					,rtd.orig_curr_code			
					,rtd.base_amount
					,rtd.orig_amount				
					,rtd.exch_rate		
					,rr.received_remarks		
					,@rows_count 'rowcount'
		from		received_transaction_detail rtd
					inner join dbo.received_request rr on (rr.code = rtd.received_request_code)
		where		rtd.received_transaction_code  = @p_received_request_code
					and (
							rtd.received_request_code		like '%' + @p_keywords + '%'
							or	rtd.orig_curr_code			like '%' + @p_keywords + '%'
							or	rtd.base_amount				like '%' + @p_keywords + '%'
							or	rtd.orig_amount				like '%' + @p_keywords + '%'
							or	rtd.exch_rate				like '%' + @p_keywords + '%'
							or	rr.received_remarks			like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then rtd.received_request_code
														when 2 then rr.received_remarks
														when 3 then rtd.orig_curr_code			
														when 4 then cast(rtd.orig_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rtd.received_request_code
														when 2 then rr.received_remarks
														when 3 then rtd.orig_curr_code			
														when 4 then cast(rtd.orig_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


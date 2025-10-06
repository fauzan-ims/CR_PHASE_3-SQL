CREATE PROCEDURE dbo.xsp_received_voucher_detail_getrows
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_received_voucher_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	received_voucher_detail rvd
			inner join dbo.journal_gl_link jgl on (jgl.code = rvd.gl_link_code)
	where	received_voucher_code = @p_received_voucher_code
			and (
					rvd.branch_name					like '%' + @p_keywords + '%'
					or	jgl.gl_link_name			like '%' + @p_keywords + '%'
					or	rvd.base_amount				like '%' + @p_keywords + '%'
					or	rvd.orig_amount				like '%' + @p_keywords + '%'
					or	rvd.exch_rate				like '%' + @p_keywords + '%'
					or	rvd.orig_currency_code		like '%' + @p_keywords + '%'
					or	rvd.remarks					like '%' + @p_keywords + '%'
				) ;

		select		id
					,rvd.branch_name
					,jgl.gl_link_name		
					,rvd.base_amount	
					,rvd.remarks
					,rvd.orig_currency_code
					,rvd.orig_amount
					,rvd.exch_rate		
					,@rows_count 'rowcount'
		from		received_voucher_detail rvd
					inner join dbo.journal_gl_link jgl on (jgl.code = rvd.gl_link_code)
		where		received_voucher_code = @p_received_voucher_code
					and (
							rvd.branch_name					like '%' + @p_keywords + '%'
							or	jgl.gl_link_name			like '%' + @p_keywords + '%'
							or	rvd.base_amount				like '%' + @p_keywords + '%'
							or	rvd.orig_amount				like '%' + @p_keywords + '%'
							or	rvd.exch_rate				like '%' + @p_keywords + '%'
							or	rvd.orig_currency_code		like '%' + @p_keywords + '%'
							or	rvd.remarks					like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then rvd.branch_name
														when 2 then jgl.gl_link_name		
														when 3 then rvd.remarks		
														when 4 then rvd.orig_currency_code		
														when 5 then cast(rvd.orig_amount as sql_variant)		
														when 6 then cast(rvd.base_amount as sql_variant)	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rvd.branch_name
														when 2 then jgl.gl_link_name		
														when 3 then rvd.remarks		
														when 4 then rvd.orig_currency_code		
														when 5 then cast(rvd.orig_amount as sql_variant)		
														when 6 then cast(rvd.base_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

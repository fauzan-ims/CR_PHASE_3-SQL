CREATE PROCEDURE dbo.xsp_payment_voucher_detail_getrows
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_payment_voucher_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	payment_voucher_detail pvd
			inner join dbo.journal_gl_link jgl on (jgl.code = pvd.gl_link_code)
	where	payment_voucher_code = @p_payment_voucher_code
			and (
					pvd.branch_name					like '%' + @p_keywords + '%'
					or	jgl.gl_link_name			like '%' + @p_keywords + '%'
					or	pvd.base_amount				like '%' + @p_keywords + '%'
					or	pvd.orig_amount				like '%' + @p_keywords + '%'
					or	pvd.exch_rate				like '%' + @p_keywords + '%'
					or	pvd.orig_currency_code		like '%' + @p_keywords + '%'
					or	pvd.remarks					like '%' + @p_keywords + '%'
				) ;

		select		id
					,pvd.branch_name
					,jgl.gl_link_name		
					,pvd.base_amount	
					,pvd.remarks
					,pvd.orig_currency_code
					,pvd.orig_amount
					,pvd.exch_rate		
					,@rows_count 'rowcount'
		from		payment_voucher_detail pvd
					inner join dbo.journal_gl_link jgl on (jgl.code = pvd.gl_link_code)
		where		payment_voucher_code = @p_payment_voucher_code
					and (
							pvd.branch_name					like '%' + @p_keywords + '%'
							or	jgl.gl_link_name			like '%' + @p_keywords + '%'
							or	pvd.base_amount				like '%' + @p_keywords + '%'
							or	pvd.orig_amount				like '%' + @p_keywords + '%'
							or	pvd.exch_rate				like '%' + @p_keywords + '%'
							or	pvd.orig_currency_code		like '%' + @p_keywords + '%'
							or	pvd.remarks					like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then pvd.branch_name
														when 2 then jgl.gl_link_name		
														when 3 then pvd.remarks		
														when 4 then pvd.orig_currency_code		
														when 5 then cast(pvd.orig_amount as sql_variant)		
														when 6 then cast(pvd.base_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then pvd.branch_name
														when 2 then jgl.gl_link_name		
														when 3 then pvd.remarks		
														when 4 then pvd.orig_currency_code		
														when 5 then cast(pvd.orig_amount as sql_variant)		
														when 6 then cast(pvd.base_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

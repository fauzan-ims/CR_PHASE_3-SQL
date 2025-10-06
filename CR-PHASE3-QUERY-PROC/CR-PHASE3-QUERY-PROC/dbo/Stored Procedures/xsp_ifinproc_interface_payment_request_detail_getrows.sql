CREATE PROCEDURE dbo.xsp_ifinproc_interface_payment_request_detail_getrows
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_payment_request_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.ifinproc_interface_payment_request_detail prd
	where	prd.payment_request_code = @p_payment_request_code
			and	(
					prd.branch_name					like '%' + @p_keywords + '%'
					or	gl_link_code				like '%' + @p_keywords + '%'
					or	orig_currency_code			like '%' + @p_keywords + '%'
					or	orig_amount					like '%' + @p_keywords + '%'
					or	division_name				like '%' + @p_keywords + '%'
					or	department_name				like '%' + @p_keywords + '%'
					or	remarks						like '%' + @p_keywords + '%'
				) ;

	select		id
				,payment_request_code
				,prd.branch_name
				,gl_link_code
				,orig_currency_code
				,orig_amount
				,division_name
				,department_name
				,remarks
				,@rows_count 'rowcount'
	from		dbo.ifinproc_interface_payment_request_detail prd
	where		prd.payment_request_code = @p_payment_request_code
				and	(
						prd.branch_name					like '%' + @p_keywords + '%'
						or	gl_link_code				like '%' + @p_keywords + '%'
						or	orig_currency_code			like '%' + @p_keywords + '%'
						or	orig_amount					like '%' + @p_keywords + '%'
						or	division_name				like '%' + @p_keywords + '%'
						or	department_name				like '%' + @p_keywords + '%'
						or	remarks						like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then gl_link_code
													 when 2 then prd.branch_name
													 when 3 then prd.orig_currency_code + cast(prd.orig_amount as nvarchar(50))
													 when 4 then division_name
													 when 5 then department_name
													 when 6 then remarks
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then gl_link_code
														when 2 then prd.branch_name
														when 3 then prd.orig_currency_code + cast(prd.orig_amount as nvarchar(50))
														when 4 then division_name
														when 5 then department_name
														when 6 then remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

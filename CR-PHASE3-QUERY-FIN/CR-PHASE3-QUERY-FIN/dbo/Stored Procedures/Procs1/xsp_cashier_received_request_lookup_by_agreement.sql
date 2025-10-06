CREATE PROCEDURE dbo.xsp_cashier_received_request_lookup_by_agreement
(
	@p_keywords					 nvarchar(50)
	,@p_pagenumber				 int
	,@p_rowspage				 int
	,@p_order_by				 int
	,@p_sort_by					 nvarchar(5)
	,@p_agreement_no			 nvarchar(50) = ''
	,@p_doc_ref_flag			 nvarchar(10) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	cashier_received_request
	where	isnull(process_reff_code,'') = ''
			and doc_ref_flag = @p_doc_ref_flag
			and request_status			 = 'HOLD'
			and isnull(agreement_no, '') = isnull(@p_agreement_no, '')
			and (
					code						like '%' + @p_keywords + '%'
					or	request_remarks			like '%' + @p_keywords + '%'
					or	request_amount			like '%' + @p_keywords + '%'
					or	request_currency_code	like '%' + @p_keywords + '%'
				) ;

		select		code
					,request_amount
					,request_currency_code
					,request_remarks
					,pdc_no
					,pdc_code
					,branch_bank_code
					,branch_bank_name
					,request_currency_code
					,@rows_count 'rowcount'
		from		cashier_received_request
		where		isnull(process_reff_code,'') = ''
					and doc_ref_flag = @p_doc_ref_flag
					and request_status			 = 'HOLD'
					and isnull(agreement_no, '') = isnull(@p_agreement_no, '')
							and (
									code						like '%' + @p_keywords + '%'
									or	request_remarks			like '%' + @p_keywords + '%'
									or	request_amount			like '%' + @p_keywords + '%'
									or	request_currency_code	like '%' + @p_keywords + '%'
								)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then request_remarks
														when 3 then request_currency_code
														when 4 then cast(request_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then request_remarks
														when 3 then request_currency_code
														when 4 then cast(request_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

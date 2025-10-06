CREATE PROCEDURE dbo.xsp_cashier_received_request_lookup_for_deposit_allocation_detail
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_branch_code				nvarchar(50)
	,@p_agreement_no			nvarchar(50)
	,@p_request_currency_code	nvarchar(5) = ''
	,@p_deposit_allocation_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	cashier_received_request
	where	branch_code					 = case @p_branch_code
											   when 'ALL' then branch_code
											   else @p_branch_code
										   end
			and not exists
						(
							select	received_request_code
							from	dbo.deposit_allocation_detail
							where	received_request_code		= code
									and deposit_allocation_code = @p_deposit_allocation_code
						)
			and request_status			 = 'HOLD'
			and isnull(doc_ref_flag,'') = ''
			and isnull(agreement_no, '') = isnull(@p_agreement_no, '')
			and request_currency_code	 = case @p_request_currency_code
												when '' then request_currency_code
												else @p_request_currency_code
											end
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
					,@rows_count 'rowcount'
		from		cashier_received_request
		where		branch_code					 = case @p_branch_code
													   when 'ALL' then branch_code
													   else @p_branch_code
												   end
					and not exists
								(
									select	received_request_code
									from	dbo.deposit_allocation_detail
									where	received_request_code		= code
											and deposit_allocation_code = @p_deposit_allocation_code
								)
					and request_status			 = 'HOLD'
					and isnull(doc_ref_flag,'') = ''
					and isnull(agreement_no, '') = isnull(@p_agreement_no, '')
					and request_currency_code	 = case @p_request_currency_code
														when '' then request_currency_code
														else @p_request_currency_code
													end
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

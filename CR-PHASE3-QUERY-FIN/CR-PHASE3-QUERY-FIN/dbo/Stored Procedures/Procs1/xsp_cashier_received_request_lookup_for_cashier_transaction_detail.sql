CREATE PROCEDURE [dbo].[xsp_cashier_received_request_lookup_for_cashier_transaction_detail]
(
	@p_keywords					 nvarchar(50)
	,@p_pagenumber				 int
	,@p_rowspage				 int
	,@p_order_by				 int
	,@p_sort_by					 nvarchar(5)
	,@p_branch_code				 nvarchar(50)
	,@p_agreement_no			 nvarchar(50) = null
	,@p_client_no				 nvarchar(50) = null
	,@p_request_currency_code	 nvarchar(5) = ''
	,@p_cashier_transaction_code nvarchar(50)
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
							from	dbo.cashier_transaction_detail
							where	received_request_code		 = code
									and cashier_transaction_code = @p_cashier_transaction_code
						)
			and request_status			 = 'HOLD'
			and isnull(doc_ref_flag,'') = ''
			-- Louis Kamis, 26 Juni 2025 13.50.26 -- 
			--and isnull(agreement_no, '') = isnull(@p_agreement_no, '')
			and isnull(agreement_no, '') = case when isnull(@p_agreement_no, '') = ''  then agreement_no else @p_agreement_no end
			and isnull(client_no, '') = case when isnull(@p_client_no, '') = ''  then client_no else @p_client_no end
			-- Louis Kamis, 26 Juni 2025 13.50.26 -- 

			--pembentukan tagihan dari agreement bisa multi currency, sehingga tidak perlu difilter. Jika di control, maka pembentukan tagihan tidak boleh multi currency
			--and request_currency_code	 = case @p_request_currency_code  
			--									when '' then request_currency_code
			--									else @p_request_currency_code
			--								end
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
					,agreement_no
					,@rows_count 'rowcount'
		from		cashier_received_request
		where		branch_code					 = case @p_branch_code
													   when 'ALL' then branch_code
													   else @p_branch_code
												   end
					and not exists
								(
									select	received_request_code
									from	dbo.cashier_transaction_detail
									where	received_request_code		 = code
											and cashier_transaction_code = @p_cashier_transaction_code
								)
					and request_status			 = 'HOLD'
					and isnull(doc_ref_flag,'') = ''
					-- Louis Kamis, 26 Juni 2025 13.50.26 -- 
					--and isnull(agreement_no, '') = isnull(@p_agreement_no, '')
					and isnull(agreement_no, '') = case when isnull(@p_agreement_no, '') = ''  then agreement_no else @p_agreement_no end
					and isnull(client_no, '') = case when isnull(@p_client_no, '') = ''  then client_no else @p_client_no end
					-- Louis Kamis, 26 Juni 2025 13.50.26 -- 
					--and request_currency_code	 = case @p_request_currency_code
					--									when '' then request_currency_code
					--									else @p_request_currency_code
					--								end
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

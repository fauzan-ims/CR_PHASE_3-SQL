CREATE PROCEDURE dbo.xsp_cashier_received_request_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_branch_code	   nvarchar(50)
	,@p_request_status nvarchar(10)
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
	from	cashier_received_request crr
			left join dbo.agreement_main am on (am.agreement_no = crr.agreement_no)
	where	crr.branch_code	   = case @p_branch_code
									 when 'ALL' then crr.branch_code
									 else @p_branch_code
								 end
			and request_status = case @p_request_status
									 when 'ALL' then request_status
									 else @p_request_status
								 end
			and (
					crr.code										like '%' + @p_keywords + '%'
					or	am.agreement_external_no					like '%' + @p_keywords + '%'
					or	am.client_name								like '%' + @p_keywords + '%'
					or	crr.branch_name								like '%' + @p_keywords + '%'
					or	crr.request_amount							like '%' + @p_keywords + '%'
					or	convert(varchar(30), crr.request_date, 103)	like '%' + @p_keywords + '%'
					or	crr.request_remarks							like '%' + @p_keywords + '%'
					or	crr.request_status							like '%' + @p_keywords + '%'
					or	crr.invoice_external_no						like '%' + @p_keywords + '%'
				) ;

		select		crr.code
					,am.agreement_external_no					
					,am.client_name								
					,crr.branch_name								
					,crr.request_amount							
					,convert(varchar(30), crr.request_date, 103) 'request_date'
					,cast(crr.request_date as date) 'date_rate'
					,crr.request_remarks							
					,crr.request_status	
					,crr.request_currency_code		
					,crr.agreement_no
					,crr.doc_ref_code
					,crr.invoice_no
					,crr.invoice_external_no
					,convert(varchar(30), crr.invoice_date, 103) 'invoice_date'
					,convert(varchar(30), crr.invoice_due_date, 103) 'invoice_due_date'
					,crr.invoice_billing_amount
					,crr.invoice_ppn_amount
					,crr.invoice_pph_amount
					,@rows_count 'rowcount'
		from		cashier_received_request crr
					left join dbo.agreement_main am on (am.agreement_no = crr.agreement_no)
		where		crr.branch_code		   = case @p_branch_code
											 when 'ALL' then crr.branch_code
											 else @p_branch_code
										 end
					and request_status = case @p_request_status
											 when 'ALL' then request_status
											 else @p_request_status
										 end
					and (
							crr.code										like '%' + @p_keywords + '%'
							or	am.agreement_external_no					like '%' + @p_keywords + '%'
							or	am.client_name								like '%' + @p_keywords + '%'
							or	crr.branch_name								like '%' + @p_keywords + '%'
							or	crr.request_amount							like '%' + @p_keywords + '%'
							or	convert(varchar(30), crr.request_date, 103)	like '%' + @p_keywords + '%'
							or	crr.request_remarks							like '%' + @p_keywords + '%'
							or	crr.request_status							like '%' + @p_keywords + '%'
							or	crr.invoice_external_no						like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then crr.code + crr.branch_name 
														when 2 then crr.invoice_external_no 
														when 3 then cast(crr.invoice_billing_amount as sql_variant)
														when 4 then cast(crr.request_amount as sql_variant)
														when 5 then crr.request_remarks	
														when 6 then crr.request_status
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then crr.code + crr.branch_name 
														when 2 then crr.invoice_external_no 
														when 3 then cast(crr.invoice_billing_amount as sql_variant)
														when 4 then cast(crr.request_amount as sql_variant)
														when 5 then crr.request_remarks	
														when 6 then crr.request_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

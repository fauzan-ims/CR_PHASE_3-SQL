CREATE PROCEDURE dbo.xsp_payment_request_getrows
(
	@p_keywords			NVARCHAR(50)
	,@p_pagenumber		INT
	,@p_rowspage		INT
	,@p_order_by		INT
	,@p_sort_by			NVARCHAR(5)
	,@p_branch_code		NVARCHAR(50)
	,@p_payment_status	NVARCHAR(50)
)
AS
BEGIN
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
	from	payment_request
	where		branch_code = case @p_branch_code
								  when 'ALL' then branch_code
								  else @p_branch_code
							  END
    and			payment_status = case @p_payment_status
										  when 'ALL' then payment_status
										  else @p_payment_status
									  end
	and		(
				code													like '%' + @p_keywords + '%'		
				or branch_code											like '%' + @p_keywords + '%'
				or branch_name											like '%' + @p_keywords + '%'
				or payment_branch_code									like '%' + @p_keywords + '%'
				or payment_branch_name									like '%' + @p_keywords + '%'
				or payment_source										like '%' + @p_keywords + '%'
				or convert(varchar(30), payment_request_date, 103)		like '%' + @p_keywords + '%'
				or payment_source_no									like '%' + @p_keywords + '%'
				or payment_status										like '%' + @p_keywords + '%'
				or payment_currency_code								like '%' + @p_keywords + '%'
				or payment_amount										like '%' + @p_keywords + '%'
				or payment_to											like '%' + @p_keywords + '%'
				or payment_remarks										like '%' + @p_keywords + '%'
				or to_bank_name											like '%' + @p_keywords + '%'
				or to_bank_account_name									like '%' + @p_keywords + '%'
				or to_bank_account_no									like '%' + @p_keywords + '%'
				or payment_transaction_code								like '%' + @p_keywords + '%'
				or tax_type												like '%' + @p_keywords + '%'
				or tax_file_no											like '%' + @p_keywords + '%'
				or tax_payer_reff_code									like '%' + @p_keywords + '%'
				or tax_file_name										like '%' + @p_keywords + '%'
			) ;

	SELECT		code						
				,branch_code				
				,branch_name				
				,payment_branch_code		
				,payment_branch_name		
				,payment_source				
				,CONVERT(VARCHAR(30), payment_request_date, 103) 'payment_request_date'		
				,payment_source_no			
				,payment_status				
				,payment_currency_code		
				,payment_amount				
				,payment_to					
				,payment_remarks			
				,to_bank_name				
				,to_bank_account_name		
				,to_bank_account_no			
				,payment_transaction_code	
				,tax_type					
				,tax_file_no				
				,tax_payer_reff_code		
				,tax_file_name				
				,@rows_count 'rowcount'
	FROM		payment_request
	WHERE		branch_code = CASE @p_branch_code
								  WHEN 'ALL' THEN branch_code
								  ELSE @p_branch_code
							  END
    AND			payment_status = CASE @p_payment_status
										  WHEN 'ALL' THEN payment_status
										  ELSE @p_payment_status
									  END
	AND			(
					code													LIKE '%' + @p_keywords + '%'		
					OR branch_code											LIKE '%' + @p_keywords + '%'
					OR branch_name											LIKE '%' + @p_keywords + '%'
					OR payment_branch_code									LIKE '%' + @p_keywords + '%'
					OR payment_branch_name									LIKE '%' + @p_keywords + '%'
					OR payment_source										LIKE '%' + @p_keywords + '%'
					OR CONVERT(VARCHAR(30), payment_request_date, 103)		LIKE '%' + @p_keywords + '%'
					OR payment_source_no									LIKE '%' + @p_keywords + '%'
					OR payment_status										LIKE '%' + @p_keywords + '%'
					OR payment_currency_code								LIKE '%' + @p_keywords + '%'
					OR payment_amount										LIKE '%' + @p_keywords + '%'
					OR payment_to											LIKE '%' + @p_keywords + '%'
					OR payment_remarks										LIKE '%' + @p_keywords + '%'
					OR to_bank_name											LIKE '%' + @p_keywords + '%'
					OR to_bank_account_name									LIKE '%' + @p_keywords + '%'
					OR to_bank_account_no									LIKE '%' + @p_keywords + '%'
					OR payment_transaction_code								LIKE '%' + @p_keywords + '%'
					OR tax_type												LIKE '%' + @p_keywords + '%'
					OR tax_file_no											LIKE '%' + @p_keywords + '%'
					OR tax_payer_reff_code									LIKE '%' + @p_keywords + '%'
					OR tax_file_name										LIKE '%' + @p_keywords + '%'
				)
	ORDER BY	CASE
					WHEN @p_sort_by = 'asc' THEN CASE @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(payment_request_date as sql_variant)
													 when 4 then payment_source
													 when 5 then payment_remarks
													 when 6 then cast(payment_amount as sql_variant)
													 when 7 then payment_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(payment_request_date as sql_variant)
													 when 4 then payment_source
													 when 5 then payment_remarks
													 when 6 then cast(payment_amount as sql_variant)
													 when 7 then payment_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

CREATE procedure [dbo].[xsp_payment_request_detail_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'ho'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'all' ;
	end ;

	select	@rows_count = count(1)
	from	payment_request_detail
	where		branch_code = case @p_branch_code
								  when 'all' then branch_code
								  else @p_branch_code
							  end

	and		(
				payment_request_code			like '%' + @p_keywords + '%'
				or branch_code					like '%' + @p_keywords + '%'
				or branch_name					like '%' + @p_keywords + '%'
				or gl_link_code					like '%' + @p_keywords + '%'
				or agreement_no					like '%' + @p_keywords + '%'
				or facility_code				like '%' + @p_keywords + '%'
				or facility_name				like '%' + @p_keywords + '%'
				or purpose_loan_code			like '%' + @p_keywords + '%'
				or purpose_loan_name			like '%' + @p_keywords + '%'
				or purpose_loan_detail_code		like '%' + @p_keywords + '%'
				or purpose_loan_detail_name		like '%' + @p_keywords + '%'
				or orig_currency_code			like '%' + @p_keywords + '%'
				or exch_rate					like '%' + @p_keywords + '%'
				or orig_amount					like '%' + @p_keywords + '%'
				or division_code				like '%' + @p_keywords + '%'
				or division_name				like '%' + @p_keywords + '%'
				or department_code				like '%' + @p_keywords + '%'
				or department_name				like '%' + @p_keywords + '%'
				or remarks						like '%' + @p_keywords + '%'
				or is_taxable					like '%' + @p_keywords + '%'
				or tax_amount					like '%' + @p_keywords + '%'
				or tax_pct						like '%' + @p_keywords + '%'
			) ;

	select		id
				,payment_request_code		
				,branch_code				
				,branch_name				
				,gl_link_code				
				,agreement_no				
				,facility_code				
				,facility_name				
				,purpose_loan_code			
				,purpose_loan_name			
				,purpose_loan_detail_code	
				,purpose_loan_detail_name	
				,orig_currency_code			
				,exch_rate					
				,orig_amount				
				,division_code				
				,division_name				
				,department_code			
				,department_name			
				,remarks					
				,is_taxable					
				,tax_amount					
				,tax_pct	
				,@rows_count 'rowcount'
	from		payment_request_detail
	where		branch_code = case @p_branch_code
								  when 'all' then branch_code
								  else @p_branch_code
							  end
	and			(
					payment_request_code			like '%' + @p_keywords + '%'
					or branch_code					like '%' + @p_keywords + '%'
					or branch_name					like '%' + @p_keywords + '%'
					or gl_link_code					like '%' + @p_keywords + '%'
					or agreement_no					like '%' + @p_keywords + '%'
					or facility_code				like '%' + @p_keywords + '%'
					or facility_name				like '%' + @p_keywords + '%'
					or purpose_loan_code			like '%' + @p_keywords + '%'
					or purpose_loan_name			like '%' + @p_keywords + '%'
					or purpose_loan_detail_code		like '%' + @p_keywords + '%'
					or purpose_loan_detail_name		like '%' + @p_keywords + '%'
					or orig_currency_code			like '%' + @p_keywords + '%'
					or exch_rate					like '%' + @p_keywords + '%'
					or orig_amount					like '%' + @p_keywords + '%'
					or division_code				like '%' + @p_keywords + '%'
					or division_name				like '%' + @p_keywords + '%'
					or department_code				like '%' + @p_keywords + '%'
					or department_name				like '%' + @p_keywords + '%'
					or remarks						like '%' + @p_keywords + '%'
					or is_taxable					like '%' + @p_keywords + '%'
					or tax_amount					like '%' + @p_keywords + '%'
					or tax_pct						like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 --when 1 then payment_source_no
													 when 1 then branch_name
													 --when 3 then cast(payment_request_date as sql_variant)
													 --when 4 then payment_source
													 --when 5 then payment_remarks
													 --when 6 then cast(payment_amount as sql_variant)
													 --when 7 then payment_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 --when 1 then payment_source_no
													 when 1 then branch_name
													 --when 3 then cast(payment_request_date as sql_variant)
													 --when 4 then payment_source
													 --when 5 then payment_remarks
													 --when 6 then cast(payment_amount as sql_variant)
													 --when 7 then payment_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

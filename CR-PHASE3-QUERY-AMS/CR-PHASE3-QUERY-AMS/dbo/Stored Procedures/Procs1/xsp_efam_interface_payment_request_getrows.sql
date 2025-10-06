CREATE PROCEDURE dbo.xsp_efam_interface_payment_request_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(20)
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
	from	efam_interface_payment_request
	where	branch_code		   = case @p_branch_code
									 when 'ALL' then branch_code
									 else @p_branch_code
								 end
			and payment_status = case @p_status
									 when 'ALL' then payment_status
									 else @p_status
								 end
			and
			(
				code												like '%' + @p_keywords + '%'
				or	branch_name										like '%' + @p_keywords + '%'
				or	convert(varchar(30), payment_request_date, 103) like '%' + @p_keywords + '%'
				or	payment_source_no								like '%' + @p_keywords + '%'
				or	payment_source									like '%' + @p_keywords + '%'
				or	payment_currency_code							like '%' + @p_keywords + '%'
				or	convert(varchar(30), payment_amount, 103)		like '%' + @p_keywords + '%'
				or	to_bank_name									like '%' + @p_keywords + '%'
				or	to_bank_account_no								like '%' + @p_keywords + '%'
				or	to_bank_account_name							like '%' + @p_keywords + '%'
				or	convert(varchar(30), mod_date, 103)				like '%' + @p_keywords + '%'
				or	payment_status									like '%' + @p_keywords + '%'
			) ;

	select		id
				,code
				,company_code
				,branch_code
				,branch_name
				,payment_branch_code
				,payment_branch_name
				,payment_source
				,payment_request_date
				,payment_source_no
				,payment_status
				,payment_currency_code
				,payment_amount
				,payment_remarks
				,to_bank_account_name
				,to_bank_name
				,to_bank_account_no
				,tax_type
				,tax_file_no
				,tax_payer_reff_code
				,tax_file_name
				,process_date
				,process_reff_no
				,process_reff_name
				,settle_date
				,job_status
				,failed_remarks
				,mod_date
				,@rows_count 'rowcount'
	from		efam_interface_payment_request
	where		branch_code		   = case @p_branch_code
										 when 'ALL' then branch_code
										 else @p_branch_code
									 end
				and payment_status = case @p_status
										 when 'ALL' then payment_status
										 else @p_status
									 end
				and
				(
					code												like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	convert(varchar(30), payment_request_date, 103) like '%' + @p_keywords + '%'
					or	payment_source_no								like '%' + @p_keywords + '%'
					or	payment_source									like '%' + @p_keywords + '%'
					or	payment_currency_code							like '%' + @p_keywords + '%'
					or	convert(varchar(30), payment_amount, 103)		like '%' + @p_keywords + '%'
					or	to_bank_name									like '%' + @p_keywords + '%'
					or	to_bank_account_no								like '%' + @p_keywords + '%'
					or	to_bank_account_name							like '%' + @p_keywords + '%'
					or	convert(varchar(30), mod_date, 103)				like '%' + @p_keywords + '%'
					or	payment_status									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then payment_branch_name
													 when 3 then cast(payment_request_date as sql_variant)
													 when 4 then payment_source_no
													 when 5 then cast(payment_amount as sql_variant)
													 when 6 then to_bank_name
													 when 7 then cast(mod_date as sql_variant)
													 when 8 then payment_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then payment_branch_name
													   when 3 then cast(payment_request_date as sql_variant)
													   when 4 then process_reff_no
													   when 5 then cast(payment_amount as sql_variant)
													   when 6 then to_bank_name
													   when 7 then cast(mod_date as sql_variant)
													   when 8 then payment_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

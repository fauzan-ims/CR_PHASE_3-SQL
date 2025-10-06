CREATE PROCEDURE dbo.xsp_ifinproc_interface_payment_request_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)
	,@p_payment_status		nvarchar(10)
	,@p_status				nvarchar(10) = 'ALL'
	,@p_job_status			nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	dbo.ifinproc_interface_payment_request
	where	branch_code		= case @p_branch_code
										  when 'ALL' then branch_code
										  else @p_branch_code
									  end
			and payment_status = case @p_payment_status
										  when 'ALL' then payment_status
										  else @p_payment_status
									  end
			and job_status = case @p_job_status
								WHEN 'ALL' then job_status
							 ELSE @p_job_status
							 END 
			and (
					code												like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	payment_source									like '%' + @p_keywords + '%'
					or	payment_source_no								like '%' + @p_keywords + '%'
					or	convert(varchar(30), payment_request_date, 103) like '%' + @p_keywords + '%'
					or	convert(varchar(30), mod_date, 103)				like '%' + @p_keywords + '%'
					or	to_bank_name									like '%' + @p_keywords + '%'
					or	to_bank_account_no								like '%' + @p_keywords + '%'
					or	to_bank_account_name							like '%' + @p_keywords + '%'
					or	payment_currency_code							like '%' + @p_keywords + '%'
					or	payment_amount									like '%' + @p_keywords + '%'
					or	payment_status									like '%' + @p_keywords + '%'
					or	job_status										like '%' + @p_keywords + '%'
				) ;

	select		id
				,code
				,branch_name
				,payment_source
				,payment_source_no
				,convert(varchar(30), payment_request_date, 103) 'payment_request_date'
				,convert(varchar(30), mod_date, 103) 'mod_date'
				,payment_currency_code
				,payment_amount
				,payment_status
				,to_bank_name
				,to_bank_account_name
				,to_bank_account_no
				,job_status
				,@rows_count 'rowcount'
	from		dbo.ifinproc_interface_payment_request
	where		branch_code		= case @p_branch_code
										  when 'ALL' then branch_code
										  else @p_branch_code
									  end
				and payment_status = case @p_payment_status
										  when 'ALL' then payment_status
										  else @p_payment_status
									  end
				and job_status = case @p_job_status
								WHEN 'ALL' then job_status
							 ELSE @p_job_status
							 END 
				and (
						code												like '%' + @p_keywords + '%'
						or	branch_name										like '%' + @p_keywords + '%'
						or	payment_source									like '%' + @p_keywords + '%'
						or	payment_source_no								like '%' + @p_keywords + '%'
						or	convert(varchar(30), payment_request_date, 103) like '%' + @p_keywords + '%'
						or	convert(varchar(30), mod_date, 103)				like '%' + @p_keywords + '%'
						or	to_bank_name									like '%' + @p_keywords + '%'
						or	to_bank_account_no								like '%' + @p_keywords + '%'
						or	to_bank_account_name							like '%' + @p_keywords + '%'
						or	payment_currency_code							like '%' + @p_keywords + '%'
						or	payment_amount									like '%' + @p_keywords + '%'
						or	payment_status									like '%' + @p_keywords + '%'
						or	job_status										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(payment_request_date as sql_variant)
													 when 4 then payment_source_no + payment_source
													 when 5 then payment_currency_code + cast(payment_amount as nvarchar(50))
													 when 6 then to_bank_name + to_bank_account_no + to_bank_name
													 when 7 then cast(mod_date as sql_variant)
													 when 8 then payment_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(payment_request_date as sql_variant)
														when 4 then payment_source_no + payment_source
														when 5 then payment_currency_code + cast(payment_amount as nvarchar(50))
														when 6 then to_bank_name + to_bank_account_no + to_bank_name
														when 7 then cast(mod_date as sql_variant)
														when 8 then payment_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

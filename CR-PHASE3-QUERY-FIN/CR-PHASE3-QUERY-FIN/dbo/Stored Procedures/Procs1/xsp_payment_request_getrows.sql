CREATE PROCEDURE dbo.xsp_payment_request_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)
	,@p_payment_branch_code	nvarchar(50)
	,@p_payment_status		nvarchar(10) 
	,@p_payment_source		nvarchar(50)
)
as
begin
	declare @rows_count int = 0
			,@rate int = 0
			-- (+) Ari 2023-11-03 ket : get max limit, outstanding, and current payment transaction
			,@transaction_limit				decimal(18,2)
			,@outstanding_limit				decimal(18,2)
			,@current_payment_transaction	decimal(18,2)
			-- (+) Ari 2023-11-03

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

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_payment_branch_code
	)
	begin
		set @p_payment_branch_code = 'ALL' ;
	end ;

	-- (+) Ari 2023-11-03 ket : get limit

	select	@outstanding_limit = isnull(limit.value,0) + isnull(sum(isnull(orig_amount, 0)),0)
			,@transaction_limit = isnull(limit.value,0)
			,@current_payment_transaction = isnull(sum(isnull(orig_amount, 0)),0)
	from	dbo.bank_mutation_history 
	outer	apply (
					select	cast(replace(replace(value,'.',''),',','') as decimal(18,2)) 'value'
					from	dbo.sys_global_param 
					where	code = 'MBTD'
				  ) limit
	where	source_reff_name = 'Payment Confirm'
	and		transaction_date = dbo.xfn_get_system_date()
	and		bank_mutation_code in (select code from dbo.bank_mutation where branch_bank_name = 'MUFG')
	group	by limit.value

	-- (+) Ari 2023-11-03 ket : ketika dihari system date tidak ada transaksi, set default
	if(isnull(@outstanding_limit,0) = 0)
	begin
		select	@transaction_limit = cast(replace(replace(value,'.',''),',','') as decimal(18,2))
		from	dbo.sys_global_param 
		where	code = 'MBTD'
		
		set		@outstanding_limit = @transaction_limit
	end

	set @current_payment_transaction = -1 * @current_payment_transaction
	-- (+) Ari 2023-11-03


	select	@rows_count = count(1)
	from	payment_request
	where	branch_code			= case @p_branch_code
											when 'ALL' then branch_code
											else @p_branch_code
										end
			and payment_branch_code	= case @p_payment_branch_code
											when 'ALL' then payment_branch_code
											else @p_payment_branch_code
										end
			and payment_status = case @p_payment_status
										when 'ALL' then payment_status
										else @p_payment_status
									end
			and payment_source = case @p_payment_source
										when 'ALL' then payment_source
										else @p_payment_source
									end
			and (
					code												like '%' + @p_keywords + '%'
					or	convert(varchar(30), payment_request_date, 103)	like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	payment_branch_name								like '%' + @p_keywords + '%'
					or	payment_source									like '%' + @p_keywords + '%'
					or	payment_source_no								like '%' + @p_keywords + '%'
					or	payment_status									like '%' + @p_keywords + '%'
					or	payment_amount									like '%' + @p_keywords + '%'
					or	payment_remarks									like '%' + @p_keywords + '%'
					or	payment_currency_code							like '%' + @p_keywords + '%'
				) ;

		select		code
					,branch_name
					,payment_branch_name
					,payment_source
					,convert(varchar(30), payment_request_date, 103) 'payment_request_date'
					,cast(payment_request_date as date) 'date_rate'
					,payment_source_no
					,payment_status
					,payment_amount
					,payment_remarks
					,payment_currency_code
					,@rate 'rate'
					,@rows_count 'rowcount'
					-- (+) Ari 2023-11-03 ket : get max limit, outstanding, and current payment transaction
					,isnull(@outstanding_limit,0) 'outstanding_limit'
					,isnull(@transaction_limit,0) 'transaction_limit'
					,isnull(@current_payment_transaction,0) 'current_total_transaction'
					-- (+) Ari 2023-11-03
		from		payment_request
		where		branch_code			= case @p_branch_code
												 when 'ALL' then branch_code
												 else @p_branch_code
											 end
					and payment_branch_code	= case @p_payment_branch_code
													when 'ALL' then payment_branch_code
													else @p_payment_branch_code
											  end
					and payment_status = case @p_payment_status
											 when 'ALL' then payment_status
											 else @p_payment_status
										 end
					and payment_source = case @p_payment_source
											 when 'ALL' then payment_source
											 else @p_payment_source
										 end
					and (
							code												like '%' + @p_keywords + '%'
							or	convert(varchar(30), payment_request_date, 103)	like '%' + @p_keywords + '%'
							or	branch_name										like '%' + @p_keywords + '%'
							or	payment_branch_name								like '%' + @p_keywords + '%'
							or	payment_source									like '%' + @p_keywords + '%'
							or	payment_source_no								like '%' + @p_keywords + '%'
							or	payment_status									like '%' + @p_keywords + '%'
							or	payment_amount									like '%' + @p_keywords + '%'
							or	payment_remarks									like '%' + @p_keywords + '%'
							or	payment_currency_code							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then payment_branch_name
														when 4 then cast(payment_request_date as sql_variant)
														when 5 then payment_source
														when 6 then payment_remarks
														when 7 then cast(payment_amount as sql_variant)
														when 8 then payment_status
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then payment_branch_name
														when 4 then cast(payment_request_date as sql_variant)
														when 5 then payment_source
														when 6 then payment_remarks
														when 7 then cast(payment_amount as sql_variant)
														when 8 then payment_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

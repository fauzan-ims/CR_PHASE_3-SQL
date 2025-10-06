CREATE PROCEDURE dbo.xsp_payment_transaction_getrows_backup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_payment_status  nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	payment_transaction pt with (nolock)
	--outer apply (
	--			select top 1 ptd.payment_request_code
	--			from   dbo.payment_transaction_detail ptd with (nolock)
	--			where  pt.code = ptd.payment_transaction_code
	--				   and ptd.payment_request_code like '%' + @p_keywords + '%'
	--	)  xdetail
	where	branch_code		   = case @p_branch_code
							     	 when 'ALL' then branch_code
							     	 else @p_branch_code
							   	 end
			and payment_status = case @p_payment_status
									 when 'ALL' then payment_status
									 else @p_payment_status
								 end
			and (
					code													like '%' + @p_keywords + '%'
					or	branch_name											like '%' + @p_keywords + '%'
					or	convert(varchar(30), payment_transaction_date, 103)	like '%' + @p_keywords + '%'
					or	payment_base_amount									like '%' + @p_keywords + '%'
					or	payment_remarks										like '%' + @p_keywords + '%'
					or	payment_status										like '%' + @p_keywords + '%'
					--or	xdetail.payment_request_code						like '%' + @p_keywords + '%'
				) ;

		select		code
					,branch_name											
					,convert(varchar(30), payment_transaction_date, 103) 'payment_transaction_date'
					,payment_base_amount									
					,payment_remarks	
					,payment_status	
					,payment_orig_amount
					,branch_bank_code
					,@rows_count 'rowcount'
		from		payment_transaction pt with (nolock)
		--outer apply (
		--		select top 1 ptd.payment_request_code
		--		from   dbo.payment_transaction_detail ptd with (nolock)
		--		where  pt.code = ptd.payment_transaction_code
		--			   and ptd.payment_request_code like '%' + @p_keywords + '%'
		--)  xdetail
		where		branch_code			= case @p_branch_code
									  		  when 'ALL' then branch_code
									  		  else @p_branch_code
										  end
					and payment_status  = case @p_payment_status
											  when 'ALL' then payment_status
											  else @p_payment_status
										  end
					and (
							code													like '%' + @p_keywords + '%'
							or	branch_name											like '%' + @p_keywords + '%'
							or	convert(varchar(30), payment_transaction_date, 103)	like '%' + @p_keywords + '%'
							or	payment_base_amount									like '%' + @p_keywords + '%'
							or	payment_remarks										like '%' + @p_keywords + '%'
							or	payment_status										like '%' + @p_keywords + '%'
							--or	xdetail.payment_request_code						like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name											
														when 3 then cast(payment_transaction_date as sql_variant)	
														when 4 then payment_remarks			
														when 5 then cast(payment_base_amount as sql_variant)									
														when 6 then payment_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name											
														when 3 then cast(payment_transaction_date as sql_variant)	
														when 4 then payment_remarks			
														when 5 then cast(payment_base_amount as sql_variant)									
														when 6 then payment_status	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

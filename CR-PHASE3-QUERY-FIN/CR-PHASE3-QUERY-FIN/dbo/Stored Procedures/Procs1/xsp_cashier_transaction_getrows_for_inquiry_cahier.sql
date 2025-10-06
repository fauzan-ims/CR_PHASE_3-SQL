CREATE PROCEDURE dbo.xsp_cashier_transaction_getrows_for_inquiry_cahier
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)
	,@p_cashier_main_code	nvarchar(50)   = 'ALL'
	,@p_from_date			datetime
	,@p_to_date				datetime
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
	select	@rows_count = count(1)
	from	cashier_transaction ct
			left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
			inner join dbo.cashier_main cm on (cm.code = ct.cashier_main_code)
	where	ct.branch_code			= case @p_branch_code
											when 'ALL' then ct.branch_code
											else @p_branch_code
										end
			and cm.employee_code  = case @p_cashier_main_code
										when 'ALL' then cm.employee_code
										else @p_cashier_main_code
									end
			and ct.cashier_trx_date between @p_from_date and @p_to_date 
			--and ct.cashier_status = 'PAID'
			and (
					ct.code												like '%' + @p_keywords + '%'
					or	am.agreement_external_no						like '%' + @p_keywords + '%'
					or	am.client_name									like '%' + @p_keywords + '%'
					or	ct.branch_name									like '%' + @p_keywords + '%'
					or	ct.cashier_base_amount							like '%' + @p_keywords + '%'
					or	convert(varchar(30), ct.cashier_trx_date, 103)	like '%' + @p_keywords + '%'
					or	ct.cashier_remarks								like '%' + @p_keywords + '%'
				) ;

		select		ct.code
					,am.agreement_external_no
					,am.client_name			
					,ct.cashier_base_amount	
					,ct.branch_name	
					,convert(varchar(30), ct.cashier_trx_date, 103) 'cashier_trx_date'
					,ct.cashier_remarks		
					,@rows_count 'rowcount'
		from		cashier_transaction ct
					left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
					inner join dbo.cashier_main cm on (cm.code = ct.cashier_main_code)
		where		ct.branch_code			= case @p_branch_code
													when 'ALL' then ct.branch_code
													else @p_branch_code
												end
					and cm.employee_code  = case @p_cashier_main_code
													when 'ALL' then cm.employee_code
													else @p_cashier_main_code
												end
					and ct.cashier_trx_date between @p_from_date and @p_to_date 
					--and ct.cashier_status = 'PAID'
					and (
							ct.code													like '%' + @p_keywords + '%'
							or	am.agreement_external_no							like '%' + @p_keywords + '%'
							or	am.client_name										like '%' + @p_keywords + '%'
							or	ct.branch_name										like '%' + @p_keywords + '%'
							or	ct.cashier_base_amount								like '%' + @p_keywords + '%'
							or	convert(varchar(30), ct.cashier_trx_date, 103)		like '%' + @p_keywords + '%'
							or	ct.cashier_remarks									like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ct.code
														when 2 then ct.branch_name
														when 3 then cast(ct.cashier_trx_date as sql_variant)
														when 4 then am.agreement_external_no
														when 5 then ct.cashier_remarks		
														when 6 then cast(ct.cashier_base_amount	as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ct.code
														when 2 then ct.branch_name
														when 3 then cast(ct.cashier_trx_date as sql_variant)
														when 4 then am.agreement_external_no
														when 5 then ct.cashier_remarks		
														when 6 then cast(ct.cashier_base_amount	as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

CREATE PROCEDURE [dbo].[xsp_cashier_transaction_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_cashier_status	nvarchar(10)
	,@p_employee_code	nvarchar(50)
)
as
begin

	declare @rows_count			int = 0 
			,@table_name		nvarchar(250)
			,@sp_name			nvarchar(250) 
			,@rpt_code			nvarchar(50)
			,@report_name		nvarchar(250);

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)
	begin
		set @p_branch_code = 'ALL'
	end
    
	select	@table_name		= table_name
			,@sp_name		= sp_name
			,@rpt_code		= code
			,@report_name	= name
	from	dbo.sys_report
	where	table_name = 'RPT_INVOICE_ALLOCATION' ;


	select	@rows_count = count(1)
	from	cashier_transaction ct
			left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
			inner join dbo.cashier_main cm on (cm.code = ct.cashier_main_code)
			outer apply 
			(
				select	count(1)'count_agreement' 
				from	dbo.cashier_transaction_detail 
				where	cashier_transaction_code = ct.code
			)ctd
	where	ct.branch_code			= case @p_branch_code
											when 'ALL' then ct.branch_code
											else @p_branch_code
										end
			and ct.cashier_status  = case @p_cashier_status
										when 'ALL' then ct.cashier_status
										else @p_cashier_status
									end
			and cm.employee_code = @p_employee_code
			and (
					ct.code													like '%' + @p_keywords + '%'
					or	am.agreement_external_no							like '%' + @p_keywords + '%'
					or	am.client_name										like '%' + @p_keywords + '%'
					or	ct.branch_name										like '%' + @p_keywords + '%'
					or	ct.cashier_base_amount								like '%' + @p_keywords + '%'
					or	convert(varchar(30), ct.cashier_trx_date, 103)		like '%' + @p_keywords + '%'
					or	ct.cashier_remarks									like '%' + @p_keywords + '%'
					or	ct.cashier_status									like '%' + @p_keywords + '%'
				) ;

		select		ct.code
					,case when ctd.count_agreement > 1 then '-'
							else am.agreement_external_no 
						end	'agreement_external_no'			-- raffyanda 2025/08/30 agreement no dikosongkan jika cashier bisa multiple agreement 
					,am.client_name			
					,ct.cashier_base_amount	
					,ct.branch_name	
					,convert(varchar(30), ct.cashier_trx_date, 103) 'cashier_trx_date'
					,ct.cashier_remarks		
					,ct.cashier_status		
					,@rows_count	'rowcount'
					,@table_name	'table_name'
					,@sp_name		'sp_name'
					,@rpt_code		'rpt_code'
					,@report_name	'report_name'
		from		cashier_transaction ct
					left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
					inner join dbo.cashier_main cm on (cm.code = ct.cashier_main_code)
					outer apply 
					(
						select	count(1)'count_agreement' 
						from	dbo.cashier_transaction_detail 
						where	cashier_transaction_code = ct.code
					)ctd
		where		ct.branch_code			= case @p_branch_code
													when 'ALL' then ct.branch_code
													else @p_branch_code
												end
					and ct.cashier_status  = case @p_cashier_status
												when 'ALL' then ct.cashier_status
												else @p_cashier_status
											end
					and cm.employee_code = @p_employee_code
					and (
							ct.code													like '%' + @p_keywords + '%'
							or	am.agreement_external_no							like '%' + @p_keywords + '%'
							or	am.client_name										like '%' + @p_keywords + '%'
							or	ct.branch_name										like '%' + @p_keywords + '%'
							or	ct.cashier_base_amount								like '%' + @p_keywords + '%'
							or	convert(varchar(30), ct.cashier_trx_date, 103)		like '%' + @p_keywords + '%'
							or	ct.cashier_remarks									like '%' + @p_keywords + '%'
							or	ct.cashier_status									like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ct.code
														when 2 then ct.branch_name
														when 3 then cast(ct.cashier_trx_date as sql_variant)
														when 4 then am.client_name
														when 5 then am.agreement_external_no
														when 6 then ct.cashier_remarks		
														when 7 then cast(ct.cashier_base_amount	as sql_variant)
														when 8 then ct.cashier_status
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ct.code
														when 2 then ct.branch_name
														when 3 then cast(ct.cashier_trx_date as sql_variant)
														when 4 then am.client_name
														when 5 then am.agreement_external_no
														when 6 then ct.cashier_remarks		
														when 7 then cast(ct.cashier_base_amount	as sql_variant)
														when 8 then ct.cashier_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

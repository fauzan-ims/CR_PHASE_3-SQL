CREATE PROCEDURE dbo.xsp_efam_interface_journal_gl_link_transaction_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code	nvarchar(50)
	,@p_status		nvarchar(20)
	,@p_from_date	datetime	= null
	,@p_to_date		datetime	= null
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
	from	efam_interface_journal_gl_link_transaction
	where	branch_code		  = case @p_branch_code
										when 'ALL' then branch_code
										else @p_branch_code
									end
	--and		cast(transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
	and		transaction_status = case @p_status
						when 'ALL' then transaction_status
						else @p_status
					end
	and	(
				code													like '%' + @p_keywords + '%'
				or	branch_name											like '%' + @p_keywords + '%'
				or	convert(varchar(30) ,transaction_date ,103)			like '%' + @p_keywords + '%'
				or	convert(varchar(30) ,transaction_value_date ,103)	like '%' + @p_keywords + '%'
				or	transaction_name									like '%' + @p_keywords + '%'
				or	reff_source_no										like '%' + @p_keywords + '%'
				or	transaction_status									like '%' + @p_keywords + '%'
			) ;

	select		id
				,code
				,company_code
				,branch_code
				,branch_name
				,transaction_status
				,convert(varchar(30) ,transaction_date ,103) 'transaction_date'
				,convert(varchar(30) ,transaction_value_date ,103) 'transaction_value_date'
				,transaction_code
				,transaction_name
				,reff_module_code
				,reff_source_no
				,reff_source_name
				,case is_journal_reversal
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_journal_reversal'
				,reversal_reff_no
				,@rows_count 'rowcount'
	from		efam_interface_journal_gl_link_transaction 
	where	branch_code		  = case @p_branch_code
										when 'ALL' then branch_code
										else @p_branch_code
									end
	--and		cast(transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
	and		transaction_status = case @p_status
						when 'ALL' then transaction_status
						else @p_status
					end
	and			(
					code													like '%' + @p_keywords + '%'
					or	branch_name											like '%' + @p_keywords + '%'
					or	convert(varchar(30) ,transaction_date ,103)			like '%' + @p_keywords + '%'
					or	convert(varchar(30) ,transaction_value_date ,103)	like '%' + @p_keywords + '%'
					or	transaction_name									like '%' + @p_keywords + '%'
					or	reff_source_no										like '%' + @p_keywords + '%'
					or	transaction_status									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(transaction_date as sql_variant)
													 when 4 then cast(transaction_value_date as sql_variant)
													 when 5 then transaction_name
													 when 6 then reff_source_no
													 when 7 then transaction_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(transaction_date as sql_variant)
													 when 4 then cast(transaction_value_date as sql_variant)
													 when 5 then transaction_name
													 when 6 then reff_source_no
													 when 7 then transaction_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

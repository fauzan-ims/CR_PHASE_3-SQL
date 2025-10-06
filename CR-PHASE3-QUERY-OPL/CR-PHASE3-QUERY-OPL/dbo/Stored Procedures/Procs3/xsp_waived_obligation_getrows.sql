CREATE PROCEDURE dbo.xsp_waived_obligation_getrows
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_branch_code				nvarchar(50)
	,@p_waived_status			nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	waived_obligation won
			left join dbo.agreement_main amn on (amn.agreement_no = won.agreement_no)
	where	won.branch_code			= case @p_branch_code
											when 'ALL' then won.branch_code
											else @p_branch_code
									  end
	and		won.waived_status	= case @p_waived_status
										when 'ALL' then won.waived_status
										else @p_waived_status
									end
	and		(
				won.code										like '%' + @p_keywords + '%'
				or	won.branch_name								like '%' + @p_keywords + '%'
				or	convert(varchar(30), won.waived_date, 103)	like '%' + @p_keywords + '%'
				or	amn.agreement_external_no					like '%' + @p_keywords + '%'
				or	amn.client_name								like '%' + @p_keywords + '%'
				or	won.waived_amount							like '%' + @p_keywords + '%'
				or	won.obligation_amount						like '%' + @p_keywords + '%'
				or	won.waived_status							like '%' + @p_keywords + '%'
			) ;

	select	won.code
			,won.branch_name								
			,convert(varchar(30), won.waived_date, 103)	'waived_date'
			,amn.agreement_external_no					
			,amn.client_name								
			,won.waived_amount							
			,won.waived_status	
			,won.obligation_amount						
			,@rows_count 'rowcount'
	from	waived_obligation won
			left join dbo.agreement_main amn on (amn.agreement_no = won.agreement_no)
	where	won.branch_code			= case @p_branch_code
											when 'ALL' then won.branch_code
											else @p_branch_code
										end
	and		won.waived_status	= case @p_waived_status
										when 'ALL' then won.waived_status
										else @p_waived_status
									end
	and		(
				won.code										like '%' + @p_keywords + '%'
				or	won.branch_name								like '%' + @p_keywords + '%'
				or	convert(varchar(30), won.waived_date, 103)	like '%' + @p_keywords + '%'
				or	amn.agreement_external_no					like '%' + @p_keywords + '%'
				or	amn.client_name								like '%' + @p_keywords + '%'
				or	won.waived_amount							like '%' + @p_keywords + '%'
				or	won.obligation_amount						like '%' + @p_keywords + '%'
				or	won.waived_status							like '%' + @p_keywords + '%'
			) 
	order by	CASE
					WHEN @p_sort_by = 'asc' then 
												case @p_order_by
													when 1 then won.code
													when 2 then won.branch_name								
													when 3 then cast(won.waived_date as sql_variant)
													when 4 then amn.agreement_external_no					
													when 5 then cast(won.waived_amount as sql_variant)						
													when 6 then cast(won.obligation_amount as sql_variant)						
													when 7 then won.waived_status	
												end
											end asc,
											 case
					when @p_sort_by = 'desc' THEN 
												case @p_order_by
													when 1 then won.code
													when 2 then won.branch_name								
													when 3 then cast(won.waived_date as sql_variant)
													when 4 then amn.agreement_external_no					
													when 5 then cast(won.waived_amount as sql_variant)				
													when 6 then cast(won.obligation_amount as sql_variant)				
													when 7 then won.waived_status	
												end
											end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;


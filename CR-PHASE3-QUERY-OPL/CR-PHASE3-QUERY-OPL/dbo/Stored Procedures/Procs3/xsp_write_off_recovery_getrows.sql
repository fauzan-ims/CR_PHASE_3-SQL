CREATE PROCEDURE dbo.xsp_write_off_recovery_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_recovery_status nvarchar(10)
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
	from	write_off_recovery wor
			inner join dbo.agreement_main am on (am.agreement_no = wor.agreement_no)
	where	wor.branch_code			= case @p_branch_code
										  when 'ALL' then wor.branch_code
										  else @p_branch_code
									  end
			and wor.recovery_status = case @p_recovery_status
										  when 'ALL' then wor.recovery_status
										  else @p_recovery_status
									  end
			and (
					wor.code										like '%' + @p_keywords + '%'
					or wor.branch_name								like '%' + @p_keywords + '%'
					or am.agreement_external_no						like '%' + @p_keywords + '%'
					or am.client_name								like '%' + @p_keywords + '%'
					or convert(varchar(30), wor.recovery_date, 103)	like '%' + @p_keywords + '%'
					or wor.recovery_amount							like '%' + @p_keywords + '%'
					or wor.recovery_status							like '%' + @p_keywords + '%'
				) ;

	select		wor.code
				,wor.branch_name
				,am.agreement_external_no
				,am.client_name
				,convert(varchar(30), wor.recovery_date, 103) 'recovery_date'
				,wor.recovery_amount
				,wor.recovery_status
				,@rows_count 'rowcount'
	from		write_off_recovery wor
				inner join dbo.agreement_main am on (am.agreement_no = wor.agreement_no)
	where		wor.branch_code			= case @p_branch_code
												when 'ALL' then wor.branch_code
												else @p_branch_code
											end
				and wor.recovery_status = case @p_recovery_status
												when 'ALL' then wor.recovery_status
												else @p_recovery_status
											end
				and (
						wor.code										like '%' + @p_keywords + '%'
						or wor.branch_name								like '%' + @p_keywords + '%'
						or am.agreement_external_no						like '%' + @p_keywords + '%'
						or am.client_name								like '%' + @p_keywords + '%'
						or convert(varchar(30), wor.recovery_date, 103)	like '%' + @p_keywords + '%'
						or wor.recovery_amount							like '%' + @p_keywords + '%'
						or wor.recovery_status							like '%' + @p_keywords + '%'
					)
	order by	CASE WHEN @p_sort_by='asc' then 
												case @p_order_by
														when 1 then wor.code
														when 2 then wor.branch_name
														when 3 then am.agreement_external_no + am.client_name
														when 4 then cast(wor.recovery_date as sql_variant)
														when 5 then cast(wor.recovery_amount as sql_variant)
														when 6 then wor.recovery_status
													end 
												end ASC,
												CASE
					WHEN @p_sort_by='desc' then 
												case @p_order_by
														when 1 then wor.code
														when 2 then wor.branch_name
														when 3 then am.agreement_external_no + am.client_name
														when 4 then cast(wor.recovery_date as sql_variant)
														when 5 then cast(wor.recovery_amount as sql_variant)
														when 6 then wor.recovery_status
													end
												end desc OFFSET ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;


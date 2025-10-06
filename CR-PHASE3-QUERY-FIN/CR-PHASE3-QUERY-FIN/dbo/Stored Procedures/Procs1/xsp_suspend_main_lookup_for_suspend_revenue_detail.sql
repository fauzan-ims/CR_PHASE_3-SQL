CREATE PROCEDURE dbo.xsp_suspend_main_lookup_for_suspend_revenue_detail
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_branch_code				nvarchar(50)
	,@p_currency_code			nvarchar(3)
	,@p_suspend_revenue_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	suspend_main sm
	where	not exists
			(
				select	srd.suspend_code
				from	dbo.suspend_revenue_detail srd
				where	srd.suspend_code			= sm.code
						and srd.suspend_revenue_code = @p_suspend_revenue_code
			)
			and	remaining_amount > 0
			and	sm.suspend_currency_code = @p_currency_code  
			and	branch_code		=	case @p_branch_code
										when 'ALL' then branch_code
										else @p_branch_code
									end
			and isnull(transaction_code,'') = ''
			and	(
					code 											like '%' + @p_keywords + '%'
					or suspend_currency_code						like '%' + @p_keywords + '%'
					or convert(varchar(30), suspend_date, 103)		like '%' + @p_keywords + '%'
					or remaining_amount								like '%' + @p_keywords + '%'
					or suspend_remarks								like '%' + @p_keywords + '%'
				) ;

		select		code
					,suspend_currency_code
					,remaining_amount 'suspend_amount'
					,suspend_remarks
					,convert(varchar(30), suspend_date, 103) 'suspend_date'
					,@rows_count 'rowcount'
		from		suspend_main sm
		where		not exists
					(
						select	srd.suspend_code
						from	dbo.suspend_revenue_detail srd
						where	srd.suspend_code			= sm.code
								and srd.suspend_revenue_code = @p_suspend_revenue_code
					)
					and	remaining_amount > 0
					and	sm.suspend_currency_code = @p_currency_code  
					and	branch_code		=	case @p_branch_code
												when 'ALL' then branch_code
												else @p_branch_code
											end
					and isnull(transaction_code,'') = ''
					and	(
							code 											like '%' + @p_keywords + '%'
							or suspend_currency_code						like '%' + @p_keywords + '%'
							or convert(varchar(30), suspend_date, 103)		like '%' + @p_keywords + '%'
							or remaining_amount								like '%' + @p_keywords + '%'
							or suspend_remarks								like '%' + @p_keywords + '%'
						) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then cast(suspend_date as sql_variant)
														when 3 then suspend_remarks
														when 4 then suspend_currency_code
														when 5 then cast(remaining_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then cast(suspend_date as sql_variant)
														when 3 then suspend_remarks
														when 4 then suspend_currency_code
														when 5 then cast(remaining_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

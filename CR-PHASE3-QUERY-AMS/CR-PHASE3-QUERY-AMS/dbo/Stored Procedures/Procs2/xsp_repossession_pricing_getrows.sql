create PROCEDURE dbo.xsp_repossession_pricing_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code	 		nvarchar(50)
	,@p_transaction_status	nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
	select	@rows_count = count(1)
	from	repossession_pricing
	where	branch_code	=	case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code
							end
			and transaction_status	=	case @p_transaction_status
											when 'ALL' then transaction_status
											else @p_transaction_status
										end
			and (
					code											like '%' + @p_keywords + '%'
					or	branch_name									like '%' + @p_keywords + '%'
					or	transaction_status							like '%' + @p_keywords + '%'
					or	convert(varchar(30), transaction_date, 103)	like '%' + @p_keywords + '%'
					or	transaction_remarks							like '%' + @p_keywords + '%'
				) ;

		select		code
					,branch_name
					,transaction_status
					,convert(varchar(30), transaction_date, 103) 'transaction_date'
					,transaction_remarks
					,@rows_count 'rowcount'
		from		repossession_pricing
		where		branch_code	=	case @p_branch_code
										when 'ALL' then branch_code
										else @p_branch_code
									end
					and transaction_status	=	case @p_transaction_status
													when 'ALL' then transaction_status
													else @p_transaction_status
												end
					and (
							code											like '%' + @p_keywords + '%'
							or	branch_name									like '%' + @p_keywords + '%'
							or	transaction_status							like '%' + @p_keywords + '%'
							or	convert(varchar(30), transaction_date, 103)	like '%' + @p_keywords + '%'
							or	transaction_remarks							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name									
													 when 3 then convert(varchar(30), transaction_date, 103)						
													 when 4 then transaction_remarks
													 when 5 then transaction_status	
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then branch_name									
													   when 3 then convert(varchar(30), transaction_date, 103)								
													   when 4 then transaction_remarks
													   when 5 then transaction_status	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

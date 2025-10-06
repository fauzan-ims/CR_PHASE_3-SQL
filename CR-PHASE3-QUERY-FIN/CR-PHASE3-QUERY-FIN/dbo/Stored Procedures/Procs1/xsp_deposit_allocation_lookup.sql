CREATE PROCEDURE dbo.xsp_deposit_allocation_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
	select	@rows_count = count(1)
	from	deposit_allocation da
			left join dbo.agreement_main am on (am.agreement_no = da.agreement_no)
	where	da.branch_code		=  case @p_branch_code
										when 'ALL' then da.branch_code
										else @p_branch_code
								end
			and (
					code													like '%' + @p_keywords + '%'
					or convert(varchar(30), da.allocation_trx_date, 103)	like '%' + @p_keywords + '%'
					or am.agreement_external_no								like '%' + @p_keywords + '%'
					or am.client_name										like '%' + @p_keywords + '%'
					or da.allocation_base_amount							like '%' + @p_keywords + '%'
				) ;

		select		code 'code'
					,da.allocation_base_amount 'amount'
					,convert(varchar(30), allocation_trx_date, 103) 'date'
					,am.agreement_external_no
					,am.client_name
					,@rows_count 'rowcount'
		from		deposit_allocation da
					left join dbo.agreement_main am on (am.agreement_no = da.agreement_no)
		where		da.branch_code		=  case @p_branch_code
												when 'ALL' then da.branch_code
												else @p_branch_code
										end
					and (
							code													like '%' + @p_keywords + '%'
							or convert(varchar(30), da.allocation_trx_date, 103)	like '%' + @p_keywords + '%'
							or am.agreement_external_no								like '%' + @p_keywords + '%'
							or am.client_name										like '%' + @p_keywords + '%'
							or da.allocation_base_amount							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then cast(da.allocation_trx_date as sql_variant)
														when 3 then am.agreement_external_no
														when 4 then da.allocation_base_amount
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then cast(da.allocation_trx_date as sql_variant)
														when 3 then am.agreement_external_no
														when 4 then da.allocation_base_amount
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

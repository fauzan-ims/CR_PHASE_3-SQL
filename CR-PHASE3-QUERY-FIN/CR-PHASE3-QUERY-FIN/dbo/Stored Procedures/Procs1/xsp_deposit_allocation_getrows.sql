CREATE PROCEDURE dbo.xsp_deposit_allocation_getrows
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	,@p_branch_code		  nvarchar(50)
	,@p_allocation_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	deposit_allocation da
			inner join dbo.agreement_main am on (am.agreement_no = da.agreement_no)
	where	da.branch_code			 = case @p_branch_code
											when 'ALL' then da.branch_code
											else @p_branch_code
										end
			and da.allocation_status = case @p_allocation_status
											when 'ALL' then da.allocation_status
											else @p_allocation_status
										end
			and (
					da.code													like '%' + @p_keywords + '%'
					or	da.branch_name										like '%' + @p_keywords + '%'
					or	am.agreement_external_no							like '%' + @p_keywords + '%'
					or	am.client_name										like '%' + @p_keywords + '%'
					or	da.allocation_base_amount							like '%' + @p_keywords + '%'
					or	convert(varchar(30), da.allocation_trx_date, 103)	like '%' + @p_keywords + '%'
					or	da.allocationt_remarks								like '%' + @p_keywords + '%'
					or	da.allocation_status								like '%' + @p_keywords + '%'
				) ;

		select		da.code
					,da.branch_name
					,am.agreement_external_no
					,am.client_name
					,da.allocation_base_amount
					,convert(varchar(30), da.allocation_trx_date, 103) 'allocation_trx_date'
					,da.allocationt_remarks
					,da.allocation_status
					,@rows_count 'rowcount'
		from		deposit_allocation da
					inner join dbo.agreement_main am on (am.agreement_no = da.agreement_no)
		where		da.branch_code			 = case @p_branch_code
												   when 'ALL' then da.branch_code
												   else @p_branch_code
											   end
					and da.allocation_status = case @p_allocation_status
												   when 'ALL' then da.allocation_status
												   else @p_allocation_status
											   end
					and (
							da.code													like '%' + @p_keywords + '%'
							or	da.branch_name										like '%' + @p_keywords + '%'
							or	am.agreement_external_no							like '%' + @p_keywords + '%'
							or	am.client_name										like '%' + @p_keywords + '%'
							or	da.allocation_base_amount							like '%' + @p_keywords + '%'
							or	convert(varchar(30), da.allocation_trx_date, 103)	like '%' + @p_keywords + '%'
							or	da.allocationt_remarks								like '%' + @p_keywords + '%'
							or	da.allocation_status								like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then da.code
														when 2 then da.branch_name
														when 3 then cast(da.allocation_trx_date as sql_variant)
														when 4 then am.agreement_external_no
														when 5 then da.allocationt_remarks
														when 6 then cast(da.allocation_base_amount as sql_variant)
														when 7 then da.allocation_status
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then da.code
														when 2 then da.branch_name
														when 3 then cast(da.allocation_trx_date as sql_variant)
														when 4 then am.agreement_external_no
														when 5 then da.allocationt_remarks
														when 6 then cast(da.allocation_base_amount as sql_variant)
														when 7 then da.allocation_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

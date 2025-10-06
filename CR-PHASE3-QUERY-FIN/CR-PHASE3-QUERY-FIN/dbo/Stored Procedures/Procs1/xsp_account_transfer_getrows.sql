CREATE PROCEDURE dbo.xsp_account_transfer_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_transfer_status	nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	account_transfer
	where	from_branch_code	=  case @p_branch_code
										when 'ALL' then from_branch_code
										else @p_branch_code
									end
			and transfer_status  = case @p_transfer_status
										when 'ALL' then transfer_status
										else @p_transfer_status
									end
			and (
					code												like '%' + @p_keywords + '%'
					or	convert(varchar(30), transfer_trx_date, 103)	like '%' + @p_keywords + '%'
					or	from_branch_name								like '%' + @p_keywords + '%'
					or	from_orig_amount								like '%' + @p_keywords + '%'
					or	transfer_remarks								like '%' + @p_keywords + '%'
					or	transfer_status									like '%' + @p_keywords + '%'
				) ;

		select		code
					,convert(varchar(30), transfer_trx_date, 103) 'transfer_trx_date'
					,from_branch_name
					,from_orig_amount
					,transfer_remarks
					,transfer_status
					,@rows_count 'rowcount'
		from		account_transfer
		where		from_branch_code	=  case @p_branch_code
												when 'ALL' then from_branch_code
												else @p_branch_code
											end
					and transfer_status  = case @p_transfer_status
												when 'ALL' then transfer_status
												else @p_transfer_status
											end
					and (
							code												like '%' + @p_keywords + '%'
							or	convert(varchar(30), transfer_trx_date, 103)	like '%' + @p_keywords + '%'
							or	from_branch_name								like '%' + @p_keywords + '%'
							or	from_orig_amount								like '%' + @p_keywords + '%'
							or	transfer_remarks								like '%' + @p_keywords + '%'
							or	transfer_status									like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then from_branch_name		
														when 3 then cast(transfer_trx_date as sql_variant)	
														when 4 then transfer_remarks	
														when 5 then cast(from_orig_amount as sql_variant)
														when 6 then transfer_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then from_branch_name		
														when 3 then cast(transfer_trx_date as sql_variant)	
														when 4 then transfer_remarks	
														when 5 then cast(from_orig_amount as sql_variant)
														when 6 then transfer_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

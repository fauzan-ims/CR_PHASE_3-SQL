CREATE PROCEDURE dbo.xsp_reprint_receipt_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_reprint_status	nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
	select	@rows_count = count(1)
	from	reprint_receipt
	where	branch_code		   = case @p_branch_code
									 when 'ALL' then branch_code
									 else @p_branch_code
								 end
			and reprint_status = case @p_reprint_status
									 when 'ALL' then reprint_status
									 else @p_reprint_status
								 end
			and (
					branch_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), reprint_date, 103)	like '%' + @p_keywords + '%'
					or	reprint_remarks							like '%' + @p_keywords + '%'
					or	cashier_type							like '%' + @p_keywords + '%'
					or	cashier_code							like '%' + @p_keywords + '%'
					or	reprint_status							like '%' + @p_keywords + '%'
				) ;

		select		code
					,branch_name
					,convert(varchar(30), reprint_date, 103) 'reprint_date'
					,reprint_remarks 
					,cashier_type	
					,cashier_code	
					,reprint_status	
					,@rows_count 'rowcount'
		from		reprint_receipt
		where		branch_code		   = case @p_branch_code
											 when 'ALL' then branch_code
											 else @p_branch_code
										 end
					and reprint_status = case @p_reprint_status
											 when 'ALL' then reprint_status
											 else @p_reprint_status
										 end
					and (
							branch_name									like '%' + @p_keywords + '%'
							or	convert(varchar(30), reprint_date, 103)	like '%' + @p_keywords + '%'
							or	reprint_remarks							like '%' + @p_keywords + '%'
							or	cashier_type							like '%' + @p_keywords + '%'
							or	cashier_code							like '%' + @p_keywords + '%'
							or	reprint_status							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then branch_name
														when 2 then cast(reprint_date as sql_variant)
														when 3 then reprint_remarks 
														when 4 then cashier_type	
														when 5 then cashier_code	
														when 6 then reprint_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then branch_name
														when 2 then cast(reprint_date as sql_variant)
														when 3 then reprint_remarks 
														when 4 then cashier_type	
														when 5 then cashier_code	
														when 6 then reprint_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

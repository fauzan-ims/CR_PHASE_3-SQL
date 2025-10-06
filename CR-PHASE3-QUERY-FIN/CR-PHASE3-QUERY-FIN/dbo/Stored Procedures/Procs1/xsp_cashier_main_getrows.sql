CREATE PROCEDURE dbo.xsp_cashier_main_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_cashier_status  nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	cashier_main
	where	branch_code			= case @p_branch_code
								  	  when 'ALL' then branch_code
								  	  else @p_branch_code
								  end
			and cashier_status  = case @p_cashier_status
									  when 'ALL' then cashier_status
									  else @p_cashier_status
								  end
			and (
					code												like 	'%'+@p_keywords+'%'
					or	branch_name										like 	'%'+@p_keywords+'%'
					or	employee_name									like 	'%'+@p_keywords+'%'
					or	convert(varchar(30), cashier_open_date, 103)	like 	'%'+@p_keywords+'%'
					or	cashier_close_amount							like 	'%'+@p_keywords+'%'
					or	cashier_status									like 	'%'+@p_keywords+'%'
				) ;

		select		code
					,branch_name									
					,employee_name								
					,convert(varchar(30), cashier_open_date, 103) 'cashier_open_date'
					,cashier_close_amount						
					,cashier_status								
					,@rows_count 'rowcount'
		from		cashier_main
		where		branch_code			= case @p_branch_code
									  		  when 'ALL' then branch_code
									  		  else @p_branch_code
										  end
					and cashier_status  = case @p_cashier_status
											  when 'ALL' then cashier_status
											  else @p_cashier_status
										  end
					and (
							code												like 	'%'+@p_keywords+'%'
							or	branch_name										like 	'%'+@p_keywords+'%'
							or	employee_name									like 	'%'+@p_keywords+'%'
							or	convert(varchar(30), cashier_open_date, 103)	like 	'%'+@p_keywords+'%'
							or	cashier_close_amount							like 	'%'+@p_keywords+'%'
							or	cashier_status									like 	'%'+@p_keywords+'%'
						) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name									
														when 3 then employee_name								
														when 4 then cast(cashier_open_date as sql_variant)
														when 5 then cast(cashier_close_amount as sql_variant)						
														when 6 then cashier_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name									
														when 3 then employee_name								
														when 4 then cast(cashier_open_date as sql_variant)
														when 5 then cast(cashier_close_amount as sql_variant)						
														when 6 then cashier_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

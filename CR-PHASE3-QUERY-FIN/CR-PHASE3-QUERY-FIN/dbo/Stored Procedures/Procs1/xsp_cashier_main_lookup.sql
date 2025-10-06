CREATE PROCEDURE dbo.xsp_cashier_main_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_date			datetime
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
			and cashier_status = 'OPEN'
			--and convert(date, cashier_open_date) = convert(date, dbo.xfn_get_system_date())
			and convert(date, cashier_open_date) = convert(date, @p_date)
			and (
					code				like 	'%'+@p_keywords+'%'
					or	employee_name	like 	'%'+@p_keywords+'%'
				) ;

		select		code
					,employee_name								
					,@rows_count 'rowcount'
		from		cashier_main
		where		branch_code			= case @p_branch_code
									  		  when 'ALL' then branch_code
									  		  else @p_branch_code
										  end
					and cashier_status  = 'OPEN'
					--and convert(date, cashier_open_date) = convert(date, dbo.xfn_get_system_date())
					and convert(date, cashier_open_date) = convert(date, @p_date)
					and (
							code				like 	'%'+@p_keywords+'%'
							or	employee_name	like 	'%'+@p_keywords+'%'
						) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then employee_name
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then employee_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

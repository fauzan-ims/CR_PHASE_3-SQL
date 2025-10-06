CREATE PROCEDURE dbo.xsp_reconcile_main_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_branch_code		 nvarchar(50)
	,@p_reconcile_status nvarchar(10)
	,@p_from_date		 datetime
	,@p_to_date			 datetime
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
	select	@rows_count = count(1)
	from	reconcile_main
	where	reconcile_from_value_date
			between @p_from_date and @p_to_date
			and branch_code		 = case @p_branch_code
									   when 'ALL' then branch_code
									   else @p_branch_code
								   end
			and reconcile_status = case @p_reconcile_status
									   when 'ALL' then reconcile_status
									   else @p_reconcile_status
								   end
			and (
					code														like '%' + @p_keywords + '%'
					or	branch_name												like '%' + @p_keywords + '%'
					or	branch_bank_name										like '%' + @p_keywords + '%'
					or	convert(varchar(30), reconcile_from_value_date, 103)	like '%' + @p_keywords + '%'
					or	convert(varchar(30), reconcile_to_value_date, 103)		like '%' + @p_keywords + '%'
					or	reconcile_status										like '%' + @p_keywords + '%'
				) ;

		select		code
					,branch_name												
					,branch_bank_name									
					,convert(varchar(30), reconcile_from_value_date, 103) 'reconcile_from_value_date'
					,convert(varchar(30), reconcile_to_value_date, 103)	'reconcile_to_value_date'
					,reconcile_status									
					,@rows_count 'rowcount'
		from		reconcile_main
		where		reconcile_from_value_date
					between @p_from_date and @p_to_date
					and branch_code		 = case @p_branch_code
											   when 'ALL' then branch_code
											   else @p_branch_code
										   end
					and reconcile_status = case @p_reconcile_status
											   when 'ALL' then reconcile_status
											   else @p_reconcile_status
										   end
					and (
							code														like '%' + @p_keywords + '%'
							or	branch_name												like '%' + @p_keywords + '%'
							or	branch_bank_name										like '%' + @p_keywords + '%'
							or	convert(varchar(30), reconcile_from_value_date, 103)	like '%' + @p_keywords + '%'
							or	convert(varchar(30), reconcile_to_value_date, 103)		like '%' + @p_keywords + '%'
							or	reconcile_status										like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name											
														when 3 then branch_bank_name									
														when 4 then cast(reconcile_from_value_date as sql_variant)
														when 5 then cast(reconcile_to_value_date as sql_variant)	
														when 6 then reconcile_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name											
														when 3 then branch_bank_name									
														when 4 then cast(reconcile_from_value_date as sql_variant)
														when 5 then cast(reconcile_to_value_date as sql_variant)	
														when 6 then reconcile_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

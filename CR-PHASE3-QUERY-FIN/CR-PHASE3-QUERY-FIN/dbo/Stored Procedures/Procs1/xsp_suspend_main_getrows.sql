CREATE PROCEDURE dbo.xsp_suspend_main_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_remaining	nvarchar(3)
	,@p_from_date	datetime
	,@p_to_date		datetime
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	if @p_remaining = 'YES'
	begin
		select	@rows_count = count(1)
		from	suspend_main
		where	remaining_amount > 0
				and branch_code	 = case @p_branch_code
									   when 'ALL' then branch_code
									   else @p_branch_code
								   end
				and cast(suspend_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) 
				and (
						code										like '%' + @p_keywords + '%'
						or	branch_name								like '%' + @p_keywords + '%'
						or	reff_no									like '%' + @p_keywords + '%'
						or	reff_name								like '%' + @p_keywords + '%'
						or	suspend_remarks							like '%' + @p_keywords + '%'
						or	suspend_amount							like '%' + @p_keywords + '%'
						or	remaining_amount						like '%' + @p_keywords + '%'
						or	suspend_currency_code					like '%' + @p_keywords + '%'
						or	convert(varchar(30), suspend_date, 103)	like '%' + @p_keywords + '%'
					) ;

			select		code
						,branch_name
						,reff_no
						,reff_name
						,suspend_remarks
						,suspend_amount
						,remaining_amount
						,convert(varchar(30), suspend_date, 103) 'suspend_date'
						,suspend_currency_code
						,@rows_count 'rowcount'
			from		suspend_main
			where		remaining_amount > 0
						and branch_code	 = case @p_branch_code
											   when 'ALL' then branch_code
											   else @p_branch_code
										   end
						and cast(suspend_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) 
						and (
								code										like '%' + @p_keywords + '%'
								or	branch_name								like '%' + @p_keywords + '%'
								or	reff_no									like '%' + @p_keywords + '%'
								or	reff_name								like '%' + @p_keywords + '%'
								or	suspend_remarks							like '%' + @p_keywords + '%'
								or	suspend_amount							like '%' + @p_keywords + '%'
								or	remaining_amount						like '%' + @p_keywords + '%'
								or	suspend_currency_code					like '%' + @p_keywords + '%'
								or	convert(varchar(30), suspend_date, 103)	like '%' + @p_keywords + '%'
							)
			order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(suspend_date as sql_variant)
														when 4 then suspend_currency_code
														when 5 then reff_no
														when 6 then suspend_remarks
														when 7 then cast(suspend_amount as sql_variant)
														when 8 then cast(remaining_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(suspend_date as sql_variant)
														when 4 then suspend_currency_code
														when 5 then reff_no
														when 6 then suspend_remarks
														when 7 then cast(suspend_amount as sql_variant)
														when 8 then cast(remaining_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select	@rows_count = count(1)
		from	suspend_main
		where	remaining_amount = 0
				and branch_code	 = case @p_branch_code
									   when 'ALL' then branch_code
									   else @p_branch_code
								   end
				and cast(suspend_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) 
				and (
						code										like '%' + @p_keywords + '%'
						or	branch_name								like '%' + @p_keywords + '%'
						or	reff_no									like '%' + @p_keywords + '%'
						or	reff_name								like '%' + @p_keywords + '%'
						or	suspend_remarks							like '%' + @p_keywords + '%'
						or	suspend_amount							like '%' + @p_keywords + '%'
						or	remaining_amount						like '%' + @p_keywords + '%'
						or	suspend_currency_code					like '%' + @p_keywords + '%'
						or	convert(varchar(30), suspend_date, 103)	like '%' + @p_keywords + '%'
					) ;

			select		code
						,branch_name
						,reff_no
						,reff_name
						,suspend_remarks
						,suspend_amount
						,remaining_amount
						,convert(varchar(30), suspend_date, 103) 'suspend_date'
						,suspend_currency_code
						,@rows_count 'rowcount'
			from		suspend_main
			where		remaining_amount = 0
						and branch_code	 = case @p_branch_code
											   when 'ALL' then branch_code
											   else @p_branch_code
										   end
						and cast(suspend_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) 
						and (
								code										like '%' + @p_keywords + '%'
								or	branch_name								like '%' + @p_keywords + '%'
								or	reff_no									like '%' + @p_keywords + '%'
								or	reff_name								like '%' + @p_keywords + '%'
								or	suspend_remarks							like '%' + @p_keywords + '%'
								or	suspend_amount							like '%' + @p_keywords + '%'
								or	remaining_amount						like '%' + @p_keywords + '%'
								or	suspend_currency_code					like '%' + @p_keywords + '%'
								or	convert(varchar(30), suspend_date, 103)	like '%' + @p_keywords + '%'
							)
			order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(suspend_date as sql_variant)
														when 4 then suspend_currency_code
														when 5 then reff_no
														when 6 then suspend_remarks
														when 7 then cast(suspend_amount as sql_variant)
														when 8 then cast(remaining_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(suspend_date as sql_variant)
														when 4 then suspend_currency_code
														when 5 then reff_no
														when 6 then suspend_remarks
														when 7 then cast(suspend_amount as sql_variant)
														when 8 then cast(remaining_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;

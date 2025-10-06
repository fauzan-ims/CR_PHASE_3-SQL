CREATE PROCEDURE dbo.xsp_warning_letter_generate_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_branch_code	  nvarchar(50) 
	,@p_letter_type   nvarchar(10) = ''
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;
    
	select	@rows_count = count(1)
	from	warning_letter wl
	where	wl.letter_type					= case @p_letter_type
												  when '' then wl.letter_type
												  else @p_letter_type
											  end
			and wl.branch_code				= case @p_branch_code
												  when 'ALL' then wl.branch_code
												  else @p_branch_code
											  end
			and wl.letter_status			in ('HOLD','NOT DELIVERED') 
			and (
					wl.branch_name									like '%' + @p_keywords + '%'
					or	wl.letter_no								like '%' + @p_keywords + '%' 
					or	convert(varchar(30), wl.letter_date, 103)	like '%' + @p_keywords + '%'
					or	wl.generate_type							like '%' + @p_keywords + '%'
					or	wl.client_no + ' - ' + wl.client_name		like '%' + @p_keywords + '%'
					or	wl.overdue_days								like '%' + @p_keywords + '%'
					or	wl.total_agreement_count					like '%' + @p_keywords + '%'
					or	wl.total_asset_count						like '%' + @p_keywords + '%'
					or	wl.total_monthly_rental_amount				like '%' + @p_keywords + '%'
				) ;

		select		wl.code
					,wl.branch_name
					,wl.letter_no
					,wl.letter_type
					,convert(varchar(30), wl.letter_date, 103) 'letter_date'
					,wl.client_no + ' - ' + wl.client_name 'client_name'
					,wl.overdue_days	
					,wl.last_print_by
					,wl.letter_status
					,wl.generate_type 
					,wl.installment_no
					--
					,total_agreement_count
					,total_asset_count
					,total_monthly_rental_amount
					,total_overdue_amount
					,@rows_count 'rowcount'
		from		warning_letter wl
		where		wl.letter_type					= case @p_letter_type
														  when '' then wl.letter_type
														  else @p_letter_type
													  end
					and wl.branch_code				= case @p_branch_code
														  when 'ALL' then wl.branch_code
														  else @p_branch_code
													  end
					and wl.letter_status			in ('HOLD','NOT DELIVERED') 
					and (
							wl.branch_name									like '%' + @p_keywords + '%'
							or	wl.letter_no								like '%' + @p_keywords + '%' 
							or	convert(varchar(30), wl.letter_date, 103)	like '%' + @p_keywords + '%'
							or	wl.generate_type							like '%' + @p_keywords + '%'
							or	wl.client_no + ' - ' + wl.client_name		like '%' + @p_keywords + '%'
							or	wl.overdue_days								like '%' + @p_keywords + '%'
							or	wl.total_agreement_count					like '%' + @p_keywords + '%'
							or	wl.total_asset_count						like '%' + @p_keywords + '%'
							or	wl.total_monthly_rental_amount				like '%' + @p_keywords + '%'
						) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then wl.letter_no
														when 2 then wl.branch_name
														when 3 then cast(wl.letter_date as sql_variant)
														when 4 then wl.generate_type
														when 5 then client_name
														when 6 then cast(wl.overdue_days as sql_variant)
														when 7 then cast(wl.total_overdue_amount as sql_variant) 
														when 8 then cast(wl.total_agreement_count as sql_variant) 
														when 9 then cast(wl.total_asset_count as sql_variant) 
														when 10 then cast(wl.total_monthly_rental_amount as sql_variant) 
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then wl.letter_no
														when 2 then wl.branch_name
														when 3 then cast(wl.letter_date as sql_variant)
														when 4 then wl.generate_type
														when 5 then client_name
														when 6 then cast(wl.overdue_days as sql_variant)
														when 7 then cast(wl.total_overdue_amount as sql_variant) 
														when 8 then cast(wl.total_agreement_count as sql_variant) 
														when 9 then cast(wl.total_asset_count as sql_variant) 
														when 10 then cast(wl.total_monthly_rental_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


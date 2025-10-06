CREATE PROCEDURE dbo.xsp_warning_letter_history_getrows
(
	@p_keywords		  NVARCHAR(50)
	,@p_pagenumber	  INT
	,@p_rowspage	  INT
	,@p_order_by	  INT
	,@p_sort_by		  NVARCHAR(5)
	,@p_branch_code	  NVARCHAR(50)
	,@p_letter_type	  NVARCHAR(30)
	,@p_from_date	  DATETIME
	,@p_to_date		  DATETIME
)
AS
BEGIN
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
			left join dbo.warning_letter_delivery wld on (wld.code = wl.delivery_code)
	where	wl.branch_code			= case @p_branch_code
										  when 'ALL' then wl.branch_code
										  else @p_branch_code
									  end
			and wl.letter_type		= case @p_letter_type
									  	  when 'ALL' then wl.letter_type
									  	  else @p_letter_type
									   end
			and wl.letter_status	not in ('REQUEST','CANCEL')
			and wl.letter_date
			between @p_from_date and @p_to_date
			and (
					wl.letter_no										like '%' + @p_keywords + '%'
					or	convert(varchar(30), wl.letter_date, 103)		like '%' + @p_keywords + '%'
					or	wl.client_name									like '%' + @p_keywords + '%'
					or	wl.overdue_days									like '%' + @p_keywords + '%'
					or	wl.last_print_by								like '%' + @p_keywords + '%'
					or	convert(varchar(30), wl.delivery_date, 103)		like '%' + @p_keywords + '%'
					or	wl.letter_status								like '%' + @p_keywords + '%'
					or	wl.branch_name									like '%' + @p_keywords + '%'
					or	wl.generate_type								like '%' + @p_keywords + '%'
					or	wl.letter_type									like '%' + @p_keywords + '%'
					or	wl.installment_no								like '%' + @p_keywords + '%'
					or	wld.delivery_status								like '%' + @p_keywords + '%'
					or	format(wld.total_monthly_rental_amount, 'n2')	like '%' + @p_keywords + '%'
					or	format(wl.total_overdue_amount, 'n2')			like '%' + @p_keywords + '%'
					or	wld.total_monthly_rental_amount					LIKE '%' + @p_keywords + '%'
					or	wl.total_overdue_amount							like '%' + @p_keywords + '%'
				) ;

		select		wl.code
					,wl.letter_no
					,convert(varchar(30), wl.letter_date, 103) 'letter_date'
					,wl.client_name
					,wl.overdue_days
					,wl.last_print_by
					,convert(varchar(30), wl.delivery_date, 103) 'delivery_date'
					,wl.letter_status
					,wl.branch_name
					,wl.generate_type
					,wl.letter_type
					,wl.installment_no
					,wld.delivery_status
					,wl.total_agreement_count
					,wl.total_asset_count
					,format(wld.total_monthly_rental_amount, 'n2')	total_monthly_rental_amount
					,format(wl.total_overdue_amount, 'n2')			total_overdue_amount
					,@rows_count 'rowcount'
		from		warning_letter wl
					left join dbo.warning_letter_delivery wld on (wld.code = wl.delivery_code)
		where		wl.branch_code			= case @p_branch_code
												  when 'ALL' then wl.branch_code
												  else @p_branch_code
											  end
					and wl.letter_type		= case @p_letter_type
												  when 'ALL' then wl.letter_type
												  else @p_letter_type
											   end
					and wl.letter_status	not in ('REQUEST','CANCEL')
					and wl.letter_date
					between @p_from_date and @p_to_date
					and (
							wl.letter_no										like '%' + @p_keywords + '%'
							or	convert(varchar(30), wl.letter_date, 103)		like '%' + @p_keywords + '%'
							or	wl.client_name									like '%' + @p_keywords + '%'
							or	wl.overdue_days									like '%' + @p_keywords + '%'
							or	wl.last_print_by								like '%' + @p_keywords + '%'
							or	convert(varchar(30), wl.delivery_date, 103)		like '%' + @p_keywords + '%'
							or	wl.letter_status								like '%' + @p_keywords + '%'
							or	wl.branch_name									like '%' + @p_keywords + '%'
							or	wl.generate_type								like '%' + @p_keywords + '%'
							or	wl.letter_type									like '%' + @p_keywords + '%'
							or	wl.installment_no								like '%' + @p_keywords + '%'
							or	wld.delivery_status								like '%' + @p_keywords + '%'
							or	format(wld.total_monthly_rental_amount, 'n2')	like '%' + @p_keywords + '%'
							or	format(wl.total_overdue_amount, 'n2')			like '%' + @p_keywords + '%'
							or	wld.total_monthly_rental_amount					LIKE '%' + @p_keywords + '%'
							or	wl.total_overdue_amount							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then wl.letter_no
														when 2 then wl.branch_name
														when 3 then cast(wl.letter_date as sql_variant)
														when 4 then wl.letter_type
														when 5 then wl.CLIENT_NAME
														when 6 then cast(wl.overdue_days as sql_variant)
														when 7 then cast(wl.total_overdue_amount as sql_variant)
														when 8 then wl.total_agreement_count
														when 9 then wl.total_asset_count
														when 10 then wld.total_monthly_rental_amount
														when 11 then wl.last_print_by
														when 12 then wl.delivery_date
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then wl.letter_no
														when 2 then wl.branch_name
														when 3 then cast(wl.letter_date as sql_variant)
														when 4 then wl.letter_type
														when 5 then wl.CLIENT_NAME
														when 6 then cast(wl.overdue_days as sql_variant)
														when 7 then cast(wl.total_overdue_amount as sql_variant)
														when 8 then wl.total_agreement_count
														when 9 then wl.total_asset_count
														when 10 then wld.total_monthly_rental_amount
														when 11 then wl.last_print_by
														when 12 then wl.delivery_date
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


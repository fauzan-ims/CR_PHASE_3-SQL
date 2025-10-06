CREATE PROCEDURE dbo.xsp_warning_letter_delivery_request_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_branch_code	  nvarchar(50)
	,@p_letter_status nvarchar(20)
	,@p_letter_type   nvarchar(6) = ''
)
as
begin
	declare @rows_count int = 0 ;

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	END

	select	@rows_count = count(1)
	from	dbo.warning_letter
	where	letter_status = 'on process'
	and		branch_code = case @p_branch_code
							 when 'all' then branch_code
							 else @p_branch_code
							end
	and		letter_type = case @p_letter_type
								when 'all' then letter_type
								else @p_letter_type
							  END
    and		(
					letter_no												like '%' + @p_keywords + '%'
				or	branch_name												like '%' + @p_keywords + '%'
				or	convert(varchar(30), letter_date, 103)					like '%' + @p_keywords + '%'
				or	letter_type												like '%' + @p_keywords + '%'
				or	generate_type											like '%' + @p_keywords + '%'
				or	client_name												like '%' + @p_keywords + '%'
				or	overdue_days											like '%' + @p_keywords + '%'
				or	convert(varchar(30), total_overdue_amount, 103)			like '%' + @p_keywords + '%'
				or	total_agreement_count									like '%' + @p_keywords + '%'
				or	total_asset_count										like '%' + @p_keywords + '%'
				or	convert(varchar(30), total_monthly_rental_amount, 103)	like '%' + @p_keywords + '%'
			)

	select	code
			,letter_no
			,branch_code
			,branch_name
			,letter_date
			,letter_type
			,generate_type
			,client_name
			,overdue_days
			,total_overdue_amount
			,total_agreement_count
			,total_asset_count
			,total_monthly_rental_amount
			,@rows_count 'rowcount'
	from	dbo.warning_letter
	where	letter_status = 'on process'
	and		branch_code = case @p_branch_code
							 when 'all' then branch_code
							 else @p_branch_code
							end
	and		letter_type = case @p_letter_type
								when 'all' then letter_type
								else @p_letter_type
							  END
    and		(
					letter_no												like '%' + @p_keywords + '%'
				or	branch_name												like '%' + @p_keywords + '%'
				or	convert(varchar(30), letter_date, 103)					like '%' + @p_keywords + '%'
				or	letter_type												like '%' + @p_keywords + '%'
				or	generate_type											like '%' + @p_keywords + '%'
				or	client_name												like '%' + @p_keywords + '%'
				or	overdue_days											like '%' + @p_keywords + '%'
				or	convert(varchar(30), total_overdue_amount, 103)			like '%' + @p_keywords + '%'
				or	total_agreement_count									like '%' + @p_keywords + '%'
				or	total_asset_count										like '%' + @p_keywords + '%'
				or	convert(varchar(30), total_monthly_rental_amount, 103)	like '%' + @p_keywords + '%'
			)
	order by	case
				when @p_sort_by = 'asc' then case @p_order_by
														when 1 then letter_no
														when 2 then branch_name
														when 3 then cast(letter_date as sql_variant)
														when 4 then letter_type
														when 5 then client_name
														when 6 then cast(overdue_days as sql_variant)
														when 7 then cast(total_overdue_amount as sql_variant)
														when 8 then cast(total_agreement_count as sql_variant)
														when 9 then cast(total_asset_count as sql_variant)
														when 10 then cast(total_monthly_rental_amount as sql_variant)
												end
			end asc
			,case
					when @p_sort_by = 'desc' then case @p_order_by
													when 1 then letter_no
													when 2 then branch_name
													when 3 then cast(letter_date as sql_variant)
													when 4 then letter_type
													when 5 then client_name
													when 6 then cast(overdue_days as sql_variant)
													when 7 then cast(total_overdue_amount as sql_variant)
													when 8 then cast(total_agreement_count as sql_variant)
													when 9 then cast(total_asset_count as sql_variant)
													when 10 then cast(total_monthly_rental_amount as sql_variant)
												end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

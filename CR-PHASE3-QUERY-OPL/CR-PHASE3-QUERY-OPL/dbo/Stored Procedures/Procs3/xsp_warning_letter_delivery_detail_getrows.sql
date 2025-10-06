CREATE PROCEDURE dbo.xsp_warning_letter_delivery_detail_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_delivery_code nvarchar(50)
)
as
begin
	declare @rows_count int;

	select	@rows_count = count(1)
	from	warning_letter_delivery_detail wldd
			left join dbo.warning_letter wl on (wl.letter_no	= wldd.letter_code)
			left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
	where	wldd.delivery_code = @p_delivery_code
			and (
					wl.letter_no									like '%' + @p_keywords + '%'
					or	am.agreement_external_no					like '%' + @p_keywords + '%'
					or	am.client_name								like '%' + @p_keywords + '%'
					or	wl.letter_type								like '%' + @p_keywords + '%'
					or	convert(varchar(30), wl.letter_date, 103)	like '%' + @p_keywords + '%'
					or	wl.print_count								like '%' + @p_keywords + '%'
					or	wl.last_print_by							like '%' + @p_keywords + '%'
				) ;

		select		wldd.id
					,wl.code
					,wl.letter_no
					,am.agreement_external_no 'agreement_no'
					,am.client_name
					,wl.letter_type
					,convert(varchar(30), wl.letter_date, 103) 'letter_date'
					,wldd.received_date
					,wl.print_count
					,wl.last_print_by
					,wldd.delivery_code
					,@rows_count 'rowcount'
		from		warning_letter_delivery_detail wldd
					left join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
					left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
		where		wldd.delivery_code = @p_delivery_code
					and (
							wl.letter_no									like '%' + @p_keywords + '%'
							or	am.agreement_external_no					like '%' + @p_keywords + '%'
							or	am.client_name								like '%' + @p_keywords + '%'
							or	wl.letter_type								like '%' + @p_keywords + '%'
							or	convert(varchar(30), wl.letter_date, 103)	like '%' + @p_keywords + '%'
							or	wl.print_count								like '%' + @p_keywords + '%'
							or	wl.last_print_by							like '%' + @p_keywords + '%'
						)

	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then wl.letter_no
													when 2 then cast(wldd.received_date as nvarchar(20))
													when 3 then am.agreement_external_no
													when 4 then wl.letter_type
													when 5 then wl.last_print_by
													when 6 then cast(wl.print_count as nvarchar(20))
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then wl.letter_no
														when 2 then cast(wldd.received_date as nvarchar(20))
														when 3 then am.agreement_external_no
														when 4 then wl.letter_type
														when 5 then wl.last_print_by
														when 6 then cast(wl.print_count as nvarchar(20))
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

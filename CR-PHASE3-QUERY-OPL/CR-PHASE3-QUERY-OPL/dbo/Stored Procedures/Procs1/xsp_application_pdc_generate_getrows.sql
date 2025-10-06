CREATE PROCEDURE dbo.xsp_application_pdc_generate_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_pdc_generate
	where	(
				application_no like '%' + @p_keywords + '%'
				or	pdc_no_prefix like '%' + @p_keywords + '%'
				or	pdc_no_running like '%' + @p_keywords + '%'
				or	pdc_no_postfix like '%' + @p_keywords + '%'
				or	pdc_frequency_month like '%' + @p_keywords + '%'
				or	pdc_count like '%' + @p_keywords + '%'
				or	pdc_bank_code like '%' + @p_keywords + '%'
				or	pdc_bank_name like '%' + @p_keywords + '%'
				or	pdc_first_date like '%' + @p_keywords + '%'
				or	pdc_allocation_type like '%' + @p_keywords + '%'
				or	pdc_currency_code like '%' + @p_keywords + '%'
				or	pdc_value_amount like '%' + @p_keywords + '%'
				or	pdc_inkaso_fee_amount like '%' + @p_keywords + '%'
				or	pdc_clearing_fee_amount like '%' + @p_keywords + '%'
				or	pdc_amount like '%' + @p_keywords + '%'
			) ;

		select		application_no
					,pdc_no_prefix
					,pdc_no_running
					,pdc_no_postfix
					,pdc_frequency_month
					,pdc_count
					,pdc_bank_code
					,pdc_bank_name
					,pdc_first_date
					,pdc_allocation_type
					,pdc_currency_code
					,pdc_value_amount
					,pdc_inkaso_fee_amount
					,pdc_clearing_fee_amount
					,pdc_amount
					,@rows_count 'rowcount'
		from		application_pdc_generate
		where		(
						application_no like '%' + @p_keywords + '%'
						or	pdc_no_prefix like '%' + @p_keywords + '%'
						or	pdc_no_running like '%' + @p_keywords + '%'
						or	pdc_no_postfix like '%' + @p_keywords + '%'
						or	pdc_frequency_month like '%' + @p_keywords + '%'
						or	pdc_count like '%' + @p_keywords + '%'
						or	pdc_bank_code like '%' + @p_keywords + '%'
						or	pdc_bank_name like '%' + @p_keywords + '%'
						or	pdc_first_date like '%' + @p_keywords + '%'
						or	pdc_allocation_type like '%' + @p_keywords + '%'
						or	pdc_currency_code like '%' + @p_keywords + '%'
						or	pdc_value_amount like '%' + @p_keywords + '%'
						or	pdc_inkaso_fee_amount like '%' + @p_keywords + '%'
						or	pdc_clearing_fee_amount like '%' + @p_keywords + '%'
						or	pdc_amount like '%' + @p_keywords + '%'
					)

order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then application_no
													when 2 then pdc_no_prefix
													when 3 then pdc_no_running
													when 4 then pdc_no_postfix
													when 5 then pdc_bank_code
													when 6 then pdc_bank_name
													when 7 then pdc_allocation_type
													when 8 then pdc_currency_code
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then application_no
														when 2 then pdc_no_prefix
														when 3 then pdc_no_running
														when 4 then pdc_no_postfix
														when 5 then pdc_bank_code
														when 6 then pdc_bank_name
														when 7 then pdc_allocation_type
														when 8 then pdc_currency_code
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


CREATE PROCEDURE dbo.xsp_application_pdc_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_application_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_pdc apdc
			inner join dbo.sys_general_subcode sgs on (sgs.code = apdc.pdc_allocation_type)
	where	application_code = @p_application_code
			and (
					id																like '%' + @p_keywords + '%'
					or	application_code											like '%' + @p_keywords + '%'
					or	pdc_no														like '%' + @p_keywords + '%'
					or	format(cast(pdc_date as datetime), 'dd/MM/yyyy', 'en-us')	like '%' + @p_keywords + '%'
					or	pdc_bank_code												like '%' + @p_keywords + '%'
					or	pdc_bank_name												like '%' + @p_keywords + '%'
					or	sgs.description												like '%' + @p_keywords + '%'
					or	pdc_currency_code											like '%' + @p_keywords + '%'
					or	pdc_value_amount											like '%' + @p_keywords + '%'
					or	pdc_inkaso_fee_amount										like '%' + @p_keywords + '%'
					or	pdc_clearing_fee_amount										like '%' + @p_keywords + '%'
					or	pdc_amount													like '%' + @p_keywords + '%'
				) ;

		select		id
					,application_code
					,pdc_no
					,format(cast(pdc_date as datetime), 'dd/MM/yyyy', 'en-us') 'pdc_date'
					,pdc_bank_code
					,pdc_bank_name
					,sgs.description 'pdc_allocation_type'
					,pdc_currency_code
					,pdc_value_amount
					,pdc_inkaso_fee_amount
					,pdc_clearing_fee_amount
					,pdc_amount
					,@rows_count 'rowcount'
		from		application_pdc apdc
					inner join dbo.sys_general_subcode sgs on (sgs.code = apdc.pdc_allocation_type)
		where		application_code = @p_application_code
					and (
							id																like '%' + @p_keywords + '%'
							or	application_code											like '%' + @p_keywords + '%'
							or	pdc_no														like '%' + @p_keywords + '%'
							or	format(cast(pdc_date as datetime), 'dd/MM/yyyy', 'en-us')	like '%' + @p_keywords + '%'
							or	pdc_bank_code												like '%' + @p_keywords + '%'
							or	pdc_bank_name												like '%' + @p_keywords + '%'
							or	sgs.description												like '%' + @p_keywords + '%'
							or	pdc_currency_code											like '%' + @p_keywords + '%'
							or	pdc_value_amount											like '%' + @p_keywords + '%'
							or	pdc_inkaso_fee_amount										like '%' + @p_keywords + '%'
							or	pdc_clearing_fee_amount										like '%' + @p_keywords + '%'
							or	pdc_amount													like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then pdc_no
													when 2 then pdc_bank_name
													when 3 then cast(pdc_date as sql_variant)
													when 4 then pdc_bank_name
													when 5 then sgs.description
													when 6 then cast(pdc_amount as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then pdc_no
														when 2 then pdc_bank_name
														when 3 then cast(pdc_date as sql_variant)
														when 4 then pdc_bank_name
														when 5 then sgs.description
														when 6 then cast(pdc_amount as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


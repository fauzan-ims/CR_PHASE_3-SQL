CREATE PROCEDURE dbo.xsp_application_document_contract_getrows
(
	@p_keywords	     nvarchar(50)
	,@p_pagenumber   int
	,@p_rowspage     int
	,@p_order_by     int
	,@p_sort_by	     nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 

	select	@rows_count = count(1)
	from	dbo.application_document_contract adc
			inner join master_document_contract mdc on (mdc.code = adc.document_contract_code)
	where	adc.application_no = @p_application_no
			and (
					mdc.description										like '%' + @p_keywords + '%'
					or	adc.filename									like '%' + @p_keywords + '%'
					or	convert(varchar(30), adc.last_print_date, 103)	like '%' + @p_keywords + '%'
					or	adc.last_print_by								like '%' + @p_keywords + '%'
					or	adc.print_count									like '%' + @p_keywords + '%'
				) ; 
		select		adc.application_no
					,mdc.description 'document_desc'
					,adc.filename									
					,convert(varchar(30), adc.last_print_date, 103) 'last_print_date'
					,adc.last_print_by								
					,adc.print_count	
					,mdc.document_type		
					,mdc.template_name
					,mdc.rpt_name
					,mdc.sp_name
					,mdc.table_name		
					,adc.document_contract_code				
					,@rows_count 'rowcount'
		from		application_document_contract adc
					inner join master_document_contract mdc on (mdc.code = adc.document_contract_code)
		where		adc.application_no = @p_application_no
					and (
							mdc.description										like '%' + @p_keywords + '%'
							or	adc.filename									like '%' + @p_keywords + '%'
							or	convert(varchar(30), adc.last_print_date, 103)	like '%' + @p_keywords + '%'
							or	adc.last_print_by								like '%' + @p_keywords + '%'
							or	adc.print_count									like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mdc.description
													when 2 then adc.filename									
													when 3 then cast(adc.last_print_date as sql_variant)
													when 4 then adc.last_print_by								
													when 5 then cast(adc.print_count as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mdc.description
													when 2 then adc.filename									
													when 3 then cast(adc.last_print_date as sql_variant)
													when 4 then adc.last_print_by								
													when 5 then cast(adc.print_count as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


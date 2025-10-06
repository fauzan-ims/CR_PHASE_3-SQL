CREATE PROCEDURE dbo.xsp_fin_interface_payment_request_for_upload_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_status			nvarchar(10) = 'ALL'
)
as
BEGIN
	
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	fin_interface_payment_request
	where	manual_upload_status = case @p_status
										when 'ALL' then isnull(manual_upload_status,'')
										else @p_status
									end
	AND			(
						branch_name										like 	'%'+ @p_keywords +'%'
					or	payment_source									like 	'%'+ @p_keywords +'%'
					or	payment_source_no								like 	'%'+ @p_keywords +'%'
					or	convert(varchar(30), payment_request_date, 103)	like 	'%'+ @p_keywords +'%'
					or	payment_currency_code							like 	'%'+ @p_keywords +'%'
					or	payment_amount									like 	'%'+ @p_keywords +'%'
					or	payment_remarks									like 	'%'+ @p_keywords +'%'
					or	manual_upload_remarks							like 	'%'+ @p_keywords +'%'
				) ;

		select	id
				,branch_name
				,payment_source
				,payment_source_no
				,convert(varchar(30), payment_request_date, 103) 'payment_request_date'
				,payment_currency_code
				,payment_amount
				,payment_remarks
				,manual_upload_status
				,manual_upload_remarks
				,@rows_count 'rowcount'
		from	fin_interface_payment_request
		where	manual_upload_status = case @p_status
											when 'ALL' then isnull(manual_upload_status,'')
											else @p_status
										end
		and		(
					branch_name											like 	'%'+ @p_keywords +'%'
					or	payment_source									like 	'%'+ @p_keywords +'%'
					or	payment_source_no								like 	'%'+ @p_keywords +'%'
					or	convert(varchar(30), payment_request_date, 103)	like 	'%'+ @p_keywords +'%'
					or	payment_currency_code							like 	'%'+ @p_keywords +'%'
					or	payment_amount									like 	'%'+ @p_keywords +'%'
					or	payment_remarks									like 	'%'+ @p_keywords +'%'
					or	manual_upload_remarks							like 	'%'+ @p_keywords +'%'
				) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then branch_name
														when 2 then payment_source							
														when 3 then cast(payment_request_date as sql_variant)
														when 4 then payment_currency_code	
														when 5 then cast(payment_amount as sql_variant)					
														when 6 then payment_remarks	
														when 7 then manual_upload_remarks	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then branch_name
														when 2 then payment_source							
														when 3 then cast(payment_request_date as sql_variant)
														when 4 then payment_currency_code	
														when 5 then cast(payment_amount as sql_variant)					
														when 6 then payment_remarks	
														when 7 then manual_upload_remarks	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end    

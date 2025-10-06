CREATE PROCEDURE dbo.xsp_fin_interface_cashier_received_request_for_upload_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_status			nvarchar(10) = 'ALL'
)
as
begin
	
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	fin_interface_cashier_received_request
	where	manual_upload_status = case @p_status
											when 'ALL' then isnull(manual_upload_status,'')
											else @p_status
										end
	and		(
				agreement_no										like 	'%'+ @p_keywords +'%'
				or	branch_name										like 	'%'+ @p_keywords +'%'
				or	convert(varchar(30), request_date, 103)			like 	'%'+ @p_keywords +'%'
				or	request_remarks									like 	'%'+ @p_keywords +'%'
				or	agreement_no									like 	'%'+ @p_keywords +'%'
				or	request_currency_code							like 	'%'+ @p_keywords +'%'
				or	request_amount									like 	'%'+ @p_keywords +'%'
				or	manual_upload_remarks							like 	'%'+ @p_keywords +'%'
			) ;

		select	id
				,branch_name
				,convert(varchar(30), request_date, 103) 'request_date'
				,request_remarks
				,agreement_no
				,request_currency_code
				,request_amount
				,manual_upload_remarks
				,@rows_count 'rowcount'
		from	fin_interface_cashier_received_request
		where	manual_upload_status = case @p_status
											when 'ALL' then isnull(manual_upload_status,'')
											else @p_status
										end
		and		(
					agreement_no										like 	'%'+ @p_keywords +'%'
					or	branch_name										like 	'%'+ @p_keywords +'%'
					or	convert(varchar(30), request_date, 103)			like 	'%'+ @p_keywords +'%'
					or	request_remarks									like 	'%'+ @p_keywords +'%'
					or	agreement_no									like 	'%'+ @p_keywords +'%'
					or	request_currency_code							like 	'%'+ @p_keywords +'%'
					or	request_amount									like 	'%'+ @p_keywords +'%'
					or	manual_upload_remarks							like 	'%'+ @p_keywords +'%'
				) 
			order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then agreement_no
														when 2 then branch_name
														when 3 then cast(request_date as sql_variant)									
														when 4 then request_remarks	
														when 5 then request_currency_code	
														when 6 then cast(request_amount as sql_variant)					
														when 7 then manual_upload_remarks	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then agreement_no
														when 2 then branch_name
														when 3 then cast(request_date as sql_variant)									
														when 4 then request_remarks	
														when 5 then request_currency_code	
														when 6 then cast(request_amount as sql_variant)					
														when 7 then manual_upload_remarks	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end    

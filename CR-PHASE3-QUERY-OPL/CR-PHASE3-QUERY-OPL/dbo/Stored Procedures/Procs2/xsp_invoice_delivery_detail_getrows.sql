CREATE PROCEDURE dbo.xsp_invoice_delivery_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_delivery_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	invoice_delivery_detail idd
	left join dbo.invoice inv with(nolock) on (inv.invoice_no = idd.invoice_no)
	where	delivery_code = @p_delivery_code
	and		(
				idd.invoice_no											 like '%' + @p_keywords + '%'
				or	inv.invoice_external_no								 like '%' + @p_keywords + '%'
				or	idd.delivery_status									 like '%' + @p_keywords + '%'
				or	idd.delivery_remark									 like '%' + @p_keywords + '%'
				or	idd.receiver_name									 like '%' + @p_keywords + '%'
				or	convert(varchar(30),inv.invoice_date,103)			 like '%' + @p_keywords + '%'
				or	convert(varchar(30),inv.invoice_due_date,103)		 like '%' + @p_keywords + '%'
				or	inv.invoice_name									 like '%' + @p_keywords + '%'
				or	inv.client_name										 like '%' + @p_keywords + '%'
				or	inv.client_address									 like '%' + @p_keywords + '%'
				or	inv.client_area_phone_no							 like '%' + @p_keywords + '%'
				or	inv.client_phone_no									 like '%' + @p_keywords + '%'
				or	inv.total_amount									 like '%' + @p_keywords + '%'
				or	inv.invoice_status									 like '%' + @p_keywords + '%'
				or	idd.delivery_date									 like '%' + @p_keywords + '%'
			) ;

	select		id
				,idd.invoice_no
				,inv.invoice_external_no
				,idd.delivery_status
				,convert(varchar(30),idd.delivery_date,103) 'delivery_date'
				,idd.delivery_remark
				,idd.receiver_name
				,convert(varchar(30),inv.invoice_date,103)		'invoice_date'		
				,convert(varchar(30),inv.invoice_due_date,103)  'invoice_due_date'	
				,inv.invoice_name		
				,inv.client_name			
				,inv.client_address		
				,inv.client_area_phone_no
				,inv.client_phone_no		
				,inv.total_amount		
				,inv.invoice_status
				,@rows_count 'rowcount'
	from		invoice_delivery_detail idd
	left join dbo.invoice inv with(nolock) on (inv.invoice_no = idd.invoice_no)
	where	delivery_code = @p_delivery_code
	and		(
					idd.invoice_no											 like '%' + @p_keywords + '%'
					or	inv.invoice_external_no								 like '%' + @p_keywords + '%'
					or	idd.delivery_status									 like '%' + @p_keywords + '%'
					or	idd.delivery_remark									 like '%' + @p_keywords + '%'
					or	idd.receiver_name									 like '%' + @p_keywords + '%'
					or	convert(varchar(30),inv.invoice_date,103)			 like '%' + @p_keywords + '%'
					or	convert(varchar(30),inv.invoice_due_date,103)		 like '%' + @p_keywords + '%'
					or	inv.invoice_name									 like '%' + @p_keywords + '%'
					or	inv.client_name										 like '%' + @p_keywords + '%'
					or	inv.client_address									 like '%' + @p_keywords + '%'
					or	inv.client_area_phone_no							 like '%' + @p_keywords + '%'
					or	inv.client_phone_no									 like '%' + @p_keywords + '%'
					or	inv.total_amount									 like '%' + @p_keywords + '%'
					or	inv.invoice_status									 like '%' + @p_keywords + '%'
					or	convert(varchar(30),idd.delivery_date,103) 			 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then inv.invoice_external_no
													 when 2 then cast(inv.invoice_date as sql_variant)
													 when 3 then cast(inv.invoice_due_date as sql_variant)
													 when 4 then inv.invoice_name
													 when 5 then inv.client_name	
													 when 6 then inv.client_address
													 when 7 then inv.client_area_phone_no
													 when 8 then inv.client_phone_no
													 when 9 then inv.total_amount
													 when 10 then idd.delivery_status		
													 when 11 then cast(idd.delivery_date as sql_variant)
													 when 12 then idd.receiver_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														 when 1 then inv.invoice_external_no
														 when 2 then cast(inv.invoice_date as sql_variant)
														 when 3 then cast(inv.invoice_due_date as sql_variant)
														 when 4 then inv.invoice_name
														 when 5 then inv.client_name	
														 when 6 then inv.client_address
														 when 7 then inv.client_area_phone_no
														 when 8 then inv.client_phone_no
														 when 9 then inv.total_amount
														 when 10 then idd.delivery_status		
														 when 11 then cast(idd.delivery_date as sql_variant)
														 when 12 then idd.receiver_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

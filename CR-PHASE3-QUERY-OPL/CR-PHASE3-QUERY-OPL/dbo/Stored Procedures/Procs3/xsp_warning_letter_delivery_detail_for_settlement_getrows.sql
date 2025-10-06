CREATE PROCEDURE dbo.xsp_warning_letter_delivery_detail_for_settlement_getrows
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
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	warning_letter_delivery_detail wldd
			left join dbo.warning_letter wl on (wl.letter_no	= wldd.letter_code)
			left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
	where	wldd.delivery_code = @p_delivery_code
			and (
					wl.letter_no									like '%' + @p_keywords + '%'
					or am.agreement_external_no 					like '%' + @p_keywords + '%'
					or am.client_name								like '%' + @p_keywords + '%'
					or wldd.file_name								like '%' + @p_keywords + '%'
					or wldd.received_remarks						like '%' + @p_keywords + '%'
					or wldd.received_by								like '%' + @p_keywords + '%'
					or wldd.received_status							like '%' + @p_keywords + '%'
					or convert(varchar(30), wl.letter_date, 103)	like '%' + @p_keywords + '%'
					or wldd.received_date							like '%' + @p_keywords + '%'
				) ;

		select		 wldd.id
					,wl.letter_no
					,am.agreement_external_no 'agreement_no'
					,am.client_name
					,wldd.file_name
					,wldd.paths
					,wldd.received_remarks
					,isnull(wldd.received_by,'') 'received_by' 
					,convert(varchar(30), wl.letter_date, 103) 'letter_date'
					,convert(varchar(30), wldd.received_date, 103) 'received_date'
					,wl.letter_type
					,isnull(wldd.received_status,'') 'received_status'
					,@rows_count 'rowcount'
		from		warning_letter_delivery_detail wldd
					left join dbo.warning_letter wl on (wl.letter_no		 = wldd.letter_code)
					left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
		where		wldd.delivery_code = @p_delivery_code
					and (
							wl.letter_no									like '%' + @p_keywords + '%'
							or am.agreement_external_no 					like '%' + @p_keywords + '%'
							or am.client_name								like '%' + @p_keywords + '%'
							or wldd.file_name								like '%' + @p_keywords + '%'
							or wldd.received_remarks						like '%' + @p_keywords + '%'
							or wldd.received_by								like '%' + @p_keywords + '%'
							or wldd.received_status							like '%' + @p_keywords + '%'
							or convert(varchar(30), wl.letter_date, 103)	like '%' + @p_keywords + '%'
							or wldd.received_date							like '%' + @p_keywords + '%'
						)
			order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then am.agreement_external_no 	
														when 2 then wl.letter_no		
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then am.agreement_external_no 	
														when 2 then wl.letter_no		
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;



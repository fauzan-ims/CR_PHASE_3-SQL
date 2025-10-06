CREATE PROCEDURE dbo.xsp_warning_letter_delivery_settlement_getrows
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	,@p_branch_code		  nvarchar(50)
	,@p_delivery_status	  nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	END

	select	@rows_count = count(1)
	from	warning_letter_delivery wld
			left join dbo.sys_general_subcode sgs on (sgs.code = wld.delivery_courier_code)
	where	wld.delivery_status in ('on process', 'done')   
	and		wld.branch_code		= case @p_branch_code
										when 'all' then branch_code 
										else @p_branch_code
									end
               and delivery_status = case @p_delivery_status
										when 'all' then delivery_status
										else @p_delivery_status
									end                
			and (
					wld.code											like '%' + @p_keywords + '%'
					or	wld.branch_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), wld.delivery_date, 103)	like '%' + @p_keywords + '%'
					or	wld.client_name									like '%' + @p_keywords + '%'
					or	wld.delivery_address							like '%' + @p_keywords + '%'
					or	wld.letter_type									like '%' + @p_keywords + '%'
					or	wld.delivery_courier_type						like '%' + @p_keywords + '%'
					or	isnull(wld.delivery_collector_name, sgs.description)	like '%' + @p_keywords + '%'
					or	wld.delivery_status								like '%' + @p_keywords + '%'
				)

		select		wld.code
					,wld.branch_name
					,convert(varchar(30), wld.delivery_date, 103) 'delivery_date'
					,wld.delivery_courier_type
					,isnull(wld.delivery_collector_name, sgs.description) 'name'
					,wld.delivery_status
					,wld.client_name
					,wld.letter_type
					,wld.delivery_address
					,wld.delivery_status
					,@rows_count 'rowcount'
		from		warning_letter_delivery wld
					left join dbo.sys_general_subcode sgs on (sgs.code = wld.delivery_courier_code)
		where		wld.delivery_status in ('on process', 'done')   
		and			wld.branch_code		= case @p_branch_code
											   when 'all' then branch_code 
											   else @p_branch_code
										  end
                    and delivery_status = case @p_delivery_status
											   when 'all' then delivery_status
											   else @p_delivery_status
										  end                
					and (
							wld.code											like '%' + @p_keywords + '%'
							or	wld.branch_name									like '%' + @p_keywords + '%'
							or	convert(varchar(30), wld.delivery_date, 103)	like '%' + @p_keywords + '%'
							or	wld.client_name									like '%' + @p_keywords + '%'
							or	wld.delivery_address							like '%' + @p_keywords + '%'
							or	wld.letter_type									like '%' + @p_keywords + '%'
							or	wld.delivery_courier_type						like '%' + @p_keywords + '%'
							or	isnull(wld.delivery_collector_name, sgs.description)	like '%' + @p_keywords + '%'
							or	wld.delivery_status								like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then wld.code
														when 2 then wld.branch_name
														when 3 then cast(wld.delivery_date as sql_variant)
														when 4 then wld.client_name
														when 5 then wld.delivery_address
														when 6 then wld.letter_type
														when 7 then wld.delivery_courier_type
														when 8 then wld.delivery_collector_name
														when 9 then wld.delivery_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then wld.code
														when 2 then wld.branch_name
														when 3 then cast(wld.delivery_date as sql_variant)
														when 4 then wld.client_name
														when 5 then wld.delivery_address
														when 6 then wld.letter_type
														when 7 then wld.delivery_courier_type
														when 8 then wld.delivery_collector_name
														when 9 then wld.delivery_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


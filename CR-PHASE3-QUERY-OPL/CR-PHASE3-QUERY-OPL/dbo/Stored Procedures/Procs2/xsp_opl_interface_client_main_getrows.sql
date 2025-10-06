create PROCEDURE dbo.xsp_opl_interface_client_main_getrows
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
	from	opl_interface_client_main
	where	(
				client_type																like '%' + @p_keywords + '%'
				or	client_no															like '%' + @p_keywords + '%'
				or	client_name															like '%' + @p_keywords + '%'
				or	case is_validate
						when '1' then 'Yes'
						else 'No'
					end																	like '%' + @p_keywords + '%'
				or	case is_red_flag
						when '1' then 'Yes'
						else 'No'
					end																	like '%' + @p_keywords + '%'
				or	watchlist_status													like '%' + @p_keywords + '%'
				or	status_slik_checking												like '%' + @p_keywords + '%'
				or	status_dukcapil_checking											like '%' + @p_keywords + '%'
				or	format(cast(cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
			) ;

	select		id
				,code
				,client_type
				,client_no
				,client_name
				,case is_validate
						when '1' then 'Yes'
						else 'No'
					end 'is_validate'
				,case is_red_flag
						when '1' then 'Yes'
						else 'No'
					end 'is_red_flag'
				,watchlist_status
				,status_slik_checking
				,status_dukcapil_checking
				,format(cast(cre_date as datetime), 'dd/MM/yyyy HH:mm:ss', 'en-us') 'cre_date'
				,@rows_count 'rowcount'
	from		opl_interface_client_main
	where		(
					client_type																like '%' + @p_keywords + '%'
					or	client_no															like '%' + @p_keywords + '%'
					or	client_name															like '%' + @p_keywords + '%'
					or	case is_validate
							when '1' then 'Yes'
							else 'No'
						end																	like '%' + @p_keywords + '%'
					or	case is_red_flag
							when '1' then 'Yes'
							else 'No'
						end																	like '%' + @p_keywords + '%'
					or	watchlist_status													like '%' + @p_keywords + '%'
					or	status_slik_checking												like '%' + @p_keywords + '%'
					or	status_dukcapil_checking											like '%' + @p_keywords + '%'
					or	format(cast(cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
				)
				
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then client_no
														when 2 then client_type
														when 3 then client_name
														when 4 then is_validate
														when 5 then is_red_flag
														when 6 then watchlist_status
														when 7 then status_slik_checking
														when 8 then status_dukcapil_checking
														when 9 then format(cast(cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then client_no
														when 2 then client_type
														when 3 then client_name
														when 4 then is_validate
														when 5 then is_red_flag
														when 6 then watchlist_status
														when 7 then status_slik_checking
														when 8 then status_dukcapil_checking
														when 9 then format(cast(cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


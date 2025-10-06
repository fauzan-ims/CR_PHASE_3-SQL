CREATE PROCEDURE dbo.xsp_client_log_getrows
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_log
	where	client_code = @p_client_code
			and (
					FORMAT(CONVERT(DATETIME,log_date,108),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
					or	log_remarks						like '%' + @p_keywords + '%'
				) ;

		select		id
					,FORMAT(CONVERT(DATETIME,log_date,108),'dd/MM/yyyy HH:mm:ss','en-us') 'log_date'
					,log_remarks
					,@rows_count 'rowcount'
		from		client_log
		where		client_code = @p_client_code
					and (
							FORMAT(CONVERT(DATETIME,log_date,108),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
							or	log_remarks						like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(log_date as sql_variant)
													when 2 then log_remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(log_date as sql_variant)
														when 2 then log_remarks
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


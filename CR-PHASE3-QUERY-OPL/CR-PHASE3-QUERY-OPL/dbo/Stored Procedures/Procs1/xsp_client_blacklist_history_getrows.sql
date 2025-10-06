CREATE PROCEDURE dbo.xsp_client_blacklist_history_getrows
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_client_blacklist_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_blacklist_history
	where	client_blacklist_code = @p_client_blacklist_code
			and (
					convert(varchar(30), history_date, 103)	like '%' + @p_keywords + '%'
					or	history_remarks						like '%' + @p_keywords + '%'
				) ;
				 
		select		id
					,client_blacklist_code
					,convert(varchar(30), history_date, 103) 'history_date'
					,history_remarks
					,@rows_count 'rowcount'
		from		client_blacklist_history
		where		client_blacklist_code = @p_client_blacklist_code
					and (
							convert(varchar(30), history_date, 103)	like '%' + @p_keywords + '%'
							or	history_remarks						like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(history_date as sql_variant)
													when 2 then history_remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cast(history_date as sql_variant)
													when 2 then history_remarks
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


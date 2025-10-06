CREATE PROCEDURE dbo.xsp_client_slik_financial_statement_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_slik_financial_statement
	where	client_code = @p_client_code
			and  (
					statement_year		like '%' + @p_keywords + '%'
					or	statement_month like '%' + @p_keywords + '%'
					or	aset			like '%' + @p_keywords + '%'
					or	liabilitas		like '%' + @p_keywords + '%'
				) ; 
		select		id
					,statement_year
					,statement_month
					,aset
					,liabilitas
					,@rows_count 'rowcount'
		from		client_slik_financial_statement
		where		client_code = @p_client_code
					and  (
							statement_year		like '%' + @p_keywords + '%'
							or	statement_month like '%' + @p_keywords + '%'
							or	aset			like '%' + @p_keywords + '%'
							or	liabilitas		like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then statement_year
													when 2 then statement_month
													when 3 then try_cast(aset as nvarchar(20))
													when 4 then try_cast(liabilitas as nvarchar(20))
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then statement_year
													when 2 then statement_month
													when 3 then try_cast(aset as nvarchar(20))
													when 4 then try_cast(liabilitas as nvarchar(20))
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


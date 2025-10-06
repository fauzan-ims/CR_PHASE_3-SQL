CREATE PROCEDURE [dbo].[xsp_application_financial_statement_getrows]
(
	@p_keywords	     nvarchar(50)
	,@p_pagenumber   int
	,@p_rowspage     int
	,@p_order_by     int
	,@p_sort_by	     nvarchar(5)
	,@p_application_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_financial_statement
	where	application_code = @p_application_code
			and	(
					code								like '%' + @p_keywords + '%'
					or	case periode_month
							when '01' then 'January'
							when '02' then 'February'
							when '03' then 'March'
							when '04' then 'April'
							when '05' then 'May'
							when '06' then 'June'
							when '07' then 'July'
							when '08' then 'August'
							when '09' then 'September'
							when '10' then 'October'
							when '11' then 'November'
							else 'December'
						end + ' ' + periode_year		like '%' + @p_keywords + '%'
				) ;

	select		code
				,application_code
				,case periode_month
						when '01' then 'January'
						when '02' then 'February'
						when '03' then 'March'
						when '04' then 'April'
						when '05' then 'May'
						when '06' then 'June'
						when '07' then 'July'
						when '08' then 'August'
						when '09' then 'September'
						when '10' then 'October'
						when '11' then 'November'
						else 'December'
					end + ' ' + periode_year 'periode'
				,@rows_count 'rowcount'
	from		application_financial_statement
	where		application_code = @p_application_code
				and	(
						code								like '%' + @p_keywords + '%'
						or	case periode_month
								when '01' then 'January'
								when '02' then 'February'
								when '03' then 'March'
								when '04' then 'April'
								when '05' then 'May'
								when '06' then 'June'
								when '07' then 'July'
								when '08' then 'August'
								when '09' then 'September'
								when '10' then 'October'
								when '11' then 'November'
								else 'December'
							end + ' ' + periode_year		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then periode_year + periode_month 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then periode_year + periode_month 
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;


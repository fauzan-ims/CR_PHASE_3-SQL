CREATE PROCEDURE dbo.xsp_application_financial_recapitulation_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_application_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_financial_recapitulation
	where	application_no = @p_application_code
			and (
					case from_periode_month
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
					end + ' ' + from_periode_year		like '%' + @p_keywords + '%'
					or	case to_periode_month
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
						end + ' ' + to_periode_year		like '%' + @p_keywords + '%'
					or	current_rasio_pct				like '%' + @p_keywords + '%'
					or	debet_to_asset_pct				like '%' + @p_keywords + '%'
					or	return_on_equity_pct			like '%' + @p_keywords + '%'
				) ;

	select		code
				,case from_periode_month
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
					end + ' ' + from_periode_year 'periode_from'
				,case to_periode_month
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
					end + ' ' + to_periode_year 'period_to'
				,current_rasio_pct
				,debet_to_asset_pct
				,return_on_equity_pct
				,@rows_count 'rowcount'
	from		application_financial_recapitulation
	where		application_no = @p_application_code
				and (
						case from_periode_month
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
						end + ' ' + from_periode_year		like '%' + @p_keywords + '%'
						or	case to_periode_month
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
							end + ' ' + to_periode_year		like '%' + @p_keywords + '%'
						or	current_rasio_pct				like '%' + @p_keywords + '%'
						or	debet_to_asset_pct				like '%' + @p_keywords + '%'
						or	return_on_equity_pct			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then from_periode_year + from_periode_month
														when 2 then to_periode_year + to_periode_month
														when 3 then cast(current_rasio_pct as sql_variant)
														when 4 then cast(debet_to_asset_pct as sql_variant)
														when 5 then cast(return_on_equity_pct as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then from_periode_year + from_periode_month
														when 2 then to_periode_year + to_periode_month
														when 3 then cast(current_rasio_pct as sql_variant)
														when 4 then cast(debet_to_asset_pct as sql_variant)
														when 5 then cast(return_on_equity_pct as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;


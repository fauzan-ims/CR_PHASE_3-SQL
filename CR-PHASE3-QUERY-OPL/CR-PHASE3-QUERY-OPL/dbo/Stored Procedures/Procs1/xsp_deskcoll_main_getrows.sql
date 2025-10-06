CREATE PROCEDURE [dbo].[xsp_deskcoll_main_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_collector_code	nvarchar(50)=''
	,@p_from_date		datetime
	,@p_to_date			datetime
)
AS
BEGIN
	DECLARE @rows_count INT = 0 ;

	select	@rows_count = count(1)
	from	deskcoll_main dmn
			left join dbo.master_collector mcr on (mcr.code = dmn.desk_collector_code)
			left join dbo.agreement_main amn on (amn.agreement_no = dmn.agreement_no)
	WHERE
	(@p_collector_code = '' OR amn.marketing_code = @p_collector_code OR dmn.desk_collector_code = @p_collector_code)
	AND (CAST(dmn.desk_date AS DATE) BETWEEN @p_from_date AND @p_to_date)
	AND dmn.desk_status = 'POST'
	AND (
		dmn.id LIKE '%' + @p_keywords + '%'
		OR mcr.collector_name LIKE '%' + @p_keywords + '%'
		OR amn.marketing_name LIKE '%' + @p_keywords + '%'
		OR amn.agreement_external_no LIKE '%' + @p_keywords + '%'
		OR amn.client_name LIKE '%' + @p_keywords + '%'
		OR CONVERT(VARCHAR(30), dmn.desk_date, 103) LIKE '%' + @p_keywords + '%'
		OR CAST(dmn.overdue_days AS NVARCHAR) LIKE '%' + @p_keywords + '%'
	)


		SELECT		dmn.id
					,ISNULL(mcr.collector_name, amn.marketing_name) 'desk_collector_name'							
					,amn.agreement_external_no							
					,amn.client_name										
					,dmn.overdue_period						
					,CONVERT(VARCHAR(30), dmn.desk_date , 103) 'desk_date'	
					,dmn.overdue_days							
					,@rows_count 'rowcount'
		FROM		deskcoll_main dmn
					LEFT JOIN dbo.master_collector mcr ON (mcr.code = dmn.desk_collector_code)
					LEFT JOIN dbo.agreement_main amn ON (amn.agreement_no = dmn.agreement_no)
		WHERE
	(@p_collector_code = '' OR amn.marketing_code = @p_collector_code OR dmn.desk_collector_code = @p_collector_code)
	AND (CAST(dmn.desk_date AS DATE) BETWEEN @p_from_date AND @p_to_date)
	AND dmn.desk_status = 'POST'
	AND (
		dmn.id LIKE '%' + @p_keywords + '%'
		OR mcr.collector_name LIKE '%' + @p_keywords + '%'
		OR amn.marketing_name LIKE '%' + @p_keywords + '%'
		OR amn.agreement_external_no LIKE '%' + @p_keywords + '%'
		OR amn.client_name LIKE '%' + @p_keywords + '%'
		OR CONVERT(VARCHAR(30), dmn.desk_date, 103) LIKE '%' + @p_keywords + '%'
		OR CAST(dmn.overdue_days AS NVARCHAR) LIKE '%' + @p_keywords + '%'
	)

		ORDER BY CASE  
					WHEN @p_sort_by = 'asc' THEN CASE @p_order_by
													WHEN 1 THEN CAST(dmn.desk_date AS SQL_VARIANT)
													WHEN 2 THEN ISNULL(mcr.collector_name, amn.marketing_name)			
													WHEN 3 THEN amn.agreement_external_no	
													WHEN 4 THEN dmn.overdue_period
													when 5 then cast(dmn.overdue_days as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cast(dmn.desk_date as sql_variant)
													when 2 then isnull(mcr.collector_name, amn.marketing_name)		
													when 3 then amn.agreement_external_no	
													when 4 then dmn.overdue_period
													when 5 then cast(dmn.overdue_days as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	

end ;

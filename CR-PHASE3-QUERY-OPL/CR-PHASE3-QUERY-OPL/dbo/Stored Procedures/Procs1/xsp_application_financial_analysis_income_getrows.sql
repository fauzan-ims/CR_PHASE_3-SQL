CREATE PROCEDURE dbo.xsp_application_financial_analysis_income_getrows
(
	@p_keywords							nvarchar(50)
	,@p_pagenumber						int
	,@p_rowspage						int
	,@p_order_by						int
	,@p_sort_by							nvarchar(5)
	,@p_application_financial_analysis_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_financial_analysis_income afai
			inner join dbo.sys_general_subcode sgs on (sgs.code = afai.income_type_code)
	where	application_financial_analysis_code = @p_application_financial_analysis_code
			and (
					sgs.description				like '%' + @p_keywords + '%'
					or	afai.income_amount		like '%' + @p_keywords + '%'
					or	afai.net_income_pct		like '%' + @p_keywords + '%'
					or	afai.net_income_amount	like '%' + @p_keywords + '%'
					or	afai.remarks			like '%' + @p_keywords + '%'
				) ;

		select		afai.id
					,sgs.description 'income_type_desc'
					,afai.income_amount
					,afai.net_income_pct
					,afai.net_income_amount
					,afai.remarks
					,@rows_count 'rowcount'
		from		application_financial_analysis_income afai
					inner join dbo.sys_general_subcode sgs on (sgs.code = afai.income_type_code)
		where		application_financial_analysis_code = @p_application_financial_analysis_code
					and (
							sgs.description				like '%' + @p_keywords + '%'
							or	afai.income_amount		like '%' + @p_keywords + '%'
							or	afai.net_income_pct		like '%' + @p_keywords + '%'
							or	afai.net_income_amount	like '%' + @p_keywords + '%'
							or	afai.remarks			like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sgs.description 
													when 2 then try_cast(afai.income_amount as nvarchar(20))
													when 3 then try_cast(afai.net_income_pct as nvarchar(20))
													when 4 then	try_cast(afai.net_income_amount as nvarchar(20))
													when 5 then	afai.remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then sgs.description 
														when 2 then try_cast(afai.income_amount as nvarchar(20))
														when 3 then try_cast(afai.net_income_pct as nvarchar(20))
														when 4 then	try_cast(afai.net_income_amount as nvarchar(20))
														when 5 then	afai.remarks
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


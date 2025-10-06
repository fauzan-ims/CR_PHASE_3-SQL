CREATE PROCEDURE dbo.xsp_application_financial_analysis_expense_getrows
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
	from	application_financial_analysis_expense afae
			inner join dbo.sys_general_subcode sgs on (sgs.code = afae.expense_type)
	where	application_financial_analysis_code = @p_application_financial_analysis_code
			and (
					sgs.description			like '%' + @p_keywords + '%'
					or	afae.expense_amount	like '%' + @p_keywords + '%'
					or	afae.remarks		like '%' + @p_keywords + '%'
				) ;

		select		afae.id
					,sgs.description 'expense_type_desc'
					,afae.expense_amount
					,afae.remarks
					,@rows_count 'rowcount'
		from		application_financial_analysis_expense afae
					inner join dbo.sys_general_subcode sgs on (sgs.code = afae.expense_type)
		where		application_financial_analysis_code = @p_application_financial_analysis_code
					and (
							sgs.description			like '%' + @p_keywords + '%'
							or	afae.expense_amount	like '%' + @p_keywords + '%'
							or	afae.remarks		like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sgs.description
													when 2 then cast(afae.expense_amount as sql_variant)	
													when 3 then afae.remarks	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then sgs.description
														when 2 then cast(afae.expense_amount as sql_variant)	
														when 3 then afae.remarks	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


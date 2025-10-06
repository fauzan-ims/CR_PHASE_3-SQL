create PROCEDURE [dbo].[xsp_master_contract_financial_recapitulation_detail_getrows]
(
	@p_keywords						  nvarchar(50)
	,@p_pagenumber					  int
	,@p_rowspage					  int
	,@p_order_by					  int
	,@p_sort_by						  nvarchar(5)
	,@p_financial_recapitulation_code nvarchar(50)
	,@p_report_type					  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_contract_financial_recapitulation_detail pfrd
			inner join dbo.master_financial_statement mfs on (mfs.code = pfrd.statement_code and mfs.report_type = pfrd.report_type)
	where	pfrd.financial_recapitulation_code = @p_financial_recapitulation_code
			and pfrd.report_type  = case @p_report_type
										when 'ALL' then pfrd.report_type
										else @p_report_type
									end
			and (
					mfs.code								like '%' + @p_keywords + '%'
					or	pfrd.statement_description			like '%' + @p_keywords + '%'
					or	pfrd.statement_from_value_amount	like '%' + @p_keywords + '%'
					or	pfrd.statement_to_value_amount		like '%' + @p_keywords + '%'
					or	pfrd.statement_ratio_pct			like '%' + @p_keywords + '%'
				) ;

	select		pfrd.id
				,mfs.code	
				,pfrd.statement_description
				,pfrd.statement_from_value_amount
				,pfrd.statement_to_value_amount
				,pfrd.statement_ratio_pct
				,pfrd.statement_parent_code
				,mfs.type
				,@rows_count 'rowcount'
	from		dbo.master_contract_financial_recapitulation_detail pfrd
				inner join dbo.master_financial_statement mfs on (mfs.code = pfrd.statement_code and mfs.report_type = pfrd.report_type)
	where		pfrd.financial_recapitulation_code = @p_financial_recapitulation_code
				and pfrd.report_type  = case @p_report_type
											when 'ALL' then pfrd.report_type
											else @p_report_type
										end
				and (
						mfs.code								like '%' + @p_keywords + '%'
						or	pfrd.statement_description			like '%' + @p_keywords + '%'
						or	pfrd.statement_from_value_amount	like '%' + @p_keywords + '%'
						or	pfrd.statement_to_value_amount		like '%' + @p_keywords + '%'
						or	pfrd.statement_ratio_pct			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mfs.code	
													when 2 then pfrd.statement_description
													when 3 then cast(pfrd.statement_from_value_amount as sql_variant)
													when 4 then cast(pfrd.statement_to_value_amount as sql_variant)
													when 5 then cast(pfrd.statement_ratio_pct as sql_variant)
											end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mfs.code	
														when 2 then pfrd.statement_description
														when 3 then cast(pfrd.statement_from_value_amount as sql_variant)
														when 4 then cast(pfrd.statement_to_value_amount as sql_variant)
														when 5 then cast(pfrd.statement_ratio_pct as sql_variant)
												end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		
end ;



CREATE PROCEDURE [dbo].[xsp_application_financial_statement_detail_getrows]
(
	@p_keywords					 nvarchar(50)
	,@p_pagenumber				 int
	,@p_rowspage				 int
	,@p_order_by				 int
	,@p_sort_by					 nvarchar(5)
	,@p_financial_statement_code nvarchar(50)
	,@p_report_type				 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_financial_statement_detail pfsd
			inner join dbo.master_financial_statement mfs on (mfs.code = pfsd.statement_code and mfs.report_type = pfsd.report_type)
	where	pfsd.financial_statement_code = @p_financial_statement_code
			and pfsd.report_type  = case @p_report_type
										when 'ALL' then pfsd.report_type
										else @p_report_type
									end
			and (
					mfs.code					   like '%' + @p_keywords + '%'
					or pfsd.statement_description  like '%' + @p_keywords + '%'
					or pfsd.statement_value_amount like '%' + @p_keywords + '%'
				) ;

	select		pfsd.id
				,mfs.code
				,pfsd.statement_description
				,pfsd.statement_value_amount
				,pfsd.statement_parent_code
				,mfs.type
				,@rows_count 'rowcount'
	from		application_financial_statement_detail pfsd
				inner join dbo.master_financial_statement mfs on (mfs.code = pfsd.statement_code and mfs.report_type = pfsd.report_type)
	where		pfsd.financial_statement_code = @p_financial_statement_code
				and pfsd.report_type  = case @p_report_type
											when 'ALL' then pfsd.report_type
											else @p_report_type
										end
				and (
						mfs.code					   like '%' + @p_keywords + '%'
						or pfsd.statement_description  like '%' + @p_keywords + '%'
						or pfsd.statement_value_amount like '%' + @p_keywords + '%'
					)
					
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then mfs.code
														when 2 then pfsd.statement_description
														when 3 then cast(pfsd.statement_value_amount as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mfs.code
														when 2 then pfsd.statement_description
														when 3 then cast(pfsd.statement_value_amount as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


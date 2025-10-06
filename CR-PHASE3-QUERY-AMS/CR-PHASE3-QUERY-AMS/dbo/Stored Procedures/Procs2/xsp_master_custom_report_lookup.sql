CREATE PROCEDURE dbo.[xsp_master_custom_report_lookup]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_custom_report
	where	company_code = @p_company_code
	and		(
				description				 like '%' + @p_keywords + '%'
			) ;

	select		code
				,company_code
				,description 'table_name'
				,asset_type
				,transaction_type
				,case is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		master_custom_report
	where		company_code = @p_company_code
	and			(
					description				 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

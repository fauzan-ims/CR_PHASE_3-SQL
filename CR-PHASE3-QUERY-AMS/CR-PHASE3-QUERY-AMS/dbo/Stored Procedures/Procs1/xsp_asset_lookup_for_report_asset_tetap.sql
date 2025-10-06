CREATE PROCEDURE dbo.xsp_asset_lookup_for_report_asset_tetap
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_branch_code		nvarchar(50) = ''
	,@p_category_code	nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset ass
	where	ass.company_code	= @p_company_code
	and		ass.branch_code		= case @p_branch_code 
								when '' then ass.branch_code
								else @p_branch_code
							  end
	and		ass.category_code	= case @p_category_code 
								when '' then ass.category_code
								else @p_category_code
							  end 
	and		(
				ass.code							like '%' + @p_keywords + '%'
				or	ass.barcode						like '%' + @p_keywords + '%'
				or	ass.item_name					like '%' + @p_keywords + '%'
			) ;

	select		ass.code
				,ass.barcode
				,ass.item_name
				,@rows_count 'rowcount'
	from	dbo.asset ass
	where	ass.company_code	= @p_company_code
	and		ass.branch_code		= case @p_branch_code 
								when '' then ass.branch_code
								else @p_branch_code
							  end
	and		ass.category_code	= case @p_category_code 
								when '' then ass.category_code
								else @p_category_code
							  end 
	and		(
				ass.code							like '%' + @p_keywords + '%'
				or	ass.barcode						like '%' + @p_keywords + '%'
				or	ass.item_name					like '%' + @p_keywords + '%'
			) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.barcode
													 when 3 then ass.item_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ass.code
													   when 2 then ass.barcode
													   when 3 then ass.item_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

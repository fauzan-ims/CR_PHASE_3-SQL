CREATE PROCEDURE dbo.xsp_asset_lookup_for_report
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_region_code		nvarchar(50) = ''
	,@p_location_code	nvarchar(50) = ''
	,@p_branch_code		nvarchar(50) = ''
	,@p_category_code	nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset
	where	company_code	= @p_company_code
	and		regional_code	= case @p_region_code 
								when '' then regional_code
								else @p_region_code
							  end
	and		branch_code		= case @p_branch_code 
								when '' then branch_code
								else @p_branch_code
							  end
	and		location_code	= case @p_location_code 
								when '' then location_code
								else @p_location_code
							  end
	and		category_code	= case @p_category_code 
								when '' then category_code
								else @p_category_code
							  end 
	and		(
				code							like '%' + @p_keywords + '%'
				or	barcode						like '%' + @p_keywords + '%'
				or	item_code					like '%' + @p_keywords + '%'
			) ;

	select		code
				,barcode
				,item_name
				,@rows_count 'rowcount'
	from		dbo.asset
	where		company_code	= @p_company_code
	and		regional_code	= case @p_region_code 
								when '' then regional_code
								else @p_region_code
							  end
	and		branch_code		= case @p_branch_code 
								when '' then branch_code
								else @p_branch_code
							  end
	and		location_code	= case @p_location_code 
								when '' then location_code
								else @p_location_code
							  end
	and		category_code	= case @p_category_code 
								when '' then category_code
								else @p_category_code
							  end 
	and			(
					code							like '%' + @p_keywords + '%'
					or	barcode						like '%' + @p_keywords + '%'
					or	item_code					like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then barcode
													 when 3 then item_code
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then barcode
													   when 3 then item_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

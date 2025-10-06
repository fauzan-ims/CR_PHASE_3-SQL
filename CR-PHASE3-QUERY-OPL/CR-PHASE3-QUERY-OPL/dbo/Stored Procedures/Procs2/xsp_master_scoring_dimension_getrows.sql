CREATE PROCEDURE dbo.xsp_master_scoring_dimension_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_scoring_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_scoring_dimension msd
			left join dbo.sys_dimension sdm on (sdm.code = msd.dimension_code)
	where	msd.scoring_code = @p_scoring_code
	and		(
				msd.reff_item_code			like '%' + @p_keywords + '%'
				or	msd.reff_item_name		like '%' + @p_keywords + '%'
				or	sdm.description			like '%' + @p_keywords + '%'
			) ;

	select	msd.id
			,msd.reff_item_code
			,msd.reff_item_name
			,msd.dimension_code
			,sdm.description
			,@rows_count 'rowcount'
	from	master_scoring_dimension msd
			left join dbo.sys_dimension sdm on sdm.code = msd.dimension_code
	where	scoring_code = @p_scoring_code
	and		(
				msd.reff_item_code			like '%' + @p_keywords + '%'
				or	msd.reff_item_name		like '%' + @p_keywords + '%'
				or	sdm.description			like '%' + @p_keywords + '%'
			)
	order by	case
			when @p_sort_by = 'asc' then case @p_order_by
											when 1 then msd.reff_item_code
											when 2 then msd.reff_item_name
											when 3 then sdm.description	
										end
		end asc
		,case
				when @p_sort_by = 'desc' then case @p_order_by
												when 1 then msd.reff_item_code
												when 2 then msd.reff_item_name
												when 3 then sdm.description
											end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;

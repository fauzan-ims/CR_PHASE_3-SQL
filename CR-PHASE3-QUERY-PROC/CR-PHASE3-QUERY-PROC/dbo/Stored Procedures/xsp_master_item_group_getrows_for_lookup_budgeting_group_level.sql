CREATE PROCEDURE dbo.xsp_master_item_group_getrows_for_lookup_budgeting_group_level
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	--
	,@p_company_code nvarchar(50)
)
as
BEGIN

	declare @rows_count int = 0 ;

	declare @temp_master_item_group table 
	(
		group_level			int
	)

	insert @temp_master_item_group
	(
		group_level
	)
	select	distinct group_level
	from	dbo.master_item_group
	where	company_code  = @p_company_code
	and		is_active = '1'

	select	@rows_count = count(1)
	from	@temp_master_item_group
	where	(
				group_level		like '%' + @p_keywords + '%'
			) ;

	select	group_level
			,@rows_count 'rowcount'
	from	@temp_master_item_group
	where	(
				group_level		like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cast(group_level as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														WHEN 1 then cast(group_level as sql_variant)
													end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;


end ;

CREATE PROCEDURE dbo.xsp_monitoring_aging_supplier_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--,@p_branch_code			nvarchar(50) -- custody_branch
	,@p_initial_branch_code nvarchar(50) -- original_branch 
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	document_pending dm
			left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
	where	dm.initial_branch_code = @p_initial_branch_code
			and dm.document_status in
	(
		'HOLD', 'TRANSIT'
	)
			and (
					dm.initial_branch_name										like '%' + @p_keywords + '%'
					or	dm.asset_no												like '%' + @p_keywords + '%'
					or	dm.asset_name											like '%' + @p_keywords + '%'
					or	fam.reff_no_1											like '%' + @p_keywords + '%'
					or	fam.reff_no_2											like '%' + @p_keywords + '%'
					or	fam.reff_no_3											like '%' + @p_keywords + '%'
					or	dm.document_type										like '%' + @p_keywords + '%'
					or	convert(varchar(30), dm.entry_date, 103)				like '%' + @p_keywords + '%'
					or	datediff(day, dm.entry_date, dbo.xfn_get_system_date())	like '%' + @p_keywords + '%'
					or	dm.document_status										like '%' + @p_keywords + '%'
				) ;

	select		dm.initial_branch_name
				,dm.asset_no
				,dm.asset_name
				,fam.reff_no_1
				,fam.reff_no_2
				,fam.reff_no_3
				,dm.document_type
				,convert(varchar(30), dm.entry_date, 103) 'agreement_date'
				,datediff(day, dm.entry_date, dbo.xfn_get_system_date()) 'aging'
				,@rows_count 'rowcount'
	from		document_pending dm
				left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
	where		dm.initial_branch_code = @p_initial_branch_code
				and dm.document_status in
	(
		'HOLD', 'TRANSIT'
	)
				and (
						dm.initial_branch_name										like '%' + @p_keywords + '%'
						or	dm.asset_no												like '%' + @p_keywords + '%'
						or	dm.asset_name											like '%' + @p_keywords + '%'
						or	fam.reff_no_1											like '%' + @p_keywords + '%'
						or	fam.reff_no_2											like '%' + @p_keywords + '%'
						or	fam.reff_no_3											like '%' + @p_keywords + '%'
						or	dm.document_type										like '%' + @p_keywords + '%'
						or	convert(varchar(30), dm.entry_date, 103)				like '%' + @p_keywords + '%'
						or	datediff(day, dm.entry_date, dbo.xfn_get_system_date())	like '%' + @p_keywords + '%'
						or	dm.document_status										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then dm.initial_branch_name
													 when 2 then dm.asset_no
													 when 3 then fam.reff_no_1
													 when 4 then dm.document_type
													 when 5 then cast(dm.entry_date as sql_variant)
													 when 6 then cast(datediff(day, dm.entry_date, dbo.xfn_get_system_date()) as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then dm.initial_branch_name
													 when 2 then dm.asset_no
													 when 3 then fam.reff_no_1
													 when 4 then dm.document_type
													 when 5 then cast(dm.entry_date as sql_variant)
													 when 6 then cast(datediff(day, dm.entry_date, dbo.xfn_get_system_date()) as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

CREATE PROCEDURE dbo.xsp_monitoring_document_non_custodian_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)
	,@p_initial_branch_code nvarchar(50)
	,@p_document_status		nvarchar(50)
)
as
begin
	declare @rows_count				int = 0
			,@p_custody_branch_code nvarchar(50) ;

	set @p_custody_branch_code = @p_initial_branch_code ;

	select	@rows_count = count(1)
	from	dbo.document_main dm
			left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
	where	dm.branch_code			   = @p_custody_branch_code
			and dm.custody_branch_code = @p_branch_code
			and dm.document_status	   = case @p_document_status
											 when 'ALL' then dm.document_status
											 else @p_document_status
										 end
			and (
					dm.branch_name				like '%' + @p_keywords + '%' 
					or	dm.asset_no				like '%' + @p_keywords + '%'
					or	dm.asset_name			like '%' + @p_keywords + '%'
					or	fam.reff_no_1			like '%' + @p_keywords + '%'
					or	fam.reff_no_2			like '%' + @p_keywords + '%'
					or	fam.reff_no_3			like '%' + @p_keywords + '%'
					or	dm.document_type		like '%' + @p_keywords + '%'
					or	dm.document_status		like '%' + @p_keywords + '%'
					or	dm.last_mutation_type	like '%' + @p_keywords + '%'
				) ;

	select		dm.custody_branch_name
				,dm.branch_name 
				,dm.asset_no
				,dm.asset_name
				,dm.document_type
				,dm.document_status
				,dm.last_mutation_type
				,fam.reff_no_1
				,fam.reff_no_2
				,fam.reff_no_3
				,@rows_count 'rowcount'
	from		dbo.document_main dm
				left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
	where		dm.branch_code			   = @p_custody_branch_code
				and dm.custody_branch_code = @p_branch_code
				and dm.document_status	   = case @p_document_status
												 when 'ALL' then dm.document_status
												 else @p_document_status
											 end
				and (
						dm.branch_name				like '%' + @p_keywords + '%' 
						or	dm.asset_no				like '%' + @p_keywords + '%'
						or	dm.asset_name			like '%' + @p_keywords + '%'
						or	fam.reff_no_1			like '%' + @p_keywords + '%'
						or	fam.reff_no_2			like '%' + @p_keywords + '%'
						or	fam.reff_no_3			like '%' + @p_keywords + '%'
						or	dm.document_type		like '%' + @p_keywords + '%'
						or	dm.document_status		like '%' + @p_keywords + '%'
						or	dm.last_mutation_type	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then dm.branch_name
													 when 2 then dm.custody_branch_name
													 when 3 then dm.asset_no  
													 when 4 then fam.reff_no_1 
													 when 5 then dm.document_type
													 when 6 then dm.document_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then dm.branch_name
													 when 2 then dm.custody_branch_name
													 when 3 then dm.asset_no  
													 when 4 then fam.reff_no_1 
													 when 5 then dm.document_type
													 when 6 then dm.document_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

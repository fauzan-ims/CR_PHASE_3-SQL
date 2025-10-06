CREATE PROCEDURE dbo.xsp_document_main_document_non_custody_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.document_main dm
			left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
	where	dm.document_status = 'ON HAND'
			and dm.branch_code = case @p_branch_code
								 	when 'ALL' then branch_code
								 	else @p_branch_code
								 end
			and dm.branch_code	   <> dm.custody_branch_code
			and dm.code not in
				(
					select isnull(dmv.document_code,'') from dbo.document_movement_detail dmv
					inner join dbo.document_movement dm on dm.code = dmv.movement_code
					where dm.movement_status in ('HOLD', 'ON PROCESS')
				)
			and (
					branch_name				like '%' + @p_keywords + '%'
					or	dm.asset_no			like '%' + @p_keywords + '%'
					or	dm.asset_name		like '%' + @p_keywords + '%'
					or	fam.reff_no_1		like '%' + @p_keywords + '%'
					or	fam.reff_no_2		like '%' + @p_keywords + '%'
					or	fam.reff_no_3		like '%' + @p_keywords + '%' 
					or	document_type		like '%' + @p_keywords + '%' 
					or	document_status		like '%' + @p_keywords + '%' 
				) ;

	select		 dm.code
				,dm.branch_name
				,dm.custody_branch_name
				,dm.asset_no
				,dm.asset_name
				,fam.reff_no_1
				,fam.reff_no_2
				,fam.reff_no_3  
				,dm.document_type
				,dm.document_status
				,@rows_count 'rowcount'
	from		dbo.document_main dm
				left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
	where		dm.document_status = 'ON HAND'
				and dm.branch_code = case @p_branch_code
										when 'ALL' then branch_code
										else @p_branch_code
									 end
				and dm.branch_code	   <> dm.custody_branch_code
				and dm.code not in
				(
					select isnull(dmv.document_code,'') from dbo.document_movement_detail dmv
					inner join dbo.document_movement dm on dm.code = dmv.movement_code
					where dm.movement_status in ('HOLD', 'ON PROCESS')
				)
				and (
						branch_name				like '%' + @p_keywords + '%'
						or	dm.asset_no			like '%' + @p_keywords + '%'
						or	dm.asset_name		like '%' + @p_keywords + '%'
						or	fam.reff_no_1		like '%' + @p_keywords + '%'
						or	fam.reff_no_2		like '%' + @p_keywords + '%'
						or	fam.reff_no_3		like '%' + @p_keywords + '%' 
						or	document_type		like '%' + @p_keywords + '%' 
						or	document_status		like '%' + @p_keywords + '%' 
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then branch_name
													 when 2 then dm.custody_branch_name
													 when 3 then dm.asset_no
													 when 4 then fam.reff_no_1
													 when 5 then document_type
													 when 6 then document_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then branch_name
													 when 2 then dm.custody_branch_name
													 when 3 then dm.asset_no
													 when 4 then fam.reff_no_1
													 when 5 then document_type
													 when 6 then document_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

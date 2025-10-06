CREATE PROCEDURE dbo.xsp_document_main_getrows
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_branch_code			  nvarchar(50) = ''
	,@p_document_status		  nvarchar(50)
	,@p_expired_date_status	  nvarchar(50)
	,@p_general_document_code nvarchar(50) = ''
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
	from		document_main dm 
				left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
				left join ifinams.dbo.asset_vehicle av on (dm.asset_no = av.asset_code)
				left join dbo.master_locker ml on ml.code = dm.locker_code
				left join dbo.master_drawer md on md.code = dm.drawer_code
				left join dbo.master_row mr on mr.code = dm.row_code
				left join dbo.master_locker ml2 on ml2.code = dm.last_locker_code
				left join dbo.master_drawer md2 on md2.code = dm.last_drawer_code
				left join dbo.master_row mr2 on mr2.code = dm.last_row_code
				outer apply
	(
		select top 1
				'1' 'is_expired'
		from	dbo.document_detail dd
		where	dm.code = dd.document_code
				and expired_date   < getdate()
	) dd
	where		dm.branch_code					 = case @p_branch_code
												   when 'ALL' then dm.branch_code
												   else @p_branch_code
											   end
				and document_status			 = case @p_document_status
												   when 'ALL' then document_status
												   else @p_document_status
											   end
				and document_type			 = case @p_general_document_code
												   when '' then document_type
												   else @p_general_document_code
											   end
				and isnull(dd.is_expired, 0) = case @p_expired_date_status
												   when 'YES' then '1'
												   when 'NO' then '0'
												   when 'ALL' then isnull(dd.is_expired, 0)
											   end
				and (
						dm.branch_name				like '%' + @p_keywords + '%'
						or	dm.asset_no			like '%' + @p_keywords + '%'
						or	dm.asset_name		like '%' + @p_keywords + '%'
						or	fam.reff_no_1		like '%' + @p_keywords + '%'
						or	fam.reff_no_2		like '%' + @p_keywords + '%'
						or	fam.reff_no_3		like '%' + @p_keywords + '%' 
						--or	av.plat_no			like '%' + @p_keywords + '%' 
						--or	av.chassis_no		like '%' + @p_keywords + '%' 
						--or	av.engine_no		like '%' + @p_keywords + '%' 
						or	document_type		like '%' + @p_keywords + '%' 
						or	document_status		like '%' + @p_keywords + '%'
						or	last_mutation_type	like '%' + @p_keywords + '%'
						or	locker_position		like '%' + @p_keywords + '%'
						-- (+) Ari 2023-11-29
						or	ml.locker_name		like '%' + @p_keywords + '%'
						or	md.drawer_name		like '%' + @p_keywords + '%'
						or	mr.row_name			like '%' + @p_keywords + '%'
						or	ml2.locker_name		like '%' + @p_keywords + '%'
						or	md2.drawer_name		like '%' + @p_keywords + '%'
						or	mr2.row_name		like '%' + @p_keywords + '%'
					);

	select		dm.code
				,dm.branch_code
				,dm.branch_name
				,dm.custody_branch_code
				,dm.custody_branch_name
				,dm.document_type 
				,dm.asset_no
				,dm.asset_name
				,fam.reff_no_1
				,fam.reff_no_2
				,fam.reff_no_3
				--,av.plat_no		'reff_no_1'
				--,av.chassis_no	'reff_no_2'
				--,av.engine_no	'reff_no_3'
				,dm.locker_position
				,dm.locker_code
				,dm.drawer_code
				,dm.row_code
				,dm.document_status
				,dm.mutation_type
				,dm.mutation_location
				,dm.mutation_from
				,dm.mutation_to
				,dm.mutation_by
				,dm.mutation_date
				,dm.mutation_return_date
				,case
					 when document_status = 'ON BORROW'
						  or document_status like 'ON TRANSIT%' then ml.locker_name
					 else ''
				 end as 'last_mutation_type'
				,last_mutation_date
				,last_locker_position
				,last_locker_code
				,last_drawer_code
				,last_row_code
				,borrow_thirdparty_type
				,first_receive_date
				,release_customer_date
				,isnull(dd.is_expired, 0) 'is_expired_date'
				,case 
					when dm.locker_position = 'IN LOCKER' then ml.locker_name + ' - ' + md.drawer_name + ' - ' + mr.row_name
					when dm.locker_position = 'OUT LOCKER' then ml2.locker_name + ' - ' + md2.drawer_name + ' - ' + mr2.row_name
				 end 'locker_location'
				,@rows_count 'rowcount'
	from		document_main dm 
				left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
				left join ifinams.dbo.asset_vehicle av on (dm.asset_no = av.asset_code)
				left join dbo.master_locker ml on ml.code = dm.locker_code
				left join dbo.master_drawer md on md.code = dm.drawer_code
				left join dbo.master_row mr on mr.code = dm.row_code
				left join dbo.master_locker ml2 on ml2.code = dm.last_locker_code
				left join dbo.master_drawer md2 on md2.code = dm.last_drawer_code
				left join dbo.master_row mr2 on mr2.code = dm.last_row_code
				outer apply
	(
		select top 1
				'1' 'is_expired'
		from	dbo.document_detail dd
		where	dm.code = dd.document_code
				and expired_date   < getdate()
	) dd
	where		dm.branch_code					 = case @p_branch_code
												   when 'ALL' then dm.branch_code
												   else @p_branch_code
											   end
				and document_status			 = case @p_document_status
												   when 'ALL' then document_status
												   else @p_document_status
											   end
				and document_type			 = case @p_general_document_code
												   when '' then document_type
												   else @p_general_document_code
											   end
				and isnull(dd.is_expired, 0) = case @p_expired_date_status
												   when 'YES' then '1'
												   when 'NO' then '0'
												   when 'ALL' then isnull(dd.is_expired, 0)
											   end
				and (
						dm.branch_name				like '%' + @p_keywords + '%'
						or	dm.asset_no			like '%' + @p_keywords + '%'
						or	dm.asset_name		like '%' + @p_keywords + '%'
						or	fam.reff_no_1		like '%' + @p_keywords + '%'
						or	fam.reff_no_2		like '%' + @p_keywords + '%'
						or	fam.reff_no_3		like '%' + @p_keywords + '%' 
						--or	av.plat_no			like '%' + @p_keywords + '%' 
						--or	av.chassis_no		like '%' + @p_keywords + '%' 
						--or	av.engine_no		like '%' + @p_keywords + '%' 
						or	document_type		like '%' + @p_keywords + '%' 
						or	document_status		like '%' + @p_keywords + '%'
						or	last_mutation_type	like '%' + @p_keywords + '%'
						or	locker_position		like '%' + @p_keywords + '%'
						-- (+) Ari 2023-11-29
						or	ml.locker_name		like '%' + @p_keywords + '%'
						or	md.drawer_name		like '%' + @p_keywords + '%'
						or	mr.row_name			like '%' + @p_keywords + '%'
						or	ml2.locker_name		like '%' + @p_keywords + '%'
						or	md2.drawer_name		like '%' + @p_keywords + '%'
						or	mr2.row_name		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then dm.branch_name
													 when 2 then dm.asset_no
													 when 3 then fam.reff_no_1
													 when 4 then document_type
													 when 5 then document_status
													 when 6 then locker_position
													 when 7 then case 
																	when dm.locker_position = 'IN LOCKER' then ml.locker_name + ' - ' + md.drawer_name + ' - ' + mr.row_name
																	when dm.locker_position = 'OUT LOCKER' then ml2.locker_name + ' - ' + md2.drawer_name + ' - ' + mr2.row_name
																 end 
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then dm.branch_name
													 when 2 then dm.asset_no
													 when 3 then fam.reff_no_1
													 when 4 then document_type
													 when 5 then document_status
													 when 6 then locker_position
													 when 7 then case 
																	when dm.locker_position = 'IN LOCKER' then ml.locker_name + ' - ' + md.drawer_name + ' - ' + mr.row_name
																	when dm.locker_position = 'OUT LOCKER' then ml2.locker_name + ' - ' + md2.drawer_name + ' - ' + mr2.row_name
																 end 
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

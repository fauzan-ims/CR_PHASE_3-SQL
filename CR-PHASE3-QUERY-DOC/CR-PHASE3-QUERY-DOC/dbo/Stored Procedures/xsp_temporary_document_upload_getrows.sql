CREATE PROCEDURE dbo.xsp_temporary_document_upload_getrows
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  INT
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
				INNER JOIN dbo.DOCUMENT_DETAIL ddt ON ddt.DOCUMENT_CODE = dm.CODE
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
				and dm.DOCUMENT_TYPE			 = case @p_general_document_code
												   when '' then dm.DOCUMENT_TYPE
												   else @p_general_document_code
											   end
				and isnull(dd.is_expired, 0) = case @p_expired_date_status
												   when 'YES' then '1'
												   when 'NO' then '0'
												   when 'ALL' then isnull(dd.is_expired, 0)
											   END
                AND		ddt.CRE_BY = 'MIGRASI'
				and (
						dm.branch_name			like '%' + @p_keywords + '%'
						or	dm.asset_no			like '%' + @p_keywords + '%'
						or	dm.asset_name		like '%' + @p_keywords + '%'
						or	fam.reff_no_1		like '%' + @p_keywords + '%'
						or	fam.reff_no_2		like '%' + @p_keywords + '%'
						or	fam.reff_no_3		like '%' + @p_keywords + '%' 
						or	dm.DOCUMENT_TYPE	like '%' + @p_keywords + '%' 
						or	document_status		like '%' + @p_keywords + '%'
						or	last_mutation_type	like '%' + @p_keywords + '%'
						or	locker_position		like '%' + @p_keywords + '%'
						or	ml.locker_name		like '%' + @p_keywords + '%'
						or	md.drawer_name		like '%' + @p_keywords + '%'
						or	mr.row_name			like '%' + @p_keywords + '%'
						or	ml2.locker_name		like '%' + @p_keywords + '%'
						or	md2.drawer_name		like '%' + @p_keywords + '%'
						or	mr2.row_name		like '%' + @p_keywords + '%'
						or	ddt.document_name	like '%' + @p_keywords + '%'
						or	ddt.doc_no			like '%' + @p_keywords + '%'
						or	ddt.doc_name		like '%' + @p_keywords + '%'
					);

	select		dm.code
				,ddt.ID
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
				 ,ddt.document_name 'document_name_detail'
				 ,ddt.doc_no
				 ,ddt.doc_name
				 ,ddt.file_name
				 ,ddt.paths
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
				inner JOIN dbo.DOCUMENT_DETAIL ddt ON ddt.DOCUMENT_CODE = dm.CODE
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
				and dm.DOCUMENT_TYPE			 = case @p_general_document_code
												   when '' then dm.DOCUMENT_TYPE
												   else @p_general_document_code
											   end
				and isnull(dd.is_expired, 0) = case @p_expired_date_status
												   when 'YES' then '1'
												   when 'NO' then '0'
												   when 'ALL' then isnull(dd.is_expired, 0)
											   END
				AND		ddt.CRE_BY = 'MIGRASI'
				and (
						dm.branch_name			like '%' + @p_keywords + '%'
						or	dm.asset_no			like '%' + @p_keywords + '%'
						or	dm.asset_name		like '%' + @p_keywords + '%'
						or	fam.reff_no_1		like '%' + @p_keywords + '%'
						or	fam.reff_no_2		like '%' + @p_keywords + '%'
						or	fam.reff_no_3		like '%' + @p_keywords + '%' 
						or	dm.document_type	like '%' + @p_keywords + '%' 
						or	document_status		like '%' + @p_keywords + '%'
						or	last_mutation_type	like '%' + @p_keywords + '%'
						or	locker_position		like '%' + @p_keywords + '%'
						or	ml.locker_name		like '%' + @p_keywords + '%'
						or	md.drawer_name		like '%' + @p_keywords + '%'
						or	mr.row_name			like '%' + @p_keywords + '%'
						or	ml2.locker_name		like '%' + @p_keywords + '%'
						or	md2.drawer_name		like '%' + @p_keywords + '%'
						or	mr2.row_name		like '%' + @p_keywords + '%'
						or	ddt.document_name	like '%' + @p_keywords + '%'
						or	ddt.doc_no			like '%' + @p_keywords + '%'
						or	ddt.doc_name		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ISNULL(dm.branch_name, '')
													when 2 then ISNULL(dm.asset_no, '')
													when 3 then ISNULL(fam.reff_no_1, '')
													when 4 then ISNULL(dm.document_type, '')
													when 5 then ISNULL(locker_position, '')
													when 6 then ISNULL(ddt.document_name, '')
													when 7 then ISNULL(ddt.doc_no, '')
													when 8 then ISNULL(ddt.doc_name, '')
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then ISNULL(dm.branch_name, '')
													when 2 then ISNULL(dm.asset_no, '')
													when 3 then ISNULL(fam.reff_no_1, '')
													when 4 then ISNULL(dm.document_type, '')
													when 5 then ISNULL(locker_position, '')
													when 6 then ISNULL(ddt.document_name, '')
													when 7 then ISNULL(ddt.doc_no, '')
													when 8 then ISNULL(ddt.doc_name, '')
												   end
				 end DESC, 
				 ddt.ID 
				 OFFSET ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

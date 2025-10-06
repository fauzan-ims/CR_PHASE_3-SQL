CREATE PROCEDURE dbo.xsp_document_storage_detail_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_document_storage_code	NVARCHAR(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	document_storage_detail dsd
			left join dbo.document_main dm on (dsd.document_code = dm.code)
			left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
			left join dbo.master_locker ml on ml.code = dm.locker_code
			left join dbo.master_drawer md on md.code = dm.drawer_code
			left join dbo.master_row mr on mr.code = dm.row_code
	where	document_storage_code = @p_document_storage_code
			and (
					dm.asset_no				like '%' + @p_keywords + '%'
					or	dm.asset_name		like '%' + @p_keywords + '%'
					or	fam.reff_no_1		like '%' + @p_keywords + '%'
					or	fam.reff_no_2		like '%' + @p_keywords + '%'
					or	fam.reff_no_3		like '%' + @p_keywords + '%'
					or	dm.document_type	like '%' + @p_keywords + '%'
					or	dm.locker_position	like '%' + @p_keywords + '%'
					or	ml.locker_name		like '%' + @p_keywords + '%'
					or	md.drawer_name		like '%' + @p_keywords + '%'
					or	mr.row_name			like '%' + @p_keywords + '%'
				);

		select		dsd.id
					,dsd.document_storage_code
					,dsd.document_code
					,dm.document_type  
					,dm.locker_position
					,dm.asset_no
					,dm.asset_name
					,fam.reff_no_1
					,fam.reff_no_2
					,fam.reff_no_3
					,ml.locker_name
					,md.drawer_name
					,mr.row_name
					,@rows_count 'rowcount'
		from		document_storage_detail dsd
					inner join dbo.document_main dm on (dsd.document_code = dm.code)
					left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
					left join dbo.master_locker ml on ml.code = dm.locker_code
					left join dbo.master_drawer md on md.code = dm.drawer_code
					left join dbo.master_row mr on mr.code = dm.row_code
		where		document_storage_code = @p_document_storage_code
					and (
							dm.asset_no				like '%' + @p_keywords + '%'
							or	dm.asset_name		like '%' + @p_keywords + '%'
							or	fam.reff_no_1		like '%' + @p_keywords + '%'
							or	fam.reff_no_2		like '%' + @p_keywords + '%'
							or	fam.reff_no_3		like '%' + @p_keywords + '%'
							or	dm.document_type	like '%' + @p_keywords + '%'
							or	dm.locker_position	like '%' + @p_keywords + '%'
							or	ml.locker_name		like '%' + @p_keywords + '%'
							or	md.drawer_name		like '%' + @p_keywords + '%'
							or	mr.row_name			like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then dm.document_type
													when 2 then dm.asset_no
													when 3 then fam.reff_no_1
													when 4 then dm.locker_position
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then dm.document_type
													when 2 then dm.asset_no
													when 3 then fam.reff_no_1
													when 4 then dm.locker_position
												 end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

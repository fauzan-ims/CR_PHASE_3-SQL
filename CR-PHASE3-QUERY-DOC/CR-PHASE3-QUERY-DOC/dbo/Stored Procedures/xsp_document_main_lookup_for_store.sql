CREATE PROCEDURE dbo.xsp_document_main_lookup_for_store
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_document_storage_code nvarchar(50)
	,@p_branch_code			  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.document_main dmn
			inner join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
			left join dbo.master_locker ml on ml.code	= dmn.last_locker_code
			left join dbo.master_drawer md on md.code	= dmn.last_drawer_code
			left join dbo.master_row mr on mr.code		= dmn.last_row_code
	where	--dmn.branch_code								= @p_branch_code
			dmn.locker_position						= 'OUT LOCKER'
			and dmn.document_status						= 'ON HAND'
			and not exists
			(
				select	dsd.document_storage_code
				from	dbo.document_storage_detail dsd
				where	dsd.document_code			  = dmn.code
						and dsd.document_storage_code = @p_document_storage_code
			)
			and (
					dmn.document_type	like '%' + @p_keywords + '%'
					or	dmn.asset_no	like '%' + @p_keywords + '%'
					or	dmn.asset_name	like '%' + @p_keywords + '%'
					or	fam.reff_no_1	like '%' + @p_keywords + '%'
					or	fam.reff_no_2	like '%' + @p_keywords + '%'
					or	fam.reff_no_3	like '%' + @p_keywords + '%'
					or	ml.locker_name	like '%' + @p_keywords + '%'
					or	md.drawer_name	like '%' + @p_keywords + '%'
					or	mr.row_name		like '%' + @p_keywords + '%'
				) ;

	select		dmn.code
				,dmn.document_type  
				,ml.locker_name
				,md.drawer_name
				,dmn.asset_no	
				,dmn.asset_name	
				,fam.reff_no_1	
				,fam.reff_no_2	
				,fam.reff_no_3	
				,mr.row_name
				,@rows_count 'rowcount'
	from		dbo.document_main dmn
				inner join dbo.fixed_asset_main fam on (fam.asset_no = dmn.asset_no)
				left join dbo.master_locker ml on ml.code	= dmn.last_locker_code
				left join dbo.master_drawer md on md.code	= dmn.last_drawer_code
				left join dbo.master_row mr on mr.code		= dmn.last_row_code
	where		--dmn.branch_code								= @p_branch_code
				dmn.locker_position						= 'OUT LOCKER'
				and dmn.document_status						= 'ON HAND'
				and not exists
				(
					select	dsd.document_storage_code
					from	dbo.document_storage_detail dsd
					where	dsd.document_code			  = dmn.code
							and dsd.document_storage_code = @p_document_storage_code
				)
				and (
						dmn.document_type	like '%' + @p_keywords + '%'
						or	dmn.asset_no	like '%' + @p_keywords + '%'
						or	dmn.asset_name	like '%' + @p_keywords + '%'
						or	fam.reff_no_1	like '%' + @p_keywords + '%'
						or	fam.reff_no_2	like '%' + @p_keywords + '%'
						or	fam.reff_no_3	like '%' + @p_keywords + '%'
						or	ml.locker_name	like '%' + @p_keywords + '%'
						or	md.drawer_name	like '%' + @p_keywords + '%'
						or	mr.row_name		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then dmn.document_type
													 when 2 then dmn.asset_no
													 when 3 then fam.reff_no_1
													 when 4 then ml.locker_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then dmn.document_type
													   when 2 then dmn.asset_no
													   when 3 then fam.reff_no_1
													   when 4 then ml.locker_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

CREATE PROCEDURE dbo.xsp_replacement_request_getrows
(
	@p_keywords		NVARCHAR(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(10)
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
	from	replacement_request rrq 
	outer apply (
					select	   top 1
							   asv.chassis_no
					from	   dbo.replacement_request_detail rrd
					inner join ifinams.dbo.asset_vehicle	  asv on rrd.asset_no = asv.asset_code
					where	  rrq.ID = rrd.REPLACEMENT_REQUEST_ID
					and	   asv.chassis_no like '%' + @p_keywords + '%'		) xdetail
	where	rrq.branch_code = case @p_branch_code
								  when 'ALL' then rrq.branch_code
								  else @p_branch_code
							  end
			and status		= case @p_status
								  when 'ALL' then status
								  else @p_status
							  end
			and ((ISNULL(rrq.replacement_code, '') = '') OR rrq.STATUS = 'EXTEND')
			and (
					rrq.branch_name												like '%' + @p_keywords + '%'
					or	rrq.cover_note_no										like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), rrq.cover_note_date, (103))		like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), rrq.cover_note_exp_date, (103))	like '%' + @p_keywords + '%'
					or	rrq.count_asset											like '%' + @p_keywords + '%'
					or	rrq.received_asset										like '%' + @p_keywords + '%'
					or	rrq.status												like '%' + @p_keywords + '%'
					or	rrq.vendor_name											like '%' + @p_keywords + '%'
					or	xdetail.chassis_no										like '%' + @p_keywords + '%'
				) ;

		select	rrq.id
				,rrq.branch_code
				,rrq.branch_name
				,rrq.cover_note_no
				,convert(nvarchar(15), rrq.cover_note_date, (103)) 'cover_note_date'
				,convert(nvarchar(15), rrq.cover_note_exp_date, (103)) 'cover_note_exp_date'
				,rrq.document_name
				,rrq.count_asset
				,rrq.received_asset
				,rrq.extend_count
				,rrq.file_name
				,rrq.paths
				,rrq.status
				,rrq.remarks
				,rrq.replacement_code
				,rrq.vendor_name
				,@rows_count 'rowcount'
		from	replacement_request rrq
		outer apply (
					select	   top 1
							   asv.chassis_no
					from	   dbo.replacement_request_detail rrd
					inner join ifinams.dbo.asset_vehicle	  asv on rrd.asset_no = asv.asset_code
					where	  rrq.ID = rrd.REPLACEMENT_REQUEST_ID
					and	   asv.chassis_no like '%' + @p_keywords + '%'		) xdetail
		where	rrq.branch_code = case @p_branch_code
									  when 'ALL' then rrq.branch_code
									  else @p_branch_code
								  end
				and status		= case @p_status
									  when 'ALL' then status
									  else @p_status
								  end
				and ((ISNULL(rrq.replacement_code, '') = '') OR rrq.STATUS = 'EXTEND')
				and (
						rrq.branch_name												like '%' + @p_keywords + '%'
						or	rrq.cover_note_no										like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), rrq.cover_note_date, (103))		like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), rrq.cover_note_exp_date, (103))	like '%' + @p_keywords + '%'
						or	rrq.count_asset											like '%' + @p_keywords + '%'
						or	rrq.received_asset										like '%' + @p_keywords + '%'
						or	rrq.status												like '%' + @p_keywords + '%'
						or	rrq.vendor_name											like '%' + @p_keywords + '%'
						or	xdetail.chassis_no										like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then rrq.branch_name
														 when 2 then rrq.branch_name
														 when 3 then rrq.cover_note_no		
														 when 4 then cast(rrq.cover_note_date as sql_variant)		
														 when 5 then cast(rrq.cover_note_exp_date as sql_variant)
														 when 5 then cast(rrq.count_asset as sql_variant)	
														 when 7 then cast(rrq.received_asset as sql_variant)	
														 when 8 then rrq.status		
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														 when 1 then rrq.branch_name
														 when 2 then rrq.branch_name
														 when 3 then rrq.cover_note_no		
														 when 4 then cast(rrq.cover_note_date as sql_variant)		
														 when 5 then cast(rrq.cover_note_exp_date as sql_variant)
														 when 5 then cast(rrq.count_asset as sql_variant)	
														 when 7 then cast(rrq.received_asset as sql_variant)	
														 when 8 then rrq.status		
													 end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

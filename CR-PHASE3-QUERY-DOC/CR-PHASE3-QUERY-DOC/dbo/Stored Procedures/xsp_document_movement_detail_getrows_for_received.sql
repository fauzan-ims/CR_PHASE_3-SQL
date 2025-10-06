CREATE PROCEDURE [dbo].[xsp_document_movement_detail_getrows_for_received]
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_movement_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	document_movement_detail dmd
			left join dbo.document_main dm on (dmd.document_code			= dm.code)
			left join dbo.fixed_asset_main dmfam on (dmfam.asset_no			= dm.asset_no)
			left join dbo.document_pending dp on (dmd.document_pending_code = dp.code)
			left join dbo.fixed_asset_main dpfam on (dpfam.asset_no			= dp.asset_no)
			left join dbo.document_detail dd on (dd.document_code			= dm.code)
			--OUTER APPLY (SELECT doc_no FROM dbo.DOCUMENT_DETAIL dd WHERE dd.DOCUMENT_CODE = dm.code) docdetail 
	where	dmd.movement_code = case @p_movement_code
									when 'ALL' then movement_code
									else @p_movement_code
								end
			and (
					isnull(dm.document_type, dp.document_type)					like '%' + @p_keywords + '%'
					or	case
							when dmd.document_code is null then dp.asset_no
							else dm.asset_no
						end														like '%' + @p_keywords + '%'
					or	case
							when dmd.document_code is null then dp.asset_name
							else dm.asset_name
						end														like '%' + @p_keywords + '%'
					or	case
							when dmd.document_code is null then dpfam.reff_no_1
							else dmfam.reff_no_1
						end														like '%' + @p_keywords + '%'
					or	case
							when dmd.document_code is null then dpfam.reff_no_2
							else dmfam.reff_no_2
						end														like '%' + @p_keywords + '%'
					or	case
							when dmd.document_code is null then dpfam.reff_no_3
							else dmfam.reff_no_3
						end														like '%' + @p_keywords + '%'
					or	dmd.is_reject											like '%' + @p_keywords + '%'
					or	dd.doc_no												like '%' + @p_keywords + '%'
				) ;

	select		dmd.id
				,dmd.remarks
				,dmd.is_reject
				,isnull(dm.document_type, dp.document_type) 'document_type'
				,case
					 when dmd.document_code is null then dp.asset_no
					 else dm.asset_no
				 end 'asset_no'
				,case
					 when dmd.document_code is null then dp.asset_name
					 else dm.asset_name
				 end 'asset_name'
				,case
					 when dmd.document_code is null then dpfam.reff_no_1
					 else dmfam.reff_no_1
				 end 'reff_no_1'
				,case
					 when dmd.document_code is null then dpfam.reff_no_2
					 else dmfam.reff_no_2
				 end 'reff_no_2'
				,case
					 when dmd.document_code is null then dpfam.reff_no_3
					 else dmfam.reff_no_3
				 end 'reff_no_3'
				,dd.doc_no 'cover_note_no'
				--,av.bpkb_no
				,@rows_count 'rowcount'
	from		document_movement_detail dmd
				left join dbo.document_main dm on (dmd.document_code			= dm.code)
				left join dbo.fixed_asset_main dmfam on (dmfam.asset_no			= dm.asset_no)
				left join dbo.document_pending dp on (dmd.document_pending_code = dp.code)
				left join dbo.fixed_asset_main dpfam on (dpfam.asset_no			= dp.asset_no)
				--OUTER APPLY (SELECT doc_no FROM dbo.DOCUMENT_DETAIL dd WHERE dd.DOCUMENT_CODE = dm.code) docdetail 
				left join dbo.document_detail dd on (dd.document_code			= dm.code)
				--left join ifinams.dbo.asset_vehicle    av with (nolock) on (av.asset_code             = dmfam.asset_no)
	where		dmd.movement_code = case @p_movement_code
										when 'ALL' then movement_code
										else @p_movement_code
									end
				and (
						isnull(dm.document_type, dp.document_type)					like '%' + @p_keywords + '%'
						or	case
								when dmd.document_code is null then dp.asset_no
								else dm.asset_no
							end														like '%' + @p_keywords + '%'
						or	case
								when dmd.document_code is null then dp.asset_name
								else dm.asset_name
							end														like '%' + @p_keywords + '%'
						or	case
								when dmd.document_code is null then dpfam.reff_no_1
								else dmfam.reff_no_1
							end														like '%' + @p_keywords + '%'
						or	case
								when dmd.document_code is null then dpfam.reff_no_2
								else dmfam.reff_no_2
							end														like '%' + @p_keywords + '%'
						or	case
								when dmd.document_code is null then dpfam.reff_no_3
								else dmfam.reff_no_3
							end														like '%' + @p_keywords + '%'
						or	dmd.is_reject											like '%' + @p_keywords + '%'
						or	dd.doc_no										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then isnull(dm.document_type, dp.document_type)
													 when 2 then case
																	 when dmd.document_code is null then dp.asset_no
																	 else dm.asset_no
																 end
													 when 3 then case
																	 when dmd.document_code is null then dpfam.reff_no_1
																	 else dmfam.reff_no_1
																 end
													 when 4 then dd.doc_no 
													 when 5 then dmd.is_reject
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then isnull(dm.document_type, dp.document_type)
													 when 2 then case
																	 when dmd.document_code is null then dp.asset_no
																	 else dm.asset_no
																 end
													 when 3 then case
																	 when dmd.document_code is null then dpfam.reff_no_1
																	 else dmfam.reff_no_1
																 end
													 when 4 then dd.doc_no
													 when 5 then dmd.is_reject
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

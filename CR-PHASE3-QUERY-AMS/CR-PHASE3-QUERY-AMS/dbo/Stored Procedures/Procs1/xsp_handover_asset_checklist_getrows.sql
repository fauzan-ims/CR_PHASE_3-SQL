CREATE PROCEDURE dbo.xsp_handover_asset_checklist_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_handover_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		handover_asset_checklist hac
	inner join	dbo.master_bast_checklist_asset bca on (hac.checklist_code = bca.code)
	where		hac.handover_code = @p_handover_code
	and			(
					bca.checklist_name			 like '%' + @p_keywords + '%'
					or	hac.checklist_status	 like '%' + @p_keywords + '%'
					or	hac.checklist_remark	 like '%' + @p_keywords + '%'
				) ;

	select		id
				,hac.handover_code
				,hac.checklist_code
				,hac.checklist_status
				,hac.checklist_remark
				,bca.checklist_name
				,@rows_count 'rowcount'
	from		handover_asset_checklist hac
	inner join	dbo.master_bast_checklist_asset bca on (hac.checklist_code = bca.code)
	where		hac.handover_code = @p_handover_code
	and			(
					bca.checklist_name			 like '%' + @p_keywords + '%'
					or	hac.checklist_status	 like '%' + @p_keywords + '%'
					or	hac.checklist_remark	 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then bca.checklist_name
													 when 2 then hac.checklist_status
													 when 3 then hac.checklist_remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then bca.checklist_name
													 when 2 then hac.checklist_status
													 when 3 then hac.checklist_remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

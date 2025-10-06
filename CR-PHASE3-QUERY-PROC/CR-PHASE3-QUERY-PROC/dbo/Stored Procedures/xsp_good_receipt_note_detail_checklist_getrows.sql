CREATE PROCEDURE dbo.xsp_good_receipt_note_detail_checklist_getrows
(
	@p_keywords										nvarchar(50)
	,@p_pagenumber									int
	,@p_rowspage									int
	,@p_order_by									int
	,@p_sort_by										nvarchar(5)
	,@p_good_receipt_note_detail_object_info_id		int
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	good_receipt_note_detail_checklist
	where	good_receipt_note_detail_object_info_id = @p_good_receipt_note_detail_object_info_id
	and		(
				checklist_name			like '%' + @p_keywords + '%'
				or	checklist_status	like '%' + @p_keywords + '%'
				or	checklist_remark	like '%' + @p_keywords + '%'
			) ;

	select		id
				,good_receipt_note_detail_id
				,good_receipt_note_detail_object_info_id
				,checklist_code
				,checklist_name
				,checklist_status
				,checklist_remark
				,@rows_count 'rowcount'
	from		good_receipt_note_detail_checklist
	where		good_receipt_note_detail_object_info_id = @p_good_receipt_note_detail_object_info_id
	and			(
					checklist_name			like '%' + @p_keywords + '%'
					or	checklist_status	like '%' + @p_keywords + '%'
					or	checklist_remark	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then checklist_name
													 when 2 then checklist_status
													 when 3 then checklist_remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then checklist_name
													   when 2 then checklist_status
													   when 3 then checklist_remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

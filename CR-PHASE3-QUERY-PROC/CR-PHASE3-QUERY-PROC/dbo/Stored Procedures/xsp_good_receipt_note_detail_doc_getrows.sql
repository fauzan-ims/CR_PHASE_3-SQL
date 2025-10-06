CREATE PROCEDURE dbo.xsp_good_receipt_note_detail_doc_getrows
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_good_receipt_note_detail_id	int
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	good_receipt_note_detail_doc grnd
	left join dbo.sys_general_subcode sgs on (sgs.code = grnd.document_code)
	where	good_receipt_note_detail_id = @p_good_receipt_note_detail_id
	and		(
				sgs.description								like '%' + @p_keywords + '%'
				or	file_name								like '%' + @p_keywords + '%'
				or	file_path								like '%' + @p_keywords + '%'
				or	convert(varchar(30), expired_date, 103) like '%' + @p_keywords + '%'
			) ;

	select		id
				,good_receipt_note_detail_id
				,document_code
				,sgs.description 'document_name'
				,file_name
				,file_path
				,convert(varchar(30), expired_date, 103) 'expired_date'
				,@rows_count 'rowcount'
	from		good_receipt_note_detail_doc grnd
	left join dbo.sys_general_subcode sgs on (sgs.code = grnd.document_code)
	where		good_receipt_note_detail_id = @p_good_receipt_note_detail_id
	and			(
					sgs.description								like '%' + @p_keywords + '%'
					or	file_name								like '%' + @p_keywords + '%'
					or	file_path								like '%' + @p_keywords + '%'
					or	convert(varchar(30), expired_date, 103) like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sgs.description
													 when 2 then file_name
													 when 3 then file_path
													 when 4 then cast(expired_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then sgs.description
													   when 2 then file_name
													   when 3 then file_path
													   when 4 then cast(expired_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

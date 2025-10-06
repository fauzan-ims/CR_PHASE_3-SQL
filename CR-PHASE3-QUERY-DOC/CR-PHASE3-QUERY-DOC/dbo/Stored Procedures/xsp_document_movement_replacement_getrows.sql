--created by, Rian at 15/02/2023 

CREATE PROCEDURE dbo.xsp_document_movement_replacement_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_movement_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.document_movement_replacement
	where	movement_code = @p_movement_code
			and (
					document_name		like '%' + @p_keywords + '%'
					or	document_no		like '%' + @p_keywords + '%'
					or	remarks			like '%' + @p_keywords + '%'
					or	file_name		like '%' + @p_keywords + '%'
					or	paths			like '%' + @p_keywords + '%'
				) ;

	select		id
				,movement_code
				,document_name
				,document_no
				,remarks
				,file_name
				,paths
				,@rows_count 'rowcount'
	from		dbo.document_movement_replacement
	where		movement_code = @p_movement_code
				and (
						document_name		like '%' + @p_keywords + '%'
						or	document_no		like '%' + @p_keywords + '%'
						or	remarks			like '%' + @p_keywords + '%'
						or	file_name		like '%' + @p_keywords + '%'
						or	paths			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then document_name
													 when 2 then document_no
													 when 3 then remarks
													 when 4 then file_name collate Latin1_General_CI_AS
													 when 5 then paths
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then document_name
														when 2 then document_no
														when 3 then remarks
														when 4 then file_name collate Latin1_General_CI_AS
														when 5 then paths
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

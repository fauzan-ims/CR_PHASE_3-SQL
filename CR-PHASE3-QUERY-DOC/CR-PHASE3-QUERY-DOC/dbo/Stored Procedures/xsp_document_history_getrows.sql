CREATE PROCEDURE dbo.xsp_document_history_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_code			nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	document_history
	where	document_code		= @p_code
			and (
					movement_type															like '%' + @p_keywords + '%'
					or	movement_location													like '%' + @p_keywords + '%'
					or	movement_from														like '%' + @p_keywords + '%'
					or	movement_to															like '%' + @p_keywords + '%'
					or	movement_by															like '%' + @p_keywords + '%'
					or	remarks																like '%' + @p_keywords + '%'
					or	format(cast(cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
				) ;

		select		id
					,document_code
					,format(cast(cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us') 'movement_date'
					,movement_type
					,movement_location
					,movement_from
					,movement_to
					,movement_by
					,remarks
					,@rows_count 'rowcount'
		from	document_history
		where	document_code		= @p_code
				and (
						movement_type															like '%' + @p_keywords + '%'
						or	movement_location													like '%' + @p_keywords + '%'
						or	movement_from														like '%' + @p_keywords + '%'
						or	movement_to															like '%' + @p_keywords + '%'
						or	movement_by															like '%' + @p_keywords + '%'
						or	remarks																like '%' + @p_keywords + '%'
						or	format(cast(cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
					)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(cre_date as sql_variant)  
													when 2 then movement_type
													when 3 then movement_location
													when 4 then isnull(movement_from, movement_to)
													when 5 then remarks
													when 6 then movement_by
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(cre_date as sql_variant)  
														when 2 then movement_type
														when 3 then movement_location
														when 4 then isnull(movement_from, movement_to)
														when 5 then remarks
														when 6 then movement_by
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

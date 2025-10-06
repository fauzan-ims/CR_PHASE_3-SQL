CREATE PROCEDURE dbo.xsp_application_survey_document_getrows
(
	@p_keywords	     nvarchar(50)
	,@p_pagenumber   int
	,@p_rowspage     int
	,@p_order_by     int
	,@p_sort_by	     nvarchar(5)
	--
	,@p_application_survey_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_survey_document 
	where	application_survey_code = @p_application_survey_code
	and		(
					id							like '%' + @p_keywords + '%'
					or location					like '%' + @p_keywords + '%'
					or remark					like '%' + @p_keywords + '%'
					or file_name				like '%' + @p_keywords + '%'
					or paths					like '%' + @p_keywords + '%'
			) ;

		select		id
				   ,application_survey_code
				   ,location
				   ,remark
				   ,file_name
				   ,paths
					,@rows_count 'rowcount'
		from		application_survey_document
		where	application_survey_code = @p_application_survey_code
		and		(
					id							like '%' + @p_keywords + '%'
					or location					like '%' + @p_keywords + '%'
					or remark					like '%' + @p_keywords + '%'
					or file_name				like '%' + @p_keywords + '%'
					or paths					like '%' + @p_keywords + '%'
				)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then location
													when 2 then remark
													when 3 then file_name
														
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then location
														when 2 then remark
														when 3 then file_name		
																
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


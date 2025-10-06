CREATE PROCEDURE [dbo].[xsp_sys_general_document_lookup_for_document_group]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_document_group_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	DECLARE @a TABLE (a NVARCHAR(50))
	INSERT INTO @a
	(
	    a
	)
		select	s.document_name	
		from	dbo.master_selling_attachment_group_detail d
				inner join dbo.sys_general_document s on (s.code = d.general_doc_code)
		where	document_group_code = @p_document_group_code

	select	@rows_count = count(1)
	from	dbo.sys_general_document
	where	code not in (select document_code from dbo.sys_document_group_detail where document_group_code = @p_document_group_code)
	and		is_active = '1'
	AND		DOCUMENT_NAME NOT IN (SELECT * FROM @a)
	and			(
					code							like '%' + @p_keywords + '%'
					or	document_name				like '%' + @p_keywords + '%'
				) ;

		select		code
					,document_name 'description'
					,@rows_count 'rowcount'
		from		dbo.sys_general_document
		where		code not in (select document_code from dbo.sys_document_group_detail where document_group_code = @p_document_group_code)
		and			is_active = '1'
		AND			DOCUMENT_NAME NOT IN (SELECT * FROM @a)
		and				(
							code							like '%' + @p_keywords + '%'
							or	document_name				like '%' + @p_keywords + '%'
						)
		order by	case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then document_name
												 end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then code
															when 2 then document_name
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;


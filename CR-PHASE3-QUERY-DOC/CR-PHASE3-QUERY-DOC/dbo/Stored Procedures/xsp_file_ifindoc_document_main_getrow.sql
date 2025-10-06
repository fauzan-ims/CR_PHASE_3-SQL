CREATE procedure dbo.xsp_file_ifindoc_document_main_getrow
(
	@p_doc_no	  nvarchar(50)
	,@p_module	  nvarchar(15)
	,@p_file_name nvarchar(250)
)
as
begin
	declare @query nvarchar(max) ;

	set @query = N'
	select	module
			,doc_type
			,doc_no
			,doc_name
			,doc_file
			,columntoswfinalresult
			,doc_date
	from ' + 'file_' + @p_module + '_document_main' + ' cross apply
	(
		select	doc_file ''*''
		for xml path('''')
	) t(columntoswfinalresult)
	where	doc_no = ''' + @p_doc_no + ''' and doc_name = ''' + @p_file_name + '''' ;

	execute sp_executesql @query ;
end ;

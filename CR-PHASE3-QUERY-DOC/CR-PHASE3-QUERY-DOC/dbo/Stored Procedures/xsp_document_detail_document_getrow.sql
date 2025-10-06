create procedure dbo.xsp_document_detail_document_getrow
(
	@p_file_name nvarchar(250)
)
as
begin
	select	id
			,document_code
			,file_name
			,paths
			,doc_file
			,columntoswfinalresult --harus di index ke 5 karena dari api blm bisa membaca indexnya  
	from	document_detail
			cross apply
	(
		select	doc_file '*'
		for xml path('')
	) t(columntoswfinalresult)
	where	file_name = @p_file_name ;
end ;

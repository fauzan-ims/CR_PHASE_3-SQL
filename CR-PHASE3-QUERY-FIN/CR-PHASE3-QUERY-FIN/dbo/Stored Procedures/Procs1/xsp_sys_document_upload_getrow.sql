CREATE procedure [dbo].[xsp_sys_document_upload_getrow]
(
	@p_file_name nvarchar(250)
)
as
begin
	select	id
			,reff_no
			,reff_name
			,reff_trx_code
			,file_name
			,fileDocResult 'doc_file'
	from	sys_document_upload
			cross apply
	(
		select	doc_file '*'
		for xml path('')
	) t(fileDocResult)
	where	file_name = @p_file_name ;
end ;

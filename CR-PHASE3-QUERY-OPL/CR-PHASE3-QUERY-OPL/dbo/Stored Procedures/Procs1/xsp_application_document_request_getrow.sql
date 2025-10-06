CREATE PROCEDURE [dbo].[xsp_application_document_request_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	adr.code
			,adr.application_no
			,cm.client_name
			,adr.request_status
			,adr.request_date
			,adr.request_by
			,adr.document_code
			,adr.result_date
			,adr.file_name
			,adr.paths
			,sgd.document_name
			,am.application_status
			,am.level_status
	from	application_document_request adr
			left join dbo.application_main am on (am.application_no = adr.application_no)
			left join dbo.client_main cm on (cm.code				 = am.client_code)
			left join dbo.sys_general_document sgd on (sgd.code	 = adr.document_code)
	where	adr.code = @p_code ;
end ;


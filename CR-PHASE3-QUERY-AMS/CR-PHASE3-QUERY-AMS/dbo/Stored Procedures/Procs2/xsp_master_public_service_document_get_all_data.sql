CREATE PROCEDURE dbo.xsp_master_public_service_document_get_all_data
(
	@p_code NVARCHAR(50)
)
as
begin
	select	document_code
	from	master_public_service_document
	where	PUBLIC_SERVICE_CODE = @p_code ;
end ;

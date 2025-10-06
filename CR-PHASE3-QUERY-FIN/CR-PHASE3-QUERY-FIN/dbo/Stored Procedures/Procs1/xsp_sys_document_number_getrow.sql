CREATE PROCEDURE dbo.xsp_sys_document_number_getrow
(
	@p_code			nvarchar(50)
) 
AS
begin

	select	code
			,code_document
			,description
	from	sys_document_number
	where	code	= @p_code
end

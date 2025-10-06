CREATE PROCEDURE [dbo].[xsp_additional_document_getrow]
(
	@p_id bigint
)
as
begin
	select	id
		   ,document_code
		   ,document_name
		   ,document_description
		   ,isnull(file_name,'')'file_name' 
		   ,ISNULL(paths,'')'paths'
		   ,expired_date
		   ,is_temporary
		   ,is_manual
	from	document_detail 
	where	id = @p_id ;
end ;

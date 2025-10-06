CREATE PROCEDURE dbo.xsp_adjustment_document_getrow
(
	@p_id bigint
)
as
begin
	select	file_name
			,path
			,description
	from	dbo.adjustment_document
	where	id = @p_id ;
end ;

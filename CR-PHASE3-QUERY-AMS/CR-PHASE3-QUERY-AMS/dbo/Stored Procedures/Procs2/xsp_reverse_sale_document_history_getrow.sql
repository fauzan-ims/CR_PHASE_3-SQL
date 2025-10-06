CREATE PROCEDURE dbo.xsp_reverse_sale_document_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,reverse_sale_code
			,file_name
			,path
			,description
	from	reverse_sale_document
	where	id = @p_id ;
end ;

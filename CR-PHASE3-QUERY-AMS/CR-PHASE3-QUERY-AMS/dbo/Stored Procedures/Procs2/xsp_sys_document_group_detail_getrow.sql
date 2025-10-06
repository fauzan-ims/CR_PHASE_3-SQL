create procedure dbo.xsp_sys_document_group_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,document_group_code
			,document_code
	from	sys_document_group_detail
	where	id = @p_id ;
end ;

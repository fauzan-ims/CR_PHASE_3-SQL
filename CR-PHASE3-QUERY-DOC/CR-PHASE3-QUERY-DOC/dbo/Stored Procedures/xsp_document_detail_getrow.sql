CREATE PROCEDURE dbo.xsp_document_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,document_code
			,document_name
			,document_type
			,document_date
			,document_description
			,file_name
			,paths
			,expired_date
			,is_temporary
			,is_manual
			,sgs.description
	from	document_detail dd
			left join dbo.sys_general_subcode sgs on (sgs.code = dd.document_type)
	where	id = @p_id ;
end ;

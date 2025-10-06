CREATE PROCEDURE [dbo].[xsp_client_doc_getrow]
(
	@p_id bigint
)
as
begin
	select	cd.id
			,cd.client_code
			,cd.doc_type_code
			,cd.document_no
			,cd.document_no 'document_no_taxid'
			,cd.doc_status
			,cd.eff_date
			,cd.exp_date
			,cd.is_default
			,sgs.description 'doc_type_desc'
			,is_existing_client
	from	client_doc cd
			inner join dbo.client_main cm on (cm.code			= cd.client_code)
			inner join dbo.sys_general_subcode sgs on (sgs.code = cd.doc_type_code)
	where	id = @p_id ;
end ;


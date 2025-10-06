CREATE procedure [dbo].[xsp_client_corporate_notarial_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	ccn.code
			,ccn.client_code
			,ccn.notarial_document_code
			,ccn.document_no
			,ccn.document_date
			,ccn.notary_name
			,ccn.skmenkumham_doc_no
			,ccn.suggest_by
			,ccn.modal_dasar
			,ccn.modal_setor
			,sgs.description 'notarial_document_desc'
	from	client_corporate_notarial ccn
			inner join dbo.sys_general_subcode sgs on (sgs.code = ccn.notarial_document_code)
	where	ccn.code = @p_code ;
end ;


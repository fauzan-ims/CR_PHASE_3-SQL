create procedure xsp_doc_interface_document_pending_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,request_branch_code
			,request_branch_name
			,general_document_code
			,document_status
			,document_expired_date
			,file_name
			,paths
			,agreement_no
			,collateral_no
			,asset_no
			,process_date
			,process_reff_no
			,process_reff_name
	from	doc_interface_document_pending
	where	code = @p_code ;
end ;

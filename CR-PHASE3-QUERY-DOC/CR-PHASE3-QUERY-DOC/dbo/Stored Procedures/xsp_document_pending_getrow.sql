CREATE PROCEDURE dbo.xsp_document_pending_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,initial_branch_code
			,initial_branch_name
			,cover_note_no
			,cover_note_date
			,cover_note_exp_date
			,document_type
			,document_status
			,asset_no
			,asset_name
			,entry_date
	from	document_pending
	where	code = @p_code ;
end ;


CREATE procedure [dbo].[xsp_application_doc_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,application_no
			,document_code
			,filename
			,paths
			,expired_date
			,promise_date
			,is_required
	from	application_doc
	where	id = @p_id ;
end ;


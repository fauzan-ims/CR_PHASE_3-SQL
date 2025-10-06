
CREATE PROCEDURE [dbo].[xsp_application_asset_doc_getrow]
(
	@p_id			  bigint
	,@p_asset_no nvarchar(50)
)
as
begin
	select	id
			,asset_no
			,document_code
			,filename
			,paths
			,expired_date
			,promise_date
			,is_required
	from	application_asset_doc
	where	id				  = @p_id
			and asset_no = @p_asset_no ;
end ;


CREATE PROCEDURE [dbo].[xsp_application_asset_doc_getrows_for_delete]
(
	@p_asset_no nvarchar(50)
)
as
begin
	declare @document_group_code	nvarchar(50);

	exec dbo.xsp_dimension_get_data_match @p_code					= @document_group_code OUTPUT,     
		                                    @p_reff_tabel_dimension	= N'MASTER_DOCUMENT_GROUP', 
		                                    @p_reff_no				= @p_asset_no,             
		                                    @p_reff_tabel_type		= 'DGASSET',    
											@p_reff_from_table		= 'APPLICATION_ASSET'
	select	pd.id
			,pd.document_code
			,pd.paths
	from	dbo.application_asset_doc pd
	where	pd.asset_no = @p_asset_no
			and pd.document_code not in
				(
					select	dgd.general_doc_code
					from	dbo.master_document_group_detail dgd
					where	dgd.document_group_code	= @document_group_code
				) ;
end ;


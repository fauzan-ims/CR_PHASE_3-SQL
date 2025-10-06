CREATE PROCEDURE dbo.xsp_application_doc_getrows_for_delete
(
	@p_application_no nvarchar(50)
)
as
begin
	declare @document_group_code	nvarchar(50);
	
	exec dbo.xsp_dimension_get_data_match @p_code					= @document_group_code OUTPUT,      
		                                    @p_reff_tabel_dimension	= N'MASTER_DOCUMENT_GROUP',
		                                    @p_reff_no				= @p_application_no,             
		                                    @p_reff_tabel_type		= 'DGAPPLICATION',
											@p_reff_from_table		= 'APPLICATION_MAIN'	
	select	pcd.id
			,pcd.document_code
			,pcd.paths
			,pcd.filename
	from	dbo.application_doc pcd
	where	pcd.application_no = @p_application_no
			and pcd.document_code not in
				(
					select	dgd.general_doc_code
					from	dbo.master_document_group_detail dgd
					where	dgd.document_group_code	= @document_group_code
				) ;
end ;


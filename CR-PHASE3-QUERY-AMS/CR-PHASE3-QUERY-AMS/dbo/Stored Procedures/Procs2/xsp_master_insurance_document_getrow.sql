CREATE PROCEDURE dbo.xsp_master_insurance_document_getrow
(
	@p_file_name nvarchar(250)
)
as
begin
	select	id
			,insurance_code
			,document_code
			,document_name
			,doc_file 
			,columntoswfinalresult--harus di index ke 5 karena dari api blm bisa membaca indexnya
			,file_name
			,paths
			,expired_date
	from	master_insurance_document cross apply
	(
		select	doc_file '*'
		for xml path('')
	) t(columntoswfinalresult)
	where	file_name = @p_file_name ;
end ;



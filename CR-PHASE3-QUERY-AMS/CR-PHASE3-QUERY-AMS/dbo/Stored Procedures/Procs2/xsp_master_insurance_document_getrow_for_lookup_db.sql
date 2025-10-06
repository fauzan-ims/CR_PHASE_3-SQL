CREATE PROCEDURE dbo.xsp_master_insurance_document_getrow_for_lookup_db
(
	@p_insurance_code nvarchar(50)
)
as
begin
	select		id
				,document_code
				,document_name
	from		dbo.master_insurance_document
	where	insurance_code = @p_insurance_code ;
end ;


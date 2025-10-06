CREATE PROCEDURE [dbo].[xsp_application_document_contract_getrow]	
(
	@p_application_no		   nvarchar(50)
)
as
begin

	select	application_no
			,document_contract_code
			,filename
			,paths
			,print_count
			,last_print_date
			,last_print_by
	from	application_document_contract
	where	application_no			   = @p_application_no;
end ;


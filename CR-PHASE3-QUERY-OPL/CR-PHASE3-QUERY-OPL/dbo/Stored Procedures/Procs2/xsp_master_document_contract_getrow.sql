
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_document_contract_getrow
(
	@p_code			nvarchar(50)
) as
begin

	select		code
				,description
				,document_type
				,template_name
				,rpt_name
				,sp_name
				,table_name
	from	master_document_contract
	where	code	= @p_code
end


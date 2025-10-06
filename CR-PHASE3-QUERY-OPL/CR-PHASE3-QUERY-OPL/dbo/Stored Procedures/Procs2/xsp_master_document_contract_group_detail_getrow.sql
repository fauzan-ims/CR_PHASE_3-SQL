

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_document_contract_group_detail_getrow
(
	@p_id							 bigint
	,@p_document_contract_group_code nvarchar(50)
)
as
begin
	select	id
			,document_contract_group_code
			,document_contract_code
	from	master_document_contract_group_detail
	where	id								 = @p_id
			and document_contract_group_code = @p_document_contract_group_code ;
end ;


CREATE PROCEDURE dbo.xsp_ifinproc_interface_document_pending_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select id
		  ,code
		  ,branch_code
		  ,branch_name
		  ,initial_branch_code
		  ,initial_branch_name
		  ,document_type
		  ,document_status
		  ,client_no
		  ,client_name
		  ,plafond_no
		  ,agreement_no
		  ,collateral_no
		  ,collateral_name
		  ,plafond_collateral_no
		  ,plafond_collateral_name
		  ,asset_no
		  ,asset_name
		  ,plat_no
		  ,chasis_no
		  ,engine_no
		  ,vendor_code
		  ,vendor_name
		  ,entry_date
	from dbo.ifinproc_interface_document_pending
	where code = @p_code
end ;

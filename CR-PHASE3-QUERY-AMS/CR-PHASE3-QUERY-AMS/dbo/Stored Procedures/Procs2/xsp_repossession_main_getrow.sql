CREATE PROCEDURE dbo.xsp_repossession_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	rmn.code
			,rmn.branch_code
			,rmn.branch_name
			,rmn.bast_code
			,rmn.repossession_status
			,rmn.repossession_status_process
			,rmn.bast_type
			,rmn.asset_code
			,rmn.item_name
			,rmn.asset_category_code
			,rmn.asset_category_name
			,rmn.exit_status
			,rmn.exit_date
			,rmn.repo_i_date
			,rmn.repo_ii_date
			,rmn.inventory_date
			,rmn.wo_date
			,rmn.back_to_current_date
			,rmn.purchase_date
			,rmn.fa_date
			,rmn.extension_count
			,rmn.estimate_repoii_date
			,rmn.warehouse_code
			,ast.location_name
			,rmn.warehouse_external_name
			,rmn.pricing_amount
			,rmn.is_permit_to_sell
			,rmn.permit_sell_remarks
			,rmn.sell_request_amount
			,rmn.sold_amount
			,rmn.is_remedial
			,rmn.overdue_period
			,rmn.overdue_days
			,rmn.overdue_penalty
			,rmn.overdue_installment
			,rmn.outstanding_installment
			,rmn.outstanding_deposit
			,rmn.status
	from	repossession_main rmn
			inner join dbo.ASSET ast on (ast.CODE = rmn.ASSET_CODE)
	where	rmn.code = @p_code ;
end ;

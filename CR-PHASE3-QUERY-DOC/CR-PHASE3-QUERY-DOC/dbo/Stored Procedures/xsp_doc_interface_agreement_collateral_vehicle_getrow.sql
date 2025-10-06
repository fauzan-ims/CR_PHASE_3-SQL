CREATE PROCEDURE dbo.xsp_doc_interface_agreement_collateral_vehicle_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,agreement_no
			,collateral_no
			,plafond_no
			,plafond_collateral_no
			,remarks
			,bpkb_no
			,bpkb_date
			,bpkb_name
			,bpkb_address
			,stnk_name
			,stnk_exp_date
			,stnk_tax_date
	from	doc_interface_agreement_collateral_vehicle
	where	id = @p_id ;
end ;

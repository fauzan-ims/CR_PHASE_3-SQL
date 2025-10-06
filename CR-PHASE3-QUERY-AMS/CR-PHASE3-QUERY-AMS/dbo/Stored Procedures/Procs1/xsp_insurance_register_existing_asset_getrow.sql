CREATE PROCEDURE dbo.xsp_insurance_register_existing_asset_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,register_code
			,fa_code
			,sum_insured_amount
			,coverage_code
			,premi_sell_amount
	from	insurance_register_existing_asset
	where	id = @p_id ;
end ;

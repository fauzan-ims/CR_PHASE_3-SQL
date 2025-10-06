CREATE PROCEDURE [dbo].[xsp_master_insurance_fee_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,insurance_code
			,eff_date
			,admin_fee_buy_amount
			,admin_fee_sell_amount
			,stamp_fee_amount
			,currency_code
	from	master_insurance_fee 
	where	id = @p_id ;
end ;



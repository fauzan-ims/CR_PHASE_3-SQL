
CREATE procedure [dbo].[xsp_application_pdc_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,application_code
			,pdc_no
			,pdc_date
			,pdc_bank_code
			,pdc_bank_name
			,pdc_allocation_type
			,pdc_currency_code
			,pdc_value_amount
			,pdc_inkaso_fee_amount
			,pdc_clearing_fee_amount
			,pdc_amount
	from	application_pdc
	where	id = @p_id ;
end ;


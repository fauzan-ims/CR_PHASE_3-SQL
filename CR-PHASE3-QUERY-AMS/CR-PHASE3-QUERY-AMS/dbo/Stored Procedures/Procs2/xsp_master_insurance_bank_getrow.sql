
CREATE procedure [dbo].[xsp_master_insurance_bank_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,insurance_code
			,currency_code
			,bank_code
			,bank_name
			,bank_branch
			,bank_account_no
			,bank_account_name
			,is_default
	from	master_insurance_bank
	where	id = @p_id ;
end ;



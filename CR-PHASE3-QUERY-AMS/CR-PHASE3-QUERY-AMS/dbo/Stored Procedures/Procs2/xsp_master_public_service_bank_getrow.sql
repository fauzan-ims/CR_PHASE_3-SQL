create PROCEDURE dbo.xsp_master_public_service_bank_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,public_service_code
			,currency_code
			,bank_code
			,bank_name
			,bank_branch
			,bank_account_no
			,bank_account_name
			,is_default
	from	master_public_service_bank
	where	id = @p_id ;
end ;

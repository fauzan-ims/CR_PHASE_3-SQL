CREATE procedure [dbo].[xsp_client_bank_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,client_code
			,currency_code
			,bank_code
			,bank_name
			,bank_branch
			,bank_account_no
			,bank_account_name
			,is_default
			,is_auto_debet_bank
	from	client_bank
	where	code = @p_code ;
end ;


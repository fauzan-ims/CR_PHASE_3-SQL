
create procedure xsp_suspend_reversal_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,reversal_status
			,reversal_date
			,reversal_amount
			,reversal_remarks
			,reversal_bank_name
			,reversal_bank_account_no
			,reversal_bank_account_name
			,suspend_code
			,suspend_currency_code
			,suspend_amount
	from	suspend_reversal
	where	code = @p_code ;
end ;

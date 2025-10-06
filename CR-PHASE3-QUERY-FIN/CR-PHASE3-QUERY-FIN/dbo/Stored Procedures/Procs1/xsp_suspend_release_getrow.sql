
CREATE procedure xsp_suspend_release_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,release_status
			,release_date
			,release_amount
			,release_remarks
			,release_bank_name
			,release_bank_account_no
			,release_bank_account_name
			,suspend_code
			,suspend_currency_code
			,suspend_amount
	from	suspend_release
	where	code = @p_code ;
end ;

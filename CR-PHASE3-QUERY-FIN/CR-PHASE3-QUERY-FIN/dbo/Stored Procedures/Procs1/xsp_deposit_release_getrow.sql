CREATE PROCEDURE dbo.xsp_deposit_release_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare	@count	int;
	
	select @count = count(1) 
	from	dbo.deposit_release_detail
	where	deposit_release_code = @p_code

	select	dr.code
			,dr.branch_code
			,dr.branch_name
			,dr.release_status
			,dr.release_date
			,dr.release_amount
			,dr.release_remarks
			,dr.release_bank_name
			,dr.release_bank_account_no
			,dr.release_bank_account_name
			,dr.agreement_no
			,dr.currency_code
			,am.agreement_external_no
			,am.client_name
			,@count 'count'
	from	deposit_release dr
			inner join dbo.agreement_main am on (am.agreement_no = dr.agreement_no)
	where	dr.code = @p_code ;
end ;

--created by, Rian at 18/03/2023	

CREATE procedure xsp_agreement_asset_interest_income_getrow
(
	@p_agreement_no nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	select	aii.agreement_no
			,aii.asset_no
			,aas.asset_name
			,aas.asset_year
			,aas.asset_condition
			,aii.installment_no
			,aii.invoice_no
			,aii.branch_code
			,aii.branch_name
			,convert(nvarchar(30), aii.transaction_date, 103) 'transaction_date'
			,aii.income_amount
			,aii.reff_no
			,aii.reff_name
	from	dbo.agreement_asset_interest_income aii
			left join dbo.AGREEMENT_ASSET aas on (aas.ASSET_NO = aii.ASSET_NO)
	where	aii.agreement_no = @p_agreement_no
			and aii.asset_no = @p_asset_no ;
end ;

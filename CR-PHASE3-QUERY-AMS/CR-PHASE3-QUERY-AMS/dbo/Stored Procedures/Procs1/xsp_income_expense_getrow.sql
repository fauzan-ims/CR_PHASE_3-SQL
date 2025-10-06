CREATE PROCEDURE dbo.xsp_income_expense_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	isnull(income.income_amount, 0)										 'income_amount'
			,isnull(expense.expense_amount, 0)									 'expense_amount'
			,isnull(income.income_amount, 0) - isnull(expense.expense_amount, 0) 'gain_loss'
			,ass.purchase_price
	from	dbo.asset ass
			outer apply
	(
		select	sum(isnull(ail.income_amount, 0)) 'income_amount'
		from	dbo.asset_income_ledger ail
		where	ail.asset_code = ass.code
	)				  income
			outer apply
	(
		select	sum(isnull(expense_amount, 0)) 'expense_amount'
		from	dbo.asset_expense_ledger ael
		where	ael.asset_code = ass.code
	) expense
	where	ass.code = @p_asset_code ;
end ;

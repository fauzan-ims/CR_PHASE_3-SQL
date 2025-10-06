create procedure dbo.xsp_maturity_amortization_history_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select maturity_code
		  ,installment_no
		  ,asset_no
		  ,due_date
		  ,billing_date
		  ,billing_amount
		  ,description
		  ,old_or_new
		  ,cre_date
		  ,cre_by
		  ,cre_ip_address
		  ,mod_date
		  ,mod_by
		  ,mod_ip_address from dbo.maturity_amortization_history
	where	maturity_code = @p_code ;
end ;

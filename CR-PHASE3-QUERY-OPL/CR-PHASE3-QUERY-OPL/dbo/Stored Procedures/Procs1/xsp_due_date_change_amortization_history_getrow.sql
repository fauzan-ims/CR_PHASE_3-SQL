--created by, Rian at 08/05/2023 

CREATE procedure xsp_due_date_change_amortization_history_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	due_date_change_code
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
			,mod_ip_address
	from	dbo.due_date_change_amortization_history
	where	due_date_change_code = @p_code ;
end ;

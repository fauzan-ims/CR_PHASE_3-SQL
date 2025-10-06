CREATE procedure dbo.[xsp_cashier_transaction_for_reversal_suspend]
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@status						nvarchar(max)
			,@remaining_amount			decimal(18, 2)
				
		select @remaining_amount = remaining_amount 
		from suspend_main
		where reff_no = @p_code

		if exists (select 1 from dbo.cashier_transaction_detail where cashier_transaction_code = @p_code and orig_amount > @remaining_amount)
		begin
			set @status = 'Suspend amount is already used';
		end
		else
		begin
			set @status = '';
		end

		select @status 'status'

end



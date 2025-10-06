CREATE PROCEDURE dbo.xsp_account_transfer_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	at.code
			,at.transfer_status
			,at.transfer_trx_date
			,at.transfer_value_date
			,at.transfer_remarks
			,isnull(at.cashier_code,'') 'cashier_code'
			,at.cashier_amount
			,at.from_branch_code
			,at.from_branch_name
			,at.from_currency_code
			,at.from_branch_bank_code
			,at.from_branch_bank_name
			,at.from_gl_link_code
			,at.from_exch_rate
			,at.from_orig_amount
			,at.to_branch_code
			,at.to_branch_name
			,at.to_currency_code
			,at.to_branch_bank_code
			,at.to_branch_bank_name
			,at.to_gl_link_code
			,at.to_exch_rate
			,at.to_orig_amount
			,case isnull(at.is_from,'')
						when '1' then '1'
						when '0' then '2'
						else case isnull(cm.cashier_status,'')
								when 'OPEN' then '1'
								when 'ON PROCESS' then '2'
								else ''
							END
			END  'iscashier'
			--,case isnull(cm.cashier_status,'')
			--		when 'OPEN' then '1'
			--		when 'ON PROCESS' then '2'
			--		else ''
			-- end 'iscashier'
	from	account_transfer at
			left join dbo.cashier_main cm on (cm.code = at.cashier_code)
	where	at.code = @p_code ;
end ;

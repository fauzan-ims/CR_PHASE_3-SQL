create procedure dbo.xsp_fin_interface_account_transfer_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	at.id
            ,at.code
            ,at.transfer_trx_date
            ,at.transfer_value_date
            ,at.transfer_remarks
            ,at.transfer_source_no
            ,at.transfer_source
            ,at.transfer_status
            ,at.from_branch_code
            ,at.from_branch_name
            ,at.from_currency_code
            ,at.from_exch_rate
            ,at.from_orig_amount
            ,at.from_branch_bank_code
            ,at.from_branch_bank_name
            ,at.from_gl_link_code
            ,at.to_branch_code
            ,at.to_branch_name
            ,at.to_currency_code
            ,at.to_exch_rate
            ,at.to_orig_amount
            ,at.to_branch_bank_code
            ,at.to_branch_bank_name
            ,at.to_gl_link_code
            ,at.job_status
            ,at.failed_remarks
	from	dbo.fin_interface_account_transfer at
	where	at.code = @p_code ;
end ;

CREATE procedure [dbo].[xsp_write_off_recovery_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	wor.code
			,wor.branch_code
			,wor.branch_name
			,wor.recovery_status
			,wor.recovery_date
			,wor.wo_amount
			,wor.wo_recovery_amount
			,wor.recovery_amount
			,wor.recovery_remarks
			,wor.agreement_no
			,wor.received_request_code
			,wor.received_voucher_no
			,wor.received_voucher_date 
			,wor.process_reff_no
			,wor.process_reff_name
			,wor.process_date
			,am.agreement_external_no
			,am.client_name
	from	write_off_recovery wor
			inner join dbo.agreement_main am on (am.agreement_no = wor.agreement_no)
	where	wor.code = @p_code ;
end ;


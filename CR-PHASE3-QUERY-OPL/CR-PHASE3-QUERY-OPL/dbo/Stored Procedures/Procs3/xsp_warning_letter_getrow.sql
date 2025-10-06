CREATE PROCEDURE dbo.xsp_warning_letter_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	wl.code
			,wl.branch_code
			,wl.branch_name
			,case wl.letter_status
					 when 'HOLD' then 'POST'
					 when 'CANCEL' then 'CANCEL'
					 when 'REQUEST' then 'REQUEST'
				 end 	'letter_status'
			--,wl.letter_status
			,wl.letter_date
			,wl.letter_no
			,wl.letter_type
			,wl.agreement_no
			,wl.max_print_count
			,wl.print_count
			,wl.last_print_by
			,wl.generate_type
			,wl.previous_letter_code
			,wl.installment_amount
			,wl.overdue_days
			,wl.overdue_penalty_amount
			,wl.overdue_installment_amount
			,wl.received_by
			,wl.received_date
			,wl.client_no
			,wl.client_name
			,am.agreement_external_no
			,wl.installment_no
	from	warning_letter wl
			left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
	where	wl.code = @p_code ;
end ;

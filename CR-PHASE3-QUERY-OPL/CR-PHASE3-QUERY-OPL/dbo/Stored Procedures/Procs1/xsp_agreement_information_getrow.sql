CREATE PROCEDURE dbo.xsp_agreement_information_getrow
(
	@p_agreement_no			nvarchar(50)
) 
as
begin

	select	agreement_no
		   ,deskcoll_staff_code
		   ,deskcoll_staff_name
		   ,installment_amount
		   ,installment_due_date
		   ,next_due_date
		   ,last_paid_period
		   ,ovd_period
		   ,ovd_days
		   ,ovd_rental_amount
		   ,ovd_penalty_amount
		   ,os_rental_amount
		   ,os_deposit_installment_amount
		   ,os_period
		   ,last_payment_installment_date
		   ,last_payment_obligation_date
		   ,payment_promise_date
	from	dbo.agreement_information
	where	agreement_no	= @p_agreement_no

end

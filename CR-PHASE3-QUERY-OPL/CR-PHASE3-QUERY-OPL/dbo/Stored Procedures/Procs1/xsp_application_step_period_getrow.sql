CREATE PROCEDURE [dbo].[xsp_application_step_period_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	asp.code
			,asp.application_no
			,asp.step_no
			,asp.recovery_flag
			,asp.recovery_principal_amount
			,asp.recovery_installment_amount
			,asp.even_method
			,asp.payment_schedule_type_code
			,asp.number_of_installment
			,mps.description 'payment_schedule_type_desc'
	from	application_step_period asp
			left join dbo.master_payment_schedule mps on (mps.code = asp.payment_schedule_type_code)
	where	asp.code = @p_code ;
end ;


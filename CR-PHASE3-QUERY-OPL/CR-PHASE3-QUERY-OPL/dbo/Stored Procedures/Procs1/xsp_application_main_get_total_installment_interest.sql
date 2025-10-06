CREATE procedure [dbo].[xsp_application_main_get_total_installment_interest]
(
	@p_application_no	   nvarchar(50)
)
as
begin

	select	sum(loan_amount)
	from	dbo.application_main
	where	application_no = @p_application_no ;
end;


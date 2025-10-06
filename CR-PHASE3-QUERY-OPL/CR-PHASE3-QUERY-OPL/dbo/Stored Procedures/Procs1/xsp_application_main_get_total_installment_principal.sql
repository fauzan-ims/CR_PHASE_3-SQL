CREATE procedure [dbo].[xsp_application_main_get_total_installment_principal]
(
	@p_application_no	   nvarchar(50)
)
as
begin
	select	sum(capitalize_amount)
	from	dbo.application_main
	where	application_no = @p_application_no ;
end;


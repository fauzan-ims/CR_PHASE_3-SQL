CREATE PROCEDURE [dbo].[xsp_application_main_get_total_installment]
(
	@p_application_no	   nvarchar(50)
)
as
begin

	select	DP_AMOUNT
	from	dbo.application_main
	where	application_no = @p_application_no ;
end;


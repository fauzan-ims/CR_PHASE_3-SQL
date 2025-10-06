CREATE PROCEDURE [dbo].[xsp_stop_billing_getrow]
(
	@p_code			nvarchar(50)
) 
as
begin

	select	code
		   ,sb.branch_code
		   ,sb.branch_name
		   ,sb.agreement_no
		   ,am.agreement_external_no
		   ,status
		   ,date
		   ,remarks
		   ,am.client_name
	from	dbo.stop_billing sb
			inner join dbo.agreement_main am on (am.agreement_no = sb.agreement_no)
	where	code = @p_code
end

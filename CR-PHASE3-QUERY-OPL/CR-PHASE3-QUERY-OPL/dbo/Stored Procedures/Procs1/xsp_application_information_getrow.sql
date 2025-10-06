CREATE PROCEDURE [dbo].[xsp_application_information_getrow]
(
	@p_application_no nvarchar(50)
)
as
begin
	declare @total_refund		decimal(18, 2)
			,@total_distributed decimal(18, 2) ;

	select	@total_refund = isnull(sum(refund_amount), 0)
	from	dbo.application_refund
	where	application_no = @p_application_no ;

	select	@total_distributed = isnull(sum(ard.distribution_amount), 0)
	from	dbo.application_refund_distribution ard
			inner join dbo.application_refund ar on (ar.code = ard.application_refund_code)
	where	application_no = @p_application_no ;

	select	ai.application_no
			,ai.workflow_step
			,ai.application_flow_code
			,ai.screen_flow_code
			,ai.is_refunded
			,ai.interest_for_first_duedate_amount
			,ai.group_limit_amount
			,ai.os_exposure_amount
			,am.vendor_code
			,case ai.is_refunded
				 when '1' then 'Yes'
				 else 'No'
			 end 'is_refundeds'
			,@total_refund 'total_refund'
			,@total_distributed 'total_distributed'
	from	dbo.application_information ai
			inner join dbo.application_main am on (am.application_no = ai.application_no)
	where	ai.application_no = @p_application_no ;
end ;


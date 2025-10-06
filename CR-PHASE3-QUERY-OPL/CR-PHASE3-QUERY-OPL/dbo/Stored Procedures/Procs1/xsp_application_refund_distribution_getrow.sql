CREATE procedure [dbo].[xsp_application_refund_distribution_getrow]
(
	@p_id bigint
)
as
begin
	select	ard.id
			,ard.application_refund_code
			,ard.staff_position_code
			,ard.staff_position_name
			,ard.staff_code
			,ard.staff_name
			,ard.refund_pct
			,ard.distribution_amount
			,ar.refund_amount
			,am.vendor_code
			,am.agent_code
	from	application_refund_distribution ard
			inner join dbo.application_refund ar on (ar.code		 = ard.application_refund_code)
			inner join dbo.application_main am on (am.application_no = ar.application_no)
	where	ard.id = @p_id ;
end ;


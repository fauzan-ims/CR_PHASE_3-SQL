CREATE procedure dbo.xsp_workflow_input_result_getrow
(
	@p_reff_code nvarchar(50)
)
as
begin
	select	code
			,flow_type
			,reff_code
			,recommendation_status
			,cp_remarks
			,ca_remarks
			,ca_capacity
			,ca_capital
			,ca_condition
			,ca_collateral
			,ca_constraints
			,po_remarks
			,printing_remarks
			,signer_remarks
			,fc_receive_date
			,fc_received_by
			,fc_received_by_relation
			,fc_date_installment
			,fc_unit_condition
			,fc_remarks
			,am.level_status
	from	dbo.workflow_input_result wir
			inner join dbo.application_main am on (am.application_no = wir.reff_code)
	where	reff_code		 = @p_reff_code
			and wir.mod_date >
			(
				select	max(cre_date)
				from	dbo.application_log
				where	application_no = @p_reff_code
			) ;
end ;

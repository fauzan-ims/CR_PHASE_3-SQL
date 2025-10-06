
CREATE procedure [dbo].[xsp_insurance_policy_main_history_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,policy_code
			,history_date
			,history_type
			,policy_status
			,history_remarks
	from	insurance_policy_main_history
	where	id = @p_id ;
end ;


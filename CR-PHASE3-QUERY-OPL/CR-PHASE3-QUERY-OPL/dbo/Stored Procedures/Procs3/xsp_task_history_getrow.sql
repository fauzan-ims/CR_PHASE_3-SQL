CREATE PROCEDURE dbo.xsp_task_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,task_date
			,desk_collector_code
			,deskcoll_main_id
			,field_collector_code
			--,fieldcoll_main_id
			,agreement_no
			,last_paid_installment_no
			,installment_due_date
			,overdue_period
			,overdue_days
			,overdue_penalty_amount
			,overdue_installment_amount
			,outstanding_installment_amount
			,outstanding_deposit_amount
	from	task_history
	where	id = @p_id ;
end ;

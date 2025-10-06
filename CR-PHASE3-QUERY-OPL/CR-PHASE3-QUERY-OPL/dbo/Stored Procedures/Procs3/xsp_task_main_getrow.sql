CREATE PROCEDURE dbo.xsp_task_main_getrow
(
	@p_id bigint
)
as
begin
	select	tmn.id
			,convert(varchar(30), tmn.task_date, 103) 'task_date'
			,tmn.desk_collector_code
			,tmn.deskcoll_main_id
			,tmn.field_collector_code
			,mcr.collector_name 'desk_collector_name'
			,tmn.fieldcoll_main_code
			,tmn.agreement_no
			,tmn.last_paid_installment_no
			,convert(varchar(30), tmn.installment_due_date, 103) 'installment_due_date'
			,tmn.overdue_period
			,tmn.overdue_days
			,tmn.overdue_penalty_amount
			,tmn.overdue_installment_amount
			,tmn.outstanding_installment_amount
			,tmn.outstanding_deposit_amount
			,amn.agreement_external_no
			,dmn.result_code
			,mdr.result_name
			,dmn.result_detail_code
			,mdd.result_detail_name
			,dmn.result_promise_date
			,dmn.result_remarks
	from	task_main tmn
			left join dbo.deskcoll_main dmn on (dmn.id					 = tmn.deskcoll_main_id)
			left join dbo.master_deskcoll_result mdr on (mdr.code		 = dmn.result_code)
			left join dbo.master_deskcoll_result_detail mdd on (mdd.code = dmn.result_detail_code)
			left join dbo.master_collector mcr on (mcr.code				 = tmn.field_collector_code)
			left join dbo.agreement_main amn on (amn.agreement_no		 = tmn.agreement_no)
	where	tmn.id = @p_id ;
end ;

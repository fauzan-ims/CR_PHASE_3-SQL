CREATE PROCEDURE [dbo].[xsp_inquriy_deskcoll_main_getrow]
(
	@p_id bigint
)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM dbo.deskcoll_main WHERE id = @p_id)
	BEGIN
		SELECT	
			 dmn.id
			,dmn.desk_date
			,dmn.desk_collector_code
			,dmn.agreement_no
			,amn.agreement_external_no
			,dmn.client_no
			,dmn.client_name
			,dmn.last_paid_installment_no
			,dmn.installment_due_date
			,dmn.overdue_period
			,dmn.overdue_days
			,dmn.overdue_penalty_amount
			,dmn.overdue_installment_amount
			,dmn.outstanding_installment_amount
			,dmn.outstanding_deposit_amount
			,dmn.result_code
			,dmn.result_detail_code
			,dmn.result_remarks
			,dmn.result_promise_date AS result_promise_date
			,mdr.result_name
			,mdd.result_detail_name
			,ISNULL(mcr.collector_name, amn.marketing_name) AS desk_collector_name
			,desk_status
			,dmn.overdue_installment_amount + dmn.overdue_penalty_amount AS overdue_total
			,dmn.outstanding_installment_amount + dmn.overdue_installment_amount + dmn.overdue_penalty_amount AS outstanding_total
			,promise.value
			,dmn.result_promise_date
			,taskAgg.total_asset_count
			,taskAgg.total_agreement_count
			,taskAgg.total_monthly_rental_amount
			,dmn.result_promise_amount
			,dmn.is_need_next_fu
			,dmn.next_fu_date
			,dmn.posting_date
		FROM	dbo.deskcoll_main dmn WITH (NOWAIT)
		LEFT JOIN dbo.agreement_main				amn WITH (NOWAIT) ON amn.agreement_no = dmn.agreement_no
		LEFT JOIN dbo.master_deskcoll_result		mdr WITH (NOWAIT) ON mdr.code = dmn.result_code
		LEFT JOIN dbo.master_deskcoll_result_detail mdd WITH (NOWAIT) ON mdd.code = dmn.result_detail_code
		LEFT JOIN dbo.master_collector				mcr WITH (NOWAIT) ON mcr.code = dmn.desk_collector_code
		OUTER APPLY
		(
			SELECT	value
			FROM	dbo.sys_global_param
			WHERE	code = 'CDPTP'
		) promise
		OUTER APPLY
		(
			SELECT	
				 COUNT(a.agreement_no) AS total_agreement_count
				,COUNT(b.asset_no) AS total_asset_count
				,SUM(b.monthly_rental_rounded_amount) AS total_monthly_rental_amount
			FROM	dbo.agreement_main a WITH (NOWAIT)
			INNER JOIN dbo.agreement_asset b WITH (NOWAIT) ON b.agreement_no = a.agreement_no
			WHERE	a.client_no = dmn.client_no
			AND		a.agreement_sub_status = 'INCOMPLETE'
		) taskAgg
		WHERE	dmn.id = @p_id;
	END
	ELSE
	BEGIN
		SELECT	
			 id
			,task_date AS desk_date
			,desk_collector_code
			,tm.AGREEMENT_NO
			,last_paid_installment_no
			,installment_due_date
			,overdue_period
			,overdue_days
			,overdue_penalty_amount
			,overdue_installment_amount
			,outstanding_installment_amount
			,outstanding_deposit_amount
			,'NEW' AS desk_status
			,tm.client_no
			,tm.client_name
			,taskAgg.total_asset_count
			,taskAgg.total_agreement_count
			,taskAgg.total_monthly_rental_amount
			,ISNULL(mcr.collector_name, am.marketing_name) AS desk_collector_name
		FROM	dbo.task_main tm WITH (NOWAIT)
		LEFT JOIN dbo.AGREEMENT_MAIN				am WITH (NOWAIT) ON am.AGREEMENT_NO = tm.AGREEMENT_NO
		LEFT JOIN dbo.master_collector				mcr WITH (NOWAIT) ON mcr.code = tm.desk_collector_code
		OUTER APPLY
		(
			SELECT	
				 COUNT(a.agreement_no) AS total_agreement_count
				,COUNT(b.asset_no) AS total_asset_count
				,SUM(b.monthly_rental_rounded_amount) AS total_monthly_rental_amount
			FROM	dbo.agreement_main a WITH (NOWAIT)
			INNER JOIN dbo.agreement_asset b WITH (NOWAIT) ON b.agreement_no = a.agreement_no
			WHERE	a.client_no = tm.client_no
			AND		a.agreement_sub_status = 'INCOMPLETE'
		) taskAgg
		WHERE	id = @p_id;
	END
END;

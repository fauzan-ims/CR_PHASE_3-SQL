CREATE PROCEDURE dbo.xsp_deskcoll_main_getrow
(
	@p_id BIGINT
)
AS
BEGIN
	SELECT	dmn.id
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
			,dmn.result_promise_date																		  'result_promise_date'
			--,mcr.collector_name
			,mdr.result_name
			,mdd.result_detail_name
			,isnull(mcr.collector_name, amn.marketing_name)													  'desk_collector_name'
			,desk_status
			,dmn.overdue_installment_amount + dmn.overdue_penalty_amount									  'overdue_total'
			,dmn.outstanding_installment_amount + dmn.overdue_installment_amount + dmn.overdue_penalty_amount 'outstanding_total'
			,promise.value
			,dmn.result_promise_date
			,taskAgg.total_asset_count
			,taskAgg.total_agreement_count
			,taskAgg.total_monthly_rental_amount
			,dmn.result_promise_amount
			,dmn.is_need_next_fu
			,dmn.next_fu_date
			,dmn.posting_date
			,dbo.xfn_get_system_date() 'sysdate'
	from	deskcoll_main								dmn
			left join dbo.agreement_main				amn on (amn.agreement_no = dmn.agreement_no)
			left join dbo.master_deskcoll_result		mdr on (mdr.code = dmn.result_code)
			left join dbo.master_deskcoll_result_detail mdd on (mdd.code = dmn.result_detail_code)
			left join dbo.master_collector				mcr on (mcr.code = dmn.desk_collector_code)
			outer apply
	(
		select	value
		from	dbo.sys_global_param
		where	code = 'CDPTP'
	)													promise
			outer apply
	(
		select	count(distinct a.agreement_no)		  as total_agreement_count
				,count(b.asset_no)					  as total_asset_count
				,sum(b.monthly_rental_rounded_amount) as total_monthly_rental_amount
		from	dbo.agreement_main			   a
				inner join dbo.agreement_asset b on b.agreement_no = a.agreement_no
		where	a.client_no = dmn.client_no
				and isnull(a.agreement_sub_status,'') = 'INCOMPLETE'
	) taskAgg

	--			outer apply
	--(
	--		SELECT	count (DISTINCT a.AGREEMENT_NO) total_agreement_count
	--				,COUNT(DISTINCT b.ASSET_NO) total_asset_count
	--				,sum(b.monthly_rental_rounded_amount) as total_monthly_rental_amount
	--	FROM dbo.AGREEMENT_MAIN a
	--		JOIN dbo.AGREEMENT_ASSET b
	--			ON b.AGREEMENT_NO = a.AGREEMENT_NO
	--		JOIN dbo.INVOICE_DETAIL c
	--			ON c.ASSET_NO = b.ASSET_NO
	--		JOIN dbo.INVOICE d
	--			ON d.INVOICE_NO = c.INVOICE_NO
	--	WHERE INVOICE_DUE_DATE < dbo.xfn_get_system_date() AND a.client_no = dmn.client_no AND INVOICE_STATUS = 'POST'
	--) taskAgg


	where	id = @p_id ;
end ;

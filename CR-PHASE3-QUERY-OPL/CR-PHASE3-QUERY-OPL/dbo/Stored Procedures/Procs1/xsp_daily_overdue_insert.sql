CREATE PROCEDURE [dbo].[xsp_daily_overdue_insert]
(
	@p_user_id NVARCHAR(15)
	,@p_branch_code NVARCHAR(50)
	,@p_branch_name NVARCHAR(250)
	,@p_as_of_date DATETIME
	,@p_is_condition NVARCHAR(1)
)
AS
BEGIN
	--sepria: rombak sp 
	declare @msg			nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_title		nvarchar(250)
			,@start_month_date	NVARCHAR(50)

	BEGIN TRY

		DELETE dbo.RPT_DAILY_OVERDUE
		WHERE USER_ID = @p_user_id

	select	@report_image = VALUE
	from	dbo.SYS_GLOBAL_PARAM
	where CODE = 'IMGDSF';

	select	@report_company = VALUE
	from	dbo.SYS_GLOBAL_PARAM
	where CODE = 'COMP2';
	
	SELECT	@start_month_date = VALUE
	from	dbo.SYS_GLOBAL_PARAM
	where CODE = 'SAODRBDL';

	set @report_title = N'Report Daily Overdue';

	INSERT INTO dbo.RPT_DAILY_OVERDUE
	(
	    BUCKET,
	    CLIENT_NO,
	    CLIENT_NAME,
	    AGREEMENT_NO,
	    TYPE_UNIT,
	    JUMLAH_UNIT,
	    TENOR,
	    INVOICE_TYPE,
	    BILLING_NO,
	    INVOICE_DATE,
	    NEW_INVOICE_DATE,
	    INVOICE_POSTING_DATE,
	    INVOICE_NO,
	    PREVIOUS_INVOICE_NO,
	    PERIODE_SEWA,
	    TOP_DAYS,
	    INVOICE_DUE_DATE,
	    LEASE_AMOUNT,
	    BILLING_AMOUNT,
	    CREDIT_AMOUNT,
	    NEW_BILLING_AMOUNT,
	    VAT_AMOUNT,
	    BILLING_AMOUNT_INC_VAT,
	    PPH_AMOUNT,
	    NETT_AMOUNT,
	    OVERDUE_AMOUNT_INC_VAT,
	    OVERDUE_AMOUNT_EXC_VAT,
	    OD_DAYS,
	    PENALTY,
	    INVOICE_DELIVERY_DATE,
	    INVOICE_RECEIVED_DATE,
	    RESULT_DESKCOLL,
	    REMARK_DESKCOLL,
	    PROMISE_DATE,
	    AGREEMENT_STATUS,
	    --GO_LIVE_AGREEMENT_DATE,
	    TERMINATION_STATUS,
	    TERMINATION_DATE,
	    DESK_COLLECTOR,
	    MARKETING_NAME,
	    MARKETING_LEADER,
	    CLIENT_ADRESS,
	    BILLING_ADRESS,
	    CLIENT_EMAIL,
	    CLIENT_PHONE_NUMBER,
	    JUMLAH_INVOICE_PAID,
	    JUMLAH_INVOICE_NOTDUE,
	    report_company,
	    report_image,
	    report_title,
	    branch_code,
	    as_of_date,
	    branch_name,
	    IS_CONDITION,
	    USER_ID,
	    --PLAT_NO,
	    --ITEM_NAME,
	    BILLING_DATE,
	    REMARK,
	    CONTACT_PERSON_NAME
	)

	select	0 'bucket'
			,am.client_no
			,am.client_name
			,am.agreement_external_no
			,ih.asset_name
			,ih.jumlah
			,am.periode
			,invh.invoice_type
			,ih.billing_no
			,cast(invh.invoice_date as date)
			,cast(invh.new_invoice_date as date)
			,cast(crr.posting_date as date)
			,invh.invoice_external_no
			,invh.invoice_name
			,ih.description
			,isnull(am.credit_term,0)	
			,cast(invh.invoice_due_date as date)
			,isnull(ih.monthly_rental_rounded_amount,0)	
			,isnull(ih.billing_amount,0)		
			,isnull(cn.credit_amount,0)	
			,isnull(cn.new_total_amount,0)		
			,isnull(ih.ppn_amount,0)			
			--
			,isnull(billing_amount_inc_vat,0)	
			,isnull(ih.pph_amount,0)	
			,isnull(nett_amount,0)	
			,isnull(overdue_amount_inc_vat,0)	
			,isnull(overdue_amount_exc_vat,0)	
			,isnull(od_days,0)	
			,isnull(penalty,0)	
			--
			,null	--invoice deliver date: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
			,null	--invoice receive date: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
			,null	--remark deskcoll: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
			,null	--result deskcoll: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
			,null	--promise date: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
			,am.agreement_status
			--,am.agreement_date
			,am.termination_status
			,am.termination_date
			,null	--ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
			,am.marketing_name
			,sem.marketing_leader
			,ih.npwp_address
			,ih.billing_to_address
			,ih.email
			,ih.contact_person_name
			,invp.jumlah_invoice_paid
			,invn.jumlah_invoice_not_due
			,@report_company
			,@report_image
			,@report_title
			,@p_branch_code
			,@p_as_of_date
			,@p_branch_name
			,@p_is_condition
			,@p_user_id
			,cast(invh.cre_date as date)			
			,invh.invoice_name
			,ih.billing_to_name
	from	dbo.invoice invh 
			outer apply (
					select	sum(isnull((cn.new_rental_amount), (invd.billing_amount))+ isnull((cn.new_ppn_amount), (invd.ppn_amount)) - isnull((invd.discount_amount), 0)) 'billing_amount_inc_vat'
							,sum(isnull(cn.new_pph_amount, invd.pph_amount)) 'pph_amount'
							,sum(case when inv.billing_to_faktur_type = '01' then (isnull((cn.new_rental_amount), (invd.billing_amount))+ isnull((cn.new_ppn_amount), (invd.ppn_amount)) - isnull((invd.discount_amount), 0) - isnull((cn.new_pph_amount), (invd.pph_amount)))
								else  (isnull(cn.new_total_amount, invd.total_amount)  - isnull((invd.discount_amount), 0) - isnull((cn.new_pph_amount), (invd.pph_amount)))
							end) 'nett_amount'
							,sum(case when inv.invoice_status = 'post' then 
									(case when cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date) then  
										(case when inv.billing_to_faktur_type = '01' then isnull((cn.new_rental_amount), (invd.billing_amount)) + isnull((cn.new_ppn_amount), (invd.ppn_amount)) - isnull((invd.discount_amount), 0)
												else  isnull((cn.new_rental_amount), (invd.billing_amount)) - isnull((invd.discount_amount), 0)
										end)
									else 0 end)
								else 0 end)	'overdue_amount_inc_vat'
							,sum(case when inv.invoice_status = 'post' then 
									(case when cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date) then  
										(case when inv.billing_to_faktur_type = '01' then isnull((cn.new_rental_amount), (invd.billing_amount)) - isnull((invd.discount_amount), 0)
												else  isnull((cn.new_rental_amount), (invd.billing_amount)) - isnull((invd.discount_amount), 0)
										end)
									else 0 end)
								else 0 end)	'overdue_amount_exc_vat'
							,sum(case when cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date) then  
								(case when ac.calculate_by = 'pct' then 
									((isnull((cn.new_rental_amount), (invd.billing_amount)) - isnull((invd.discount_amount),0)) * (ac.charges_rate/100) * datediff(day, cast(inv.invoice_due_date as date), cast(dbo.xfn_get_system_date() as date)))
									else ac.charges_amount * datediff(day, cast(inv.invoice_due_date as date), cast(dbo.xfn_get_system_date() as date)) end )
							 else 0 end) 'penalty'
							,sum(datediff(day, cast(inv.invoice_due_date as date), cast(dbo.xfn_get_system_date() as date))) 'od_days'
							,invd.billing_amount
							,ags.asset_name
							--
							,invd.description
							,invd.billing_no
							,sum(isnull(cn.new_ppn_amount, invd.ppn_amount)) 'ppn_amount'
							,ags.agreement_no
							,ags.monthly_rental_rounded_amount
							,ags.npwp_address
							,ags.billing_to_address
							,ags.email
							,ags.billing_to_name
							,ags.billing_to_area_no + ' - ' + ags.billing_to_phone_no 'contact_person_name'
							,count(ags.asset_name) 'jumlah'
					from	dbo.invoice inv
							inner join dbo.invoice_detail invd on invd.invoice_no = inv.invoice_no
							inner join dbo.agreement_asset ags on ags.asset_no = invd.asset_no and ags.agreement_no = invd.agreement_no
							outer apply (	select	cnn.new_rental_amount
													,cnn.new_ppn_amount
													,cnn.new_pph_amount
													,cnn.new_total_amount
											from	dbo.credit_note cn
													inner join dbo.credit_note_detail cnn on cnn.credit_note_code = cn.code
											where	cn.invoice_no = inv.invoice_no
											and		cnn.invoice_detail_id = invd.id
										) cn
							outer apply (	select	ac.calculate_by
													,ac.charges_rate
													,ac.charges_amount
											from	dbo.agreement_charges ac
											where	ac.agreement_no = invd.agreement_no
											and		ac.charges_code = 'ovdp'
										) ac
					where	inv.invoice_no = invh.invoice_no
					group by invd.billing_amount
							,ags.asset_name
							,invd.description
							,invd.billing_no
							,ags.agreement_no
							,ags.monthly_rental_rounded_amount
							,ags.npwp_address
							,ags.billing_to_address
							,ags.email
							,ags.billing_to_name
							,ags.billing_to_area_no + ' - ' + ags.billing_to_phone_no 
					)ih
			inner join dbo.agreement_main am on am.agreement_no = ih.agreement_no
			outer apply (	select	distinct crr.cre_date 'posting_date'
							from	dbo.opl_interface_cashier_received_request crr
							where	crr.invoice_no = invh.invoice_no
						) crr
			outer apply (	select	cn.credit_amount
									,cn.new_total_amount
							from	dbo.credit_note cn
							where	cn.invoice_no = invh.invoice_no
						) cn
			outer apply (	select	head.name	'marketing_leader'
							from	ifinsys.dbo.sys_employee_main sem
									inner join ifinsys.dbo.sys_employee_main head on head.code = sem.head_emp_code
							where	sem.code = am.marketing_code
						) sem
			outer apply (	select	count(distinct amz.invoice_no) 'jumlah_invoice_paid'
							from	dbo.agreement_asset_amortization amz
									inner join dbo.invoice invp on amz.invoice_no = invp.invoice_no
							where	amz.agreement_no = am.agreement_no
							and		invp.invoice_status = 'paid'
						) invp
			outer apply (	select	count(distinct amz.invoice_no) 'jumlah_invoice_not_due'
							from	dbo.agreement_asset_amortization amz
									inner join dbo.invoice invp on amz.invoice_no = invp.invoice_no
							where	amz.agreement_no = am.agreement_no
							and		invp.invoice_status = 'post'
							and		cast(invp.invoice_due_date as date) > cast(dbo.xfn_get_system_date() as date)
						) invn
	where	invh.invoice_status= 'post'
	and		invh.branch_code = case @p_branch_code when 'all' then invh.branch_code else @p_branch_code end
    and		cast(invh.invoice_due_date as date) between dateadd(month, abs(convert(int,@start_month_date))*-1, @p_as_of_date) and cast(@p_as_of_date as date)

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

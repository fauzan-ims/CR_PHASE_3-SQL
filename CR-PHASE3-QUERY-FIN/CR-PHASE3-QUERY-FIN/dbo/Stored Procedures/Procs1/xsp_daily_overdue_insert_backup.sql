create PROCEDURE [dbo].[xsp_daily_overdue_insert_backup]
(	
	@p_user_id		   nvarchar(15)
	,@p_branch_code	   NVARCHAR(50)
	,@p_branch_name	   NVARCHAR(250)
	,@p_as_of_date		datetime
    ,@p_is_condition   NVARCHAR(1)
)
as
begin

	declare @msg	   nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_title		nvarchar(250)

		delete	dbo.RPT_DAILY_OVERDUE

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2';

		set @report_title = 'Report Daily Overdue' ;
		
		insert into dbo.RPT_DAILY_OVERDUE
		(
			USER_ID
			,as_of_date		
			,branch_code	
			,report_company	
			,report_image	
			,report_title	
			,bucket
			,client_no
			,client_name
			,agreement_no
			,type_unit
			,jumlah_unit
			,tenor
			,invoice_type
			,billing_no
			,invoice_date
			,new_invoice_date
			,invoice_posting_date
			,invoice_no
			,previous_invoice_no
			,periode_sewa
			,top_days
			,invoice_due_date
			,lease_amount
			,billing_amount
			,credit_amount
			,new_billing_amount
			,vat_amount
			,billing_amount_inc_vat
			,pph_amount
			,nett_amount
			,overdue_amount_inc_vat
			,overdue_amount_exc_vat
			,od_days
			,invoice_delivery_date
			,invoice_received_date
			,result_deskcoll
			,remark_deskcoll
			,promise_date
			,agreement_status
			,go_live_agreement_date
			,termination_status
			,termination_date
			,desk_collector
			,marketing_name
			,marketing_leader
			,client_adress
			,billing_adress
			,client_email
			,client_phone_number
			,jumlah_invoice_paid
			,jumlah_invoice_notdue
			,branch_name
		)
		select
			@p_user_id 
			,@p_as_of_date
			,@p_branch_code	
			,@report_company
			,@report_image
			,@report_title
			,0
			--,isnull(   case
			--					   when case
			--								when (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term < 0 then 0
			--								else (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term
			--							end <= 10 then '1'
			--					   when case
			--								when (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term < 0 then 0
			--								else (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term
			--							end >= 11
			--							and case
			--									when (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term < 0 then 0
			--									else (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term
			--								end <= 90 then '2'
			--					   when case
			--								when (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term < 0 then 0
			--								else (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term
			--							end >= 91
			--							and case
			--									when (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term < 0 then 0
			--									else (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term
			--								end <= 120 then '3'
			--					   when case
			--								when (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term < 0 then 0
			--								else (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term
			--							end >= 121
			--							and case
			--									when (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term < 0 then 0
			--									else (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term
			--								end <= 180 then '4'
			--					   when case
			--								when (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term < 0 then 0
			--								else (isnull(datediff(day, am.invoice_date, @p_as_of_date), 0)) - am.credit_term
			--							end >= 180 then '5'
			--				   end, 0
			--			   ) -- BUCKET - int
			,i.CLIENT_NO
			,am.CLIENT_NAME 'CUSTOMER_NAME'
			,am.AGREEMENT_EXTERNAL_NO 'AGREEMENT_NO'
			,ab.ASSET_NAME 'TYPE_UNIT'
			,count(ide.ASSET_NO) 'JUMLAH_UNIT'
			,asst.TENOR
			,i.INVOICE_TYPE
			,ide.BILLING_NO
			,i.INVOICE_DATE
			,i.NEW_INVOICE_DATE
			,''
			,i.INVOICE_EXTERNAL_NO 'INVOICE_NO'
			,''
			,case
				when INVOICE_TYPE = 'RENTAL' then right(ide.DESCRIPTION, 43)
				else ide.DESCRIPTION
			end 'PERIODE_SEWA'
			,am.CREDIT_TERM 'TOP_DAYS'
			,i.INVOICE_DUE_DATE
			,ide.BILLING_AMOUNT 'LEASE_AMOUNT / MONTH'
			,sum(ide.BILLING_AMOUNT) 'BILLING_AMOUNT'
			,isnull(sum(CN.ADJUSTMENT_AMOUNT), sum(ide.DISCOUNT_AMOUNT)) 'CREDIT_AMOUNT'
			,isnull(sum(CN.NEW_RENTAL_AMOUNT), (sum(ide.BILLING_AMOUNT) - isnull(sum(ide.DISCOUNT_AMOUNT), 0))) 'NEW_BILLING_AMOUNT'
			,isnull(sum(CN.NEW_PPN_AMOUNT), sum(ide.PPN_AMOUNT)) 'VAT_AMOUNT'
			,isnull(sum(CN.NEW_RENTAL_AMOUNT), sum(ide.BILLING_AMOUNT))
			+ isnull(sum(CN.NEW_PPN_AMOUNT), sum(ide.PPN_AMOUNT)) - isnull(sum(ide.DISCOUNT_AMOUNT), 0) 'RENTAL_AMOUNT_INC_VAT'
			,isnull(sum(CN.NEW_PPH_AMOUNT), sum(ide.PPH_AMOUNT)) 'PPH_AMOUNT'
			,isnull(sum(CN.NEW_TOTAL_AMOUNT), sum(ide.TOTAL_AMOUNT)) 'NETT_AMOUNT'
			,case
				when i.INVOICE_TYPE = 'RENTAL' then
					case
						when asst.WAPU = '01' then
							isnull(sum(CN.NEW_RENTAL_AMOUNT), sum(ide.BILLING_AMOUNT))
							+ isnull(sum(CN.NEW_PPN_AMOUNT), sum(ide.PPN_AMOUNT)) - isnull(sum(ide.DISCOUNT_AMOUNT), 0)
						else isnull(sum(CN.NEW_RENTAL_AMOUNT), sum(ide.BILLING_AMOUNT))
					end
				else
					isnull(sum(CN.NEW_RENTAL_AMOUNT), sum(ide.BILLING_AMOUNT))
					+ isnull(sum(CN.NEW_PPN_AMOUNT), sum(ide.PPN_AMOUNT)) - isnull(sum(ide.DISCOUNT_AMOUNT), 0)
			end 'OVERDUE_AMOUNT_INC_VAT'
			,isnull(sum(CN.NEW_RENTAL_AMOUNT), sum(ide.BILLING_AMOUNT)) - isnull(sum(ide.DISCOUNT_AMOUNT), 0) 'OVERDUE_AMOUNT_EXC_VAT'
			,datediff(day, INVOICE_DUE_DATE, @p_as_of_date) 'OD_DAYS'
			,''
			,''
			,''
			,''
			,''
			,am.AGREEMENT_STATUS
			,am.AGREEMENT_DATE
			,am.TERMINATION_STATUS
			,am.TERMINATION_DATE
			,''
			,am.MARKETING_NAME
			,am.MARKETING_LEADER
			,i.CLIENT_ADDRESS
			,asst.BILLING_TO_ADDRESS
			,am.EMAIL
			,i.CLIENT_PHONE_NO
			,max(INVOICE_PAID) 'JUMLAH INVOICE_PAID'
			,max(INVDN.INVOICE_NOTDUE) 'JUMLAH INVOICE_NOTDUE'
			,@p_branch_name
	from	IFINOPL.dbo.INVOICE i with (nolock)
			inner join IFINOPL.dbo.INVOICE_DETAIL ide with (nolock) on ide.INVOICE_NO = i.INVOICE_NO
			left join IFINOPL.dbo.CREDIT_NOTE_DETAIL CN with (nolock) on CN.INVOICE_DETAIL_ID = ide.ID
			outer apply
		(
			select	AGREEMENT_EXTERNAL_NO
					,CLIENT_NAME
					,CREDIT_TERM
					,AMA.MARKETING_NAME
					,HEAD.NAME 'MARKETING_LEADER'
					,AMA.AGREEMENT_STATUS
					,AMA.AGREEMENT_NO
					,SEM.EMAIL
					,AMA.AGREEMENT_DATE
					,AMA.TERMINATION_DATE
					,AMA.TERMINATION_STATUS
					--,ai.INVOICE_DATE
			from	IFINOPL.dbo.AGREEMENT_MAIN AMA with (nolock)
					--left join dbo.agreement_invoice ai on ai.agreement_no = ama.agreement_no
					left join IFINSYS.dbo.SYS_EMPLOYEE_MAIN SEM with (nolock) on SEM.CODE = AMA.MARKETING_CODE
					left join IFINSYS.dbo.SYS_EMPLOYEE_MAIN HEAD with (nolock) on HEAD.CODE = SEM.HEAD_EMP_CODE
			where AMA.AGREEMENT_NO = ide.AGREEMENT_NO
		) am
			outer apply
		(
			select	top 1
					aast.ASSET_NAME
					,aast.PERIODE 'TENOR'
					,aast.BILLING_TO_FAKTUR_TYPE 'WAPU'
					,aast.BILLING_TO_ADDRESS
			from	IFINOPL.dbo.AGREEMENT_ASSET aast with (nolock)
			where ide.AGREEMENT_NO = aast.AGREEMENT_NO
		) asst
			outer apply
		(
			select	top 1
					b.ASSET_NAME
			from	IFINOPL.dbo.INVOICE_DETAIL a with (nolock)
					inner join dbo.AGREEMENT_ASSET b with (nolock) on a.ASSET_NO = b.ASSET_NO
			where a.INVOICE_NO = i.INVOICE_NO
		) ab
			outer apply
		(
			select	count(distinct INV.INVOICE_NO) 'INVOICE_PAID'
			from	IFINOPL.dbo.INVOICE_DETAIL INVD with (nolock)
					inner join IFINOPL.dbo.INVOICE INV with (nolock) on INV.INVOICE_NO = INVD.INVOICE_NO
			where	INVD.AGREEMENT_NO = am.AGREEMENT_NO
			and		INV.INVOICE_STATUS	= 'PAID'
		) INVD
			outer apply
		(
			select	count(distinct INV.INVOICE_NO) 'INVOICE_NOTDUE'
			from	IFINOPL.dbo.INVOICE_DETAIL INVD with (nolock)
					inner join IFINOPL.dbo.INVOICE INV with (nolock) on INV.INVOICE_NO = INVD.INVOICE_NO
			where	INVD.AGREEMENT_NO				= am.AGREEMENT_NO
			and		INV.INVOICE_STATUS					= 'POST'
			and		cast(INV.INVOICE_DUE_DATE as date) <= cast(@p_as_of_date as date)
		) INVDN
	where	cast(i.INVOICE_DUE_DATE as date) <= cast(@p_as_of_date as date)
	and		i.INVOICE_STATUS				= 'POST'
	and		i.BRANCH_CODE						= case @p_branch_code
													when 'ALL' then i.BRANCH_CODE
													else @p_branch_code
												end
	group by ide.AGREEMENT_NO
			,i.INVOICE_EXTERNAL_NO
			,am.AGREEMENT_EXTERNAL_NO
			,am.CLIENT_NAME
			,asst.TENOR
			,i.INVOICE_TYPE
			,ide.BILLING_NO
			,i.INVOICE_DATE
			,ide.DESCRIPTION
			,am.CREDIT_TERM
			,i.INVOICE_DUE_DATE
			,am.AGREEMENT_STATUS
			,am.MARKETING_NAME
			,am.MARKETING_LEADER
			,asst.WAPU
			,ab.ASSET_NAME
			,i.CLIENT_NO
			,i.NEW_INVOICE_DATE
			,ide.BILLING_AMOUNT
			,i.CLIENT_ADDRESS
			,asst.BILLING_TO_ADDRESS
			,am.EMAIL
			,i.CLIENT_PHONE_NO
			,am.AGREEMENT_DATE
			,am.TERMINATION_DATE
			,am.TERMINATION_STATUS
			--,am.invoice_date
end ;

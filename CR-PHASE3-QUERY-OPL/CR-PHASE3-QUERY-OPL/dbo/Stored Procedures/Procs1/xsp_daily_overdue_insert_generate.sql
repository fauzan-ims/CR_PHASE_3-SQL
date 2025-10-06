
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_daily_overdue_insert_generate]
(
	@p_user_id nvarchar(15)
	,@p_branch_code nvarchar(50)
	,@p_branch_name nvarchar(250)
	,@p_as_of_date datetime
	,@p_is_condition nvarchar(1) = ''
)
as
begin
	-- insert into RPT_DAILY_OVERDUE_BUTTON_DISABLE
	-- select	CODE
	-- 		,''
	-- from	IFINSYS.dbo.SYS_EMPLOYEE_MAIN
	-- where CODE not in
	-- 		(
	-- 			select user_id from		RPT_DAILY_OVERDUE_BUTTON_DISABLE
	-- 		) ;
	-- update	RPT_DAILY_OVERDUE_BUTTON_DISABLE
	-- set is_disable = '1'
	--where user_id = @p_user_id ;

	--sepria: rombak sp 


	DECLARE @result INT;

	EXEC @result = sp_getapplock @Resource = 'generate_lock', -- nama kunci
								 @LockMode = 'Exclusive',     -- hanya 1 yang bisa masuk
								 @LockTimeout = 0;
	IF @result < 0
	BEGIN
		RAISERROR('Generate sedang berjalan oleh user lain.', 16, 1);
		RETURN;
	END;

	declare @msg			nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_title		nvarchar(250)
			,@start_month_date	nvarchar(50) ;
	begin try

		delete	dbo.RPT_DAILY_OVERDUE
		--where USER_ID = @p_user_id ;

		select	@report_image	= VALUE
		from	dbo.SYS_GLOBAL_PARAM
		where CODE = 'IMGDSF' ;

		select	@report_company = VALUE
		from	dbo.SYS_GLOBAL_PARAM
		where CODE = 'COMP2' ;

		select	@start_month_date	= VALUE
		from	dbo.SYS_GLOBAL_PARAM
		where CODE = 'SAODRBDL' ;

		set @report_title = N'Report Daily Overdue' ;

		insert into dbo.RPT_DAILY_OVERDUE
		(
			BUCKET
			,CLIENT_NO
			,CLIENT_NAME
			,AGREEMENT_NO
			,TYPE_UNIT
			,JUMLAH_UNIT
			,TENOR
			,INVOICE_TYPE
			,BILLING_NO
			,INVOICE_DATE
			,NEW_INVOICE_DATE
			,INVOICE_POSTING_DATE
			,INVOICE_NO
			,PREVIOUS_INVOICE_NO
			,PERIODE_SEWA
			,TOP_DAYS
			,INVOICE_DUE_DATE
			,LEASE_AMOUNT
			,BILLING_AMOUNT
			,CREDIT_AMOUNT
			,NEW_BILLING_AMOUNT
			,VAT_AMOUNT
			,BILLING_AMOUNT_INC_VAT
			,PPH_AMOUNT
			,NETT_AMOUNT
			,OVERDUE_AMOUNT_INC_VAT
			,OVERDUE_AMOUNT_EXC_VAT
			,OD_DAYS
			,PENALTY
			,INVOICE_DELIVERY_DATE
			,INVOICE_RECEIVED_DATE
			,RESULT_DESKCOLL
			,REMARK_DESKCOLL
			,PROMISE_DATE
			,AGREEMENT_STATUS
			--GO_LIVE_AGREEMENT_DATE,
			,TERMINATION_STATUS
			,TERMINATION_DATE
			,DESK_COLLECTOR
			,MARKETING_NAME
			,MARKETING_LEADER
			,CLIENT_ADRESS
			,BILLING_ADRESS
			,CLIENT_EMAIL
			,CLIENT_PHONE_NUMBER
			,JUMLAH_INVOICE_PAID
			,JUMLAH_INVOICE_NOTDUE
			,report_company
			,report_image
			,report_title
			,branch_code
			,as_of_date
			,branch_name
			,IS_CONDITION
			,USER_ID
			--PLAT_NO,
			--ITEM_NAME,
			,BILLING_DATE
			,REMARK
			,CONTACT_PERSON_NAME
			,cre_date
		)
		select	0	'bucket'
				,am.CLIENT_NO
				,am.CLIENT_NAME
				,am.AGREEMENT_EXTERNAL_NO
				,ih.asset_no
				,ih.jumlah
				,am.PERIODE
				,invh.INVOICE_TYPE
				,ih.BILLING_NO
				,null
				,null
				,cast(crr.posting_date as date)
				,invh.INVOICE_EXTERNAL_NO
				,invh.INVOICE_NAME
				,ih.DESCRIPTION
				,isnull(am.CREDIT_TERM, 0)
				,cast(invh.INVOICE_DUE_DATE as date)
				,null
				,isnull(ih.BILLING_AMOUNT, 0)
				,isnull(ih.creamount, 0)
				,(isnull(ih.BILLING_AMOUNT, 0) - isnull(ih.creamount, 0))	--isnull(cn.NEW_TOTAL_AMOUNT, 0)
				,isnull(ih.ppn_amount, 0)
																				--
				,isnull(billing_amount_inc_vat, 0)
				,isnull(ih.pph_amount, 0)
				,isnull(nett_amount, 0)
				,isnull(overdue_amount_inc_vat, 0)
				,isnull(overdue_amount_exc_vat, 0)
				,isnull(od_days, 0)
				,isnull(penalty, 0)
																				--
				,null															--invoice deliver date: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
				,null															--invoice receive date: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
				,null															--remark deskcoll: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
				,null															--result deskcoll: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
				,null															--promise date: ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
				,am.AGREEMENT_STATUS
																				--,am.agreement_date
				,am.TERMINATION_STATUS
				,am.TERMINATION_DATE
				,null															--ini masih kosong karena fiturnya ada di phase 3 after cr priority ini
				,am.MARKETING_NAME
				,sem.marketing_leader
				,ih.NPWP_ADDRESS
				,ih.BILLING_TO_ADDRESS
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
				,ih.billing_date												--cast(invh.CRE_DATE as date)
				,pt.periode_text												--ih.DESCRIPTION
				,ih.BILLING_TO_NAME
				,getdate()
		from	dbo.INVOICE invh with (nolock)
				--join dbo.INVOICE_DETAIL on INVOICE_DETAIL.INVOICE_NO = invh.INVOICE_NO
				--join dbo.AGREEMENT_ASSET_AMORTIZATION on AGREEMENT_ASSET_AMORTIZATION.ASSET_NO = dbo.INVOICE_DETAIL.ASSET_NO and AGREEMENT_ASSET_AMORTIZATION.INVOICE_NO = dbo.INVOICE_DETAIL.INVOICE_NO
				outer apply
		(
			select	sum(isnull(cn.NEW_RENTAL_AMOUNT, invd.BILLING_AMOUNT) + isnull(cn.NEW_PPN_AMOUNT, invd.PPN_AMOUNT)
						- isnull(invd.DISCOUNT_AMOUNT, 0)
					)																								as billing_amount_inc_vat
					,sum(isnull(cn.NEW_PPH_AMOUNT, invd.PPH_AMOUNT))										as pph_amount
					,sum(	case
								when inv.BILLING_TO_FAKTUR_TYPE = '01' then
									isnull(cn.NEW_RENTAL_AMOUNT, invd.BILLING_AMOUNT)
									+ isnull(cn.NEW_PPN_AMOUNT, invd.PPN_AMOUNT) - isnull(invd.DISCOUNT_AMOUNT, 0)
									- isnull(cn.NEW_PPH_AMOUNT, invd.PPH_AMOUNT)else
																					isnull(
																								cn.NEW_TOTAL_AMOUNT
																								,invd.TOTAL_AMOUNT
																							)
																					- isnull(invd.DISCOUNT_AMOUNT, 0)
																					- isnull(
																								cn.NEW_PPH_AMOUNT
																								,invd.PPH_AMOUNT
																							)
							end
						)																							as nett_amount
					,sum(	case
								when inv.INVOICE_STATUS = 'post'
									and cast(inv.INVOICE_DUE_DATE as date) < cast(dbo.xfn_get_system_date() as date) then
									case
										when inv.BILLING_TO_FAKTUR_TYPE = '01' then
											isnull(cn.NEW_RENTAL_AMOUNT, invd.BILLING_AMOUNT)
											+ isnull(cn.NEW_PPN_AMOUNT, invd.PPN_AMOUNT) - isnull(invd.DISCOUNT_AMOUNT, 0)else
																																isnull(
																																		cn.NEW_RENTAL_AMOUNT
																																		,invd.BILLING_AMOUNT
																																	)
																																- isnull(
																																			invd.DISCOUNT_AMOUNT
																																			,0
																																		)
									end else 0
							end
						)																							as overdue_amount_inc_vat
					,sum(	case
								when inv.INVOICE_STATUS = 'post'
									and cast(inv.INVOICE_DUE_DATE as date) < cast(dbo.xfn_get_system_date() as date) then
									isnull(cn.NEW_RENTAL_AMOUNT, invd.BILLING_AMOUNT) - isnull(invd.DISCOUNT_AMOUNT, 0)else
																															0
							end
						)																							as overdue_amount_exc_vat
					,sum(	case
								when cast(inv.INVOICE_DUE_DATE as date) < cast(dbo.xfn_get_system_date() as date) then
									case
										when ac.CALCULATE_BY = 'pct' then
							((isnull(cn.NEW_RENTAL_AMOUNT, invd.BILLING_AMOUNT) - isnull(invd.DISCOUNT_AMOUNT, 0))
								* (ac.CHARGES_RATE / 100)
								* datediff(day, cast(inv.INVOICE_DUE_DATE as date), cast(dbo.xfn_get_system_date() as date))
							)			else
											ac.CHARGES_AMOUNT
											* datediff(
															day
															,cast(inv.INVOICE_DUE_DATE as date)
															,cast(dbo.xfn_get_system_date() as date)
														)
									end else 0
							end
						)																							as penalty
					,max(datediff(day, cast(inv.INVOICE_DUE_DATE as date), cast(dbo.xfn_get_system_date() as date))) as od_days
					,sum(invd.BILLING_AMOUNT)																		as BILLING_AMOUNT
					,sum(ADJUSTMENT_AMOUNT)																				as creamount
					-- Ambil nilai dari salah satu row (arbitrary row dalam group)
					,min(invd.DESCRIPTION)																			as DESCRIPTION
					,invd.BILLING_NO																				as BILLING_NO
					,sum(isnull(cn.NEW_PPN_AMOUNT, invd.PPN_AMOUNT))										as ppn_amount
					,ags.AGREEMENT_NO
					,min(ags.MONTHLY_RENTAL_ROUNDED_AMOUNT)															as MONTHLY_RENTAL_ROUNDED_AMOUNT
					,min(ags.NPWP_ADDRESS)																			as NPWP_ADDRESS
					,min(ags.BILLING_TO_ADDRESS)																	as BILLING_TO_ADDRESS
					,min(ags.BILLING_TO_NAME)																		as BILLING_TO_NAME
					,min(ags.BILLING_TO_AREA_NO + ' - ' + ags.BILLING_TO_PHONE_NO)								as contact_person_name
					,count(ags.ASSET_NAME)																			as jumlah
					,min(ags.EMAIL)																					as email
					,min(ags.ASSET_NAME)																			as asset_no
					,max(BILLING_DATE)																				as billing_date
			from	dbo.INVOICE					inv with (nolock)
					join dbo.INVOICE_DETAIL invd with (nolock) on invd.INVOICE_NO = inv.INVOICE_NO
					join dbo.AGREEMENT_ASSET ags with (nolock) on ags.ASSET_NO = invd.ASSET_NO
																	and ags.AGREEMENT_NO = invd.AGREEMENT_NO
					join dbo.AGREEMENT_ASSET_AMORTIZATION with (nolock) on AGREEMENT_ASSET_AMORTIZATION.ASSET_NO = ags.ASSET_NO
																		and AGREEMENT_ASSET_AMORTIZATION.INVOICE_NO = inv.INVOICE_NO
					left join dbo.CREDIT_NOTE_DETAIL with (nolock) on CREDIT_NOTE_DETAIL.INVOICE_DETAIL_ID = invd.ID
					left join dbo.CREDIT_NOTE with (nolock) on CREDIT_NOTE.INVOICE_NO = CREDIT_NOTE_DETAIL.INVOICE_NO
					outer apply
			(
				select	cnn.NEW_RENTAL_AMOUNT
						,cnn.NEW_PPN_AMOUNT
						,cnn.NEW_PPH_AMOUNT
						,cnn.NEW_TOTAL_AMOUNT
				from	dbo.CREDIT_NOTE				cn with (nolock)
						join dbo.CREDIT_NOTE_DETAIL cnn with (nolock) on cnn.CREDIT_NOTE_CODE = cn.CODE
				where cn.INVOICE_NO = inv.INVOICE_NO and cnn.INVOICE_DETAIL_ID = invd.ID
			)									cn
					outer apply
			(
				select	ac.CALCULATE_BY
						,ac.CHARGES_RATE
						,ac.CHARGES_AMOUNT
				from	dbo.AGREEMENT_CHARGES ac with (nolock)
				where ac.AGREEMENT_NO = invd.AGREEMENT_NO and	ac.CHARGES_CODE = 'ovdp'
			)	ac
			where inv.INVOICE_NO = invh.INVOICE_NO
			group by
				invd.BILLING_AMOUNT
				,ags.AGREEMENT_NO
				,invd.BILLING_NO
		)					ih
				inner join dbo.AGREEMENT_MAIN am on am.AGREEMENT_NO = ih.AGREEMENT_NO
				outer apply
		(
			select	distinct
					crr.CRE_DATE	'posting_date'
			from	dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST crr with (nolock)
			where crr.INVOICE_NO = invh.INVOICE_NO and	crr.DOC_REFF_NAME = 'INVOICE SEND'
		)										crr
		--		outer apply
		--(
		--	select	cn.CREDIT_AMOUNT
		--			,cn.NEW_TOTAL_AMOUNT
		--	from	dbo.CREDIT_NOTE cn with (nolock)
		--	where cn.INVOICE_NO = invh.INVOICE_NO
		--)	cn
				outer apply
		(
			select	head.NAME	'marketing_leader'
			from	IFINSYS.dbo.SYS_EMPLOYEE_MAIN				sem with (nolock)
					inner join IFINSYS.dbo.SYS_EMPLOYEE_MAIN head with (nolock) on head.CODE = sem.HEAD_EMP_CODE
			where sem.CODE = am.MARKETING_CODE
		)	sem
			outer	apply
		(
			select	count(distinct amz.INVOICE_NO) 'jumlah_invoice_paid'
			from	dbo.AGREEMENT_ASSET_AMORTIZATION	amz with (nolock)
					inner join dbo.INVOICE			invp with (nolock) on amz.INVOICE_NO = invp.INVOICE_NO
			where amz.AGREEMENT_NO = am.AGREEMENT_NO and invp.INVOICE_STATUS = 'paid'
		)	invp
				outer apply
		(
			select	count(distinct amz.INVOICE_NO) 'jumlah_invoice_not_due'
			from	dbo.AGREEMENT_ASSET_AMORTIZATION	amz with (nolock)
					inner join dbo.INVOICE			invp with (nolock) on amz.INVOICE_NO = invp.INVOICE_NO
			where amz.AGREEMENT_NO						= am.AGREEMENT_NO
				and invp.INVOICE_STATUS					= 'post'
				and cast(invp.INVOICE_DUE_DATE as date) > cast(dbo.xfn_get_system_date() as date)
		)	invn
				outer apply
		(
			select	convert(nvarchar(10), min(period.period_date), 103) + ' - '
					+ convert(nvarchar(10), max(period.period_due_date), 103) as periode_text
			from	dbo.AGREEMENT_ASSET						aast with (nolock)
					join dbo.AGREEMENT_ASSET_AMORTIZATION artz with (nolock) on artz.AGREEMENT_NO = aast.AGREEMENT_NO
																				and aast.ASSET_NO = artz.ASSET_NO
					join dbo.AGREEMENT_MAIN			am with (nolock) on am.AGREEMENT_NO = artz.AGREEMENT_NO
					outer apply
			(
				select	billing_no
						,case am.FIRST_PAYMENT_TYPE
							when 'ARR' then
								dateadd(day, 1, period_date)else period_date
						end		as period_date
						,aa.period_due_date
				from	dbo.xfn_due_date_period(artz.ASSET_NO, cast(artz.BILLING_NO as int)) aa
				where aa.billing_no = artz.BILLING_NO
			)												period
			where artz.INVOICE_NO = invh.INVOICE_NO
		)	pt



		--		outer apply
		--(
		--	select	distinct
		--			EMAIL, ASSET_NO
		--	from	dbo.AGREEMENT_ASSET
		--	where AGREEMENT_NO = am.AGREEMENT_NO
		--)	amor
		where invh.INVOICE_STATUS				= 'post' and	invh.BRANCH_CODE = case @p_branch_code
																						when 'all' then
																							invh.BRANCH_CODE else @p_branch_code
																					end
			--and cast(invh.INVOICE_DUE_DATE as date) between dateadd(
			--															month
			--															,abs(convert(int, @start_month_date)) * -1
			--															,@p_as_of_date
			--														) and cast(@p_as_of_date as date) ;
			and cast(invh.INVOICE_DUE_DATE as date) <= cast(@p_as_of_date as date) ;

		update	RPT_DAILY_OVERDUE_BUTTON_DISABLE
		set is_disable = '0'
		--where user_id = @p_user_id ;

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

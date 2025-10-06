--EXEC dbo.cari_sp_mengandung @keyword = 'rpt_daily_overdue' -- varchar(500)

CREATE PROCEDURE [dbo].[xsp_daily_overdue_insert_xxx]
(
	@p_user_id NVARCHAR(15)
	,@p_branch_code NVARCHAR(50)
	,@p_branch_name NVARCHAR(250)
	,@p_as_of_date DATETIME
	,@p_is_condition NVARCHAR(1)
)
AS
BEGIN

	DELETE dbo.RPT_DAILY_OVERDUE
	WHERE USER_ID = @p_user_id

	declare @temp table
		(
			AGREEMENT_NO nvarchar(50)
			,AR_AMOUNT decimal(18, 2)
			,AR_PAYMENT_AMOUNT decimal(18, 2)
			,PPN_AMOUNT decimal(18, 2)
			,PAYMENT_EXC_VAT_AMOUNT decimal(18, 2)
			,RUNNING_PERIOD int
			,INVOICE_DATE datetime
			,TOP_DATE DATETIME
		)
	BEGIN TRY
		begin
			insert into @temp
			(
				AGREEMENT_NO
				,INVOICE_DATE
			)
			select	ai.AGREEMENT_NO
					,ai.INVOICE_DATE	--'INVOICE_DATE'
			from	[IFINOPL].dbo.AGREEMENT_INVOICE ai with (nolock)
					outer apply
				(
					select	crr.INVOICE_NO
							,ct.CASHIER_TRX_DATE
					from	IFINFIN.dbo.CASHIER_TRANSACTION ct with (nolock)
							inner join IFINFIN.dbo.CASHIER_TRANSACTION_DETAIL ctd with (nolock) on (ctd.CASHIER_TRANSACTION_CODE = ct.CODE)
							inner join IFINFIN.dbo.CASHIER_RECEIVED_REQUEST crr with (nolock) on (crr.CODE	= ctd.RECEIVED_REQUEST_CODE)
					where	crr.INVOICE_NO	= ai.INVOICE_NO
					and		ct.CASHIER_STATUS	= 'PAID'
				) csh
					outer apply
				(
					select	crr.INVOICE_NO
							,depa.ALLOCATION_TRX_DATE
					from	[IFINFIN].dbo.DEPOSIT_ALLOCATION depa with (nolock)
							inner join [IFINFIN].dbo.DEPOSIT_ALLOCATION_DETAIL depad with (nolock) on depad.DEPOSIT_ALLOCATION_CODE = depa.CODE
							inner join [IFINFIN].dbo.CASHIER_RECEIVED_REQUEST crr with (nolock) on (crr.CODE = depad.RECEIVED_REQUEST_CODE)
					where	crr.INVOICE_NO		= ai.INVOICE_NO
					and		depa.ALLOCATION_STATUS	= 'APPROVE'
				) dep
					outer apply
				(
					select	ap.INVOICE_NO
							,sum(ap.PAYMENT_AMOUNT) as payment_amount
							,isnull(isnull(max(ct.CASHIER_TRX_DATE), max(DA.ALLOCATION_TRX_DATE)), max(ap.PAYMENT_DATE)) as trx_date
							,sum(invd.BILLING_AMOUNT) 'payment_exc_vat_amount'
							,sum(invd.PPN_AMOUNT) 'PPN_AMOUNT'
					from	[IFINOPL].dbo.AGREEMENT_INVOICE_PAYMENT ap with (nolock)
							left join IFINOPL.dbo.INVOICE_DETAIL invd with (nolock) on (
																							invd.INVOICE_NO		= ap.INVOICE_NO
																					and		invd.AGREEMENT_NO	= ap.AGREEMENT_NO
																					and		invd.ASSET_NO		= ap.ASSET_NO
																					and		invd.BILLING_NO		= ai.BILLING_NO
																					)
							left join IFINFIN.dbo.CASHIER_TRANSACTION ct with (nolock) on ct.CODE = ap.TRANSACTION_NO
							left join IFINFIN.dbo.DEPOSIT_ALLOCATION DA with (nolock) on DA.CODE = ap.TRANSACTION_NO
					where	ai.CODE																								= ap.AGREEMENT_INVOICE_CODE
					and		ap.PAYMENT_AMOUNT																						<> 0
					and		convert(nvarchar(8), isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DATE), ap.PAYMENT_DATE), 112) <= convert(
																																				nvarchar(8)
																																				,@p_as_of_date
																																				,112
																																			)
					group by ap.INVOICE_NO
				) aip
					inner join [IFINOPL].dbo.INVOICE inv with (nolock) on inv.INVOICE_NO = ai.INVOICE_NO
			where	((
						convert(nvarchar(8), isnull(csh.CASHIER_TRX_DATE, isnull(dep.ALLOCATION_TRX_DATE, aip.trx_date)), 112) > convert(
																																			nvarchar(8)
																																			,@p_as_of_date
																																			,112
																																		)
				or		aip.trx_date is null
				or		((ai.AR_AMOUNT - isnull(aip.payment_amount, 0))										> 0)
					)
					)
			and		inv.INVOICE_TYPE																							<> 'PENALTY' -- (+) 20240104 - Anas - invoice penalty tidak ikut dihitung
			and		convert(nvarchar(8), inv.IS_JOURNAL_DATE, 112)												<= convert(nvarchar(8), @p_as_of_date, 112)
			and		ai.AGREEMENT_NO in
						(
							select AGREEMENT_NO from [IFINOPL] .dbo.AGREEMENT_MAIN
						)	-- (+) Ari 2024-04-01 ket : kondisi pengganti join diatas
			group by ai.AGREEMENT_NO
					,ai.BILLING_NO
					,ai.INVOICE_DATE
					,ai.DUE_DATE;
		end;

	declare @msg			nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_title		nvarchar(250);

	delete	dbo.RPT_DAILY_OVERDUE;

	select	@report_image = VALUE
	from	dbo.SYS_GLOBAL_PARAM
	where CODE = 'IMGDSF';

	select	@report_company = VALUE
	from	dbo.SYS_GLOBAL_PARAM
	where CODE = 'COMP2';

	set @report_title = N'Report Daily Overdue';

	INSERT INTO dbo.RPT_DAILY_OVERDUE
	(
		USER_ID
		,as_of_date
		,branch_code
		,report_company
		,report_image
		,report_title
		,BUCKET
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
		,GO_LIVE_AGREEMENT_DATE
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
		,branch_name
		,ITEM_NAME
		,PLAT_NO
		,BILLING_DATE
		,REMARK
	)
	SELECT	DISTINCT
			@p_user_id
			,@p_as_of_date
			,@p_branch_code
			,@report_company
			,@report_image
			,@report_title
			,0 -- SEPRIA 19-05-2025: TUTUP SEMENTARA UNTUK BUCKET, KARENA DI OPL SEKRANG BELUM ADA SETTINGAN BUCKET.
			--,ISNULL(
			--	CASE
			--		WHEN CASE
			--				WHEN (ISNULL(DATEDIFF(DAY, topdate.invo, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 THEN
			--					0
			--				ELSE (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
			--			END <= 10 THEN '1'
			--		WHEN CASE
			--					WHEN (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 THEN
			--						0
			--					ELSE (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
			--				END >= 11
			--		AND		CASE
			--					WHEN (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 THEN
			--						0
			--					ELSE (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
			--				END <= 90 THEN '2'
			--		WHEN CASE
			--					WHEN (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 THEN
			--						0
			--					ELSE (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
			--				END >= 91
			--		AND		CASE
			--					WHEN (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 THEN
			--						0
			--					ELSE (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
			--				END <= 120 THEN '3'
			--		WHEN CASE
			--					WHEN (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 THEN
			--						0
			--					ELSE (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
			--				END >= 121
			--		AND		CASE
			--					WHEN (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 THEN
			--						0
			--					ELSE (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
			--				END <= 180 THEN '4'
			--		WHEN CASE
			--				WHEN (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 THEN
			--					0
			--				ELSE (ISNULL(DATEDIFF(DAY, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
			--			END >= 180 THEN '5'
			--	END, 0
			--) 'BUCKET'
		,i.CLIENT_NO
		,am.CLIENT_NAME 'CUSTOMER_NAME'
		,am.AGREEMENT_EXTERNAL_NO 'AGREEMENT_NO'
		,ab.ASSET_NAME 'TYPE_UNIT'
		,COUNT(ide.ASSET_NO) 'JUMLAH_UNIT'
		,asst.TENOR
		,i.INVOICE_TYPE
		,MAX(ide.BILLING_NO)
		,i.INVOICE_DATE
		,i.NEW_INVOICE_DATE
		,glt.TRANSACTION_DATE 'INVOICE_POSTING_DATE'
		,i.INVOICE_EXTERNAL_NO 'INVOICE_NO'
		,iiid.INVOICE_EXTERNAL_NO 'PREVIOUS_INVOICE_NO'
		,CASE
			WHEN INVOICE_TYPE = 'RENTAL' THEN RIGHT(ide.DESCRIPTION, 43)
			ELSE ide.DESCRIPTION
		END 'PERIODE_SEWA'
		,am.CREDIT_TERM 'TOP_DAYS'
		,i.INVOICE_DUE_DATE
		,SUM(ide.BILLING_AMOUNT) 'LEASE_AMOUNT / MONTH'
		,SUM(ide.BILLING_AMOUNT) 'RENTAL_AMOUNT'
		,ISNULL(SUM(CN.ADJUSTMENT_AMOUNT), SUM(ide.DISCOUNT_AMOUNT)) 'CREDIT_AMOUNT'
		,ISNULL(SUM(CN.NEW_RENTAL_AMOUNT), (SUM(ide.BILLING_AMOUNT) - ISNULL(SUM(ide.DISCOUNT_AMOUNT), 0))) 'NEW_BILLING_AMOUNT'
		,ISNULL(SUM(CN.NEW_PPN_AMOUNT), SUM(ide.PPN_AMOUNT)) 'VAT_AMOUNT'
		,ISNULL(SUM(CN.NEW_RENTAL_AMOUNT), SUM(ide.BILLING_AMOUNT)) + ISNULL(SUM(CN.NEW_PPN_AMOUNT), SUM(ide.PPN_AMOUNT))
		- ISNULL(SUM(ide.DISCOUNT_AMOUNT), 0) 'RENTAL_AMOUNT_INC_VAT'
		,ISNULL(SUM(CN.NEW_PPH_AMOUNT), SUM(ide.PPH_AMOUNT)) 'PPH_AMOUNT'
		,ISNULL(SUM(CN.NEW_TOTAL_AMOUNT), SUM(ide.TOTAL_AMOUNT)) 'NETT_AMOUNT'
		,CASE
			WHEN i.INVOICE_TYPE = 'RENTAL' THEN
				CASE
					WHEN asst.WAPU = '01' THEN
						ISNULL(SUM(CN.NEW_RENTAL_AMOUNT), SUM(ide.BILLING_AMOUNT))
						+ ISNULL(SUM(CN.NEW_PPN_AMOUNT), SUM(ide.PPN_AMOUNT)) - ISNULL(SUM(ide.DISCOUNT_AMOUNT), 0)
					ELSE ISNULL(SUM(CN.NEW_RENTAL_AMOUNT), SUM(ide.BILLING_AMOUNT))
				END
			ELSE
				ISNULL(SUM(CN.NEW_RENTAL_AMOUNT), SUM(ide.BILLING_AMOUNT))
				+ ISNULL(SUM(CN.NEW_PPN_AMOUNT), SUM(ide.PPN_AMOUNT)) - ISNULL(SUM(ide.DISCOUNT_AMOUNT), 0)
		END 'OVERDUE_AMOUNT_INC_VAT'
		,ISNULL(SUM(CN.NEW_RENTAL_AMOUNT), SUM(ide.BILLING_AMOUNT)) - ISNULL(SUM(ide.DISCOUNT_AMOUNT), 0) 'OVERDUE_AMOUNT_EXC_VAT'
		,DATEDIFF(DAY, INVOICE_DUE_DATE, @p_as_of_date) 'OD_DAYS'
		,ISNULL(SUM(CN.NEW_RENTAL_AMOUNT), SUM(ide.BILLING_AMOUNT)) - ISNULL(SUM(ide.DISCOUNT_AMOUNT), 0) 'OVERDUE_AMOUNT_EXC_VAT'


		,glt.TRANSACTION_DATE
		,glt.TRANSACTION_DATE
		,am.RESULT_DESKCOLL
		,am.REMARK_DESKCOLL
		,am.PROMISSE_DATE
		,am.AGREEMENT_STATUS
		,am.AGREEMENT_DATE
		,am.TERMINATION_STATUS
		,am.TERMINATION_DATE
		,am.DESK_COLLECTOR_NAME
		,am.MARKETING_NAME
		,am.MARKETING_LEADER
		,i.CLIENT_ADDRESS
		,asst.BILLING_TO_ADDRESS
		,am.EMAIL
		,i.CLIENT_PHONE_NO
		,MAX(INVOICE_PAID) 'JUMLAH INVOICE_PAID'
		,MAX(INVDN.INVOICE_NOTDUE) 'JUMLAH INVOICE_NOTDUE'
		,@p_branch_name
		,ab.ASSET_NAME
		,ab.FA_REFF_NO_01
		,CONVERT(date, bildate.CRE_DATE, 103)
		,ide.DESCRIPTION
FROM	IFINOPL.dbo.INVOICE i WITH (NOLOCK)
		INNER JOIN IFINOPL.dbo.INVOICE_DETAIL ide WITH (NOLOCK) ON ide.INVOICE_NO = i.INVOICE_NO
		LEFT JOIN IFINOPL.dbo.CREDIT_NOTE_DETAIL CN WITH (NOLOCK) ON CN.INVOICE_DETAIL_ID = ide.ID
		OUTER APPLY
	(
		SELECT	MIN(tmp.INVOICE_DATE) invoice_date
		FROM	@temp tmp 
		WHERE tmp.AGREEMENT_NO = ide.AGREEMENT_NO
	) topdate
		outer apply
	(
		select	distinct
				AGREEMENT_EXTERNAL_NO
				,CLIENT_NAME
				,AMA.CREDIT_TERM
				,AMA.MARKETING_NAME
				,HEAD.NAME 'MARKETING_LEADER'
				,AMA.AGREEMENT_STATUS
				,AMA.AGREEMENT_NO
				,SEM.EMAIL
				,AMA.AGREEMENT_DATE
				,AMA.TERMINATION_DATE
				,AMA.TERMINATION_STATUS
				,dmn.RESULT_PROMISE_DATE 'PROMISSE_DATE'
				,dmn.RESULT_REMARKS 'REMARK_DESKCOLL'
				,mdd.RESULT_DETAIL_NAME 'RESULT_DESKCOLL'
				,isnull(mcr.COLLECTOR_NAME, AMA.MARKETING_NAME) 'DESK_COLLECTOR_NAME'
		from	IFINOPL.dbo.AGREEMENT_MAIN AMA with (nolock)
				left join IFINSYS.dbo.SYS_EMPLOYEE_MAIN SEM with (nolock) on SEM.CODE = AMA.MARKETING_CODE
				left join IFINSYS.dbo.SYS_EMPLOYEE_MAIN HEAD with (nolock) on HEAD.CODE = SEM.HEAD_EMP_CODE
				left join dbo.DESKCOLL_MAIN dmn with (nolock) on dmn.AGREEMENT_NO = AMA.AGREEMENT_NO
				left join dbo.MASTER_DESKCOLL_RESULT mdr with (nolock) on (mdr.CODE = dmn.RESULT_CODE)
				left join dbo.MASTER_DESKCOLL_RESULT_DETAIL mdd with (nolock) on (mdd.CODE = dmn.RESULT_DETAIL_CODE)
				left join dbo.MASTER_COLLECTOR mcr with (nolock) on (mcr.CODE = dmn.DESK_COLLECTOR_CODE)
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
	--AND    ide.ASSET_NO = aast.ASSET_NO    
	) asst
		outer apply
	(
		select	top 1
				b.ASSET_NAME
				,b.FA_REFF_NO_01
		from	IFINOPL.dbo.INVOICE_DETAIL a with (nolock)
				inner join dbo.AGREEMENT_ASSET b with (nolock) on a.ASSET_NO = b.ASSET_NO
		where a.INVOICE_NO = i.INVOICE_NO
	) ab
		outer apply
	(
		select	top 1
				TRANSACTION_DATE
		from	dbo.OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION with (nolock)
		where REFF_SOURCE_NO = i.INVOICE_NO
		order by TRANSACTION_DATE desc
	) glt
		outer apply
	(
		select	top 1
				oicr.INVOICE_EXTERNAL_NO
		from	dbo.INVOICE ii with (nolock)
				inner join dbo.INVOICE_DETAIL iid with (nolock) on iid.INVOICE_NO = ii.INVOICE_NO
				INNER JOIN dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST oicr with (nolock) on ii.INVOICE_NO = oicr.INVOICE_NO
		where	iid.AGREEMENT_NO	= am.AGREEMENT_NO
		and		iid.BILLING_NO		= ide.BILLING_NO
		and		iid.ASSET_NO		= ide.ASSET_NO
		and		oicr.REQUEST_STATUS	= 'CANCEL'
	) iiid
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
		and		cast(INV.INVOICE_DUE_DATE as date) <= cast(getdate() as date)
	) INVDN
	OUTER APPLY
	(
	SELECT TOP 1 CRE_DATE FROM dbo.OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION WHERE REFF_SOURCE_NO = i.INVOICE_NO AND TRANSACTION_NAME = 'INVOICE GENERATE'
	) bildate
where	i.INVOICE_STATUS				= 'POST'
and		cast(i.INVOICE_DUE_DATE as date) < cast(@p_as_of_date as date)
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
		,i.INVOICE_NO
		,ide.BILLING_AMOUNT
		,bildate.CRE_DATE
		--,item
		--,isnull(
		--		case
		--			when case
		--					when (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 then
		--						0
		--					else (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
		--				end <= 10 then '1'
		--			when	case
		--						when (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 then
		--							0
		--						else (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
		--					end >= 11
		--			and		case
		--						when (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 then
		--							0
		--						else (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
		--					end <= 90 then '2'
		--			when	case
		--						when (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 then
		--							0
		--						else (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
		--					end >= 91
		--			and		case
		--						when (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 then
		--							0
		--						else (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
		--					end <= 120 then '3'
		--			when	case
		--						when (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 then
		--							0
		--						else (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
		--					end >= 121
		--			and		case
		--						when (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 then
		--							0
		--						else (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
		--					end <= 180 then '4'
		--			when case
		--					when (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM < 0 then
		--						0
		--					else (isnull(datediff(day, topdate.invoice_date, @p_as_of_date), 0)) - am.CREDIT_TERM
		--				end >= 180 then '5'
		--		end, 0
		--	)
		,i.CLIENT_NO
		,glt.TRANSACTION_DATE
		,iiid.INVOICE_EXTERNAL_NO
		,am.RESULT_DESKCOLL
		,am.REMARK_DESKCOLL
		,am.PROMISSE_DATE
		,am.AGREEMENT_DATE
		,am.TERMINATION_STATUS
		,am.TERMINATION_DATE
		,am.DESK_COLLECTOR_NAME
		,i.CLIENT_ADDRESS
		,asst.BILLING_TO_ADDRESS
		,am.EMAIL
		,i.CLIENT_PHONE_NO
		,i.NEW_INVOICE_DATE
		,ab.FA_REFF_NO_01
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


-- Stored Procedure

-- Stored Procedure

CREATE procedure [dbo].[xsp_daily_overdue_getrows]
	(
		@p_branch_code nvarchar(10)
		,@p_as_of_date datetime
	)
as
begin

	select	row_number() over (order by am.AGREEMENT_EXTERNAL_NO) 'NO'
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
			,i.INVOICE_EXTERNAL_NO 'INVOICE_NO'
			,am.CREDIT_TERM 'TOP_DAYS'
			,case
				when INVOICE_TYPE = 'RENTAL' then right(ide.DESCRIPTION, 43)
				else ide.DESCRIPTION
			end 'PERIODE_SEWA'
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
			,datediff(day, INVOICE_DUE_DATE, '2024-07-31') 'OD_DAYS'
			,am.AGREEMENT_STATUS
			,am.AGREEMENT_DATE
			,am.TERMINATION_DATE
			,am.TERMINATION_STATUS
			,am.MARKETING_NAME
			,am.MARKETING_LEADER
			,i.CLIENT_ADDRESS
			,asst.BILLING_TO_ADDRESS
			,am.EMAIL
			,i.CLIENT_PHONE_NO
			,max(INVOICE_PAID) 'JUMLAH INVOICE_PAID'
			,max(INVDN.INVOICE_NOTDUE) 'JUMLAH INVOICE_NOTDUE'
	from	IFINOPL.dbo.INVOICE i
			inner join IFINOPL.dbo.INVOICE_DETAIL ide on ide.INVOICE_NO = i.INVOICE_NO
			left join IFINOPL.dbo.CREDIT_NOTE_DETAIL CN on CN.INVOICE_DETAIL_ID = ide.ID
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
			from	IFINOPL.dbo.AGREEMENT_MAIN AMA
					left join IFINSYS.dbo.SYS_EMPLOYEE_MAIN SEM on SEM.CODE = AMA.MARKETING_CODE
					left join IFINSYS.dbo.SYS_EMPLOYEE_MAIN HEAD on HEAD.CODE = SEM.HEAD_EMP_CODE
			where AMA.AGREEMENT_NO = ide.AGREEMENT_NO
		) am
			outer apply
		(
			select	top 1
					aast.ASSET_NAME
					,aast.PERIODE 'TENOR'
					,aast.BILLING_TO_FAKTUR_TYPE 'WAPU'
					,aast.BILLING_TO_ADDRESS
			from	IFINOPL.dbo.AGREEMENT_ASSET aast
			where ide.AGREEMENT_NO = aast.AGREEMENT_NO
		) asst
			outer apply
		(
			select	top 1
					b.ASSET_NAME
			from	IFINOPL.dbo.INVOICE_DETAIL a
					inner join dbo.AGREEMENT_ASSET b on a.ASSET_NO = b.ASSET_NO
			where a.INVOICE_NO = i.INVOICE_NO
		) ab
			outer apply
		(
			select	count(distinct INV.INVOICE_NO) 'INVOICE_PAID'
			from	IFINOPL.dbo.INVOICE_DETAIL INVD
					inner join IFINOPL.dbo.INVOICE INV on INV.INVOICE_NO = INVD.INVOICE_NO
			where	INVD.AGREEMENT_NO = am.AGREEMENT_NO
			and		INV.INVOICE_STATUS	= 'PAID'
		) INVD
			outer apply
		(
			select	count(distinct INV.INVOICE_NO) 'INVOICE_NOTDUE'
			from	IFINOPL.dbo.INVOICE_DETAIL INVD
					inner join IFINOPL.dbo.INVOICE INV on INV.INVOICE_NO = INVD.INVOICE_NO
			where	INVD.AGREEMENT_NO				= am.AGREEMENT_NO
			and		INV.INVOICE_STATUS					= 'POST'
			and		cast(INV.INVOICE_DUE_DATE as date) <= cast(@p_as_of_date as date)
		) INVDN
	where	i.INVOICE_STATUS				= 'POST'
	and		cast(i.INVOICE_DUE_DATE as date) <= cast(@p_as_of_date as date)
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
			,am.TERMINATION_STATUS;


end;

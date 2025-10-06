-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_rpt_billing_due_list_insert]
	(
		@p_user_id nvarchar(15)
		,@p_branch_code nvarchar(50)
		,@p_branch_name nvarchar(250)
		,@p_as_of_date datetime
		,@p_is_condition nvarchar(1)
		,@p_invoice_status NVARCHAR(50)
	)
as
begin
	declare @msg				nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_title		nvarchar(250)
			,@ppn_pct			decimal(9, 6)
			,@pph_pct			decimal(9, 6)
			,@star_asofdate		nvarchar(50)

	delete	dbo.rpt_billing_due_list
	where	user_id  = @p_user_id

	begin try

		select	@report_image = VALUE
		from	dbo.SYS_GLOBAL_PARAM
		where CODE = 'IMGDSF';

		select	@report_company = VALUE
		from	dbo.SYS_GLOBAL_PARAM
		where CODE = 'COMP2';

		select	@ppn_pct = value
		from	dbo.sys_global_param
		where	code = ('RTAXPPN') ;

		select	@pph_pct = value
		from	dbo.sys_global_param
		where	code = ('RTAXPPH') ;

		select	@star_asofdate = value
		from	dbo.sys_global_param
		where	code = ('SAODRBDL') ;

		set @report_title = N'Report Billing Due List';

		insert into dbo.RPT_BILLING_DUE_LIST
		(
			USER_ID
			,AS_OF_DATE
			,BRANCH_CODE
			,REPORT_COMPANY
			,REPORT_IMAGE
			,REPORT_TITLE
			,BRANCH_NAME
			,IS_CONDITION
			,INVOICE_NO
			,BILLING_NO
			,CLIENT_NO
			,NPWP_NO
			,CLIENT_NAME
			,INVOICE_TYPE
			,DESCRIPTION
			,BILLING_DATE
			,DUE_DATE
			--,STATUS
			,CURRENCY
			,RENTAL_AMOUNT
			,PPN_AMOUNT
			,INVOICE_AMOUNT
			,PPH_AMOUNT
			,NETT_AMOUNT
			,AGREEMEN_NO
			,START_SETTLEMENT_PERIODE
			,END_SETTLEMENT_PERIODE
			,FA_CODE
			,PLAT_NO
			,UNIT_TYPE
			,TOP_DAYS
			,BILLING_TYPE
			,FIRST_PAYMENT_TYPE
			,BILLING_MODE
			,BAST_DATE
			,GOLIVE_DATE
			,ASSET_STATUS
			,AGREEMENT_STATUS
			,INVOICE_STATUS
		)
		SELECT	@p_user_id
				,@p_as_of_date
				,@p_branch_code
				,@report_company
				,@report_image
				,@report_title
				,@p_branch_name
				,@p_is_condition
				,INV.INVOICE_EXTERNAL_NO
				,amz.BILLING_NO
				,AM.CLIENT_NO
				,AGS.BILLING_TO_NPWP
				,AM.CLIENT_NAME
				,INV.INVOICE_TYPE
				,INV.INVOICE_NAME
				,AMZ.BILLING_DATE
				,AMZ.DUE_DATE
				,AM.CURRENCY_CODE
				,amz.BILLING_AMOUNT
				,ISNULL(INV.PPN_AMOUNT, (AMZ.BILLING_AMOUNT * @ppn_pct/ 100))
				,ISNULL(INV.BILLING_AMOUNT, amz.BILLING_AMOUNT)
				,ISNULL(INV.PPH_AMOUNT, (AMZ.BILLING_AMOUNT * @pph_pct/ 100))
				,ISNULL(INV.BILLING_AMOUNT + INV.PPN_AMOUNT, amz.BILLING_AMOUNT + (AMZ.BILLING_AMOUNT * @ppn_pct/ 100))
				,AM.AGREEMENT_EXTERNAL_NO
				,period.period_date
				,period_due_date
				,amz.ASSET_NO
				,ags.FA_REFF_NO_01
				,ags.ASSET_NAME
				,CONVERT(NVARCHAR(5),amz.BILLING_NO) + '/' + CONVERT(NVARCHAR(5),AZ.BILLING_NO)
				,MBT.DESCRIPTION
				,case
						 when am.first_payment_type = 'ADV' then 'ADVANCE'
						 when am.first_payment_type = 'ARR' then 'ARREAR'
						 else ''
					 end 'first_payment_type'
				,ags.BILLING_MODE
				,CAST(ags.HANDOVER_BAST_DATE AS DATE)
				,CAST(AM.AGREEMENT_DATE AS DATE)
				,ags.ASSET_STATUS
				,AM.AGREEMENT_STATUS
				,CASE WHEN ISNULL(INV.INVOICE_STATUS,'') = '' THEN 'OPEN' ELSE INV.INVOICE_STATUS END
		FROM	dbo.AGREEMENT_ASSET_AMORTIZATION amz
				INNER JOIN dbo.AGREEMENT_ASSET ags ON ags.ASSET_NO = amz.ASSET_NO 
				INNER JOIN dbo.AGREEMENT_MAIN AM ON AM.AGREEMENT_NO = ags.AGREEMENT_NO
				OUTER APPLY (	SELECT	INV.INVOICE_STATUS 
										,INV.INVOICE_TYPE
										,INV.INVOICE_NAME
										,INVD.PPN_AMOUNT
										,INVD.BILLING_AMOUNT
										,INVD.PPH_AMOUNT
										,INV.INVOICE_EXTERNAL_NO
								FROM	dbo.INVOICE_DETAIL INVD
										INNER JOIN dbo.INVOICE INV ON INV.INVOICE_NO = INVD.INVOICE_NO
								WHERE	INVD.INVOICE_NO = AMZ.INVOICE_NO
								AND		INVD.ASSET_NO = AMZ.ASSET_NO
								AND		INVD.BILLING_NO = AMZ.BILLING_NO
							) INV
				outer APPLY (
								select	case am.first_payment_type
											when 'ARR'
											then period_date + 1
											else period_date
										end 'period_date'
										,period_due_date
								from	dbo.xfn_due_date_period(amz.asset_no,cast(amz.billing_no as int)) aa
								where	amz.billing_no = aa.billing_no
								and		amz.asset_no = aa.asset_no
							)period
				OUTER APPLY (SELECT MAX(AZ.BILLING_NO) 'BILLING_NO' FROM dbo.AGREEMENT_ASSET_AMORTIZATION AZ WHERE AZ.ASSET_NO = AGS.ASSET_NO) AZ
				INNER JOIN dbo.MASTER_BILLING_TYPE MBT ON MBT.CODE = AM.BILLING_TYPE
		WHERE	ISNULL(INVOICE_STATUS,'') = case @p_invoice_status
										when 'ALL' then ISNULL(INV.INVOICE_STATUS,'')
										when 'OPEN' then ''
										else @p_invoice_status
									end
		AND		CAST(amz.BILLING_DATE AS DATE) BETWEEN CAST(DATEADD(MONTH, (ABS(CONVERT(INT,@star_asofdate)) *-1) , @p_as_of_date) AS DATE) AND CAST(@p_as_of_date AS DATE)
		--select	distinct
		--		@p_user_id
		--		,@p_as_of_date
		--		,@p_branch_code
		--		,@report_company
		--		,@report_image
		--		,@report_title
		--		,@p_branch_name
		--		,@p_is_condition
		--		,isnull(i.INVOICE_EXTERNAL_NO, '')
		--		,asa.BILLING_NO
		--		,am.CLIENT_NO
		--		,i.CLIENT_NPWP
		--		,am.CLIENT_NAME
		--		,i.INVOICE_TYPE
		--		,id.DESCRIPTION
		--		,asa.BILLING_DATE
		--		,asa.DUE_DATE
		--		,i.INVOICE_STATUS
		--		,i.CURRENCY_CODE
		--		,asa.BILLING_AMOUNT
		--		,id.PPN_AMOUNT
		--		,id.TOTAL_AMOUNT
		--		,id.PPH_AMOUNT
		--		,id.BILLING_AMOUNT
		--		,am.AGREEMENT_EXTERNAL_NO
		--		,asa.DUE_DATE
		--		,i.INVOICE_DUE_DATE
		--		,ass.FA_CODE
		--		,ass.FA_REFF_NO_01
		--		,ass.FA_NAME
		--		,asa.BILLING_NO
		--		,mbt.DESCRIPTION
		--		,case
		--				when am.first_payment_type = 'ADV' then 'ADVANCE'
		--				when am.first_payment_type = 'ARR' then 'ARREAR'
		--				else ''
		--			end 'first_payment_type'
		--		,ass.BILLING_MODE
		--		,ass.handover_bast_date
		--		,am.AGREEMENT_DATE
		--		,ass.ASSET_STATUS
		--		,am.AGREEMENT_STATUS
		--		,i.INVOICE_STATUS
		--from	dbo.AGREEMENT_MAIN am with (nolock)
		--		inner join dbo.MASTER_BILLING_TYPE mbt with (nolock) on mbt.CODE = am.BILLING_TYPE
		--		inner join dbo.AGREEMENT_ASSET ass with (nolock) on ass.AGREEMENT_NO = am.AGREEMENT_NO
		--		inner join dbo.AGREEMENT_ASSET_AMORTIZATION asa with (nolock) on asa.AGREEMENT_NO = am.AGREEMENT_NO and asa.ASSET_NO = ass.ASSET_NO
		--		left join dbo.INVOICE_DETAIL id on id.AGREEMENT_NO = asa.AGREEMENT_NO and id.ASSET_NO = asa.ASSET_NO and asa.BILLING_NO = id.BILLING_NO and id.INVOICE_NO = asa.INVOICE_NO
		--		left join dbo.INVOICE i with (nolock) on asa.INVOICE_NO			= i.INVOICE_NO
		--where	isnull(i.INVOICE_STATUS, 'NEW') = 'NEW'
		--and		i.INVOICE_STATUS					= case @p_invoice_status
		--												when 'ALL' then i.INVOICE_STATUS
		--												else @p_invoice_status
		--											end	
		--and 	ass.ASSET_STATUS					= 'RENTED'
		--and		am.AGREEMENT_STATUS					= 'GO LIVE'
		--and		cast(asa.DUE_DATE as date) <= cast(@p_as_of_date as date)
		--and		am.BRANCH_CODE						= case @p_branch_code
		--												when 'ALL' then am.BRANCH_CODE
		--												else @p_branch_code
		--											end
	end try
	begin catch
		declare @error int;

		set @error = @@error;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg;
		end;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message();
			end;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message();
			end;
		end;

		raiserror(@msg, 16, -1);

		return;
	end catch;
end;

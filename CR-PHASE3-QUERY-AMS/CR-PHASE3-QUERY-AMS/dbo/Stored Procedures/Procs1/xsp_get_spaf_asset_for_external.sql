CREATE PROCEDURE dbo.xsp_get_spaf_asset_for_external
(
	@p_date datetime
)
as
begin

	/*case sensitif jangan di rubah
	agreementNo	appNo	branch	branchID	branchCode	dealerName	
	dealerCode	engineNo	chassisNo	goliveDate	assetSeqNo	
	skD_No	skD_date_app_dt	skD_date_apv_dt	totalAsset	customerName	
	customerNo	supplierName	type	packageType	periodLease	atpmid	brand	
	statusAgreement	subventionSubsidy	spafSubsidy	productOfferingName	receiptNoSPAF	
	receiptDateSPAF	receiptNoSubvention	receiptDateSubvention	billingNoSPAF	
	receiptUpdateDate	assetUpdateDate	agreementAssetId	insurance	customerid	
	agreementid	amountinstallment	amountcredit	downpayment	creditscoring	
	customer_type	mobilephone1	mobilephone2	email1	email2	occupation	income

	
	
	*/
	select	agrm.agreement_external_no						'agreementNo'		-- ambil external no
			,am.application_no								'appNo'
			,ass.branch_name								'branch'
			,ass.branch_code								'branchID'
			,ass.branch_name								'branchCode'
			,ass.vendor_name								'dealerName'
			,ass.vendor_code								'dealerCode'
			,av.engine_no									'engineNo'
			,av.chassis_no									'chassisNo'
			--,dbo.xfn_get_system_date()									'goliveDate'		-- sementara
			,agrm.agreement_date							'goliveDate'
			,isnull(ass.spaf_pct,2)									'assetSeqNo'		-- spafpct
			,am.application_external_no						'skD_No'			-- harusnya external no
			,getdate()										'skD_date_app_dt'	-- harusnya application date  -- sementara
			,getdate()										'skD_date_apv_dt'	-- approve date				  -- sementara
			,'1'											'totalAsset'
			,agrm.client_name								'customerName'
			,agrm.client_no									'customerNo'
			,ass.vendor_name								'supplierName'
			,'OPL'											'type'
			,case
				 when sa.spaf_amount > 0
					  and	sa.subvention_amount > 0 then '1'
				 else '2'
			 end											'packageType'
			,agrm.PERIODE									'periodLease'
			,case
				 when mi.class_type_code in
				 (
					 '11', '12', '13', '14', '24-NTR', '24-TR', '24-NTR'
				 ) then 'MMKSI'
				 else 'KTB'
			 end											'atpmid'			-- jika pc atau lcv maka MMKSI
			,av.merk_name									'brand'
			,agrm.agreement_status							'statusAgreement'
			,sa.subvention_amount							'subventionSubsidy'
			,sa.spaf_amount									'spafSubsidy'
																				--,mi.spaf_pct			  'SpafPct'
			,''												'productOfferingName'
			,sa.spaf_receipt_no								'receiptNoSPAF'
			,sa.receipt_date								'receiptDateSPAF'
			,sa.subvention_receipt_no						'receiptNoSubvention'
			,sa.receipt_date								'receiptDateSubvention'
			,sa.code										'billingNoSPAF'
			,sa.receipt_date								'receiptUpdateDate'
			,sa.validation_date								'assetUpdateDate'
			,sa.fa_code										'agreementAssetId'
																				--,am.application_date	  'SKDDate_APP_DT'
																				--,''						  'SKDDate_APV_DT'
			,''												'insurance'			--?
			,agrm.client_no									'customerid'
			,agrm.agreement_external_no						'agreementid'
			,isnull(aa.lease_rounded_amount, 0)				'amountinstallment'
			,''												'amountcredit'
			,'0'											'downpayment'
			,''												'creditscoring'
			,agrm.client_type								'customer_type'
			,aa.billing_to_area_no + aa.billing_to_phone_no 'mobilephone1'
			,aa.pickup_phone_area_no + aa.pickup_phone_no	'mobilephone2'
			,aa.email										'email1'
			,aa.email										'email2'
			,''												'occupation'
			,''												'income'
	from	dbo.spaf_asset						   sa
			left join dbo.asset					   ass on (sa.fa_code		  = ass.code)
			left join dbo.asset_vehicle			   av on (av.asset_code		  = ass.code)
			left join ifinopl.dbo.agreement_asset  aa on (aa.fa_code		  = sa.fa_code)
			left join ifinopl.dbo.agreement_main   agrm on (agrm.agreement_no = ass.agreement_no)
			left join ifinopl.dbo.application_main am on (am.application_no	  = agrm.application_no)
			--left join ifinopl.dbo.client_main	   cm on (cm.client_no		  = agrm.client_no)
			left join ifinbam.dbo.master_item	   mi on (mi.code			  = ass.item_code)
	--		outer apply
	--(
	--	select	billing_amount 'billing_amount'
	--	from	ifinopl.dbo.agreement_asset_amortization aaa
	--	where	aaa.agreement_no = agrm.agreement_no
	--			and aaa.asset_no = sa.fa_code
	--)											   billing
	--where	sa.date = @p_date ;
	WHERE agrm.AGREEMENT_DATE = @p_date
	and ass.STATUS <> 'CANCEL'
end ;

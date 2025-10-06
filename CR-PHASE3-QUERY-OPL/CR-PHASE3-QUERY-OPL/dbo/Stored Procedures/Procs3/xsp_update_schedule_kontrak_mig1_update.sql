CREATE PROCEDURE dbo.xsp_update_schedule_kontrak_mig1_update
(
	@p_agreement_no	nvarchar(50) 
)
as    
BEGIN

/*
--  bikin script untuk ubah schedule amort, bikin script global yang bisa di eksekusi per agreement.
-- bikin nilai os ar sebelum amort di ubah dan sesudah, keluarkan nilainya dan info ke pak Compi (koreksi by pak compi)
-- AGREEMENT_ASSET_AMORTIZATION
-- agreement_invoice
-- agreement_invoice_payment
-- invoice - hapus dan insert : cek apakah invoice yang ada di amortization ini ada di agreement lain
-- invoice_detail
-- tabel dari IAP = MIG1
*/

declare	@billing_to_faktur_type		nvarchar(10)
		,@is_invoice_deduct_pph		nvarchar(10)
		,@is_receipt_deduct_pph		nvarchar(10)
		,@is_journal_ppn_wapu		nvarchar(10)
		,@cutof_recon				datetime = '2023-11-30'
		,@cre_date					datetime = getdate()
		,@cre_by					nvarchar(15) = 'MIGRASI'
		,@cre_ip_address			nvarchar(15) = 'MIGRASI'
		,@mod_date					datetime = getdate()
		,@mod_by					nvarchar(15) = 'MIG1_MIGRASI'
		,@mod_ip_address			nvarchar(15) = 'MIG1_MIGRASI'
		,@top_days					INT=0

-- cek os ar balance
PRINT 'OS AR BEFORE UPDATE'
BEGIN

select		'OS AR NOT DUE BEFORE UPDATE',
			am.AGREEMENT_EXTERNAL_NO
			,am.CLIENT_NAME
			,sum(ai.AR_AMOUNT)							 'AR AMOUNT'
			,sum(aippp.AR_PAYMENT_AMOUNT)				 'PAYMENT AMOUNT'
			,sum(ai.AR_AMOUNT - aippp.AR_PAYMENT_AMOUNT) 'OUTSTANDING AR'
			, ai.INVOICE_NO
			,inv.IS_JOURNAL
from		dbo.AGREEMENT_INVOICE ai
inner join	dbo.AGREEMENT_MAIN	  am on am.AGREEMENT_NO = ai.AGREEMENT_NO
inner join	dbo.INVOICE			  inv on (inv.INVOICE_NO = ai.INVOICE_NO)
outer apply (
				select isnull(sum(aip.PAYMENT_AMOUNT), 0) 'AR_PAYMENT_AMOUNT'
				from   dbo.AGREEMENT_INVOICE_PAYMENT aip
				where  aip.AGREEMENT_INVOICE_CODE = ai.CODE --AND aip.CRE_BY IN ( 'MIGRASI', 'PAID_RECON')	
				AND	aip.PAYMENT_DATE <= '2023-11-30'		
			)					  aippp
outer apply (
				select sum(adh.ORIG_AMOUNT) 'deposit_amount'
				from   dbo.AGREEMENT_DEPOSIT_HISTORY adh
				where  adh.AGREEMENT_NO = am.AGREEMENT_NO
					   and adh.CRE_BY	= 'MIGRASI'
			) adh
where		ai.INVOICE_DATE		 <= @cutof_recon
			and inv.INVOICE_TYPE <> 'PENALTY'
			AND ai.AGREEMENT_NO = @p_agreement_no
group by	isnull(adh.deposit_amount, 0)
			,am.AGREEMENT_EXTERNAL_NO
			,am.CLIENT_NAME
			,ai.INVOICE_NO
			,inv.IS_JOURNAL


--select		'OS AR BEFORE UPDATE', SUM(isnull(ai.ar_amount, 0) - isnull(aip.payment_amount, 0)),sum(isnull(ai.ar_amount, 0))'ar_amount', SUM(ISNULL(aip.payment_amount, 0))'payment_amount'
--			,ai.AGREEMENT_NO
--from		dbo.AGREEMENT_INVOICE ai
--			outer apply
--(
--	select	isnull(sum(aip.PAYMENT_AMOUNT), 0) 'payment_amount'
--	from	dbo.AGREEMENT_INVOICE_PAYMENT aip
--	where	aip.AGREEMENT_INVOICE_CODE = ai.CODE
--			and aip.CRE_BY in
--(
--	'MIGRASI', 'PAID_RECON'
--)
--) aip
--where		ai.AGREEMENT_NO = @p_agreement_no
--			and ai.INVOICE_DATE <= @cutof_recon
--group by	ai.AGREEMENT_NO ;

END


PRINT 'MIG1_INVOICE'
-- update mig1_invoice sesuai dgn invoice sebelumnya
BEGIN
	select	 @billing_to_faktur_type = billing_to_faktur_type 
			,@is_invoice_deduct_pph	 = is_invoice_deduct_pph	 
			,@is_receipt_deduct_pph	 = is_receipt_deduct_pph	 
			,@is_journal_ppn_wapu	 = is_journal_ppn_wapu	 
	from	dbo.invoice
	where	invoice_no in (select top 1 invoice_no from dbo.agreement_asset_amortization where agreement_no = @p_agreement_no AND ISNULL(INVOICE_NO,'') <> '')
END

-- UPDATE DATA MIG1 INVOICE NYA SALAH, set invoicenya manual ya
BEGIN	

UPDATE dbo.MIG1_INVOICE
SET	BILLING_TO_FAKTUR_TYPE	= @billing_to_faktur_type
	,IS_INVOICE_DEDUCT_PPH	= @is_invoice_deduct_pph	
	,IS_RECEIPT_DEDUCT_PPH	= @is_receipt_deduct_pph	
	,IS_JOURNAL_PPN_WAPU	= @is_journal_ppn_wapu	
WHERE ISNULL(invoice_no,'') in (select ISNULL(invoice_no,'') from dbo.agreement_asset_amortization where agreement_no = @p_agreement_no AND ISNULL(INVOICE_NO,'') <> '')

SELECT 'MIG1_INVOICE',* FROM dbo.MIG1_INVOICE
WHERE ISNULL(invoice_no,'') in (select ISNULL(invoice_no,'') from dbo.agreement_asset_amortization where agreement_no = @p_agreement_no AND ISNULL(INVOICE_NO,'') <> '')

END

----- INSERT AMORTIZATION
PRINT 'INSERT AMORTIZATION'
BEGIN	

SELECT @top_days = CREDIT_TERM FROM dbo.AGREEMENT_MAIN
WHERE AGREEMENT_NO = @p_agreement_no

SELECT 'AGREEMENT_ASSET',* FROM dbo.AGREEMENT_ASSET
WHERE AGREEMENT_NO = @p_agreement_no

DELETE dbo.AGREEMENT_ASSET_AMORTIZATION
WHERE AGREEMENT_NO = @p_agreement_no

SELECT DISTINCT 'DISTINCT AGREEMENT_ASSET_AMORTIZATION', ASSET_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION
WHERE AGREEMENT_NO = @p_agreement_no

SELECT DISTINCT 'DISTINCT MIG1_AGREEMENT_ASSET_AMORTIZATION_ANNUALY', ASSET_NO FROM dbo.MIG1_AGREEMENT_ASSET_AMORTIZATION_ANNUALY
WHERE AGREEMENT_NO = @p_agreement_no

INSERT INTO dbo.AGREEMENT_ASSET_AMORTIZATION
(
    AGREEMENT_NO,
    BILLING_NO,
    ASSET_NO,
    DUE_DATE,
    BILLING_DATE,
    BILLING_AMOUNT,
    DESCRIPTION,
    INVOICE_NO,
    GENERATE_CODE,
    HOLD_BILLING_STATUS,
    HOLD_DATE,
    REFF_CODE,
    REFF_REMARK,
    REFF_DATE,
    CRE_DATE,
    CRE_BY,
    CRE_IP_ADDRESS,
    MOD_DATE,
    MOD_BY,
    MOD_IP_ADDRESS
)
SELECT	AGREEMENT_NO
		,BILLING_NO
		,ASSET_NO
		,DUE_DATE
		,BILLING_DATE
		,BILLING_AMOUNT
		,DESCRIPTION
		,INVOICE_NO
		,CASE(ISNULL(INVOICE_NO,'')) WHEN '' THEN NULL ELSE	'MIGRASI' END,
		HOLD_BILLING_STATUS,
		HOLD_DATE,
		REFF_CODE,
		REFF_REMARK,
		REFF_DATE,
		@cre_date		
       ,@cre_by		
       ,@cre_ip_address
       ,@mod_date					
	   ,@mod_by					
	   ,@mod_ip_address			
FROM	dbo.MIG1_AGREEMENT_ASSET_AMORTIZATION_ANNUALY
WHERE	AGREEMENT_NO = @p_agreement_no

UPDATE dbo.AGREEMENT_ASSET_AMORTIZATION
SET		DESCRIPTION = 'Billing ke ' + ISNULL(CONVERT(NVARCHAR(5),ivd.BILLING_NO),'') + ' dari periode ' + ISNULL(CONVERT(NVARCHAR(10), period.period_date, 103),'') + ' sampai dengan ' + ISNULL(CONVERT(NVARCHAR(10), period.period_due_date, 103),'')
FROM dbo.AGREEMENT_ASSET_AMORTIZATION ivd
	INNER JOIN dbo.AGREEMENT_MAIN am ON am.AGREEMENT_NO = ivd.AGREEMENT_NO
--OUTER APPLY (
--						select	asset_no
--								,billing_no
--								,case am.first_payment_type
--									when 'ARR'
--									then period_date + 1
--									else period_date
--								end 'period_date'
--								,case am.first_payment_type
--									when 'ADV'
--									then period_due_date - 1
--									else period_due_date
--								end 'period_due_date'
--						from	dbo.xfn_due_date_period(ivd.asset_no,cast(ivd.billing_no as int)) aa
--						where	ivd.billing_no = aa.billing_no
--						and		ivd.asset_no = aa.asset_no
--			)period
			outer apply
			(
				select	asset_no
						,billing_no
						,case am.first_payment_type
							when 'ARR'
							then period_date + 1
							else period_date
						end 'period_date'
						,period_due_date
				from	dbo.xfn_due_date_period(ivd.asset_no,cast(ivd.billing_no as int)) aa
				where	ivd.billing_no = aa.billing_no
				and		ivd.asset_no = aa.asset_no
			)period
WHERE	ivd.AGREEMENT_NO = @p_agreement_no

SELECT 'AGREEMENT_ASSET_AMORTIZATION',* FROM dbo.AGREEMENT_ASSET_AMORTIZATION
WHERE	AGREEMENT_NO = @p_agreement_no
END

-- DELETE TABLE INVOICE RELASI
PRINT 'DELETE TABLE INVOICE RELASI'

BEGIN	

DELETE dbo.AGREEMENT_INVOICE
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

DELETE dbo.AGREEMENT_INVOICE_PPH
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

DELETE dbo.INVOICE_PPH
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

DELETE dbo.INVOICE_DETAIL
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

DELETE  dbo.INVOICE
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

END
SELECT 'INSERT INVOICE'
------- INSER INVOICE
PRINT 'INSERT INVOICE'
BEGIN	

INSERT INTO dbo.INVOICE
(
    INVOICE_NO,
    INVOICE_EXTERNAL_NO,
    BRANCH_CODE,
    BRANCH_NAME,
    INVOICE_TYPE,
    INVOICE_DATE,
    INVOICE_DUE_DATE,
    INVOICE_NAME,
    INVOICE_STATUS,
    CLIENT_NO,
    CLIENT_NAME,
    CLIENT_ADDRESS,
    CLIENT_AREA_PHONE_NO,
    CLIENT_PHONE_NO,
    CLIENT_NPWP,
    CURRENCY_CODE,
    TOTAL_BILLING_AMOUNT,
    CREDIT_BILLING_AMOUNT,
    TOTAL_DISCOUNT_AMOUNT,
    TOTAL_PPN_AMOUNT,
    CREDIT_PPN_AMOUNT,
    TOTAL_PPH_AMOUNT,
    CREDIT_PPH_AMOUNT,
    TOTAL_AMOUNT,
    STAMP_DUTY_AMOUNT,
    FAKTUR_NO,
    GENERATE_CODE,
    SCHEME_CODE,
    RECEIVED_REFF_NO,
    RECEIVED_REFF_DATE,
    DELIVER_CODE,
    DELIVER_DATE,
    PAYMENT_PPN_CODE,
    PAYMENT_PPN_DATE,
    PAYMENT_PPH_CODE,
    PAYMENT_PPH_DATE,
    ADDITIONAL_INVOICE_CODE,
    IS_JOURNAL,
    IS_RECOGNITION_JOURNAL,
    KWITANSI_NO,
    NEW_INVOICE_DATE,
    BILLING_TO_FAKTUR_TYPE,
    IS_INVOICE_DEDUCT_PPH,
    IS_RECEIPT_DEDUCT_PPH,
    IS_JOURNAL_PPN_WAPU,
	IS_JOURNAL_DATE,
    CRE_DATE,
    CRE_BY,
    CRE_IP_ADDRESS,
    MOD_DATE,
    MOD_BY,
    MOD_IP_ADDRESS
)
SELECT INVOICE_NO,
       INVOICE_EXTERNAL_NO,
       BRANCH_CODE,
       BRANCH_NAME,
       INVOICE_TYPE,
       INVOICE_DATE,
       DATEADD(DAY,@top_days,INVOICE_DATE),
       INVOICE_NAME,
       INVOICE_STATUS,
       CLIENT_NO,
       CLIENT_NAME,
       CLIENT_ADDRESS,
       CLIENT_AREA_PHONE_NO,
       CLIENT_PHONE_NO,
       CLIENT_NPWP,
       CURRENCY_CODE,
       TOTAL_BILLING_AMOUNT,
       CREDIT_BILLING_AMOUNT,
       TOTAL_DISCOUNT_AMOUNT,
       TOTAL_PPN_AMOUNT,
       CREDIT_PPN_AMOUNT,
       TOTAL_PPH_AMOUNT,
       CREDIT_PPH_AMOUNT,
       TOTAL_AMOUNT,
       STAMP_DUTY_AMOUNT,
       FAKTUR_NO,
       GENERATE_CODE,
       SCHEME_CODE,
       RECEIVED_REFF_NO,
       RECEIVED_REFF_DATE,
       DELIVER_CODE,
       DELIVER_DATE,
       PAYMENT_PPN_CODE,
       PAYMENT_PPN_DATE,
       PAYMENT_PPH_CODE,
       PAYMENT_PPH_DATE,
       ADDITIONAL_INVOICE_CODE,
       IS_JOURNAL,
       IS_RECOGNITION_JOURNAL,
       KWITANSI_NO,
       NEW_INVOICE_DATE,
		@billing_to_faktur_type,
       @is_invoice_deduct_pph,
       @is_receipt_deduct_pph,
       @is_journal_ppn_wapu,
		CASE
			when INVOICE_DUE_DATE <= '2023-10-31' then INVOICE_DUE_DATE
			else '2023-10-31'
		END,
       @cre_date		
       ,@cre_by		
       ,@cre_ip_address
       ,@mod_date					
	   ,@mod_by					
	   ,@mod_ip_address			
FROM dbo.MIG1_INVOICE
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM MIG1_AGREEMENT_ASSET_AMORTIZATION_ANNUALY WHERE	AGREEMENT_NO = @p_agreement_no) 

SELECT 'INVOICE',* FROM dbo.INVOICE
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

INSERT INTO INVOICE_DETAIL
SELECT	INVOICE_NO,
        AGREEMENT_NO,
        ASSET_NO,
        BILLING_NO,
        DESCRIPTION,
        QUANTITY,
        TAX_SCHEME_CODE,
        TAX_SCHEME_NAME,
        BILLING_AMOUNT,
        DISCOUNT_AMOUNT,
        PPN_PCT,
        PPN_AMOUNT,
        PPH_PCT,
        PPH_AMOUNT,
        PPN_AMOUNT+BILLING_AMOUNT,
       @cre_date		
       ,@cre_by		
       ,@cre_ip_address
       ,@mod_date					
	   ,@mod_by					
	   ,@mod_ip_address			
FROM	dbo.MIG1_INVOICE_DETAIL
WHERE	INVOICE_NO IN (SELECT INVOICE_NO FROM MIG1_AGREEMENT_ASSET_AMORTIZATION_ANNUALY WHERE	AGREEMENT_NO = @p_agreement_no) 
AND		AGREEMENT_NO = @p_agreement_no

UPDATE dbo.INVOICE_DETAIL
SET		DESCRIPTION = AAZ.DESCRIPTION
FROM	dbo.INVOICE_DETAIL IND
		INNER JOIN dbo.AGREEMENT_ASSET_AMORTIZATION AAZ ON AAZ.AGREEMENT_NO = IND.AGREEMENT_NO AND AAZ.ASSET_NO = IND.ASSET_NO AND AAZ.BILLING_NO = IND.BILLING_NO
WHERE	IND.AGREEMENT_NO = @p_agreement_no

SELECT 'INVOICE_DETAIL',* FROM dbo.INVOICE_DETAIL
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

INSERT INTO dbo.INVOICE_PPH
(
    INVOICE_NO,
    SETTLEMENT_TYPE,
    SETTLEMENT_STATUS,
    TOTAL_PPH_AMOUNT,
    CRE_DATE,
    CRE_BY,
    CRE_IP_ADDRESS,
    MOD_DATE,
    MOD_BY,
    MOD_IP_ADDRESS
)
SELECT A.INVOICE_NO
		,'PKP'
		,'POST'
		,PPH_AMOUNT,
		@cre_date		
       ,@cre_by		
       ,@cre_ip_address
       ,@mod_date					
	   ,@mod_by					
	   ,@mod_ip_address			
FROM dbo.INVOICE_DETAIL A
	INNER JOIN dbo.INVOICE B ON B.INVOICE_NO = A.INVOICE_NO
WHERE A.INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 
AND B.IS_INVOICE_DEDUCT_PPH = '1'

SELECT 'INVOICE_PPH',* FROM dbo.INVOICE_PPH
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

INSERT INTO dbo.AGREEMENT_INVOICE_PPH
(
    CODE,
    INVOICE_NO,
    AGREEMENT_NO,
    ASSET_NO,
    BILLING_NO,
    DUE_DATE,
    INVOICE_DATE,
    PPH_AMOUNT,
    DESCRIPTION,
    CRE_DATE,
    CRE_BY,
    CRE_IP_ADDRESS,
    MOD_DATE,
    MOD_BY,
    MOD_IP_ADDRESS
)
SELECT REPLACE(invd.INVOICE_NO,'.','') + REPLACE(invd.ASSET_NO,'.','') + CONVERT(NVARCHAR(2),BILLING_NO )
		,invd.INVOICE_NO
		,AGREEMENT_NO
		,ASSET_NO
		,BILLING_NO,
		inv.INVOICE_DUE_DATE,
		inv.INVOICE_DATE,
		PPH_AMOUNT,
		DESCRIPTION,
		@cre_date		
       ,@cre_by		
       ,@cre_ip_address
      ,@mod_date					
	  ,@mod_by					
	  ,@mod_ip_address			
FROM dbo.INVOICE_DETAIL invd
		INNER JOIN dbo.INVOICE inv ON inv.INVOICE_NO = invd.INVOICE_NO
WHERE invd.INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

SELECT 'AGREEMENT_INVOICE_PPH',* FROM dbo.AGREEMENT_INVOICE_PPH
WHERE INVOICE_NO IN (SELECT INVOICE_NO FROM AGREEMENT_ASSET_AMORTIZATION WHERE	AGREEMENT_NO = @p_agreement_no) 

-----

INSERT INTO AGREEMENT_INVOICE
SELECT  REPLACE(INVOICE_NO,'.','') + REPLACE(ASSET_NO,'.','') + CONVERT(NVARCHAR(2),BILLING_NO ),
       INVOICE_NO,
       AGREEMENT_NO,
       ASSET_NO,
       BILLING_NO,
       DUE_DATE,
       INVOICE_DATE,
       AR_AMOUNT,
       DESCRIPTION,
		@cre_date		
       ,@cre_by		
       ,@cre_ip_address
       ,@mod_date					
	   ,@mod_by					
	   ,@mod_ip_address			
FROM	dbo.MIG1_AGREEMENT_INVOICE
WHERE	AGREEMENT_NO = @p_agreement_no

SELECT 'AGREEMENT_INVOICE',* FROM dbo.AGREEMENT_INVOICE
WHERE	AGREEMENT_NO = @p_agreement_no
END

------ delete invoice terbayar
PRINT 'delete invoice terbayar'
BEGIN
    
DELETE dbo.AGREEMENT_INVOICE_PAYMENT
where	INVOICE_NO IN (SELECT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no)
OR		AGREEMENT_INVOICE_PAYMENT.AGREEMENT_NO = @p_agreement_no
																					 
delete	OPL_INTERFACE_CASHIER_RECEIVED_REQUEST										 
where	INVOICE_NO IN (SELECT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no)
																					 
delete	IFINFIN.dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST							 
where	INVOICE_NO IN (SELECT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no)
																					 
delete	IFINFIN.dbo.CASHIER_RECEIVED_REQUEST										 
where	INVOICE_NO IN (SELECT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no)
																					 
delete	OPL_INTERFACE_CASHIER_RECEIVED_REQUEST										 
where	INVOICE_NO IN (SELECT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no)
																					 
delete	IFINFIN.dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST							 
where	INVOICE_NO IN (SELECT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no)
																					 
delete	IFINFIN.dbo.CASHIER_RECEIVED_REQUEST										 
where	INVOICE_NO IN (SELECT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no)

END

PRINT 'insert ke AGREEMENT_INVOICE_PAYMENT UNTUK INVOICE PAID'
-- insert ke AGREEMENT_INVOICE_PAYMENT UNTUK INVOICE PAID
BEGIN
    INSERT INTO dbo.AGREEMENT_INVOICE_PAYMENT
    (
        AGREEMENT_INVOICE_CODE,
        INVOICE_NO,
        AGREEMENT_NO,
        ASSET_NO,
        TRANSACTION_NO,
        TRANSACTION_TYPE,
        PAYMENT_DATE,
        PAYMENT_AMOUNT,
        VOUCHER_NO,
        DESCRIPTION,
        CRE_DATE,
        CRE_BY,
        CRE_IP_ADDRESS,
        MOD_DATE,
        MOD_BY,
        MOD_IP_ADDRESS,
        MF_PAYMENT_AMOUNT
    )
    
	SELECT CODE,
           a.INVOICE_NO,
           a.AGREEMENT_NO,
           a.ASSET_NO,
           a.BILLING_NO,
           'CASHIER',
           b.PAYMENT_DATE,
           b.PAYMENT_AMOUNT,--C.BILLING_AMOUNT + C.PPN_AMOUNT,
		   b.VOUCHER_NO,
           a.DESCRIPTION,
			@cre_date		
		   ,@cre_by		
		   ,@cre_ip_address
		   ,@mod_date					
		   ,@mod_by					
		   ,@mod_ip_address			
		    ,b.PAYMENT_AMOUNT--C.BILLING_AMOUNT + C.PPN_AMOUNT
	FROM	dbo.AGREEMENT_INVOICE a
			INNER JOIN dbo.MIG1_AGREEMENT_INVOICE_PAYMENT b ON b.AGREEMENT_NO = a.AGREEMENT_NO AND b.ASSET_NO = a.ASSET_NO AND b.TRANSACTION_NO = a.BILLING_NO
			INNER JOIN dbo.INVOICE_DETAIL C ON C.AGREEMENT_NO = a.AGREEMENT_NO AND C.ASSET_NO = a.ASSET_NO AND C.BILLING_NO = a.BILLING_NO AND C.INVOICE_NO = a.INVOICE_NO
	WHERE	a.AGREEMENT_NO = @p_agreement_no

	SELECT 'AGREEMENT_INVOICE_PAYMENT',* FROM dbo.AGREEMENT_INVOICE_PAYMENT a
	WHERE	a.AGREEMENT_NO = @p_agreement_no

END

PRINT 'INSERT KE CASHIER UNTUK INVOICE POST'

-- INSERT KE CASHIER UNTUK INVOICE POST
begin
declare @DATE				 datetime = getdate()
		,@CASHIER_INVOICE_NO nvarchar(50) ;

declare C_INVOICE cursor for
select	INVOICE_NO
from	IFINOPL.DBO.INVOICE
where	INVOICE_NO in (SELECT DISTINCT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no )
AND		INVOICE_STATUS = 'POST'

open	C_INVOICE ;

fetch	C_INVOICE
into	@CASHIER_INVOICE_NO ;

while @@fetch_status = 0
BEGIN

	exec IFINOPL.DBO.INVOICE_TO_INTERFACE_CASHIER_RECEIVE_INSERT	@CASHIER_INVOICE_NO -- NVARCHAR(50)
																	,@mod_date					
																	,@mod_by					
																	,@mod_ip_address			
	
	fetch C_INVOICE
	into @CASHIER_INVOICE_NO ;
end ;

close C_INVOICE ;
deallocate C_INVOICE ;

select	'OPL_INTERFACE_CASHIER_RECEIVED_REQUEST',*
from	dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST
where	INVOICE_NO in (SELECT DISTINCT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no )

select	'OPL_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL',*
from	dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL
where	CASHIER_RECEIVED_REQUEST_CODE IN (SELECT CODE FROM dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST
where	INVOICE_NO in (SELECT DISTINCT INVOICE_NO FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @p_agreement_no ))

end

-- cek os ar balance
PRINT 'OS AR AFTER UPDATE'
BEGIN
 
select		'OS AR NOT DUE AFTER UPDATE',
			am.AGREEMENT_EXTERNAL_NO
			,am.CLIENT_NAME
			,sum(ai.AR_AMOUNT)							 'AR AMOUNT'
			,sum(aippp.AR_PAYMENT_AMOUNT)				 'PAYMENT AMOUNT'
			,sum(ai.AR_AMOUNT - aippp.AR_PAYMENT_AMOUNT) 'OUTSTANDING AR'
			, ai.INVOICE_NO
			,inv.IS_JOURNAL
from		dbo.AGREEMENT_INVOICE ai
inner join	dbo.AGREEMENT_MAIN	  am on am.AGREEMENT_NO = ai.AGREEMENT_NO
inner join	dbo.INVOICE			  inv on (inv.INVOICE_NO = ai.INVOICE_NO)
outer apply (
				select isnull(sum(aip.PAYMENT_AMOUNT), 0) 'AR_PAYMENT_AMOUNT'
				from   dbo.AGREEMENT_INVOICE_PAYMENT aip
				where  aip.AGREEMENT_INVOICE_CODE = ai.CODE --AND aip.CRE_BY IN ( 'MIGRASI', 'PAID_RECON')	
				AND	aip.PAYMENT_DATE <= '2023-11-30'		
			)					  aippp
outer apply (
				select sum(adh.ORIG_AMOUNT) 'deposit_amount'
				from   dbo.AGREEMENT_DEPOSIT_HISTORY adh
				where  adh.AGREEMENT_NO = am.AGREEMENT_NO
					   and adh.CRE_BY	= 'MIGRASI'
			) adh
where		ai.INVOICE_DATE		 <= @cutof_recon
			and inv.INVOICE_TYPE <> 'PENALTY'
			AND ai.AGREEMENT_NO = @p_agreement_no
group by	isnull(adh.deposit_amount, 0)
			,am.AGREEMENT_EXTERNAL_NO
			,am.CLIENT_NAME
			,ai.INVOICE_NO
			,inv.IS_JOURNAL


--select		'OS AR AFTER UPDATE', sum(isnull(ai.ar_amount, 0) - isnull(aip.payment_amount, 0)),sum(isnull(ai.ar_amount, 0))'ar_amount', SUM(ISNULL(aip.payment_amount, 0))'payment_amount'
--			,ai.AGREEMENT_NO
--from		dbo.AGREEMENT_INVOICE ai
--			outer apply
--(
--	select	isnull(sum(aip.PAYMENT_AMOUNT), 0) 'payment_amount'
--	from	dbo.AGREEMENT_INVOICE_PAYMENT aip
--	where	aip.AGREEMENT_INVOICE_CODE = ai.CODE
--			and aip.CRE_BY in
--(
--	'MIGRASI', 'PAID_RECON'
--)
--) aip
--where		ai.AGREEMENT_NO = @p_agreement_no
--			and ai.INVOICE_DATE <= @cutof_recon
--group by	ai.AGREEMENT_NO ;

END

END

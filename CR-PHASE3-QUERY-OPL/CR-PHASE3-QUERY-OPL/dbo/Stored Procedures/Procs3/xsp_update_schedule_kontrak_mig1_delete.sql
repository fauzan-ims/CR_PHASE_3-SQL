CREATE PROCEDURE dbo.xsp_update_schedule_kontrak_mig1_delete
(
	@p_agreement_no	nvarchar(50) 
)
as    
begin

/*
	delete invoice yang udah masuk bulanan yang di tiadakan pada amotization,
*/

	declare @cutof_recon				datetime = '2023-11-30'

if exists 
(
	select	1
	from	ifinfin.dbo.cashier_transaction a
			INNER JOIN IFINFIN.dbo.CASHIER_TRANSACTION_DETAIL b ON b.CASHIER_TRANSACTION_CODE = a.CODE
			INNER JOIN ifinfin.dbo.CASHIER_RECEIVED_REQUEST c ON a.RECEIVED_REQUEST_CODE = b.RECEIVED_REQUEST_CODE
	where	cashier_status = 'PAID'
	and		c.INVOICE_NO IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)
)
begin
	raiserror('cashier_transaction Invoice udah terbayar',16,1)
	return;
end
else
if exists
(
	select	1 
	from	dbo.agreement_invoice_payment	
	where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)
)
begin
	raiserror('agreement_invoice_payment Sudah terbayar',16,-1)
	return;
END
ELSE
BEGIN
    

-- finance

PRINT 'SELECT FINANCE'
select 'ifinfin.dbo.fin_interface_cashier_received_request_detail',* from 	ifinfin.dbo.fin_interface_cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from ifinfin.dbo.fin_interface_cashier_received_request fin where invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no))

select 'ifinfin.dbo.fin_interface_cashier_received_request',* from 	ifinfin.dbo.fin_interface_cashier_received_request
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'ifinfin.dbo.cashier_received_request_detail',* from 	ifinfin.dbo.cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from ifinfin.dbo.cashier_received_request fin where invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no))

select 'ifinfin.dbo.cashier_received_request',* from 	ifinfin.dbo.cashier_received_request
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

-- delete 
PRINT 'delete FINANCE'

delete	ifinfin.dbo.fin_interface_cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from ifinfin.dbo.fin_interface_cashier_received_request fin where invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no))

delete	ifinfin.dbo.fin_interface_cashier_received_request
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

delete	ifinfin.dbo.cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from ifinfin.dbo.cashier_received_request fin where invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no))

delete	ifinfin.dbo.cashier_received_request
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

-- opl
-- select
PRINT 'select OPL'

select 'dbo.opl_interface_cashier_received_request_detail',* from 	dbo.opl_interface_cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from dbo.opl_interface_cashier_received_request fin where invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no))

select 'opl_interface_cashier_received_request',* from 	dbo.opl_interface_cashier_received_request
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'agreement_invoice',* from 	dbo.agreement_invoice 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'agreement_invoice_payment',* from 	dbo.agreement_invoice_payment 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'invoice_pph',* from 	dbo.invoice_pph 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'agreement_invoice_pph',* from 	dbo.agreement_invoice_pph 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'invoice',* from 	dbo.invoice 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'invoice_detail',* from 	dbo.invoice_detail 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

PRINT 'delete OPL'
-- delete
delete	dbo.opl_interface_cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from dbo.opl_interface_cashier_received_request fin where invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no))

delete	dbo.opl_interface_cashier_received_request
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

delete	dbo.agreement_invoice 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

delete	dbo.agreement_invoice_payment 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

delete	dbo.invoice_pph 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

delete	dbo.agreement_invoice_pph 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

delete	dbo.invoice 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

delete	dbo.invoice_detail 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)


PRINT 'TERHAPUS FINANCE'
SELECT 'TERHAPUS'

--finance
select 'ifinfin.dbo.fin_interface_cashier_received_request_detail',* from 	ifinfin.dbo.fin_interface_cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from ifinfin.dbo.fin_interface_cashier_received_request fin where invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no))

select 'ifinfin.dbo.fin_interface_cashier_received_request',* from 	ifinfin.dbo.fin_interface_cashier_received_request
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'ifinfin.dbo.cashier_received_request_detail',* from 	ifinfin.dbo.cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from ifinfin.dbo.cashier_received_request fin where invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no))

select 'ifinfin.dbo.cashier_received_request',* from 	ifinfin.dbo.cashier_received_request
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

-- opl
PRINT 'TERHAPUS OPL'
select 'dbo.opl_interface_cashier_received_request_detail',* from 	dbo.opl_interface_cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from dbo.opl_interface_cashier_received_request fin where invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no))

select 'opl_interface_cashier_received_request',* from 	dbo.opl_interface_cashier_received_request
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'agreement_invoice',* from 	dbo.agreement_invoice 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'agreement_invoice_payment',* from 	dbo.agreement_invoice_payment 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'invoice_pph',* from 	dbo.invoice_pph 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

select 'agreement_invoice_pph',* from 	dbo.agreement_invoice_pph 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)


select 'invoice',* from 	dbo.invoice 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

								select 'invoice_detail',* from 	dbo.invoice_detail 
where	invoice_no  IN (	SELECT A.INVOICE_NO FROM dbo.INVOICE A
								INNER JOIN dbo.INVOICE_DETAIL B ON B.INVOICE_NO = A.INVOICE_NO
								WHERE ISNULL(A.INVOICE_NO,'') NOT IN (SELECT ISNULL(INVOICE_NO,'') FROM dbo.AGREEMENT_ASSET_AMORTIZATION )
								AND A.MOD_BY = 'MIGRASI'
								AND INVOICE_STATUS = 'POST'
								AND B.AGREEMENT_NO = @p_agreement_no)

--finance
PRINT 'TIDAK DI HAPUS FINANCE'
SELECT 'TIDAK DI HAPUS'

select 'ifinfin.dbo.fin_interface_cashier_received_request_detail',* from 	ifinfin.dbo.fin_interface_cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from ifinfin.dbo.fin_interface_cashier_received_request fin 
										where invoice_no  in (	select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> ''))
																	

select 'ifinfin.dbo.fin_interface_cashier_received_request',* from 	ifinfin.dbo.fin_interface_cashier_received_request
where invoice_no  in (	select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> '')
																

select 'ifinfin.dbo.cashier_received_request_detail',* from 	ifinfin.dbo.cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from ifinfin.dbo.cashier_received_request fin where invoice_no in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> ''))

select 'ifinfin.dbo.cashier_received_request',* from 	ifinfin.dbo.cashier_received_request
where	invoice_no  in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> '')

-- opl
PRINT 'TIDAK DIHAPUS OPL'
select 'dbo.opl_interface_cashier_received_request_detail',* from 	dbo.opl_interface_cashier_received_request_detail
where	cashier_received_request_code in (select fin.code from dbo.opl_interface_cashier_received_request fin where invoice_no  in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> ''))

select 'opl_interface_cashier_received_request',* from 	dbo.opl_interface_cashier_received_request
where	invoice_no in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> '')

select 'agreement_invoice',* from 	dbo.agreement_invoice 
where	invoice_no  in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> '')

select 'agreement_invoice_payment',* from 	dbo.agreement_invoice_payment 
where	invoice_no  in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> '')

select 'invoice_pph',* from 	dbo.invoice_pph 
where	invoice_no  in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> '')

select 'agreement_invoice_pph',* from 	dbo.agreement_invoice_pph 
where	invoice_no  in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> '')

select 'invoice',* from 	dbo.invoice 
where	invoice_no  in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> '')

select 'invoice_detail',* from 	dbo.invoice_detail 
where	invoice_no  in (select distinct a.invoice_no from dbo.agreement_asset_amortization a where a.agreement_no = @p_agreement_no and isnull(a.invoice_no,'') <> '')


-- cek os ar balance
BEGIN
    
	
select		'OS AR BEFORE UPDATE',
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
				AND	aip.PAYMENT_DATE <= '2023-11-28'		
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
--select		'cek os ar balance',SUM(isnull(ai.ar_amount, 0) - isnull(aip.payment_amount, 0)),sum(isnull(ai.ar_amount, 0))'ar_amount', SUM(ISNULL(aip.payment_amount, 0))'payment_amount'
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
--			and ai.INVOICE_DATE <= '2023-10-31'
--group by	ai.AGREEMENT_NO ;

END

END
end

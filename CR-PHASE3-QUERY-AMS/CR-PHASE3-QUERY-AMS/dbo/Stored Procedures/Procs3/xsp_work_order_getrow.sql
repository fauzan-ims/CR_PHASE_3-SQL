CREATE PROCEDURE [dbo].[xsp_work_order_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	wo.code
			,wo.asset_code
			,ass.item_name
			,maintenance_code
			,wo.maintenance_by
			,wo.status
			,wo.remark
			,wo.total_ppn_amount
			,wo.total_pph_amount
			,wo.total_amount
			,wo.payment_amount
			,wo.actual_km
			,wo.work_date
			,mnt.service_type
			,mnt.branch_code
			,mnt.branch_name
			,mnt.vendor_code
			,mnt.vendor_name
			,mnt.is_reimburse
			,mnt.bank_account_no
			,mnt.bank_account_name
			,wo.file_name
			,wo.file_path
			,wo.invoice_no
			,wo.faktur_no
			,wo.faktur_date
			,fin.payment_transaction_date 'transaction_date'
			,fin.payment_value_date		  'value_date'
			,wo.last_km_service
			--,sem.name
			,wo.PROCED_BY name
			,wo.last_meter
			,wo.is_claim_approve
			,wo.claim_approve_claim_date
			,wo.invoice_date
	from	work_order										 wo
			left join dbo.asset								 ass on (wo.asset_code					= ass.code)
																	and (ass.company_code			= wo.company_code)
			left join dbo.maintenance						 mnt on (mnt.code						= wo.maintenance_code)
			left join dbo.payment_request					 pr on (pr.payment_source_no			= wo.code and pr.payment_status <> 'CANCEL') --(+)Raffi : freshdesk 2327268 <> cancel dikarnakan ada cancel payment request pada kontrak sehingga mengambi 2 trx
			left join dbo.payment_transaction_detail		 ptd on (ptd.payment_request_code		= pr.code)
			left join dbo.payment_transaction				 pt on (pt.code							= ptd.payment_transaction_code)
			left join ifinfin.dbo.payment_request			 finpr on (finpr.payment_source_no		= pt.code)
			left join ifinfin.dbo.payment_transaction_detail finptd on (finptd.payment_request_code = finpr.code)
			left join ifinfin.dbo.payment_transaction		 fin on (fin.code						= finptd.payment_transaction_code)
			left join ifinsys.dbo.sys_employee_main			 sem on sem.code						= wo.proced_by
	where	wo.code = @p_code ;
end ;

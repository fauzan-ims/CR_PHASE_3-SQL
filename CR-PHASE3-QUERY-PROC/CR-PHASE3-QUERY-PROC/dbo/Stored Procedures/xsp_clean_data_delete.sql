CREATE PROCEDURE dbo.xsp_clean_data_delete
as
begin
	declare @msg nvarchar(max) ;

	begin try
		truncate table dbo.procurement_request_item ;

		truncate table dbo.procurement_request_document ;

		delete	dbo.procurement_request ;

		delete	dbo.procurement ;

		truncate table dbo.quotation_review_detail ;

		truncate table dbo.quotation_review_document ;

		truncate table dbo.TERM_OF_PAYMENT ;

		delete	dbo.quotation_review ;

		truncate table dbo.supplier_selection_detail ;

		delete	dbo.supplier_selection ;

		truncate table dbo.purchase_order_detail ;

		truncate table dbo.purchase_order_detail_object_info ;

		delete	dbo.purchase_order ;

		truncate table dbo.good_receipt_note_detail ;

		truncate table dbo.good_receipt_note_detail_doc ;

		delete	dbo.good_receipt_note ;

		truncate table dbo.final_good_receipt_note_detail ;

		delete	dbo.final_good_receipt_note ;

		truncate table ap_invoice_registration_detail ;

		delete	ap_invoice_registration ;

		truncate table ap_payment_request_detail ;

		delete	ap_payment_request ;

		truncate table dbo.RPT_SURAT_KUASA_PO ;

		truncate table dbo.RPT_PURCHASE_ORDER_UNIT_DETAIL ;

		truncate table dbo.RPT_PURCHASE_ORDER_UNIT ;

		truncate table dbo.RPT_PURCHASE_ORDER_KAROSERI_DETAIL ;

		truncate table dbo.RPT_PURCHASE_ORDER_KAROSERI ;

		truncate table dbo.RPT_PURCHASE_ORDER_DETAIL ;

		truncate table dbo.RPT_PURCHASE_ORDER ;

		truncate table dbo.RPT_PAYMENT_REQUEST_DETAIL ;

		truncate table dbo.RPT_PAYMENT_REQUEST ;

		truncate table dbo.RPT_MONITORING_PO ;

		truncate table dbo.RPT_GOOD_RECEIPT_NOTE_DETAIL ;

		truncate table dbo.PROC_INTERFACE_PURCHASE_REQUEST ;

		truncate table dbo.PROC_INTERFACE_PURCHASE_ORDER_UPDATE ;

		truncate table dbo.PROC_INTERFACE_ASSET_VEHICLE ;

		truncate table dbo.PROC_INTERFACE_ASSET_MACHINE ;

		truncate table dbo.PROC_INTERFACE_ASSET_HE ;

		truncate table dbo.PROC_INTERFACE_ASSET_ELECTRONIC ;

		truncate table dbo.PROC_INTERFACE_APPROVAL_REQUEST ;

		truncate table dbo.PROC_INTERFACE_APPROVAL_DOCUMENT ;

		truncate table dbo.PROC_INTERFACE_APPROVAL_DIMENSION ;

		truncate table dbo.INVENTORY_OPNAME ;

		truncate table dbo.INVENTORY_CARD ;

		truncate table dbo.INVENTORY_ADJUSTMENT_DETAIL ;

		truncate table dbo.INVENTORY_ADJUSTMENT ;

		truncate table dbo.IFINPROC_INTERFACE_PAYMENT_REQUEST_DETAIL ;

		truncate table dbo.IFINPROC_INTERFACE_PAYMENT_REQUEST ;

		truncate table dbo.IFINPROC_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL ;

		delete	dbo.IFINPROC_INTERFACE_JOURNAL_GL_LINK_TRANSACTION ;

		truncate table dbo.IFINPROC_INTERFACE_HANDOVER_REQUEST ;

		truncate table dbo.IFINPROC_INTERFACE_DOCUMENT_PENDING_DETAIL ;

		truncate table dbo.IFINPROC_INTERFACE_DOCUMENT_PENDING ;

		truncate table dbo.IFINPROC_INTERFACE_ASSET_EXPENSE_LEDGER ;

		truncate table dbo.IFINPROC_INTERFACE_ADJUSTMENT_ASSET ;

		truncate table dbo.IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST ;

		truncate table dbo.GOOD_RECEIPT_NOTE_DETAIL_OBJECT_INFO ;

		truncate table dbo.GOOD_RECEIPT_NOTE_DETAIL_CHECKLIST ;

		truncate table dbo.EPROC_INTERFACE_ASSET ;

		truncate table dbo.EPROC_INTERFACE_AP_PAYMENT_REQUEST_DETAIL ;

		truncate table dbo.EPROC_INTERFACE_AP_PAYMENT_REQUEST ;

		truncate table dbo.RPT_GOOD_RECEIPT_NOTE ;

		dbcc checkident('IFINPROC_INTERFACE_JOURNAL_GL_LINK_TRANSACTION', reseed, 0) ;

		dbcc checkident('TRANSACTION_LOCK', reseed, 0) ;

		update	dbo.sys_job_tasklist
		set		last_id = 0
				,eod_status = 'NONE'
				,eod_remark = '' ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

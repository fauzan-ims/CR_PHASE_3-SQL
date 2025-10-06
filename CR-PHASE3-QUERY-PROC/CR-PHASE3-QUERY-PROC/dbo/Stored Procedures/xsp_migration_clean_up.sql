CREATE PROCEDURE dbo.xsp_migration_clean_up
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

		truncate table dbo.PROC_INTERFACE_PURCHASE_REQUEST

		truncate table dbo.PROC_INTERFACE_PURCHASE_ORDER_UPDATE

		truncate table dbo.PROC_INTERFACE_SYS_DOCUMENT_UPLOAD

		truncate table dbo.RPT_GOOD_RECEIPT_NOTE ;

		dbcc checkident('IFINPROC_INTERFACE_JOURNAL_GL_LINK_TRANSACTION', reseed, 0) ;

		dbcc checkident('TRANSACTION_LOCK', reseed, 0) ;

		update	dbo.sys_job_tasklist
		set		last_id = 0
				,eod_status = 'NONE'
				,eod_remark = '' ;

		select		(schema_name(a.schema_id) + '.' + a.name) as tablename
					,sum(b.rows) as recordcount
		from		sys.objects a
					inner join sys.partitions b on a.object_id = b.object_id
		where		a.type = 'u'
		group by	a.schema_id
					,a.name
		order by	tablename desc ;

		select		A.TABLE_CATALOG as CATALOG
					,A.TABLE_SCHEMA as "SCHEMA"
					,A.TABLE_NAME as "TABLE"
					,B.COLUMN_NAME as "COLUMN"
					,ident_seed(A.TABLE_NAME) as Seed
					,ident_incr(A.TABLE_NAME) as Increment
					,ident_current(A.TABLE_NAME) as Curr_Value
		from		INFORMATION_SCHEMA.TABLES A
					,INFORMATION_SCHEMA.COLUMNS B
		where		A.TABLE_CATALOG															 = B.TABLE_CATALOG
					and A.TABLE_SCHEMA														 = B.TABLE_SCHEMA
					and A.TABLE_NAME														 = B.TABLE_NAME
					and columnproperty(object_id(B.TABLE_NAME), B.COLUMN_NAME, 'IsIdentity') = 1
					and objectproperty(object_id(A.TABLE_NAME), 'TableHasIdentity')			 = 1
					and A.TABLE_TYPE														 = 'BASE TABLE' 
		order by	A.TABLE_SCHEMA
					,A.TABLE_NAME ;
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

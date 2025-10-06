CREATE procedure dbo.xsp_migration_clean_up
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete dbo.WITHHOLDING_TAX_HISTORY ;

		delete dbo.UPLOAD_ERROR_LOG ;

		delete dbo.TRANSACTION_LOCK_HISTORY ;

		delete dbo.TRANSACTION_LOCK ;

		delete dbo.SUSPEND_REVENUE_DETAIL ;

		delete dbo.SUSPEND_REVENUE ;

		delete dbo.SUSPEND_RELEASE ;

		delete dbo.SUSPEND_MERGER_DETAIL ;

		delete dbo.SUSPEND_MERGER ;

		delete dbo.SUSPEND_HISTORY ;

		delete dbo.SUSPEND_ALLOCATION_DETAIL ;

		delete dbo.SUSPEND_ALLOCATION ;

		delete dbo.SUSPEND_MAIN ;

		delete dbo.RPT_UNKNOWN_MONITORING ;

		delete dbo.RPT_RECEIVED_VOUCHER ;

		delete dbo.RPT_PENDING_DISBURSEMENT ;

		delete dbo.RPT_PAYMENT_VOUCHER ;

		delete dbo.RPT_INVOICE_ALLOCATION ;

		delete dbo.RPT_FINANCE_TRANSACTION ;

		delete dbo.RPT_CASHIER_TRANSACTION_CASH ;

		delete dbo.RPT_BANK_BOOK ;

		delete dbo.RPT_AUTO_DEBET ;

		delete dbo.RPT_AP_PAYMENT_REQUEST ;

		delete dbo.RPT_ADVANCE_ALLOCATION_PER_AGREEMENT ;

		delete dbo.REVERSAL_MAIN ;

		delete dbo.REPRINT_RECEIPT ;

		delete dbo.RECONCILE_TRANSACTION ;

		delete dbo.RECONCILE_MAIN ;

		delete dbo.RECEIVED_VOUCHER_DETAIL ;

		delete dbo.RECEIVED_VOUCHER ;

		delete dbo.RECEIVED_TRANSACTION_DETAIL ;

		delete dbo.RECEIVED_TRANSACTION ;

		delete dbo.RECEIVED_REQUEST_DETAIL ;

		delete dbo.RECEIVED_REQUEST ;

		delete dbo.RECEIPT_VOID_DETAIL ;

		delete dbo.RECEIPT_VOID ;

		delete dbo.RECEIPT_REGISTER_DETAIL ;

		delete dbo.RECEIPT_REGISTER ;

		delete dbo.PAYMENT_VOUCHER_DETAIL ;

		delete dbo.PAYMENT_VOUCHER ;

		delete dbo.PAYMENT_TRANSACTION_DETAIL ;

		delete dbo.PAYMENT_TRANSACTION ;

		delete dbo.PAYMENT_REQUEST_DETAIL ;

		delete dbo.PAYMENT_REQUEST ;

		delete dbo.IFINFIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT ;

		delete dbo.FIN_INTERFACE_RECEIVED_REQUEST_DETAIL ;

		delete dbo.FIN_INTERFACE_RECEIVED_REQUEST ;

		delete dbo.FIN_INTERFACE_PAYMENT_REQUEST_DETAIL ;

		delete dbo.FIN_INTERFACE_PAYMENT_REQUEST ;

		delete dbo.FIN_INTERFACE_NOTIFICATION_REQUEST ;

		delete dbo.FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL ;

		delete dbo.FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION ;

		delete dbo.FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL ;

		delete dbo.FIN_INTERFACE_DEPOSIT_REVENUE ;

		delete dbo.FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL ;

		delete dbo.FIN_INTERFACE_DEPOSIT_ALLOCATION ;

		delete dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL ;

		delete dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST ;

		delete dbo.FIN_INTERFACE_BANK_MUTATION_OUT ;

		delete dbo.FIN_INTERFACE_BANK_MUTATION_HISTORY ;

		delete dbo.FIN_INTERFACE_BANK_MUTATION ;

		delete dbo.FIN_INTERFACE_APPROVAL_REQUEST_DIMENSION ;

		delete dbo.FIN_INTERFACE_APPROVAL_REQUEST ;

		delete dbo.FIN_INTERFACE_AGREEMENT_UPDATE ;

		delete dbo.FIN_INTERFACE_AGREEMENT_RETENTION_HISTORY ;

		delete dbo.FIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT ;

		delete dbo.FIN_INTERFACE_AGREEMENT_MAIN ;

		delete dbo.FIN_INTERFACE_AGREEMENT_INVOICE_LEDGER_HISTORY ;

		delete dbo.FIN_INTERFACE_AGREEMENT_FUND_IN_USED_HISTORY ;

		delete dbo.FIN_INTERFACE_AGREEMENT_DEPOSIT_HISTORY ;

		delete dbo.FIN_INTERFACE_AGREEMENT_AP_THIRDPARTY_HISTORY ;

		delete dbo.FIN_INTERFACE_AGREEMENT_AMORTIZATION_PAYMENT ;

		delete dbo.FIN_INTERFACE_ACCOUNT_TRANSFER ;

		delete dbo.DEPOSIT_REVENUE_DETAIL ;

		delete dbo.DEPOSIT_REVENUE ;

		delete dbo.DEPOSIT_RELEASE_DETAIL ;

		delete dbo.DEPOSIT_RELEASE ;

		delete dbo.DEPOSIT_MOVE ;

		delete dbo.DEPOSIT_ALLOCATION_DETAIL ;

		delete dbo.DEPOSIT_ALLOCATION ;

		delete dbo.CORE_UPLOAD_GENERIC ;

		delete dbo.CASHIER_UPLOAD_MAIN ;

		delete dbo.CASHIER_UPLOAD_DETAIL ;

		delete dbo.CASHIER_TRANSACTION_INVOICE ;

		delete dbo.CASHIER_TRANSACTION_DETAIL ;

		delete dbo.CASHIER_TRANSACTION ;

		delete dbo.CASHIER_RECEIVED_REQUEST_DETAIL ;

		delete dbo.CASHIER_RECEIVED_REQUEST ;

		delete dbo.CASHIER_RECEIPT_ALLOCATED ;

		delete dbo.CASHIER_MAIN ;

		delete dbo.CASHIER_BANKNOTE_AND_COIN ;

		delete dbo.BANK_MUTATION_HISTORY ;

		delete dbo.BANK_MUTATION ;

		delete dbo.AGREEMENT_MAIN_EXTENTION ;

		delete dbo.AGREEMENT_MAIN ;

		delete dbo.ACCOUNT_TRANSFER ;

		delete dbo.RECEIPT_MAIN ;

		dbcc checkident('BANK_MUTATION_HISTORY', reseed, 0) ;

		dbcc checkident('CASHIER_BANKNOTE_AND_COIN', reseed, 0) ;

		dbcc checkident('CASHIER_RECEIPT_ALLOCATED', reseed, 0) ;

		dbcc checkident('CASHIER_RECEIVED_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('CASHIER_TRANSACTION_DETAIL', reseed, 0) ;

		dbcc checkident('CASHIER_TRANSACTION_INVOICE', reseed, 0) ;

		dbcc checkident('CASHIER_UPLOAD_DETAIL', reseed, 0) ;

		dbcc checkident('CORE_UPLOAD_GENERIC', reseed, 0) ;

		dbcc checkident('DEPOSIT_ALLOCATION_DETAIL', reseed, 0) ;

		dbcc checkident('DEPOSIT_RELEASE_DETAIL', reseed, 0) ;

		dbcc checkident('DEPOSIT_REVENUE_DETAIL', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_ACCOUNT_TRANSFER', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_AGREEMENT_AMORTIZATION_PAYMENT', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_AGREEMENT_AP_THIRDPARTY_HISTORY', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_AGREEMENT_FUND_IN_USED_HISTORY', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_AGREEMENT_INVOICE_LEDGER_HISTORY', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_AGREEMENT_MAIN', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_AGREEMENT_RETENTION_HISTORY', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_AGREEMENT_UPDATE', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_APPROVAL_REQUEST', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_APPROVAL_REQUEST_DIMENSION', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_BANK_MUTATION', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_BANK_MUTATION_HISTORY', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_BANK_MUTATION_OUT', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_CASHIER_RECEIVED_REQUEST', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_DEPOSIT_ALLOCATION', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_DEPOSIT_REVENUE', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_NOTIFICATION_REQUEST', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_PAYMENT_REQUEST', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_PAYMENT_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_RECEIVED_REQUEST', reseed, 0) ;

		dbcc checkident('FIN_INTERFACE_RECEIVED_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('IFINFIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT', reseed, 0) ;

		dbcc checkident('PAYMENT_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('PAYMENT_TRANSACTION_DETAIL', reseed, 0) ;

		dbcc checkident('PAYMENT_VOUCHER_DETAIL', reseed, 0) ;

		dbcc checkident('RECEIPT_REGISTER_DETAIL', reseed, 0) ;

		dbcc checkident('RECEIPT_VOID_DETAIL', reseed, 0) ;

		dbcc checkident('RECEIVED_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('RECEIVED_TRANSACTION_DETAIL', reseed, 0) ;

		dbcc checkident('RECEIVED_VOUCHER_DETAIL', reseed, 0) ;

		dbcc checkident('RECONCILE_TRANSACTION', reseed, 0) ;

		dbcc checkident('SUSPEND_ALLOCATION_DETAIL', reseed, 0) ;

		dbcc checkident('SUSPEND_HISTORY', reseed, 0) ;

		dbcc checkident('SUSPEND_MERGER_DETAIL', reseed, 0) ;

		dbcc checkident('SUSPEND_REVENUE_DETAIL', reseed, 0) ;

		dbcc checkident('TRANSACTION_LOCK', reseed, 0) ;

		dbcc checkident('TRANSACTION_LOCK_HISTORY', reseed, 0) ;

		dbcc checkident('UPLOAD_ERROR_LOG', reseed, 0) ;

		dbcc checkident('WITHHOLDING_TAX_HISTORY', reseed, 0) ;
		dbcc checkident('BANK_MUTATION_HISTORY', reseed, 0)
		dbcc checkident('CASHIER_BANKNOTE_AND_COIN', reseed, 0)
		dbcc checkident('CASHIER_RECEIPT_ALLOCATED', reseed, 0)
		dbcc checkident('CASHIER_RECEIVED_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('CASHIER_TRANSACTION_DETAIL', reseed, 0)
		dbcc checkident('CASHIER_TRANSACTION_INVOICE', reseed, 0)
		dbcc checkident('CASHIER_UPLOAD_DETAIL', reseed, 0)
		dbcc checkident('CORE_UPLOAD_GENERIC', reseed, 0)
		dbcc checkident('DEPOSIT_ALLOCATION_DETAIL', reseed, 0)
		dbcc checkident('DEPOSIT_RELEASE_DETAIL', reseed, 0)
		dbcc checkident('DEPOSIT_REVENUE_DETAIL', reseed, 0)
		dbcc checkident('FIN_INTERFACE_ACCOUNT_TRANSFER', reseed, 0)
		dbcc checkident('FIN_INTERFACE_AGREEMENT_AMORTIZATION_PAYMENT', reseed, 0)
		dbcc checkident('FIN_INTERFACE_AGREEMENT_AP_THIRDPARTY_HISTORY', reseed, 0)
		dbcc checkident('FIN_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', reseed, 0)
		dbcc checkident('FIN_INTERFACE_AGREEMENT_FUND_IN_USED_HISTORY', reseed, 0)
		dbcc checkident('FIN_INTERFACE_AGREEMENT_INVOICE_LEDGER_HISTORY', reseed, 0)
		dbcc checkident('FIN_INTERFACE_AGREEMENT_MAIN', reseed, 0)
		dbcc checkident('FIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT', reseed, 0)
		dbcc checkident('FIN_INTERFACE_AGREEMENT_RETENTION_HISTORY', reseed, 0)
		dbcc checkident('FIN_INTERFACE_AGREEMENT_UPDATE', reseed, 0)
		dbcc checkident('FIN_INTERFACE_APPROVAL_REQUEST', reseed, 0)
		dbcc checkident('FIN_INTERFACE_APPROVAL_REQUEST_DIMENSION', reseed, 0)
		dbcc checkident('FIN_INTERFACE_BANK_MUTATION', reseed, 0)
		dbcc checkident('FIN_INTERFACE_BANK_MUTATION_HISTORY', reseed, 0)
		dbcc checkident('FIN_INTERFACE_BANK_MUTATION_OUT', reseed, 0)
		dbcc checkident('FIN_INTERFACE_CASHIER_RECEIVED_REQUEST', reseed, 0)
		dbcc checkident('FIN_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('FIN_INTERFACE_DEPOSIT_ALLOCATION', reseed, 0)
		dbcc checkident('FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL', reseed, 0)
		dbcc checkident('FIN_INTERFACE_DEPOSIT_REVENUE', reseed, 0)
		dbcc checkident('FIN_INTERFACE_DEPOSIT_REVENUE_DETAIL', reseed, 0)
		dbcc checkident('FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION', reseed, 0)
		dbcc checkident('FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL', reseed, 0)
		dbcc checkident('FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL_TAX', reseed, 0)
		dbcc checkident('FIN_INTERFACE_NOTIFICATION_REQUEST', reseed, 0)
		dbcc checkident('FIN_INTERFACE_PAYMENT_REQUEST', reseed, 0)
		dbcc checkident('FIN_INTERFACE_PAYMENT_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('FIN_INTERFACE_RECEIVED_REQUEST', reseed, 0)
		dbcc checkident('FIN_INTERFACE_RECEIVED_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('IFINFIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT', reseed, 0)
		dbcc checkident('PAYMENT_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('PAYMENT_TRANSACTION_DETAIL', reseed, 0)
		dbcc checkident('PAYMENT_VOUCHER_DETAIL', reseed, 0)
		dbcc checkident('RECEIPT_REGISTER_DETAIL', reseed, 0)
		dbcc checkident('RECEIPT_VOID_DETAIL', reseed, 0)
		dbcc checkident('RECEIVED_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('RECEIVED_TRANSACTION_DETAIL', reseed, 0)
		dbcc checkident('RECEIVED_VOUCHER_DETAIL', reseed, 0)
		dbcc checkident('RECONCILE_TRANSACTION', reseed, 0)
		dbcc checkident('SUSPEND_ALLOCATION_DETAIL', reseed, 0)
		dbcc checkident('SUSPEND_HISTORY', reseed, 0)
		dbcc checkident('SUSPEND_MERGER_DETAIL', reseed, 0)
		dbcc checkident('SUSPEND_REVENUE_DETAIL', reseed, 0)
		dbcc checkident('TRANSACTION_LOCK', reseed, 0)
		dbcc checkident('TRANSACTION_LOCK_HISTORY', reseed, 0)
		dbcc checkident('UPLOAD_ERROR_LOG', reseed, 0)
		dbcc checkident('WITHHOLDING_TAX_HISTORY', reseed, 0)

		delete dbo.FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION
		dbcc checkident('FIN_INTERFACE_JOURNAL_GL_LINK_TRANSACTION', reseed, 0)

		truncate table dbo.SYS_REPORT_LOG ;

		truncate table dbo.SYS_DOC_ACCESS_LOG ;

		truncate table dbo.SYS_DOCUMENT_UPLOAD ;

		truncate table SYS_CALENDER_EMPLOYEE

		truncate table dbo.SYS_ERROR_LOG
		truncate table dbo.SYS_JOB_TASKLIST_LOG

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
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
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
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;


CREATE PROCEDURE dbo.xsp_migration_clean_up
as
begin
	-- CLEAN UP TRANSAKSI -- untuk DSF
	begin
		truncate table dbo.DOC_INTERFACE_SYS_GENERAL_DOCUMENT ;

		truncate table dbo.DOC_INTERFACE_SYS_DOCUMENT_UPLOAD ;

		truncate table dbo.DOC_INTERFACE_INSURANCE_POLICY_MAIN ;

		truncate table dbo.DOC_INTERFACE_FIXED_ASSET_MAIN ;

		truncate table dbo.DOC_INTERFACE_DOCUMENT_REQUEST ;

		truncate table dbo.DOC_INTERFACE_DOCUMENT_PENDING_DETAIL ;

		delete dbo.DOC_INTERFACE_DOCUMENT_PENDING ;

		delete dbo.DOC_INTERFACE_DOCUMENT_PENDING ;

		truncate table dbo.DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED_DOC ;

		truncate table dbo.DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED ;

		truncate table dbo.DOC_INTERFACE_COLLATERAL_SWITCH_RELEASED ;

		truncate table dbo.DOC_INTERFACE_COLLATERAL_SWITCH ;

		truncate table dbo.DOC_INTERFACE_APPROVAL_REQUEST_DIMENSION ;

		truncate table dbo.DOC_INTERFACE_APPROVAL_REQUEST ;

		truncate table dbo.DOC_INTERFACE_APPROVAL_DIMENSION ;

		truncate table dbo.REPLACEMENT_DETAIL ;

		delete dbo.REPLACEMENT ;

		delete dbo.DOCUMENT_MOVEMENT ;

		truncate table dbo.DOCUMENT_MOVEMENT_DETAIL ;

		truncate table dbo.DOCUMENT_MOVEMENT_REPLACEMENT ;

		truncate table dbo.DOCUMENT_PENDING_DETAIL ;

		delete dbo.DOCUMENT_PENDING ;

		delete dbo.DOCUMENT_REQUEST ;

		truncate table dbo.DOCUMENT_STORAGE_DETAIL ;

		delete dbo.DOCUMENT_STORAGE ;

		truncate table dbo.DOCUMENT_DETAIL ;

		truncate table dbo.DOCUMENT_HISTORY ;

		delete dbo.DOCUMENT_MAIN ;

		delete dbo.FIXED_ASSET_MAIN ;

		delete dbo.REPLACEMENT_REQUEST_DETAIL ;

		truncate table dbo.FILE_IFINDOC_DOCUMENT_MAIN ;

		truncate table dbo.FILE_IFINDOC_ADDITIONAL_DOCUMENT ;

		truncate table dbo.RPT_TANDA_TERIMA_DOKUMEN_RELEASE_DETAIL ;

		truncate table dbo.RPT_TANDA_TERIMA_DOKUMEN_RELEASE ;

		truncate table dbo.RPT_SURAT_TAGIH_DETAIL ;

		truncate table dbo.RPT_SURAT_TAGIH ;

		truncate table dbo.RPT_SURAT_PERSETUJUAN_PENGELUARAN_DOKUMEN_DETAIL ;

		truncate table dbo.RPT_SURAT_PERSETUJUAN_PENGELUARAN_DOKUMEN ;

		truncate table dbo.RPT_SERAH_TERIMA_DOCUMENT_RELEASE_PERMANENT_DETAIL ;

		truncate table dbo.RPT_SERAH_TERIMA_DOCUMENT_RELEASE_PERMANENT ;

		truncate table dbo.RPT_SERAH_TERIMA_DOCUMENT_BORROW_DETAIL ;

		truncate table dbo.RPT_SERAH_TERIMA_DOCUMENT_BORROW ;

		truncate table dbo.RPT_SEND_OR_RELEASE_DOCUMENT_DETAIL ;

		truncate table dbo.RPT_SEND_OR_RELEASE_DOCUMENT ;

		truncate table dbo.RPT_RETURN_OF_LOAN_BPKB_SUMMARY ;

		truncate table dbo.RPT_RETURN_OF_LOAN_BPKB ;

		truncate table dbo.RPT_RELEASED_PERMANENT_BPKB_SUMMARY ;

		truncate table dbo.RPT_RELEASED_PERMANENT_BPKB ;

		truncate table dbo.RPT_RELEASED_BORROW_BPKB_SUMMARY ;

		truncate table dbo.RPT_RELEASED_BORROW_BPKB ;

		truncate table dbo.RPT_RELEASE_ADDITIONAL_DOCUMENT_BORROW ;

		truncate table dbo.RPT_RECEIVED_EXISTING ;

		truncate table dbo.RPT_RECEIVED_BPKB_DETAIL ;

		truncate table dbo.RPT_RECEIVED_BPKB ;

		truncate table dbo.RPT_RECEIVED_ADH_COLLATERAL ;

		truncate table dbo.RPT_PENDING_COVER_NOTE ;

		truncate table dbo.RPT_PENDING_BPKB ;

		truncate table dbo.RPT_MONITORING_BPKB ;

		truncate table dbo.RPT_DOCUMENT_REPLACEMENT ;

		truncate table dbo.RPT_DOCUMENT_RECEIVE ;

		truncate table dbo.RPT_DOCUMENT_BORROW ;

		truncate table dbo.RPT_DOCUMENT_AND_STATUS ;

		truncate table dbo.RPT_BORROW_BPKB_DETAIL ;

		truncate table dbo.RPT_BORROW_BPKB ;

		truncate table dbo.RPT_ANNUAL_REPORT_DETAIL ;

		truncate table dbo.RPT_ANNUAL_REPORT ;

		truncate table dbo.RPT_ADDITIONAL_COLLATERAL ;

		truncate table dbo.SYS_CALENDER_EMPLOYEE ;

		truncate table dbo.SYS_DOC_ACCESS_LOG ;

		truncate table dbo.SYS_ERROR_LOG ;

		truncate table dbo.SYS_JOB_TASKLIST_LOG ;

		truncate table dbo.SYS_JOB_TASKLIST_LOG_HISTORY ;

		truncate table dbo.SYS_REPORT_LOG ;

		truncate table dbo.SYS_TODO_EMPLOYEE ;

		truncate table dbo.RPT_TANDA_TERIMA_JAMINAN_RECEIVE_DETAIL
		truncate table dbo.RPT_TANDA_TERIMA_JAMINAN_RECEIVE
		truncate table dbo.RPT_TANDA_TERIMA_JAMINAN_DETAIL
		truncate table dbo.RPT_TANDA_TERIMA_JAMINAN
		truncate table dbo.RPT_TANDA_TERIMA_DOKUMEN_RELEASE_DETAIL
		truncate table dbo.RPT_TANDA_TERIMA_DOKUMEN_RELEASE
		truncate table dbo.RPT_SURAT_TAGIH_DETAIL
		truncate table dbo.RPT_SURAT_TAGIH
		truncate table dbo.RPT_SURAT_PERSETUJUAN_PENGELUARAN_DOKUMEN_DETAIL
		truncate table dbo.RPT_SURAT_PERSETUJUAN_PENGELUARAN_DOKUMEN
		truncate table dbo.RPT_SERAH_TERIMA_DOCUMENT_RELEASE_PERMANENT_DETAIL
		truncate table dbo.RPT_SERAH_TERIMA_DOCUMENT_RELEASE_PERMANENT
		truncate table dbo.RPT_SERAH_TERIMA_DOCUMENT_BORROW_DETAIL
		truncate table dbo.RPT_SERAH_TERIMA_DOCUMENT_BORROW
		truncate table dbo.RPT_SEND_OR_RELEASE_DOCUMENT_DETAIL
		truncate table dbo.RPT_SEND_OR_RELEASE_DOCUMENT
		truncate table dbo.RPT_RETURN_OF_LOAN_BPKB_SUMMARY
		truncate table dbo.RPT_RETURN_OF_LOAN_BPKB
		truncate table dbo.RPT_RELEASED_PERMANENT_BPKB_SUMMARY
		truncate table dbo.RPT_RELEASED_PERMANENT_BPKB
		truncate table dbo.RPT_RELEASED_BORROW_BPKB_SUMMARY
		truncate table dbo.RPT_RELEASED_BORROW_BPKB
		truncate table dbo.RPT_RELEASE_ADDITIONAL_DOCUMENT_BORROW
		truncate table dbo.RPT_RECEIVED_EXISTING
		truncate table dbo.RPT_RECEIVED_BPKB_DETAIL
		truncate table dbo.RPT_RECEIVED_BPKB
		truncate table dbo.RPT_RECEIVED_ADH_COLLATERAL
		truncate table dbo.RPT_RECEIVED_ADDITIONAL_COLLATERAL_DETAIL
		truncate table dbo.RPT_RECEIVED_ADDITIONAL_COLLATERAL
		truncate table dbo.RPT_PENDING_COVER_NOTE
		truncate table dbo.RPT_PENDING_BPKB
		truncate table dbo.RPT_MONITORING_BPKB
		truncate table dbo.RPT_DOCUMENT_REPLACEMENT
		truncate table dbo.RPT_DOCUMENT_RECEIVE
		truncate table dbo.RPT_DOCUMENT_BORROW
		truncate table dbo.RPT_DOCUMENT_AND_STATUS
		truncate table dbo.RPT_DAILY_RECEIVED_OF_LEASED_GOODS_DETAIL
		truncate table dbo.RPT_DAILY_RECEIVED_OF_LEASED_GOODS
		truncate table dbo.RPT_COUNT_BPKB_SUMMARY
		truncate table dbo.RPT_COUNT_BPKB_DETAIL
		truncate table dbo.RPT_COUNT_BPKB
		truncate table dbo.RPT_BORROW_BPKB_DETAIL
		truncate table dbo.RPT_BORROW_BPKB
		truncate table dbo.RPT_ANNUAL_REPORT_DETAIL
		truncate table dbo.RPT_ANNUAL_REPORT
		truncate table dbo.RPT_ADH_COLLATERAL_DETAIL
		truncate table dbo.RPT_ADH_COLLATERAL
		truncate table dbo.RPT_ADDITIONAL_COLLATERAL


		delete dbo.SYS_TODO ;

		truncate table dbo.TRANSACTION_LOCK ;

		truncate table dbo.SYS_JOB_TASKLIST_LOG_HISTORY ;

		delete dbo.REPLACEMENT_DETAIL ;

		delete dbo.REPLACEMENT_REQUEST ;

		truncate table dbo.SYS_AUDIT_DETAIL ;

		delete dbo.SYS_AUDIT ;

		delete dbo.SYS_BRANCH ;

		TRUNCATE TABLE dbo.SYS_DOCUMENT_UPLOAD

		dbcc checkident('DOC_ASSET_VEHICLE_UPDATE', reseed, 0)
		dbcc checkident('DOC_INTERFACE_APPROVAL_DIMENSION', reseed, 0)
		dbcc checkident('DOC_INTERFACE_APPROVAL_REQUEST', reseed, 0)
		dbcc checkident('DOC_INTERFACE_APPROVAL_REQUEST_DIMENSION', reseed, 0)
		dbcc checkident('DOC_INTERFACE_COLLATERAL_SWITCH_RELEASED', reseed, 0)
		dbcc checkident('DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED', reseed, 0)
		dbcc checkident('DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED_DOC', reseed, 0)
		dbcc checkident('DOC_INTERFACE_DOCUMENT_PENDING', reseed, 0)
		dbcc checkident('DOC_INTERFACE_DOCUMENT_PENDING_DETAIL', reseed, 0)
		dbcc checkident('DOC_INTERFACE_DOCUMENT_REQUEST', reseed, 0)
		dbcc checkident('DOC_INTERFACE_FIXED_ASSET_MAIN', reseed, 0)
		dbcc checkident('DOC_INTERFACE_INSURANCE_POLICY_MAIN', reseed, 0)
		dbcc checkident('DOCUMENT_DETAIL', reseed, 0)
		dbcc checkident('DOCUMENT_HISTORY', reseed, 0)
		dbcc checkident('DOCUMENT_MOVEMENT_DETAIL', reseed, 0)
		dbcc checkident('DOCUMENT_MOVEMENT_REPLACEMENT', reseed, 0)
		dbcc checkident('DOCUMENT_PENDING_DETAIL', reseed, 0)
		dbcc checkident('DOCUMENT_STORAGE_DETAIL', reseed, 0)
		dbcc checkident('FILE_IFINDOC_DOCUMENT_MAIN', reseed, 0)
		dbcc checkident('REPLACEMENT_DETAIL', reseed, 0)
		dbcc checkident('REPLACEMENT_REQUEST', reseed, 0)
		dbcc checkident('REPLACEMENT_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('TRANSACTION_LOCK', reseed, 0)
		dbcc checkident('TRANSACTION_LOCK_HISTORY', reseed, 0)

	end ;
end ;


-- update tabel job
begin
	update	dbo.sys_job_tasklist
	set		last_id = 0
			, eod_status = 'NONE'
			, eod_remark = '' ;
end ;

-- check row count & identity
begin
	select		(schema_name(a.schema_id) + '.' + a.name) as tablename
				, sum(b.rows)							  as recordcount
	from		sys.objects				  a
				inner join sys.partitions b on a.object_id = b.object_id
	where		a.type = 'u'
	group by	a.schema_id
				, a.name
	order by	tablename desc ;

	-- identity
	select		A.TABLE_CATALOG				  as CATALOG
				, A.TABLE_SCHEMA			  as "SCHEMA"
				, A.TABLE_NAME				  as "TABLE"
				, B.COLUMN_NAME				  as "COLUMN"
				, ident_seed(A.TABLE_NAME)	  as Seed
				, ident_incr(A.TABLE_NAME)	  as Increment
				, ident_current(A.TABLE_NAME) as Curr_Value
	from		INFORMATION_SCHEMA.TABLES A
				, INFORMATION_SCHEMA.COLUMNS B
	where		A.TABLE_CATALOG															 = B.TABLE_CATALOG
				and A.TABLE_SCHEMA														 = B.TABLE_SCHEMA
				and A.TABLE_NAME														 = B.TABLE_NAME
				and columnproperty(object_id(B.TABLE_NAME), B.COLUMN_NAME, 'IsIdentity') = 1
				and objectproperty(object_id(A.TABLE_NAME), 'TableHasIdentity')			 = 1
				and A.TABLE_TYPE														 = 'BASE TABLE'
	order by	ident_current(A.TABLE_NAME)
				, A.TABLE_SCHEMA
				, A.TABLE_NAME ;
end ;

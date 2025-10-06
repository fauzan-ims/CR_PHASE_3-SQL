CREATE procedure dbo.xsp_maintenence_data_cleanup
	@p_cleanup_type nvarchar(50) -- 'all', 'transaksi', 'inject'
as
begin
	if @p_cleanup_type = 'ALL'
	   or	@p_cleanup_type = 'TRANSACTION'
	begin
		truncate table dbo.DOC_INTERFACE_ADJUSTMENT_PLAFOND_COLLATERAL_OUT ;

		truncate table dbo.DOC_INTERFACE_AGREEMENT_COLLATERAL ;

		truncate table dbo.DOC_INTERFACE_AGREEMENT_COLLATERAL_AGING ;

		truncate table dbo.DOC_INTERFACE_AGREEMENT_COLLATERAL_VEHICLE ;

		delete dbo.DOC_INTERFACE_AGREEMENT_MAIN ;

		truncate table dbo.DOC_INTERFACE_AGREEMENT_UPDATE ;

		truncate table dbo.DOC_INTERFACE_COLLATERAL_SWITCH ;

		truncate table dbo.DOC_INTERFACE_COLLATERAL_SWITCH_RELEASED ;

		truncate table dbo.DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED ;

		truncate table dbo.DOC_INTERFACE_COLLATERAL_SWITCH_REPLACED_DOC ;

		delete dbo.DOC_INTERFACE_DOCUMENT_PENDING ;

		truncate table dbo.DOC_INTERFACE_DOCUMENT_PENDING_DETAIL ;

		truncate table dbo.DOC_INTERFACE_DOCUMENT_REQUEST ;

		truncate table dbo.DOC_INTERFACE_FIXED_ASSET_MAIN ;

		truncate table dbo.DOC_INTERFACE_INSURANCE_POLICY_MAIN ;

		truncate table dbo.DOC_INTERFACE_PLAFOND_COLLATERAL ;

		truncate table dbo.DOC_INTERFACE_PLAFOND_MAIN ;

		truncate table dbo.DOC_INTERFACE_SYS_DOCUMENT_UPLOAD ;

		truncate table dbo.DOC_INTERFACE_SYS_GENERAL_DOCUMENT ;

		truncate table dbo.REPLACEMENT_DETAIL ;

		truncate table dbo.REPLACEMENT_REQUEST ;

		delete dbo.REPLACEMENT ;

		delete dbo.AGREEMENT_ASSET ;

		delete dbo.AGREEMENT_COLLATERAL ;

		delete dbo.AGREEMENT_MAIN ;

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

		delete dbo.MASTER_DRAWER ;

		truncate table dbo.FIXED_ASSET_MAIN ;

		delete dbo.MASTER_LOCKER ;

		delete dbo.MASTER_ROW ;

		delete dbo.PLAFOND_COLLATERAL ;

		delete dbo.PLAFOND_MAIN ;

		truncate table dbo.RPT_DOCUMENT_AND_STATUS ;

		truncate table dbo.RPT_DOCUMENT_BORROW ;

		truncate table dbo.RPT_DOCUMENT_RECEIVE ;

		truncate table dbo.RPT_DOCUMENT_REPLACEMENT ;

		truncate table dbo.RPT_SEND_OR_RELEASE_DOCUMENT ;

		truncate table dbo.RPT_SEND_OR_RELEASE_DOCUMENT_DETAIL ;

		truncate table dbo.SYS_CALENDER_EMPLOYEE ;

		truncate table dbo.SYS_DOC_ACCESS_LOG ;

		truncate table dbo.SYS_ERROR_LOG ;

		truncate table dbo.SYS_JOB_TASKLIST_LOG ;

		truncate table dbo.SYS_JOB_TASKLIST_LOG_HISTORY ;

		truncate table dbo.SYS_REPORT_LOG ;

		truncate table dbo.SYS_TODO_EMPLOYEE ;

		delete dbo.SYS_TODO ;

		truncate table dbo.TRANSACTION_LOCK ;
	end ;

	if @p_cleanup_type = 'ALL'
	   or	@p_cleanup_type = 'MASTER'
	begin
		delete dbo.MASTER_DRAWER ;

		delete dbo.MASTER_LOCKER ;

		delete dbo.MASTER_ROW ;

		truncate table dbo.SYS_BRANCH ;

		truncate table dbo.SYS_DOCUMENT_NUMBER ;

		truncate table dbo.SYS_ERROR_LOG ;

		delete dbo.SYS_GENERAL_CODE ;

		truncate table dbo.SYS_GENERAL_DOCUMENT ;

		truncate table dbo.SYS_GENERAL_SUBCODE ;

		truncate table dbo.SYS_GENERAL_VALIDATION ;

		truncate table dbo.SYS_GLOBAL_PARAM ;

		truncate table dbo.SYS_JOB_TASKLIST ;

		truncate table dbo.SYS_JOB_TASKLIST_LOG ;

		truncate table dbo.SYS_JOB_TASKLIST_LOG_HISTORY ;

		truncate table dbo.SYS_REPORT ;
	end ;
end ;

select		(schema_name(a.schema_id) + '.' + a.name) as tablename
			,sum(b.rows) as recordcount
from		sys.objects a
			inner join sys.partitions b on a.object_id = b.object_id
where		a.type = 'u'
group by	a.schema_id
			,a.name ;

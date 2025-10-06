CREATE PROCEDURE dbo.xsp_migration_clean_up
as
begin
	declare @msg nvarchar(max) ;

	begin try
		-- company, company user, group role, subscription history
		delete	dbo.handover_request ;

		delete	dbo.handover_asset_checklist ;

		delete	dbo.handover_asset_doc ;

		delete	dbo.handover_asset ;

		truncate table dbo.asset_barcode_history ;

		truncate table dbo.asset_barcode_image ;

		truncate table dbo.asset_depreciation ;

		truncate table dbo.asset_depreciation_schedule_commercial ;

		truncate table dbo.asset_depreciation_schedule_fiscal ;

		truncate table dbo.asset_document ;

		truncate table dbo.asset_electronic ;

		truncate table dbo.asset_furniture ;

		truncate table dbo.asset_machine ;

		truncate table dbo.asset_maintenance_schedule ;

		truncate table dbo.asset_mutation_history ;

		truncate table dbo.asset_other ;

		truncate table dbo.asset_property ;

		truncate table dbo.ASSET_HE ;

		truncate table dbo.ASSET_AGING ;

		truncate table dbo.asset_vehicle ;

		truncate table dbo.MUTATION_DOCUMENT ;

		truncate table dbo.MUTATION_DETAIL ;

		delete	dbo.MUTATION ;

		truncate table asset_expense_ledger ;

		truncate table asset_income_ledger ;

		truncate table dbo.maintenance_detail ;

		delete	dbo.maintenance ;

		truncate table work_order_detail ;

		delete	work_order ;

		truncate table dbo.opname_detail ;

		delete	dbo.opname ;

		truncate table dbo.opname_detail_history ;

		delete	dbo.opname_history ;

		truncate table dbo.adjustment_document ;

		truncate table dbo.adjustment_detail ;

		delete	dbo.adjustment ;

		truncate table dbo.adjustment_document_history ;

		truncate table dbo.adjustment_detail_history ;

		delete	dbo.adjustment_history ;

		delete	dbo.spaf_asset ;

		truncate table dbo.spaf_claim_detail ;

		delete	dbo.spaf_claim ;

		truncate table dbo.SALE_DETAIL_FEE ;

		truncate table dbo.SALE_DETAIL_HISTORY ;

		delete	dbo.sale_detail ;

		truncate table dbo.sale_document ;

		delete	dbo.sale ;

		truncate table dbo.disposal_detail ;

		truncate table dbo.disposal_document ;

		delete	dbo.disposal ;

		truncate table dbo.order_detail ;

		delete	dbo.order_main ;

		truncate table register_document ;

		truncate table register_detail ;

		delete	register_main ;

		truncate table dbo.insurance_policy_asset_coverage ;

		delete	insurance_policy_asset ;

		truncate table insurance_policy_main_loading ;

		truncate table insurance_policy_main_period ;

		truncate table dbo.INSURANCE_POLICY_MAIN_PERIOD_ADJUSMENT ;

		truncate table dbo.INSURANCE_POLICY_MAIN_HISTORY ;

		delete	dbo.INSURANCE_PAYMENT_SCHEDULE_RENEWAL ;

		truncate table dbo.insurance_register_asset_coverage ;

		delete	dbo.insurance_register_asset ;

		truncate table dbo.insurance_register_period ;

		truncate table dbo.sppa_detail_asset_coverage ;

		truncate table dbo.sppa_detail ;

		delete	dbo.sppa_main ;

		truncate table dbo.insurance_register_existing_asset ;

		delete	dbo.insurance_register_existing ;

		truncate table dbo.claim_detail_asset ;

		truncate table dbo.claim_doc ;

		truncate table dbo.claim_progress ;

		delete	dbo.claim_main ;

		truncate table dbo.termination_detail_asset ;

		delete	dbo.termination_main ;

		truncate table dbo.payment_request_detail ;

		delete	dbo.payment_request ;

		truncate table dbo.payment_transaction_detail ;

		delete	dbo.sppa_request ;

		delete	dbo.insurance_register ;

		delete	dbo.payment_transaction ;

		delete	dbo.termination_request ;

		delete	dbo.claim_request ;

		delete	dbo.ENDORSEMENT_DETAIL ;

		delete	dbo.CHANGE_ITEM_TYPE ;

		delete	dbo.CHANGE_CATEGORY ;

		delete	dbo.ASSET_PREPAID_MAIN ;

		delete	dbo.ASSET_PREPAID_SCHEDULE ;

		delete	dbo.REPOSSESSION_PRICING ;

		delete	insurance_policy_main ;

		truncate table dbo.REVERSE_DISPOSAL_DETAIL ;

		delete	dbo.REVERSE_DISPOSAL ;

		truncate table dbo.ASSET_MANAGEMENT_PRICING_DETAIL ;

		delete	dbo.ASSET_MANAGEMENT_PRICING ;

		delete	dbo.asset ;

		truncate table dbo.EFAM_INTERFACE_ASSET ;

		truncate table dbo.EFAM_INTERFACE_ASSET_VEHICLE ;

		truncate table dbo.EFAM_INTERFACE_ASSET_HE ;

		truncate table dbo.EFAM_INTERFACE_ASSET_PROPERTY ;

		truncate table dbo.EFAM_INTERFACE_ASSET_ELECTRONIC ;

		truncate table dbo.EFAM_INTERFACE_ASSET_OTHER ;

		truncate table dbo.ASSET_MACHINE ;

		truncate table dbo.AMS_INTERFACE_ADJUSTMENT_ASSET ;

		truncate table dbo.IFINAMS_INTERFACE_SPAF_ASSET ;

		truncate table dbo.IFINAMS_INTERFACE_ASSET_EXPENSE ;

		truncate table dbo.IFINAMS_INTERFACE_ADDITIONAL_REQUEST ;

		truncate table dbo.EFAM_INTERFACE_RECEIVED_REQUEST_DETAIL ;

		delete	dbo.EFAM_INTERFACE_RECEIVED_REQUEST ;

		truncate table dbo.EFAM_INTERFACE_PAYMENT_REQUEST_DETAIL ;

		delete	dbo.EFAM_INTERFACE_PAYMENT_REQUEST ;

		truncate table dbo.AMS_INTERFACE_HANDOVER_ASSET ;

		truncate table dbo.AMS_INTERFACE_DOCUMENT_REQUEST ;

		truncate table dbo.AMS_INTERFACE_DOCUMENT_PENDING_DETAIL ;

		delete	dbo.AMS_INTERFACE_DOCUMENT_PENDING ;

		truncate table dbo.AMS_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL ;

		delete	dbo.AMS_INTERFACE_CASHIER_RECEIVED_REQUEST ;

		truncate table dbo.AMS_INTERFACE_ASSET_VEHICLE_UPDATE ;

		truncate table dbo.AMS_INTERFACE_ASSET_MAIN ;

		truncate table dbo.AMS_INTERFACE_APPROVAL_REQUEST ;

		truncate table dbo.AMS_INTERFACE_APPROVAL_DIMENSION ;

		truncate table dbo.AMS_INTERFACE_ADJUSTMENT_ASSET ;

		truncate table dbo.TRANSACTION_LOCK ;

		truncate table dbo.TEMP_INSURANCE_POLICY_PLUS_ACODE ;

		truncate table dbo.RPT_VENDOR_OPL ;

		truncate table dbo.RPT_UTILIZATION_REPLACEMENT_CAR ;

		truncate table dbo.RPT_TANDA_TERIMA_DELIVERY ;

		truncate table dbo.RPT_SURAT_PERMOHONAN_PEMBAYARAN_SERVICE_ITEM ;

		truncate table dbo.RPT_SURAT_PERINTAH_KERJA_ITEM ;

		truncate table dbo.RPT_SURAT_PERINTAH_KERJA ;

		truncate table dbo.RPT_SURAT_KUASA ;

		truncate table dbo.RPT_SURAT_JALAN ;

		truncate table dbo.RPT_STOCK_UTILIZATION ;

		truncate table dbo.RPT_STNK_AND_KEUR ;

		truncate table dbo.RPT_SPPA_WITHOUT_PAYMENT_STATUS ;

		truncate table dbo.RPT_SPPA_WITH_PAYMENT_STATUS ;

		truncate table dbo.RPT_RECEIVED_ADH_COLLATERAL ;

		truncate table dbo.RPT_PROFITABILITY_ASSET ;

		truncate table dbo.RPT_PROFIT_LOSS_ASSET ;

		truncate table dbo.RPT_PHYSICAL_CHECKING ;

		truncate table dbo.RPT_PERMOHONAN_PEMBAYARAN_SERVICE ;

		truncate table dbo.RPT_PER_UNIT ;

		truncate table dbo.RPT_PENJUALAN_ASSET_SUMMARY ;

		truncate table dbo.RPT_PENJUALAN_ASSET ;

		truncate table dbo.RPT_PAYMENT_STNK_KEUR ;

		truncate table dbo.RPT_PA_WITH_AMORTIZATION ;

		truncate table dbo.RPT_MONITORING_PAYMENT ;

		truncate table dbo.RPT_MONITORING ;

		truncate table dbo.RPT_KWITANSI_SPAF ;

		truncate table dbo.RPT_HANDOVER ;

		truncate table dbo.RPT_GATE_PASS ;

		truncate table dbo.RPT_FORM_GENERAL_CHECK ;

		truncate table dbo.RPT_FA_IN_USE_BOOK ;

		truncate table dbo.RPT_EXPENSE_ASSET ;

		truncate table dbo.RPT_DETAIL_UNIT_STOCK ;

		truncate table dbo.RPT_DELIVERY_UNIT ;

		truncate table dbo.RPT_DELIVERY_COLLECT_ORDER ;

		truncate table dbo.RPT_BPKB_BORROW_REPORT ;

		truncate table dbo.RPT_BERITA_ACARA_STOCK_OPNAME_TOTAL ;

		truncate table dbo.RPT_BERITA_ACARA_STOCK_OPNAME_DETAIL_DETAIL_DETAIL ;

		truncate table dbo.RPT_BERITA_ACARA_STOCK_OPNAME_DETAIL_DETAIL ;

		truncate table dbo.RPT_BERITA_ACARA_STOCK_OPNAME_DETAIL ;

		truncate table dbo.RPT_BERITA_ACARA_STOCK_OPNAME ;

		truncate table dbo.RPT_BERITA_ACARA_SERAH_TERIMA_DOCUMENT ;

		truncate table dbo.RPT_BERITA_ACARA_SERAH_TERIMA ;

		truncate table dbo.RPT_ASSET ;

		truncate table dbo.GET_DATA_PROFITABILITY_ASSET ;

		truncate table dbo.EFAM_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL ;

		delete	dbo.EFAM_INTERFACE_JOURNAL_GL_LINK_TRANSACTION ;

		truncate table dbo.EFAM_INTERFACE_ASSET_MACHINE ;

		truncate table dbo.AMS_INTERFACE_SPAF_CLAIM ;

		truncate table dbo.AMS_INTERFACE_SYS_DOCUMENT_UPLOAD

		truncate table dbo.RPT_EXT_DEPRE_MATURE_CONTRACT

		delete dbo.RPT_VENDOR_OPL_UI

		truncate table dbo.RPT_UNIT_STOCK_MONTHLY

		truncate table dbo.RPT_SURAT_PERMOHONAN_PEMBAYARAN_SERVICE_JASA

		truncate table dbo.RPT_SURAT_PERINTAH_KERJA_JASA

		truncate table dbo.RPT_SURAT_JALAN_DETAIL

		truncate table dbo.RPT_STATUS_PENGAJUAN_BIROJASA

		truncate table dbo.RPT_SPPA_WITHOUT_PAYMENT_STATUS_DETAIL

		truncate table dbo.RPT_PROFITABILITY_ASSET_INCOME

		truncate table dbo.RPT_PROFITABILITY_ASSET_EXPENSE

		truncate table dbo.RPT_PJB_BASTK

		truncate table dbo.RPT_PER_CUSTOMER

		truncate table dbo.RPT_PEMAKAIAN_JASA_VENDOR_STNK

		truncate table dbo.RPT_LAPORAN_PJB

		truncate table dbo.RPT_EXT_NET_ASSET_DEPRE

		truncate table dbo.RPT_EXT_NET_ASSET_COST_PRICE

		truncate table dbo.RPT_EXT_EXPENSE

		truncate table dbo.RPT_EXT_DEPRE_ALL_CONTRACT

		truncate table dbo.RPT_EXT_ASSET_SELLING

		truncate table dbo.RPT_DELIVERY_VEHICLE_BAST

		truncate table dbo.RPT_DELIVERY_AND_COLLECT_ORDER

		truncate table dbo.RPT_DATA_ASSET

		truncate table dbo.RPT_DAILY_BPKB_RELEASED_REPORT

		truncate table dbo.RPT_CONTROL_CARD_MAINTENANCE

		truncate table dbo.RPT_CETAKAN_PJB_BERITA_ACARA_SERAH_TERIMA_KENDARAAN

		truncate table dbo.RPT_CETAKAN_PJB

		truncate table dbo.RPT_BAST_UNIT_REPORT

		truncate table dbo.AMS_INTERFACE_INCOME_LEDGER

		dbcc checkident('EFAM_INTERFACE_RECEIVED_REQUEST', reseed, 0) ;

		dbcc checkident('EFAM_INTERFACE_PAYMENT_REQUEST', reseed, 0) ;

		dbcc checkident('AMS_INTERFACE_DOCUMENT_PENDING', reseed, 0) ;

		dbcc checkident('AMS_INTERFACE_CASHIER_RECEIVED_REQUEST', reseed, 0) ;

		dbcc checkident('SALE_DETAIL', reseed, 0) ;

		dbcc checkident('HANDOVER_ASSET_DOC', reseed, 0) ;

		dbcc checkident('HANDOVER_ASSET_CHECKLIST', reseed, 0) ;

		dbcc checkident('ENDORSEMENT_PERIOD', reseed, 0) ;

		dbcc checkident('ENDORSEMENT_DETAIL', reseed, 0) ;

		dbcc checkident('ASSET_PREPAID_SCHEDULE', reseed, 0) ;

		dbcc checkident('AMS_INTERFACE_SPAF_CLAIM', reseed, 0) ;

		dbcc checkident('EFAM_INTERFACE_JOURNAL_GL_LINK_TRANSACTION', reseed, 0) ;

		dbcc checkident('RPT_EXT_ASSET_SELLING', reseed, 0) ;

		dbcc checkident('RPT_EXT_EXPENSE', reseed, 0) ;

		dbcc checkident('RPT_EXT_NET_ASSET_COST_PRICE', reseed, 0) ;

		dbcc checkident('RPT_EXT_NET_ASSET_COST_PRICE', reseed, 0) ;



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

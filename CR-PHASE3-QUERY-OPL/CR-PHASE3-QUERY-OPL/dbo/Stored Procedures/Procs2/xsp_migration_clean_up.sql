CREATE PROCEDURE dbo.xsp_migration_clean_up
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete dbo.WRITE_OFF_TRANSACTION ;

		delete dbo.WRITE_OFF_RECOVERY ;

		delete dbo.WRITE_OFF_MAIN ;

		delete dbo.WRITE_OFF_INVOICE ;

		delete dbo.WRITE_OFF_DETAIL ;

		delete dbo.WORKFLOW_INPUT_RESULT ;

		delete dbo.WITHHOLDING_SETTLEMENT_AUDIT ;

		delete dbo.WARNING_LETTER_DELIVERY_DETAIL ;

		delete dbo.WARNING_LETTER_DELIVERY ;

		delete dbo.WARNING_LETTER ;

		delete dbo.WAIVED_OBLIGATION_DETAIL ;

		delete dbo.WAIVED_OBLIGATION ;

		delete dbo.TRANSACTION_LOCK_HISTORY ;

		delete dbo.TRANSACTION_LOCK ;

		delete dbo.TASK_MAIN ;

		delete dbo.TASK_HISTORY ;

		delete dbo.STOP_BILLING ;

		delete dbo.SETTLEMENT_AGREEMENT_DETAIL ;

		delete dbo.SETTLEMENT_AGREEMENT ;

		delete dbo.RPT_SURVEY_TOP_CUSTOMER ;

		delete dbo.RPT_SURVEY_RENCANA_PENGADAAN ;

		delete dbo.RPT_SURVEY_REKENING ;

		delete dbo.RPT_SURVEY_PROJECT_LESSEE ;

		delete dbo.RPT_SURVEY_OTHER_LESSEE ;

		delete dbo.RPT_SURVEY_FOTO_AND_DOCUMENT ;

		delete dbo.RPT_SURVEY ;

		delete dbo.RPT_SURAT_TAGIH_WRITE_OFF_LAMPIRAN_III ;

		delete dbo.RPT_SURAT_TAGIH_WRITE_OFF_LAMPIRAN_II ;

		delete dbo.RPT_SURAT_TAGIH_WRITE_OFF_LAMPIRAN_I ;

		delete dbo.RPT_SURAT_TAGIH_WRITE_OFF ;

		delete dbo.RPT_SURAT_SOMASI ;

		delete dbo.RPT_SURAT_PERINGATAN_PERTAMA ;

		delete dbo.RPT_SURAT_PERINGATAN_KEDUA ;

		delete dbo.RPT_SURAT_PERINGATAN_II_LAMPIRAN_I ;

		delete dbo.RPT_SURAT_PERINGATAN_II ;

		delete dbo.RPT_SURAT_PERINGATAN_I_LAMPIRAN_I ;

		delete dbo.RPT_SURAT_PERINGATAN_I ;

		delete dbo.RPT_SURAT_KUASA ;

		delete dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_III ;

		delete dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_II ;

		delete dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_I ;

		delete dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN_TUNGGAKAN ;

		delete dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN_KEKURANGAN_PEMBAYARAN ;

		delete dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN_DENDA_PEMBATALAN ;

		delete dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN_DENDA_KETERLAMBATAN ;

		delete dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN ;

		delete dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN ;

		delete dbo.RPT_SOMASI_PEMENUHAN_KEWAJIBAN_LAMPIRAN ;

		delete dbo.RPT_SOMASI_PEMENUHAN_KEWAJIBAN_DETAIL ;

		delete dbo.RPT_SOMASI_PEMENUHAN_KEWAJIBAN ;

		delete dbo.RPT_SOMASI_LAMPIRAN_III ;

		delete dbo.RPT_SOMASI_LAMPIRAN_II ;

		delete dbo.RPT_SOMASI_LAMPIRAN_I ;

		delete dbo.RPT_SOMASI ;

		delete dbo.RPT_SKT_LAMPIRAN_I ;

		delete dbo.RPT_SKT ;

		delete dbo.RPT_SKD_APPROVED ;

		delete dbo.RPT_SCHEDULE_RENTAL ;

		delete dbo.RPT_REALIZATION_CONTRACT ;

		delete dbo.RPT_QUOTATION ;

		delete dbo.RPT_PROFIT_LOSS_ASSET ;

		delete dbo.RPT_PERMOHONAN_PENARIKAN_BARANG ;

		delete dbo.RPT_PERJANJIAN_PELAKSANAAN_LAMPIRAN_III ;

		delete dbo.RPT_PERJANJIAN_PELAKSANAAN_LAMPIRAN_I ;

		delete dbo.RPT_PERJANJIAN_PELAKSANAAN ;

		delete dbo.RPT_PENDING_DOCUMENT_DETAIL ;

		delete dbo.RPT_PENDING_DOCUMENT ;

		delete dbo.RPT_OVERDUE ;

		delete dbo.RPT_OUTSTANDING_NI ;

		delete dbo.RPT_OUTSTANDING_INVOICE ;

		delete dbo.RPT_OPEN_CONTRACT ;

		delete dbo.RPT_MONTHLY_SALES ;

		delete dbo.RPT_MATURITY_DETAIL ;

		delete dbo.RPT_MATURITY ;

		delete dbo.RPT_LIST_FAKTUR_PAJAK_AR_DETAIL_DETAIL ;

		delete dbo.RPT_LIST_FAKTUR_PAJAK_AR_DETAIL ;

		delete dbo.RPT_LEMBAR_PERSETUJUAN_OR_SIMULASI_ADJUSTMENT_DUEDATE ;

		delete dbo.RPT_KONTRAK_OVERDUE ;

		delete dbo.RPT_INVOICE_PENAGIHAN_DETAIL_ASSET ;

		delete dbo.RPT_INVOICE_PENAGIHAN_DETAIL ;

		delete dbo.RPT_INVOICE_PENAGIHAN ;

		delete dbo.RPT_INVOICE_PEMBATALAN_KONTRAK_KWITANSI ;

		delete dbo.RPT_INVOICE_PEMBATALAN_KONTRAK_DETAIL ;

		delete dbo.RPT_INVOICE_PEMBATALAN_KONTRAK ;

		delete dbo.RPT_INVOICE_LIST ;

		delete dbo.RPT_INVOICE_KWITANSI_DETAIL ;

		delete dbo.RPT_INVOICE_KWITANSI ;

		delete dbo.RPT_INVOICE_FAKTUR_DETAIL ;

		delete dbo.RPT_INVOICE_FAKTUR ;

		delete dbo.RPT_INVOICE_DETAIL ;

		delete dbo.RPT_INVOICE_DENDA_KETERLAMBATAN_KWITANSI ;

		delete dbo.RPT_INVOICE_DENDA_KETERLAMBATAN_DETAIL ;

		delete dbo.RPT_INVOICE_DENDA_KETERLAMBATAN ;

		delete dbo.RPT_INVOICE ;

		delete dbo.RPT_EXT_WRITE_OFF ;

		delete dbo.RPT_EXT_REVENUE ;

		delete dbo.RPT_EXT_PROJECTION_DATA ;

		delete dbo.RPT_EXT_OVERDUE ;

		delete dbo.RPT_EXT_OTHER_OPERATIONAL_INCOME ;

		delete dbo.RPT_EXT_INTEREST_EXPENSE ;

		delete dbo.RPT_EXT_DISBURSEMENT ;

		delete dbo.RPT_EXT_AGREEMENT_MAIN ;

		delete dbo.RPT_EXT_AGREEMENT_ASSET ;

		delete dbo.RPT_EXPENSE_ASSET ;

		delete dbo.RPT_EXPENSE ;

		delete dbo.RPT_END_CONTRACT ;

		delete dbo.RPT_DATA_ASSET ;

		delete dbo.RPT_DAILY_OR_MONTHLY_TRANSACTION ;

		delete dbo.RPT_CONTRACT_LAMPIRAN_III ;

		delete dbo.RPT_CONTRACT_LAMPIRAN_II ;

		delete dbo.RPT_CONTRACT_LAMPIRAN_I ;

		delete dbo.RPT_CONTRACT ;

		delete dbo.RPT_ASSET_ALLOCATION_PERMOHONAN_PENGIRIMAN_BARANG_ADDRESS ;

		delete dbo.RPT_ASSET_ALLOCATION_PERMOHONAN_PENGIRIMAN_BARANG ;

		delete dbo.RPT_AGREEMENT_AMORTIZATION ;

		delete dbo.REPOSSESSION_LETTER_COLLATERAL ;

		delete dbo.REPOSSESSION_LETTER ;

		delete dbo.REALIZATION_DETAIL ;

		delete dbo.REALIZATION ;

		delete dbo.OPL_INTERFACE_INCOME_LEDGER

		delete dbo.OPL_INTERFACE_SYS_DOCUMENT_UPLOAD ;

		delete dbo.OPL_INTERFACE_SURVEY_REQUEST_DETAIL ;

		delete dbo.OPL_INTERFACE_SURVEY_REQUEST ;

		delete dbo.OPL_INTERFACE_SCORING_REQUEST_DETAIL ;

		delete dbo.OPL_INTERFACE_SCORING_REQUEST ;

		delete dbo.OPL_INTERFACE_PURCHASE_REQUEST ;

		delete dbo.OPL_INTERFACE_PURCHASE_ORDER_UPDATE ;

		delete dbo.OPL_INTERFACE_PAYMENT_REQUEST_DETAIL ;

		delete dbo.OPL_INTERFACE_PAYMENT_REQUEST ;

		delete dbo.OPL_INTERFACE_NOTIFICATION_REQUEST ;

		delete dbo.OPL_INTERFACE_MASTER_ITEM ;

		delete dbo.OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL ;

		delete dbo.OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION ;

		delete dbo.OPL_INTERFACE_HANDOVER_ASSET ;

		delete dbo.OPL_INTERFACE_EXT_CLIENT_MAIN ;

		delete dbo.OPL_INTERFACE_DOCUMENT_PENDING_DETAIL ;

		delete dbo.OPL_INTERFACE_DOCUMENT_PENDING ;

		delete dbo.OPL_INTERFACE_DEPOSIT_REVENUE_DETAIL ;

		delete dbo.OPL_INTERFACE_DEPOSIT_REVENUE ;

		delete dbo.OPL_INTERFACE_CLIENT_SLIK_FINANCIAL_STATEMENT ;

		delete dbo.OPL_INTERFACE_CLIENT_RELATION ;

		delete dbo.OPL_INTERFACE_CLIENT_PERSONAL_WORK ;

		delete dbo.OPL_INTERFACE_CLIENT_PERSONAL_INFO ;

		delete dbo.OPL_INTERFACE_CLIENT_MAIN ;

		delete dbo.OPL_INTERFACE_CLIENT_LOG ;

		delete dbo.OPL_INTERFACE_CLIENT_KYC_DETAIL ;

		delete dbo.OPL_INTERFACE_CLIENT_KYC ;

		delete dbo.OPL_INTERFACE_CLIENT_DOC ;

		delete dbo.OPL_INTERFACE_CLIENT_CORPORATE_NOTARIAL ;

		delete dbo.OPL_INTERFACE_CLIENT_CORPORATE_INFO ;

		delete dbo.OPL_INTERFACE_CLIENT_BLACKLIST ;

		delete dbo.OPL_INTERFACE_CLIENT_BANK_BOOK ;

		delete dbo.OPL_INTERFACE_CLIENT_BANK ;

		delete dbo.OPL_INTERFACE_CLIENT_ASSET ;

		delete dbo.OPL_INTERFACE_CLIENT_ADDRESS ;

		delete dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL ;

		delete dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST ;

		delete dbo.OPL_INTERFACE_ASSET_VEHICLE_UPDATE ;

		delete dbo.OPL_INTERFACE_APPROVAL_REQUEST_DIMENSION ;

		delete dbo.OPL_INTERFACE_APPROVAL_REQUEST ;

		delete dbo.OPL_INTERFACE_APPLICATION_MAIN ;

		delete dbo.OPL_INTERFACE_AGREEMENT_UPDATE_OUT ;

		delete dbo.OPL_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT ;

		delete dbo.OPL_INTERFACE_AGREEMENT_MAIN_OUT ;

		delete dbo.OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY ;

		delete dbo.OPL_INTERFACE_ADDITIONAL_INVOICE_REQUEST ;

		delete dbo.MATURITY_DETAIL ;

		delete dbo.MATURITY_AMORTIZATION_HISTORY ;

		delete dbo.MATURITY ;

		delete dbo.AGREEMENT_INVOICE_PPH_SETTLEMENT ;

		delete dbo.AGREEMENT_INVOICE_PPH ;

		delete dbo.AGREEMENT_INVOICE_PAYMENT ;

		delete dbo.AGREEMENT_INVOICE ;

		delete dbo.INVOICE_VAT_PAYMENT_DETAIL ;

		delete dbo.INVOICE_VAT_PAYMENT ;

		delete dbo.INVOICE_PPH_PAYMENT_DETAIL ;

		delete dbo.INVOICE_PPH_PAYMENT ;

		delete dbo.INVOICE_PPH ;

		delete dbo.INVOICE_DETAIL ;

		delete dbo.INVOICE_DELIVERY_DETAIL ;

		delete dbo.INVOICE_DELIVERY ;

		delete dbo.INVOICE ;

		delete dbo.HANDOVER_ASSET_DOC ;

		delete dbo.HANDOVER_ASSET_CHECKLIST ;

		delete dbo.HANDOVER_ASSET ;

		delete dbo.FAKTUR_REGISTRATION_DETAIL ;

		delete dbo.FAKTUR_REGISTRATION ;

		delete dbo.FAKTUR_MAIN ;

		delete dbo.FAKTUR_CANCELATION_DETAIL ;

		delete dbo.FAKTUR_CANCELATION ;

		delete dbo.FAKTUR_ALLOCATION_DETAIL ;

		delete dbo.FAKTUR_ALLOCATION ;

		delete dbo.ET_TRANSACTION ;

		delete dbo.ET_MAIN ;

		delete dbo.ET_DETAIL ;

		delete dbo.DUE_DATE_CHANGE_AMORTIZATION_HISTORY ;

		delete dbo.DUE_DATE_CHANGE_TRANSACTION ;

		delete dbo.DUE_DATE_CHANGE_MAIN ;

		delete dbo.DUE_DATE_CHANGE_DETAIL ;

		delete dbo.DESKCOLL_MAIN ;

		delete dbo.DESKCOLL_COSTUMER_INFO ;

		delete dbo.DEBIT_NOTE ;

		delete dbo.CREDIT_NOTE_DETAIL ;

		delete dbo.CREDIT_NOTE ;

		delete dbo.BUDGET_APPROVAL_DETAIL ;

		delete dbo.BUDGET_APPROVAL ;

		delete dbo.BILLING_SCHEME_DETAIL ;

		delete dbo.BILLING_SCHEME ;

		delete dbo.BILLING_GENERATE_DETAIL ;

		delete dbo.BILLING_GENERATE ;

		delete dbo.ASSET_REPLACEMENT_RETURN ;

		delete dbo.ASSET_REPLACEMENT_DETAIL ;

		delete dbo.ASSET_REPLACEMENT ;

		delete dbo.APPLICATION_ASSET_DETAIL ;

		delete dbo.ASSET_INSURANCE_DETAIL ;

		delete dbo.ASSET_DELIVERY_DETAIL ;

		delete dbo.ASSET_DELIVERY ;

		delete dbo.AREA_BLACKLIST_TRANSACTION_DETAIL ;

		delete dbo.AREA_BLACKLIST_TRANSACTION ;

		delete dbo.AREA_BLACKLIST_HISTORY ;

		delete dbo.AREA_BLACKLIST ;

		delete dbo.APPLICATION_EXTERNAL_DATA ;

		delete dbo.APPLICATION_EXTENTION ;

		delete dbo.APPLICATION_SURVEY_REQUEST ;

		delete dbo.APPLICATION_SURVEY_PROJECT ;

		delete dbo.APPLICATION_SURVEY_PLAN ;

		delete dbo.APPLICATION_SURVEY_OTHER_LEASE ;

		delete dbo.APPLICATION_SURVEY_DOCUMENT ;

		delete dbo.APPLICATION_SURVEY_CUSTOMER ;

		delete dbo.APPLICATION_SURVEY_BANK_DETAIL ;

		delete dbo.APPLICATION_SURVEY_BANK ;

		delete dbo.APPLICATION_SURVEY ;

		delete dbo.APPLICATION_SCORING_REQUEST ;

		delete dbo.APPLICATION_RULES_RESULT ;

		delete dbo.APPLICATION_RECOMENDATION ;

		delete dbo.APPLICATION_NOTARY ;

		delete dbo.APPLICATION_MAIN ;

		delete dbo.APPLICATION_LOG ;

		delete dbo.APPLICATION_INFORMATION ;

		delete dbo.APPLICATION_GUARANTOR ;

		delete dbo.APPLICATION_FINANCIAL_RECAPITULATION_DETAIL ;

		delete dbo.APPLICATION_FINANCIAL_RECAPITULATION ;

		delete dbo.APPLICATION_FINANCIAL_ANALYSIS_INCOME ;

		delete dbo.APPLICATION_FINANCIAL_ANALYSIS_EXPENSE ;

		delete dbo.APPLICATION_FINANCIAL_ANALYSIS ;

		delete dbo.APPLICATION_FEE ;

		delete dbo.APPLICATION_EXPOSURE ;

		delete dbo.APPLICATION_DOC ;

		delete dbo.APPLICATION_DEVIATION ;

		delete dbo.APPLICATION_CHARGES ;

		delete dbo.APPLICATION_ASSET_VEHICLE ;

		delete dbo.APPLICATION_ASSET_RESERVATION ;

		delete dbo.APPLICATION_ASSET_MACHINE ;

		delete dbo.APPLICATION_ASSET_HE ;

		delete dbo.APPLICATION_ASSET_ELECTRONIC ;

		delete dbo.APPLICATION_ASSET_DOC ;

		delete dbo.APPLICATION_ASSET_BUDGET ;

		delete dbo.APPLICATION_ASSET ;

		delete dbo.APPLICATION_APPROVAL_COMMENT ;

		delete dbo.APPLICATION_AMORTIZATION ;

		delete dbo.ADDITIONAL_INVOICE_REQUEST ;

		delete dbo.ADDITIONAL_INVOICE_DETAIL ;

		delete dbo.ADDITIONAL_INVOICE ;

		delete dbo.AGREEMENT_OBLIGATION_PAYMENT ;

		delete dbo.AGREEMENT_OBLIGATION ;

		delete dbo.AGREEMENT_MAIN ;

		delete dbo.AGREEMENT_LOG ;

		delete dbo.AGREEMENT_INFORMATION ;

		delete dbo.AGREEMENT_DEPOSIT_MAIN ;

		delete dbo.AGREEMENT_DEPOSIT_HISTORY ;

		delete dbo.AGREEMENT_CHARGES ;

		delete dbo.AGREEMENT_ASSET_VEHICLE ;

		delete dbo.AGREEMENT_ASSET_REPLACEMENT_HISTORY ;

		delete dbo.AGREEMENT_ASSET_MACHINE ;

		delete dbo.AGREEMENT_ASSET_INTEREST_INCOME ;

		delete dbo.AGREEMENT_ASSET_HE ;

		delete dbo.AGREEMENT_ASSET_ELECTRONIC ;

		delete dbo.AGREEMENT_ASSET_AMORTIZATION ;

		delete dbo.AGREEMENT_ASSET ;

		delete dbo.AGREEMENT_AGING_HISTORY ;

		delete dbo.AGREEMENT_AGING ;

		delete dbo.CLIENT_RELATION ;

		delete dbo.CLIENT_REFERENCE ;

		delete dbo.CLIENT_PERSONAL_WORK ;

		delete dbo.CLIENT_PERSONAL_INFO ;

		delete dbo.CLIENT_LOG ;

		delete dbo.CLIENT_KYC_DETAIL ;

		delete dbo.CLIENT_KYC ;

		delete dbo.CLIENT_DOC ;

		delete dbo.CLIENT_CORPORATE_NOTARIAL ;

		delete dbo.CLIENT_CORPORATE_INFO ;

		delete dbo.CLIENT_BLACKLIST_TRANSACTION_DETAIL ;

		delete dbo.CLIENT_BLACKLIST_TRANSACTION ;

		delete dbo.CLIENT_BLACKLIST_HISTORY ;

		delete dbo.CLIENT_BLACKLIST ;

		delete dbo.CLIENT_BANK_BOOK ;

		delete dbo.CLIENT_BANK ;

		delete dbo.CLIENT_ASSET ;

		delete dbo.CLIENT_ADDRESS ;

		delete dbo.CLIENT_MAIN ;

		delete dbo.PURCHASE_REQUEST ;

		truncate table dbo.SYS_REPORT_LOG ;

		truncate table dbo.SYS_DOC_ACCESS_LOG ;

		truncate table dbo.SYS_DOCUMENT_UPLOAD ;

		truncate table dbo.SYS_CLIENT_RUNNING_AGREEMENT_NO ;

		truncate table dbo.SYS_JOB_TASKLIST_LOG;

		truncate table dbo.RPT_PERJANJIAN_PELAKSANAAN_JADWAL_PEMBAYARAN

		delete dbo.MASTER_VEHICLE_UNIT
		delete dbo.MASTER_VEHICLE_TYPE
		delete dbo.MASTER_VEHICLE_SUBCATEGORY
		delete dbo.MASTER_VEHICLE_PRICELIST_UPLOAD
		delete dbo.MASTER_VEHICLE_PRICELIST_DETAIL
		delete dbo.MASTER_VEHICLE_PRICELIST
		delete dbo.MASTER_VEHICLE_MODEL
		delete dbo.MASTER_VEHICLE_MERK
		delete dbo.MASTER_VEHICLE_MADE_IN
		delete dbo.MASTER_VEHICLE_CATEGORY
		delete dbo.MASTER_SURVEY_DIMENSION
		delete dbo.MASTER_SURVEY
		delete dbo.MASTER_MACHINERY_UNIT
		delete dbo.MASTER_MACHINERY_TYPE
		delete dbo.MASTER_MACHINERY_SUBCATEGORY
		delete dbo.MASTER_MACHINERY_MODEL
		delete dbo.MASTER_MACHINERY_MERK
		delete dbo.MASTER_MACHINERY_CATEGORY
		delete dbo.MASTER_HE_UNIT
		delete dbo.MASTER_HE_TYPE
		delete dbo.MASTER_HE_SUBCATEGORY
		delete dbo.MASTER_HE_MODEL
		delete dbo.MASTER_HE_MERK
		delete dbo.MASTER_HE_CATEGORY 
		delete dbo.MASTER_ELECTRONIC_UNIT
		delete dbo.MASTER_ELECTRONIC_SUBCATEGORY
		delete dbo.MASTER_ELECTRONIC_MODEL
		delete dbo.MASTER_ELECTRONIC_MERK
		delete dbo.MASTER_ELECTRONIC_CATEGORY
		delete dbo.CLIENT_BANK_MUTATION
		 
		truncate table dbo.RPT_SURVEY_BANK_MUTATION
		truncate table dbo.RPT_QUOTATION_APPLICATION
		truncate table dbo.RPT_PERJANJIAN_PELAKSANAAN_REPRINT
		truncate table dbo.RPT_LEMBAR_PERSETUJUAN_OR_SIMULASI_ADJUSTMENT_DUEDATE_DETAIL
		truncate table dbo.RPT_INVOICE_PENAGIHAN_GROUP
		truncate table dbo.RPT_CREDIT_NOTE
		
		
		dbcc checkident('CLIENT_BANK_MUTATION', reseed, 0) ;

		dbcc checkident('APPLICATION_EXTENTION', reseed, 0) ;

		dbcc checkident('ADDITIONAL_INVOICE_DETAIL', reseed, 0) ;

		dbcc checkident('WRITE_OFF_TRANSACTION', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_PAYMENT_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('WRITE_OFF_DETAIL', reseed, 0) ;

		dbcc checkident('APPLICATION_SURVEY_PROJECT', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_SLIK_FINANCIAL_STATEMENT', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_AGREEMENT_MAIN_OUT', reseed, 0) ;

		dbcc checkident('APPLICATION_SURVEY_BANK', reseed, 0) ;

		dbcc checkident('BILLING_SCHEME_DETAIL', reseed, 0) ;

		dbcc checkident('MATURITY_DETAIL', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_ADDITIONAL_INVOICE_REQUEST', reseed, 0) ;

		dbcc checkident('SETTLEMENT_AGREEMENT', reseed, 0) ;

		dbcc checkident('FAKTUR_ALLOCATION_DETAIL', reseed, 0) ;

		dbcc checkident('APPLICATION_ASSET_DETAIL', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_HANDOVER_ASSET', reseed, 0) ;

		dbcc checkident('APPLICATION_SURVEY_BANK_DETAIL', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CASHIER_RECEIVED_REQUEST', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_NOTIFICATION_REQUEST', reseed, 0) ;

		dbcc checkident('WARNING_LETTER_DELIVERY_DETAIL', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_SCORING_REQUEST', reseed, 0) ;

		dbcc checkident('AREA_BLACKLIST_HISTORY', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_SCORING_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('RPT_EXT_OVERDUE', reseed, 0) ;

		dbcc checkident('AGREEMENT_ASSET_REPLACEMENT_HISTORY', reseed, 0) ;

		dbcc checkident('ASSET_INSURANCE_DETAIL', reseed, 0) ;

		dbcc checkident('RPT_EXT_REVENUE', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_LOG', reseed, 0) ;

		dbcc checkident('RPT_EXT_INTEREST_EXPENSE', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_PURCHASE_REQUEST', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_APPROVAL_REQUEST', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_BLACKLIST', reseed, 0) ;

		dbcc checkident('RPT_EXT_OTHER_OPERATIONAL_INCOME', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_KYC_DETAIL', reseed, 0) ;

		dbcc checkident('RPT_EXT_DISBURSEMENT', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_APPROVAL_REQUEST_DIMENSION', reseed, 0) ;

		dbcc checkident('RPT_EXT_WRITE_OFF', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_DOC', reseed, 0) ;

		dbcc checkident('RPT_EXT_AGREEMENT_MAIN', reseed, 0) ;

		dbcc checkident('APPLICATION_FINANCIAL_RECAPITULATION_DETAIL', reseed, 0) ;

		dbcc checkident('RPT_EXT_AGREEMENT_ASSET', reseed, 0) ;

		dbcc checkident('AGREEMENT_CHARGES', reseed, 0) ;

		dbcc checkident('BUDGET_APPROVAL_DETAIL', reseed, 0) ;

		dbcc checkident('RPT_EXT_PROJECTION_DATA', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_DEPOSIT_REVENUE_DETAIL', reseed, 0) ;

		dbcc checkident('FAKTUR_CANCELATION_DETAIL', reseed, 0) ;

		dbcc checkident('CREDIT_NOTE_DETAIL', reseed, 0) ;

		dbcc checkident('APPLICATION_SURVEY_CUSTOMER', reseed, 0) ;

		dbcc checkident('APPLICATION_FINANCIAL_ANALYSIS_INCOME', reseed, 0) ;

		dbcc checkident('REPOSSESSION_LETTER_COLLATERAL', reseed, 0) ;

		dbcc checkident('APPLICATION_ASSET_RESERVATION', reseed, 0) ;

		dbcc checkident('AGREEMENT_LOG', reseed, 0) ;

		dbcc checkident('INVOICE_PPH_PAYMENT_DETAIL', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_DEPOSIT_REVENUE', reseed, 0) ;

		dbcc checkident('APPLICATION_FINANCIAL_ANALYSIS_EXPENSE', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_APPLICATION_MAIN', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_BANK_BOOK', reseed, 0) ;

		dbcc checkident('DUE_DATE_CHANGE_DETAIL', reseed, 0) ;

		dbcc checkident('TASK_MAIN', reseed, 0) ;

		dbcc checkident('HANDOVER_ASSET_CHECKLIST', reseed, 0) ;

		dbcc checkident('ASSET_REPLACEMENT_RETURN', reseed, 0) ;

		dbcc checkident('HANDOVER_ASSET_DOC', reseed, 0) ;

		dbcc checkident('AREA_BLACKLIST_TRANSACTION_DETAIL', reseed, 0) ;

		dbcc checkident('INVOICE_DELIVERY_DETAIL', reseed, 0) ;

		dbcc checkident('INVOICE_PPH', reseed, 0) ;

		dbcc checkident('WAIVED_OBLIGATION_DETAIL', reseed, 0) ;

		dbcc checkident('SETTLEMENT_AGREEMENT_DETAIL', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_SURVEY_REQUEST', reseed, 0) ;

		dbcc checkident('TASK_HISTORY', reseed, 0) ;

		dbcc checkident('WRITE_OFF_INVOICE', reseed, 0) ;

		dbcc checkident('APPLICATION_RECOMENDATION', reseed, 0) ;

		dbcc checkident('INVOICE_VAT_PAYMENT_DETAIL', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_AGREEMENT_UPDATE_OUT', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_SURVEY_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('INVOICE_DETAIL', reseed, 0) ;

		dbcc checkident('APPLICATION_ASSET_DOC', reseed, 0) ;

		dbcc checkident('DUE_DATE_CHANGE_TRANSACTION', reseed, 0) ;

		dbcc checkident('APPLICATION_SURVEY_PLAN', reseed, 0) ;

		dbcc checkident('CLIENT_ASSET', reseed, 0) ;

		dbcc checkident('DESKCOLL_MAIN', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_ASSET', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_PURCHASE_ORDER_UPDATE', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL', reseed, 0) ;

		dbcc checkident('APPLICATION_APPROVAL_COMMENT', reseed, 0) ;

		dbcc checkident('REALIZATION_DETAIL', reseed, 0) ;

		dbcc checkident('CLIENT_BANK_BOOK', reseed, 0) ;

		dbcc checkident('APPLICATION_DOC', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_PAYMENT_REQUEST', reseed, 0) ;

		dbcc checkident('APPLICATION_CHARGES', reseed, 0) ;

		dbcc checkident('CLIENT_BLACKLIST_HISTORY', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION', reseed, 0) ;

		dbcc checkident('CLIENT_BLACKLIST_TRANSACTION_DETAIL', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_ASSET_VEHICLE_UPDATE', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL', reseed, 0) ;

		dbcc checkident('RPT_INVOICE_DETAIL', reseed, 0) ;


		dbcc checkident('AGREEMENT_DEPOSIT_HISTORY', reseed, 0) ;

		dbcc checkident('APPLICATION_DEVIATION', reseed, 0) ;

		dbcc checkident('APPLICATION_ASSET_BUDGET', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT', reseed, 0) ;

		dbcc checkident('CLIENT_DOC', reseed, 0) ;

		dbcc checkident('BILLING_GENERATE_DETAIL', reseed, 0) ;

		dbcc checkident('APPLICATION_EXPOSURE', reseed, 0) ;

		dbcc checkident('AGREEMENT_OBLIGATION_PAYMENT', reseed, 0) ;

		dbcc checkident('FAKTUR_REGISTRATION_DETAIL', reseed, 0) ;

		dbcc checkident('CLIENT_KYC_DETAIL', reseed, 0) ;

		dbcc checkident('AGREEMENT_INVOICE_PAYMENT', reseed, 0) ;

		dbcc checkident('APPLICATION_FEE', reseed, 0) ;

		dbcc checkident('CLIENT_LOG', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_EXT_CLIENT_MAIN', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_DOCUMENT_PENDING', reseed, 0) ;

		dbcc checkident('APPLICATION_GUARANTOR', reseed, 0) ;

		dbcc checkident('APPLICATION_MAIN', reseed, 0) ;

		dbcc checkident('ET_DETAIL', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_DOCUMENT_PENDING_DETAIL', reseed, 0) ;

		dbcc checkident('AGREEMENT_INVOICE_PPH_SETTLEMENT', reseed, 0) ;

		dbcc checkident('APPLICATION_LOG', reseed, 0) ;

		dbcc checkident('APPLICATION_EXTERNAL_DATA', reseed, 0) ;

		dbcc checkident('CLIENT_PERSONAL_WORK', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_MAIN', reseed, 0) ;

		dbcc checkident('CLIENT_REFERENCE', reseed, 0) ;

		dbcc checkident('ET_TRANSACTION', reseed, 0) ;

		dbcc checkident('ASSET_DELIVERY_DETAIL', reseed, 0) ;

		dbcc checkident('TRANSACTION_LOCK', reseed, 0) ;

		dbcc checkident('CLIENT_RELATION', reseed, 0) ;

		dbcc checkident('TRANSACTION_LOCK_HISTORY', reseed, 0) ;

		dbcc checkident('ASSET_REPLACEMENT_DETAIL', reseed, 0) ;

		dbcc checkident('APPLICATION_NOTARY', reseed, 0) ;

		dbcc checkident('APPLICATION_RULES_RESULT', reseed, 0) ;

		dbcc checkident('AGREEMENT_AGING', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_PERSONAL_WORK', reseed, 0) ;

		dbcc checkident('AGREEMENT_AGING_HISTORY', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_CLIENT_RELATION', reseed, 0) ;

		dbcc checkident('APPLICATION_SURVEY_OTHER_LEASE', reseed, 0) ;

		dbcc checkident('RPT_INVOICE_FAKTUR_DETAIL', reseed, 0) ;

		dbcc checkident('APPLICATION_SURVEY_DOCUMENT', reseed, 0) ;

		dbcc checkident('OPL_INTERFACE_INCOME_LEDGER', reseed, 0) ;

		dbcc checkident('ADDITIONAL_INVOICE_DETAIL', reseed, 0)
		dbcc checkident('AGREEMENT_AGING', reseed, 0)
		dbcc checkident('AGREEMENT_AGING_HISTORY', reseed, 0)
		dbcc checkident('AGREEMENT_ASSET_REPLACEMENT_HISTORY', reseed, 0)
		dbcc checkident('AGREEMENT_CHARGES', reseed, 0)
		dbcc checkident('AGREEMENT_DEPOSIT_HISTORY', reseed, 0)
		dbcc checkident('AGREEMENT_INVOICE_PAYMENT', reseed, 0)
		dbcc checkident('AGREEMENT_INVOICE_PPH_SETTLEMENT', reseed, 0)
		dbcc checkident('AGREEMENT_LOG', reseed, 0)
		dbcc checkident('AGREEMENT_OBLIGATION_PAYMENT', reseed, 0)
		dbcc checkident('APPLICATION_APPROVAL_COMMENT', reseed, 0)
		dbcc checkident('APPLICATION_ASSET_BUDGET', reseed, 0)
		dbcc checkident('APPLICATION_ASSET_DETAIL', reseed, 0)
		dbcc checkident('APPLICATION_ASSET_DOC', reseed, 0)
		dbcc checkident('APPLICATION_ASSET_RESERVATION', reseed, 0)
		dbcc checkident('APPLICATION_CHARGES', reseed, 0)
		dbcc checkident('APPLICATION_DEVIATION', reseed, 0)
		dbcc checkident('APPLICATION_DOC', reseed, 0)
		dbcc checkident('APPLICATION_EXPOSURE', reseed, 0)
		dbcc checkident('APPLICATION_EXTENTION', reseed, 0)
		dbcc checkident('APPLICATION_EXTERNAL_DATA', reseed, 0)
		dbcc checkident('APPLICATION_FEE', reseed, 0)
		dbcc checkident('APPLICATION_FINANCIAL_ANALYSIS_EXPENSE', reseed, 0)
		dbcc checkident('APPLICATION_FINANCIAL_ANALYSIS_INCOME', reseed, 0)
		dbcc checkident('APPLICATION_FINANCIAL_RECAPITULATION_DETAIL', reseed, 0)
		dbcc checkident('APPLICATION_GUARANTOR', reseed, 0)
		dbcc checkident('APPLICATION_LOG', reseed, 0)
		dbcc checkident('APPLICATION_MAIN', reseed, 0)
		dbcc checkident('APPLICATION_NOTARY', reseed, 0)
		dbcc checkident('APPLICATION_RECOMENDATION', reseed, 0)
		dbcc checkident('APPLICATION_RULES_RESULT', reseed, 0)
		dbcc checkident('APPLICATION_SURVEY_BANK', reseed, 0)
		dbcc checkident('APPLICATION_SURVEY_BANK_DETAIL', reseed, 0)
		dbcc checkident('APPLICATION_SURVEY_CUSTOMER', reseed, 0)
		dbcc checkident('APPLICATION_SURVEY_DOCUMENT', reseed, 0)
		dbcc checkident('APPLICATION_SURVEY_OTHER_LEASE', reseed, 0)
		dbcc checkident('APPLICATION_SURVEY_PLAN', reseed, 0)
		dbcc checkident('APPLICATION_SURVEY_PROJECT', reseed, 0)
		dbcc checkident('AREA_BLACKLIST_HISTORY', reseed, 0)
		dbcc checkident('AREA_BLACKLIST_TRANSACTION_DETAIL', reseed, 0)
		dbcc checkident('ASSET_DELIVERY_DETAIL', reseed, 0)
		dbcc checkident('ASSET_INSURANCE_DETAIL', reseed, 0)
		dbcc checkident('ASSET_REPLACEMENT_DETAIL', reseed, 0)
		dbcc checkident('ASSET_REPLACEMENT_RETURN', reseed, 0)
		dbcc checkident('BILLING_GENERATE_DETAIL', reseed, 0)
		dbcc checkident('BILLING_SCHEME_DETAIL', reseed, 0)
		dbcc checkident('BUDGET_APPROVAL_DETAIL', reseed, 0)
		dbcc checkident('CLIENT_ASSET', reseed, 0)
		dbcc checkident('CLIENT_BANK_BOOK', reseed, 0)
		dbcc checkident('CLIENT_BANK_MUTATION', reseed, 0)
		dbcc checkident('CLIENT_BLACKLIST_HISTORY', reseed, 0)
		dbcc checkident('CLIENT_BLACKLIST_TRANSACTION_DETAIL', reseed, 0)
		dbcc checkident('CLIENT_DOC', reseed, 0)
		dbcc checkident('CLIENT_KYC_DETAIL', reseed, 0)
		dbcc checkident('CLIENT_LOG', reseed, 0)
		dbcc checkident('CLIENT_PERSONAL_WORK', reseed, 0)
		dbcc checkident('CLIENT_REFERENCE', reseed, 0)
		dbcc checkident('CLIENT_RELATION', reseed, 0)
		dbcc checkident('CREDIT_NOTE_DETAIL', reseed, 0)
		dbcc checkident('DESKCOLL_MAIN', reseed, 0)
		dbcc checkident('DUE_DATE_CHANGE_DETAIL', reseed, 0)
		dbcc checkident('DUE_DATE_CHANGE_TRANSACTION', reseed, 0)
		dbcc checkident('ET_DETAIL', reseed, 0)
		dbcc checkident('ET_TRANSACTION', reseed, 0)
		dbcc checkident('FAKTUR_ALLOCATION_DETAIL', reseed, 0)
		dbcc checkident('FAKTUR_CANCELATION_DETAIL', reseed, 0)
		dbcc checkident('FAKTUR_REGISTRATION_DETAIL', reseed, 0)
		dbcc checkident('HANDOVER_ASSET_CHECKLIST', reseed, 0)
		dbcc checkident('HANDOVER_ASSET_DOC', reseed, 0)
		dbcc checkident('INVOICE_DELIVERY_DETAIL', reseed, 0)
		dbcc checkident('INVOICE_DETAIL', reseed, 0)
		dbcc checkident('INVOICE_PPH', reseed, 0)
		dbcc checkident('INVOICE_PPH_PAYMENT_DETAIL', reseed, 0)
		dbcc checkident('INVOICE_VAT_PAYMENT_DETAIL', reseed, 0)
		dbcc checkident('MATURITY_DETAIL', reseed, 0)
		dbcc checkident('OPL_INTERFACE_ADDITIONAL_INVOICE_REQUEST', reseed, 0)
		dbcc checkident('OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY', reseed, 0)
		dbcc checkident('OPL_INTERFACE_AGREEMENT_MAIN_OUT', reseed, 0)
		dbcc checkident('OPL_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT', reseed, 0)
		dbcc checkident('OPL_INTERFACE_AGREEMENT_UPDATE_OUT', reseed, 0)
		dbcc checkident('OPL_INTERFACE_APPLICATION_MAIN', reseed, 0)
		dbcc checkident('OPL_INTERFACE_APPROVAL_REQUEST', reseed, 0)
		dbcc checkident('OPL_INTERFACE_APPROVAL_REQUEST_DIMENSION', reseed, 0)
		dbcc checkident('OPL_INTERFACE_ASSET_VEHICLE_UPDATE', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CASHIER_RECEIVED_REQUEST', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_ASSET', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_BANK_BOOK', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_BLACKLIST', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_DOC', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_KYC_DETAIL', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_LOG', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_MAIN', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_PERSONAL_WORK', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_RELATION', reseed, 0)
		dbcc checkident('OPL_INTERFACE_CLIENT_SLIK_FINANCIAL_STATEMENT', reseed, 0)
		dbcc checkident('OPL_INTERFACE_DEPOSIT_REVENUE', reseed, 0)
		dbcc checkident('OPL_INTERFACE_DEPOSIT_REVENUE_DETAIL', reseed, 0)
		dbcc checkident('OPL_INTERFACE_DOCUMENT_PENDING', reseed, 0)
		dbcc checkident('OPL_INTERFACE_DOCUMENT_PENDING_DETAIL', reseed, 0)
		dbcc checkident('OPL_INTERFACE_EXT_CLIENT_MAIN', reseed, 0)
		dbcc checkident('OPL_INTERFACE_HANDOVER_ASSET', reseed, 0)
		dbcc checkident('OPL_INTERFACE_INCOME_LEDGER', reseed, 0)
		dbcc checkident('OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION', reseed, 0)
		dbcc checkident('OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL', reseed, 0)
		dbcc checkident('OPL_INTERFACE_NOTIFICATION_REQUEST', reseed, 0)
		dbcc checkident('OPL_INTERFACE_PAYMENT_REQUEST', reseed, 0)
		dbcc checkident('OPL_INTERFACE_PAYMENT_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('OPL_INTERFACE_PURCHASE_ORDER_UPDATE', reseed, 0)
		dbcc checkident('OPL_INTERFACE_PURCHASE_REQUEST', reseed, 0)
		dbcc checkident('OPL_INTERFACE_SCORING_REQUEST', reseed, 0)
		dbcc checkident('OPL_INTERFACE_SCORING_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('OPL_INTERFACE_SURVEY_REQUEST', reseed, 0)
		dbcc checkident('OPL_INTERFACE_SURVEY_REQUEST_DETAIL', reseed, 0)
		dbcc checkident('REALIZATION_DETAIL', reseed, 0)
		dbcc checkident('REPOSSESSION_LETTER_COLLATERAL', reseed, 0)
		dbcc checkident('RPT_EXT_AGREEMENT_ASSET', reseed, 0)
		dbcc checkident('RPT_EXT_AGREEMENT_MAIN', reseed, 0)
		dbcc checkident('RPT_EXT_DISBURSEMENT', reseed, 0)
		dbcc checkident('RPT_EXT_INTEREST_EXPENSE', reseed, 0)
		dbcc checkident('RPT_EXT_OTHER_OPERATIONAL_INCOME', reseed, 0)
		dbcc checkident('RPT_EXT_OVERDUE', reseed, 0)
		dbcc checkident('RPT_EXT_PROJECTION_DATA', reseed, 0)
		dbcc checkident('RPT_EXT_REVENUE', reseed, 0)
		dbcc checkident('RPT_EXT_WRITE_OFF', reseed, 0)
		dbcc checkident('RPT_INVOICE_DETAIL', reseed, 0)
		dbcc checkident('RPT_INVOICE_FAKTUR_DETAIL', reseed, 0)
		dbcc checkident('SETTLEMENT_AGREEMENT', reseed, 0)
		dbcc checkident('SETTLEMENT_AGREEMENT_DETAIL', reseed, 0)
		dbcc checkident('TASK_HISTORY', reseed, 0)
		dbcc checkident('TASK_MAIN', reseed, 0)
		dbcc checkident('TRANSACTION_LOCK', reseed, 0)
		dbcc checkident('TRANSACTION_LOCK_HISTORY', reseed, 0)
		dbcc checkident('WAIVED_OBLIGATION_DETAIL', reseed, 0)
		dbcc checkident('WARNING_LETTER_DELIVERY_DETAIL', reseed, 0)
		dbcc checkident('WRITE_OFF_DETAIL', reseed, 0)
		dbcc checkident('WRITE_OFF_INVOICE', reseed, 0)
		dbcc checkident('WRITE_OFF_TRANSACTION', reseed, 0)

		
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

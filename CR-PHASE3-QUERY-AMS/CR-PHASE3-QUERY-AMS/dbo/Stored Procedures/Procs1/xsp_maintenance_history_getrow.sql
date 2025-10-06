CREATE procedure [dbo].[xsp_maintenance_history_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mm.code
			,mm.company_code
			,mm.asset_code
			,ass.item_name																																   'asset_name'
			,transaction_date
			,transaction_amount
			,mm.branch_code
			,mm.branch_name
			,mm.requestor_code
			,mm.requestor_name
			,mm.division_code
			,ass.barcode
			,mm.division_name
			,mm.department_code
			,mm.department_name
			,mm.status
			,mm.maintenance_by
			,mm.vendor_code
			,mm.vendor_name
			,mm.vendor_city_name
			,mm.vendor_address
			,mm.vendor_province_name
			,mm.vendor_phone
			,mm.vendor_bank_name
			,mm.vendor_bank_account_no
			,mm.vendor_bank_account_name
			,mm.actual_km
			,mm.service_type
			,mm.work_date
			,mm.remark
			,mm.hour_meter
			,ass.type_code
			,avh.plat_no
			,mm.is_reimburse
			,mm.bank_code
			,mm.bank_name
			,mm.bank_account_no
			,mm.bank_account_name
			,mm.sa_vendor_name
			,mm.sa_vendor_area_phone
			,mm.sa_vendor_phone_no
			,mm.last_km_service
			--,case
			--		when agremeent_asset.is_use_maintenance = '1' then 'MAINTENANCE' + ' - ' + ass.agreement_external_no
			--		when ISNULL(agremeent_asset.is_use_maintenance,'0') = '0' then 'NON MAINTENANCE' + ' - ' + ass.agreement_external_no
			--		else 'STOCK IN MAINTENANCE'
			--	end 'is_use_maintenance'
			-- (+) Ari 2023-12-28 ket : jika asset tidak terdaftar pada kontrak (agreement) set default
			,isnull(   case
						   when agremeent_asset.is_use_maintenance = '1' then 'MAINTENANCE' + ' - ' + ass.agreement_external_no
						   when isnull(agremeent_asset.is_use_maintenance, '0') = '0' then 'NON MAINTENANCE' + ' - ' + ass.agreement_external_no
						   else 'STOCK IN MAINTENANCE'
					   end, 'STOCK IN MAINTENANCE'
				   )																																	   'is_use_maintenance'
			,isnull(agremeent_asset.budget_maintenance_amount, 0)																						   'budget_maintenance_amount'
			,ass.agreement_external_no
			,ass.client_name
			--,isnull(maintenance_actual.amount_total, 0)														'amount_total'
			,isnull(maintenance_actual.amount_total, 0) + isnull(maintenance_gts.amount_total, 0)														   'amount_total'
			--,isnull(agremeent_asset.BUDGET_MAINTENANCE_AMOUNT - maintenance.amount_total, 0) 'sisa'
			--,isnull(agremeent_asset.budget_maintenance_amount, 0) - isnull(maintenance_actual.amount_total, 0) 'sisa'
			,isnull(agremeent_asset.budget_maintenance_amount, 0) - (isnull(maintenance_actual.amount_total, 0) + isnull(maintenance_gts.amount_total, 0)) 'sisa'
			,mm.free_service
			,mm.file_name
			,mm.file_path
			,mm.estimated_start_date
			,mm.estimated_finish_date
			,mm.call_center_ticket_no
			,mm.is_request_replacement
			,mm.delivery_address
			,mm.contact_name
			,mm.contact_phone_no
			,mm.reason_code
			,mm.start_date
			,mm.finish_date
			,mm.remark_return
			,mm.count_return
			,sgs.description																															   'reason_name'
	from	dbo.maintenance_history			  mm
			inner join dbo.asset			  ass on (ass.code = mm.asset_code)
			inner join dbo.asset_vehicle	  avh on (avh.asset_code = ass.code)
			left join dbo.sys_general_subcode sgs on (sgs.code = mm.reason_code)
			outer apply
	(
		select	is_use_maintenance
				,aa.budget_maintenance_amount
				,aa.agreement_no
				,aa.FA_CODE
				,aa.REPLACEMENT_FA_CODE
		from	ifinopl.dbo.agreement_asset aa
		where	aa.agreement_no				   = ass.agreement_no
				and
				(
					aa.fa_code				   = ass.code
					or	aa.replacement_fa_code = ass.code
				)
	)										  agremeent_asset
			--left join ifinopl.dbo.agreement_asset aga on (aga.agreement_no = ass.agreement_no)
			--		outer apply
			--(
			--	select	sum(isnull(maintenance_actual.amount, 0)) 'amount_total'
			--	from	dbo.asset_expense_ledger ael
			--		outer apply
			--(
			--	select	sum(ael2.EXPENSE_AMOUNT) 'amount_total'
			--	from	ifinams.dbo.ASSET_EXPENSE_LEDGER ael2
			--	where	reff_name			  = 'WORK ORDER'
			--			and ael2.agreement_no = agremeent_asset.agreement_no
			--			and ael2.asset_code	  = ass.code
			--)								 maintenance_actual
			outer apply
	(
		select	sum(ael2.EXPENSE_AMOUNT) 'amount_total'
		from	ifinams.dbo.ASSET_EXPENSE_LEDGER ael2
		where	reff_name			  = 'WORK ORDER'
				and ael2.agreement_no = agremeent_asset.agreement_no
				and ael2.asset_code	  = agremeent_asset.FA_CODE
	) maintenance_actual
			outer apply
	(
		select	sum(ael2.EXPENSE_AMOUNT) 'amount_total'
		from	ifinams.dbo.ASSET_EXPENSE_LEDGER ael2
		where	reff_name			  = 'WORK ORDER'
				and ael2.agreement_no = agremeent_asset.agreement_no
				and ael2.asset_code	  = agremeent_asset.REPLACEMENT_FA_CODE
	) maintenance_gts
	--	where	ael.agreement_no   = agremeent_asset.agreement_no
	--			and ael.asset_code = ass.code
	--) maintenance
	where	mm.code = @p_code ;
end ;

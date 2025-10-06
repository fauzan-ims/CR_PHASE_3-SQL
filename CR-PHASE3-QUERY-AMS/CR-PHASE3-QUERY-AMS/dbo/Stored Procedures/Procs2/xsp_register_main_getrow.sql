CREATE PROCEDURE [dbo].[xsp_register_main_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @is_print_tanda_terima nvarchar(max)
			,@tax_ppn			   int
			,@tax_pph			   int ;

	if exists
	(
		select	1
		from	dbo.register_detail rd
		where	(
					rd.service_code like '%STNK%'
					or	rd.service_code like '%PBSPSTN%'
					or	rd.service_code like '%KEUR%'
				)
				and rd.register_code = @p_code
	)
		set @is_print_tanda_terima = N'1' ;
	else
		set @is_print_tanda_terima = N'0' ;

	select	rm.code
			,rm.branch_code
			,rm.branch_name
			,rm.register_date
			,rm.register_no
			--,rm.register_status
			,case
				 when rm.register_status = 'PAID'
					  and	rm.register_process_by = 'INTERNAL' then 'REGISTER'
				 --when rm.register_status = 'PAID' and rm.register_process_by = 'CUSTOMER' then 'DONE'
				 else rm.register_status
			 end					  as 'register_status'
			,case
				 when rm.payment_status is not null then rm.register_status + ' / ' + rm.payment_status
				 else rm.register_status
			 end					  as 'payment_status'
			,rm.payment_status		  'payment_status_2'
			,rm.register_process_by
			,rm.register_remarks
			,rm.order_code
			,om.order_date
			,rm.order_status
			,rm.realization_invoice_no
			,rm.realization_internal_income
			,rm.realization_actual_fee
			,rm.realization_service_fee
			,rm.realization_date
			,rm.public_service_settlement_date
			,rm.public_service_settlement_amount
			,rm.public_service_settlement_voucher
			,rm.delivery_date
			,rm.delivery_receive_by
			,rm.delivery_remarks
			,rm.dp_to_public_service_amount
			,rm.dp_to_public_service_date
			,rm.dp_to_public_service_voucher
			,mps.public_service_name
			,ass.item_name
			,rm.fa_code
			,rd.service_code
			,rm.stnk_no
			,rm.stnk_tax_date
			,rm.stnk_expired_date
			,rm.keur_no
			,rm.keur_date
			,rm.keur_expired_date
			,rm.receive_date
			,rm.receive_by
			,rm.receive_remarks
			,rm.register_date
			,rm.is_reimburse
			,rm.payment_bank_name	  'bank_name'
			,rm.payment_bank_account_no
			,rm.payment_bank_account_name
			,rm.realization_service_tax_ppn_pct
			,rm.realization_service_tax_pph_pct
			,rm.realization_service_tax_code
			,rm.realization_service_tax_name
			,rm.return_date
			,rm.return_by
			,rm.reason_return_desc
			,rm.reason_return_remark
			--,cast(ceiling(rm.realization_service_fee * (rm.realization_service_tax_pph_pct / 100)) as int) 'tax_pph'
			--,cast(ceiling(rm.realization_service_fee * (rm.realization_service_tax_ppn_pct / 100)) as int) 'tax_ppn'
			-- (+) Ari 2023-12-28 ket : get ppn&pph amount
			,case rm.service_pph_amount
				 when 0 then cast(ceiling(rm.realization_service_fee * (rm.realization_service_tax_pph_pct / 100)) as int)
				 else rm.service_pph_amount
			 end					  'service_pph_amount'
			,case rm.service_ppn_amount
				 when 0 then cast(ceiling(rm.realization_service_fee * (rm.realization_service_tax_ppn_pct / 100)) as int)
				 else rm.service_ppn_amount
			 end					  'service_ppn_amount'
			,rm.faktur_no
			,isnull(rm.file_name, '') 'file_name'
			,isnull(rm.paths, '')	  'paths'
			,rm.delivery_to_name
			,rm.delivery_to_phone_area
			,rm.delivery_to_phone_no
			,rm.delivery_to_address
			,avh.plat_no
			,@is_print_tanda_terima	  'is_print_tanda_terima'
			,rm.faktur_date			  'faktur_date'
			,rm.is_reimburse_to_customer
			,rm.realization_invoic_date
	from	register_main						rm
			left join dbo.order_main			om on (om.code collate latin1_general_ci_as = rm.order_code)
			left join dbo.order_detail			od on (od.order_code						= om.code)
			left join dbo.master_public_service mps on (mps.code							= om.public_service_code)
			left join dbo.asset					ass on (ass.code							= rm.fa_code)
			inner join dbo.asset_vehicle		avh on (avh.asset_code						= ass.code)
			left join dbo.register_detail		rd on (rd.register_code						= rm.code)
	where	rm.code = @p_code ;
end ;

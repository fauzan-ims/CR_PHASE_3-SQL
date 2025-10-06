CREATE PROCEDURE dbo.xsp_old_journal_final
(
	@p_code			   nvarchar(50)
	,@p_final_grn_code nvarchar(50)
	,@p_company_code   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							  nvarchar(max)
			,@code							  nvarchar(50)
			,@branch_code					  nvarchar(50)
			,@branch_name					  nvarchar(250)
			,@division_code					  nvarchar(50)
			,@division_name					  nvarchar(250)
			,@department_code				  nvarchar(50)
			,@department_name				  nvarchar(250)
			,@item_code						  nvarchar(50)
			,@item_name						  nvarchar(250)
			,@po_quantity					  decimal(18, 2)
			,@recive_quantity				  int
			,@po_no							  nvarchar(50)
			,@purchase_date					  datetime		= dbo.xfn_get_system_date()
			,@purchase_price				  decimal(18, 2)
			,@original_price				  decimal(18, 2)
			,@vendor_code					  nvarchar(50)
			,@vendor_name					  nvarchar(250)
			,@category_code					  nvarchar(50)
			,@price_amount					  decimal(18, 2)
			,@type_code						  nvarchar(50)
			,@requestor_code				  nvarchar(50)
			,@requestor_name				  nvarchar(250)
			,@category_name					  nvarchar(250)
			,@interface_purchase_request_code nvarchar(50)
			,@good_receipt_note_detail_id	  bigint
			,@merk_code						  nvarchar(50)
			,@model_code					  nvarchar(50)
			,@type_item_code				  nvarchar(50)
			,@merk_desc						  nvarchar(50)
			,@model_desc					  nvarchar(50)
			,@type_item_desc				  nvarchar(50)
			,@remaining_qty					  int
			,@type_name						  nvarchar(250)
			,@ppn_pct						  decimal(9, 6)
			,@pph_pct						  decimal(9, 6)
			,@sp_name						  nvarchar(250)
			,@debet_or_credit				  nvarchar(10)
			,@gl_link_code					  nvarchar(50)
			,@transaction_name				  nvarchar(250)
			,@gl_link_transaction_code		  nvarchar(50)
			,@orig_amount_cr				  decimal(18, 2)
			,@orig_amount_db				  decimal(18, 2)
			,@return_value					  decimal(18, 2)
			,@remarks_journal				  nvarchar(4000)
			,@grn_id						  bigint
			,@uom_name						  nvarchar(50)
			,@plat_no						  nvarchar(50)
			,@engine_no						  nvarchar(50)
			,@chassis_no					  nvarchar(50)
			,@category_desc					  nvarchar(250)
			,@item_code_for_jrnl			  nvarchar(50)
			,@item_name_for_jrnl			  nvarchar(250)
			,@sum_order_remaining			  int
			,@is_rent						  nvarchar(25)
			,@unit_from						  nvarchar(25)
			,@item_group_code				  nvarchar(50)
			,@branch_code_header			  nvarchar(50)
			,@branch_name_header			  nvarchar(250)
			,@opl_code						  nvarchar(50)
			,@asset_purpose					  nvarchar(50)
			,@spesification					  nvarchar(4000)
			,@serial_no						  nvarchar(50)
			,@asset_code					  nvarchar(50)
			,@invoice_no					  nvarchar(50)
			,@domain						  nvarchar(50)
			,@imei							  nvarchar(50)
			,@proc_req_code					  nvarchar(50)
			,@document_pending_code			  nvarchar(50)
			,@date							  datetime
			,@document_code					  nvarchar(50)
			,@document_name					  nvarchar(250)
			,@file_name						  nvarchar(250)
			,@file_path						  nvarchar(250)
			,@exp_date_doc					  datetime
			,@procurement_type				  nvarchar(50)
			,@branch_code_mobilisasi		  nvarchar(50)
			,@branch_name_mobilisasi		  nvarchar(250)
			,@to_province_code_mobilisasi	  nvarchar(50)
			,@to_province_name_mobilisasi	  nvarchar(250)
			,@to_city_code_mobilisasi		  nvarchar(50)
			,@to_city_name_mobilisasi		  nvarchar(250)
			,@to_area_phone_no_mobilisasi	  nvarchar(4)
			,@to_phone_no_mobilisasi		  nvarchar(15)
			,@to_address_mobilisasi			  nvarchar(4000)
			,@eta_date_mobilisasi			  datetime
			,@fa_code_mobilisasi			  nvarchar(50)
			,@fa_name_mobilisasi			  nvarchar(250)
			,@requestor_name_mobilisasi		  nvarchar(50)
			,@is_reimburse_mobilisasi		  nvarchar(1)
			,@handover_remark				  nvarchar(4000)
			,@supplier_code					  nvarchar(50)
			,@supplier_name					  nvarchar(250)
			,@ppn_amount					  decimal(18, 2)
			,@pph_amount					  decimal(18, 2)
			,@currency						  nvarchar(3)
			,@discount_amount				  decimal(18, 2)
			,@branch_code_adjust			  nvarchar(50)
			,@branch_name_adjust			  nvarchar(250)
			,@fa_code_adjust				  nvarchar(50)
			,@fa_name_adjust				  nvarchar(250)
			,@division_code_adjust			  nvarchar(50)
			,@division_name_adjust			  nvarchar(250)
			,@department_code_adjust		  nvarchar(50)
			,@department_name_adjust		  nvarchar(250)
			,@specification_adjust			  nvarchar(4000)
			,@cat_type_proc_request			  nvarchar(50)
			,@yang_diterima					  int
			,@gl_link_transaction_final_code  nvarchar(50)
			,@process_code					  nvarchar(50)
			,@journal_grn					  nvarchar(50)
			,@journal_final					  nvarchar(50)
			,@spaf_amount					  decimal(18, 2)
			,@subvention_amount				  decimal(18, 2)
			,@code_asset_for_adjustment		  nvarchar(50)
			,@name_asset_for_adjustment		  nvarchar(250)
			,@purchase_order_detail_id		  int
			,@cover_note					  nvarchar(50)
			,@bpkb_no						  nvarchar(50)
			,@cover_note_date				  datetime
			,@cover_exp_date				  datetime
			,@cover_file_name				  nvarchar(250)
			,@cover_file_path				  nvarchar(250)
			,@upload_reff_no				  nvarchar(50)
			,@upload_reff_name				  nvarchar(250)
			,@upload_reff_trx_code			  nvarchar(50)
			,@upload_file_name				  nvarchar(250)
			,@upload_doc_file				  varbinary(max)
			,@item_code_adj					  nvarchar(50)
			,@item_name_adj					  nvarchar(250)
			,@document_type					  nvarchar(15)
			,@agreement_no					  nvarchar(50)
			,@asset_no						  nvarchar(50)
			,@client_no						  nvarchar(50)
			,@client_name					  nvarchar(250)
			,@stnk_no						  nvarchar(50)
			,@stnk_date						  datetime
			,@stnk_exp_date					  datetime
			,@stck_no						  nvarchar(50)
			,@stck_date						  datetime
			,@stck_exp_date					  datetime
			,@keur_no						  nvarchar(50)
			,@keur_date						  datetime
			,@keur_exp_date					  datetime
			,@object_info_id				  bigint
			,@mobilisasi_type				  nvarchar(50)
			,@uom_name_adj					  nvarchar(15)
			,@quantity_adj					  int
			,@is_validate					  nvarchar(1)
			,@asset_expense_remark			  nvarchar(250)
			,@branch_code_asset				  nvarchar(50)
			,@branch_name_asset				  nvarchar(250)
			,@branch_code_request			  nvarchar(50)
			,@branch_name_request			  nvarchar(250)
			,@tax_scheme_code				  nvarchar(50)
			,@tax_scheme_name				  nvarchar(250)
			,@description_mobilisasi		  nvarchar(4000)
			,@from_city_name				  nvarchar(250)
			,@additional_amount				  decimal(18, 2)
			,@transaction_code				  nvarchar(50)
			,@item_name_for_journal			  nvarchar(250)
			,@journal_date					  datetime		= dbo.xfn_get_system_date()
			,@ppn_grn						  decimal(18, 2)
			,@pph_grn						  decimal(18, 2)
			,@discount_grn					  decimal(18, 2)
			,@asset_code_final				  nvarchar(50)
			,@asset							  nvarchar(50) ;

	begin try
		set @date = getdate() ;

		select	@division_code		 = grn.division_code
				,@division_name		 = grn.division_name
				,@department_code	 = grn.department_code
				,@department_name	 = grn.department_name
				,@po_no				 = grn.purchase_order_code
				--,@purchase_date			= po.order_date 
				,@vendor_code		 = grn.supplier_code
				,@vendor_name		 = grn.supplier_name
				,@requestor_code	 = po.requestor_code
				,@requestor_name	 = po.requestor_name
				,@ppn_pct			 = pod.ppn_pct
				,@pph_pct			 = pod.pph_pct
				,@unit_from			 = po.unit_from
				,@branch_code_header = grn.branch_code
				,@branch_name_header = grn.branch_name
				,@asset_code		 = grnd.type_asset_code
		from	dbo.good_receipt_note							   grn
				left join dbo.purchase_order					   po on grn.purchase_order_code = po.code
				left join dbo.purchase_order_detail				   pod on (pod.po_code			 = po.code)
				left join dbo.good_receipt_note_detail			   grnd on (grn.code			 = grnd.good_receipt_note_code)
				left join dbo.good_receipt_note_detail_object_info grndoi on (grnd.id			 = grndoi.good_receipt_note_detail_id)
		where	grn.code = @p_code ;

		select	@po_quantity				  = grnd.po_quantity
				,@recive_quantity			  = grnd.receive_quantity
				,@type_code					  = grnd.type_asset_code
				,@type_name					  = sgs.description
				,@chassis_no				  = podo.chassis_no
				,@plat_no					  = podo.plat_no
				,@engine_no					  = podo.engine_no
				,@serial_no					  = podo.serial_no
				,@invoice_no				  = podo.invoice_no
				,@domain					  = podo.domain
				,@imei						  = podo.imei
				,@category_desc				  = grnd.item_category_name
				,@merk_code					  = grnd.item_merk_code
				,@merk_desc					  = grnd.item_merk_name
				,@model_code				  = grnd.item_model_code
				,@model_desc				  = grnd.item_model_name
				,@type_item_code			  = grnd.item_type_code
				,@type_item_desc			  = grnd.item_type_name
				,@item_code					  = grnd.item_code
				,@item_name					  = grnd.item_name
				,@category_code				  = grnd.item_category_code
				,@category_name				  = grnd.item_category_name
				,@price_amount				  = grnd.price_amount - pod.discount_amount
				,@original_price			  = grnd.price_amount
				,@purchase_price			  = grnd.price_amount * grnd.receive_quantity
				,@good_receipt_note_detail_id = grnd.id
				,@is_rent					  = po.unit_from
				,@opl_code					  = isnull(pr.reff_no, pr2.reff_no)
				,@spesification				  = grnd.spesification
				,@proc_req_code				  = isnull(pr.code, pr2.code)
				,@procurement_type			  = isnull(pr.procurement_type, pr2.procurement_type)
				,@supplier_code				  = po.supplier_code
				,@supplier_name				  = po.supplier_name
				,@ppn_amount				  = pod.ppn_amount
				,@pph_amount				  = pod.pph_amount
				,@currency					  = po.currency_code
				,@discount_amount			  = pod.discount_amount
				,@branch_code				  = grn.branch_code
				,@branch_name				  = grn.branch_name
				,@spaf_amount				  = isnull(prc.spaf_amount, prc2.spaf_amount)
				,@subvention_amount			  = isnull(prc.subvention_amount, prc2.subvention_amount)
				,@purchase_order_detail_id	  = pod.id
				,@cover_note				  = podo.cover_note
				,@bpkb_no					  = podo.bpkb_no
				,@cover_note_date			  = podo.cover_note_date
				,@cover_exp_date			  = podo.exp_date
				,@cover_file_name			  = podo.file_name
				,@cover_file_path			  = podo.file_path
				,@stnk_no					  = podo.stnk
				,@stnk_date					  = podo.stnk_date
				,@stnk_exp_date				  = podo.stnk_exp_date
				,@stck_no					  = podo.stck
				,@stck_date					  = podo.stck_date
				,@stck_exp_date				  = podo.stck_exp_date
				,@keur_no					  = podo.keur
				,@keur_date					  = podo.keur_date
				,@keur_exp_date				  = podo.keur_exp_date
				,@object_info_id			  = podo.id
				,@mobilisasi_type			  = isnull(pr.mobilisasi_type, pr2.mobilisasi_type)
				,@branch_code_asset			  = isnull(pr.branch_code, pr2.branch_code)
				,@branch_name_asset			  = isnull(pr.branch_name, pr2.branch_name)
				,@tax_scheme_code			  = pod.tax_code
				,@tax_scheme_name			  = pod.tax_name
				,@ppn_grn					  = grnd.ppn_amount
				,@pph_grn					  = grnd.pph_amount
				,@discount_grn				  = grnd.discount_amount
		from	dbo.good_receipt_note_detail					grnd
				left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
				--ADD NEW BAGAS
				left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.good_receipt_note_detail_id	  = grnd.id)
				left join dbo.final_good_receipt_note			fgrn on (fgrn.code							  = fgrnd.final_good_receipt_note_code)
				--ADD NEW BAGAS
				left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
				left join dbo.sys_general_subcode				sgs on (sgs.code							  = grnd.type_asset_code)
																	   and	 sgs.company_code				  = 'DSF'
				left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
				--tambahan untuk ambil reff no di proc request
				left join dbo.purchase_order_detail				pod on (
																		   pod.po_code						  = po.code
																		   and pod.id						  = grnd.purchase_order_detail_id
																	   )
				left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
				left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
				left join dbo.procurement						prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
				left join dbo.procurement						prc2 on (prc2.code							  = ssd.reff_no)
				left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
				left join dbo.procurement_request				pr2 on (pr2.code							  = prc2.procurement_request_code)
		where	fgrn.code				  = @p_final_grn_code
				--grnd.good_receipt_note_code = @p_code
				and grnd.receive_quantity <> 0 ;

		begin --insert journal FINAL GRN
			-- jika unit from nya BUY maka bentuk jurnal Final GRN
			if (@unit_from = 'BUY')
			begin
				select	@asset_code_final = pri.FA_CODE
				from	dbo.final_good_receipt_note						fgrn
						left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code  = fgrn.code)
						left join dbo.good_receipt_note_detail			grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
						left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
						left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
						left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
						left join dbo.purchase_order_detail				pod on (
																				   pod.po_code						  = po.code
																				   and pod.id						  = grnd.purchase_order_detail_id
																			   )
						left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
						left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
						left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
						left join dbo.procurement_request_item			pri on (pr.code								  = pri.procurement_request_code)
				where	fgrn.code = @p_final_grn_code ;

				declare curr_branch_request cursor fast_forward read_only for
				select		pr.branch_code
							,pr.branch_name
				from		dbo.good_receipt_note_detail					grnd
							left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
							left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.good_receipt_note_detail_id	  = grnd.id)
							left join dbo.final_good_receipt_note			fgrn on (fgrn.code							  = fgrnd.final_good_receipt_note_code)
							left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
							left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
							left join dbo.purchase_order_detail				pod on (
																					   pod.po_code						  = po.code
																					   and pod.id						  = grnd.purchase_order_detail_id
																				   )
							left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
							inner join dbo.procurement						prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no))
							inner join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
				where		fgrn.code				  = @p_final_grn_code
							and grnd.receive_quantity <> 0
				group by	pr.branch_code
							,pr.branch_name ;

				open curr_branch_request ;

				fetch next from curr_branch_request
				into @branch_code_request
					 ,@branch_name_request ;

				while @@fetch_status = 0
				begin

					--Pembentukan Journal Final GRN
					set @transaction_name = N'Invoice Final Good Receipt Note ' + @p_final_grn_code + N' From PO ' + @po_no + N'.' + N' Vendor ' + @vendor_name ;

					exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_insert @p_code							= @journal_final output
																					   ,@p_company_code					= 'DSF'
																					   ,@p_branch_code					= @branch_code_request
																					   ,@p_branch_name					= @branch_name_request
																					   ,@p_transaction_status			= 'HOLD'
																					   ,@p_transaction_date				= @journal_date
																					   ,@p_transaction_value_date		= @journal_date
																					   ,@p_transaction_code				= @p_final_grn_code
																					   ,@p_transaction_name				= 'Final Good Receipt Note'
																					   ,@p_reff_module_code				= 'IFINPROC'
																					   ,@p_reff_source_no				= @p_final_grn_code
																					   ,@p_reff_source_name				= @transaction_name
																					   ,@p_is_journal_reversal			= '0'
																					   ,@p_transaction_type				= null
																					   ,@p_cre_date						= @p_mod_date
																					   ,@p_cre_by						= @p_mod_by
																					   ,@p_cre_ip_address				= @p_mod_ip_address
																					   ,@p_mod_date						= @p_mod_date
																					   ,@p_mod_by						= @p_mod_by
																					   ,@p_mod_ip_address				= @p_mod_ip_address ;

					declare curr_jur_grn cursor fast_forward read_only for
					select		mt.sp_name
								,mtp.debet_or_credit
								,mtp.gl_link_code
								,mtp.transaction_code
								,mt.transaction_name
								,grnd.id
								,grnd.uom_name
								,grnd.item_code
								,grnd.item_name
								,prc.item_group_code
								,mtp.process_code
								,podoi.asset_code
					from		dbo.master_transaction_parameter				mtp
								left join dbo.sys_general_subcode				sgs on (sgs.code							  = mtp.process_code)
								left join dbo.master_transaction				mt on (mt.code								  = mtp.transaction_code)
								inner join dbo.final_good_receipt_note			fgrn on (fgrn.code							  = @p_final_grn_code)
								inner join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code  = fgrn.code)
								inner join dbo.good_receipt_note_detail			grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
								left join dbo.purchase_order_detail				pod on (pod.id								  = grnd.purchase_order_detail_id)
								left join dbo.purchase_order_detail_object_info podoi on (
																							 pod.id							  = podoi.purchase_order_detail_id
																							 and   grnd.id					  = podoi.good_receipt_note_detail_id
																						 )
								left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
								left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
								inner join dbo.procurement						prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no))
								inner join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
					where		mtp.process_code		  = 'S240600002'--'SGS230600003'
								and grnd.receive_quantity <> 0
								and pr.branch_code		  = @branch_code_request
					order by	grnd.item_code ;

					open curr_jur_grn ;

					fetch next from curr_jur_grn
					into @sp_name
						 ,@debet_or_credit
						 ,@gl_link_code
						 ,@transaction_code
						 ,@transaction_name
						 ,@grn_id
						 ,@uom_name
						 ,@item_code_for_jrnl
						 ,@item_name_for_jrnl
						 ,@item_group_code
						 ,@process_code
						 ,@asset_code ;

					while @@fetch_status = 0
					begin
						set @asset = isnull(@asset_code, @asset_code_final) ;

						-- nilainya exec dari MASTER_TRANSACTION.sp_name
						exec @return_value = @sp_name @grn_id ; -- sp ini mereturn value angka 

						if (@return_value <> 0)
						begin
							if (@debet_or_credit = 'DEBIT')
							begin
								set @orig_amount_cr = 0 ;
								set @orig_amount_db = @return_value ;
							end ;
							else
							begin
								set @orig_amount_cr = abs(@return_value) ;
								set @orig_amount_db = 0 ;
							end ;
						end ;

						-- Jika GL Code  = ASSET, cek di master category berdasarkan ASSET
						if (@gl_link_code = 'ASTGRN')
						begin
							--Jika asset nya BUY
							if (@unit_from = 'BUY')
							begin
								select	@gl_link_code = dbo.xfn_get_asset_gl_code_by_item(@item_group_code) ;
							end ;
							else
							begin
								select	@gl_link_code = dbo.xfn_get_asset_gl_code_by_item_rent(@item_group_code) ;
							end ;
						end ;

						if (isnull(@gl_link_code, '') = '')
						begin
							set @msg = N'Please Setting GL Link For ' + @transaction_name ;

							raiserror(@msg, 16, -1) ;
						end ;

						--jika unit from nya BUY maka bentuk jurnal
						if (@is_rent = 'BUY')
						begin
							if @return_value <> 0
							begin
								set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(convert(nvarchar(3), @recive_quantity), '') + N' ' + isnull(@uom_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO No : ' + isnull(@po_no, '') ;

								-- jurnal asset digabung pada saat insert ke journal detail
								if (@transaction_code = 'ASTGRNO')
								begin
									--if not exists (select 1 from dbo.ifinproc_interface_journal_gl_link_transaction_detail where gl_link_transaction_code = @journal_final and gl_link_code = @gl_link_code)
									begin
										set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(@item_name_for_journal, '') ;

										exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @journal_final
																												  ,@p_company_code				= 'DSF'
																												  ,@p_branch_code				= @branch_code_request
																												  ,@p_branch_name				= @branch_name_request
																												  ,@p_cost_center_code			= null
																												  ,@p_cost_center_name			= null
																												  ,@p_gl_link_code				= @gl_link_code
																												  ,@p_agreement_no				= @asset				--@asset_code
																												  ,@p_facility_code				= null
																												  ,@p_facility_name				= null
																												  ,@p_purpose_loan_code			= null
																												  ,@p_purpose_loan_name			= null
																												  ,@p_purpose_loan_detail_code	= null
																												  ,@p_purpose_loan_detail_name	= null
																												  ,@p_orig_currency_code		= 'IDR'
																												  ,@p_orig_amount_db			= @orig_amount_db
																												  ,@p_orig_amount_cr			= @orig_amount_cr
																												  ,@p_exch_rate					= 1
																												  ,@p_base_amount_db			= @orig_amount_db
																												  ,@p_base_amount_cr			= @orig_amount_cr
																												  ,@p_division_code				= @division_code
																												  ,@p_division_name				= @division_name
																												  ,@p_department_code			= @department_code
																												  ,@p_department_name			= @department_name
																												  ,@p_remarks					= @remarks_journal
																												  ,@p_cre_date					= @p_mod_date
																												  ,@p_cre_by					= @p_mod_by
																												  ,@p_cre_ip_address			= @p_mod_ip_address
																												  ,@p_mod_date					= @p_mod_date
																												  ,@p_mod_by					= @p_mod_by
																												  ,@p_mod_ip_address			= @p_mod_ip_address ;
									end 
									--else
									--begin
									--	update dbo.ifinproc_interface_journal_gl_link_transaction_detail
									--	set orig_amount_db	= orig_amount_db + @orig_amount_db
									--		,orig_amount_cr	= orig_amount_cr + @orig_amount_cr
									--		,base_amount_db = base_amount_db + @orig_amount_db
									--		,base_amount_cr = base_amount_cr + @orig_amount_cr
									--		,agreement_no	= @asset
									--	where gl_link_code = @gl_link_code
									--	and gl_link_transaction_code = @journal_final
									--end
								end ;
								else if (@transaction_code = 'AUCFO')
								begin
									if not exists
									(
										select	1
										from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
										where	gl_link_transaction_code = @journal_final
												and gl_link_code		 = @gl_link_code
									)
									begin
										set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(@item_name_for_journal, '') ;

										exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @journal_final
																												  ,@p_company_code					= 'DSF'
																												  ,@p_branch_code					= @branch_code_request
																												  ,@p_branch_name					= @branch_name_request
																												  ,@p_cost_center_code				= null
																												  ,@p_cost_center_name				= null
																												  ,@p_gl_link_code					= @gl_link_code
																												  ,@p_agreement_no					= @po_no
																												  ,@p_facility_code					= null
																												  ,@p_facility_name					= null
																												  ,@p_purpose_loan_code				= null
																												  ,@p_purpose_loan_name				= null
																												  ,@p_purpose_loan_detail_code		= null
																												  ,@p_purpose_loan_detail_name		= null
																												  ,@p_orig_currency_code			= 'IDR'
																												  ,@p_orig_amount_db				= @orig_amount_db
																												  ,@p_orig_amount_cr				= @orig_amount_cr
																												  ,@p_exch_rate						= 1
																												  ,@p_base_amount_db				= @orig_amount_db
																												  ,@p_base_amount_cr				= @orig_amount_cr
																												  ,@p_division_code					= @division_code
																												  ,@p_division_name					= @division_name
																												  ,@p_department_code				= @department_code
																												  ,@p_department_name				= @department_name
																												  ,@p_remarks						= @remarks_journal
																												  ,@p_cre_date						= @p_mod_date
																												  ,@p_cre_by						= @p_mod_by
																												  ,@p_cre_ip_address				= @p_mod_ip_address
																												  ,@p_mod_date						= @p_mod_date
																												  ,@p_mod_by						= @p_mod_by
																												  ,@p_mod_ip_address				= @p_mod_ip_address ;
									end
								    else
									begin
										update dbo.ifinproc_interface_journal_gl_link_transaction_detail
										set orig_amount_db	= orig_amount_db + @orig_amount_db
											,orig_amount_cr	= orig_amount_cr + @orig_amount_cr
											,base_amount_db = base_amount_db + @orig_amount_db
											,base_amount_cr = base_amount_cr + @orig_amount_cr
										where gl_link_code = @gl_link_code
										and gl_link_transaction_code = @journal_final
									end
								end ;
								else
								begin
									exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @journal_final
																											  ,@p_company_code					= 'DSF'
																											  ,@p_branch_code					= @branch_code_request
																											  ,@p_branch_name					= @branch_name_request
																											  ,@p_cost_center_code				= null
																											  ,@p_cost_center_name				= null
																											  ,@p_gl_link_code					= @gl_link_code
																											  ,@p_agreement_no					= @po_no
																											  ,@p_facility_code					= null
																											  ,@p_facility_name					= null
																											  ,@p_purpose_loan_code				= null
																											  ,@p_purpose_loan_name				= null
																											  ,@p_purpose_loan_detail_code		= null
																											  ,@p_purpose_loan_detail_name		= null
																											  ,@p_orig_currency_code			= 'IDR'
																											  ,@p_orig_amount_db				= @orig_amount_db
																											  ,@p_orig_amount_cr				= @orig_amount_cr
																											  ,@p_exch_rate						= 1
																											  ,@p_base_amount_db				= @orig_amount_db
																											  ,@p_base_amount_cr				= @orig_amount_cr
																											  ,@p_division_code					= @division_code
																											  ,@p_division_name					= @division_name
																											  ,@p_department_code				= @department_code
																											  ,@p_department_name				= @department_name
																											  ,@p_remarks						= @remarks_journal
																											  ,@p_cre_date						= @p_mod_date
																											  ,@p_cre_by						= @p_mod_by
																											  ,@p_cre_ip_address				= @p_mod_ip_address
																											  ,@p_mod_date						= @p_mod_date
																											  ,@p_mod_by						= @p_mod_by
																											  ,@p_mod_ip_address				= @p_mod_ip_address ;
								end ;
							end ;
						end ;

						fetch next from curr_jur_grn
						into @sp_name
							 ,@debet_or_credit
							 ,@gl_link_code
							 ,@transaction_code
							 ,@transaction_name
							 ,@grn_id
							 ,@uom_name
							 ,@item_code_for_jrnl
							 ,@item_name_for_jrnl
							 ,@item_group_code
							 ,@process_code
							 ,@asset_code ;
					end ;

					close curr_jur_grn ;
					deallocate curr_jur_grn ;

					select	@orig_amount_db	 = sum(orig_amount_db)
							,@orig_amount_cr = sum(orig_amount_cr)
					from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
					where	gl_link_transaction_code = @journal_final ;

					--+ validasi : total detail =  payment_amount yang di header
					if (@orig_amount_db <> @orig_amount_cr)
					begin
						set @msg = N'Journal does not balance' ;

						raiserror(@msg, 16, -1) ;
					end ;

					fetch next from curr_branch_request
					into @branch_code_request
						 ,@branch_name_request ;
				end ;

				close curr_branch_request ;
				deallocate curr_branch_request ;
			end ;
		end ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
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

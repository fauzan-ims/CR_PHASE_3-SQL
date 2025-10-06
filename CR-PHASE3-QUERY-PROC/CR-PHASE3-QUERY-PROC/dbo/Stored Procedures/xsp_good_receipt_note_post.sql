-- Stored Procedure

CREATE PROCEDURE dbo.xsp_good_receipt_note_post

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
			,@asset							  nvarchar(50)
			,@receive_date					  datetime
			,@asset_code_expense			  nvarchar(50)
			,@pph_for_expense				  decimal(18, 2)
			,@counter						  int 
			,@fa_code_expense				nvarchar(50)
			,@supplier_code_expense			nvarchar(50)
			,@supplier_name_expense			nvarchar(250)
			,@receive_date_expense			datetime

	begin try
		set @date = dbo.xfn_get_system_date() ;

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

		update	dbo.good_receipt_note
		set		status = 'APPROVE'--POST'
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;

		begin --push ke asset
			declare curr_asset cursor fast_forward read_only for
			select	grnd.po_quantity
					,grnd.receive_quantity
					,grnd.type_asset_code
					,sgs.description
					,podo.chassis_no
					,podo.plat_no
					,podo.engine_no
					,podo.serial_no
					,podo.invoice_no
					,podo.domain
					,podo.imei
					,grnd.item_category_name
					,grnd.item_merk_code
					,grnd.item_merk_name
					,grnd.item_model_code
					,grnd.item_model_name
					,grnd.item_type_code
					,grnd.item_type_name
					,grnd.item_code
					,grnd.item_name
					,grnd.item_category_code
					,grnd.item_category_name
					,grnd.price_amount - pod.discount_amount
					,grnd.price_amount
					,grnd.price_amount * grnd.receive_quantity
					,grnd.id
					,po.unit_from
					,pr.reff_no
					,grnd.spesification
					,pr.code
					,pr.procurement_type
					,po.supplier_code
					,po.supplier_name
					,pod.ppn_amount
					,pod.pph_amount
					,po.currency_code
					,pod.discount_amount
					,grn.branch_code
					,grn.branch_name
					,prc.spaf_amount
					,prc.subvention_amount
					,pod.id
					,podo.cover_note
					,podo.bpkb_no
					,podo.cover_note_date
					,podo.exp_date
					,podo.file_name
					,podo.file_path
					,podo.stnk
					,podo.stnk_date
					,podo.stnk_exp_date
					,podo.stck
					,podo.stck_date
					,podo.stck_exp_date
					,podo.keur
					,podo.keur_date
					,podo.keur_exp_date
					,podo.id
					,pr.mobilisasi_type
					,pr.branch_code
					,pr.branch_name
					,pod.tax_code
					,pod.tax_name
					,grnd.ppn_amount
					,grnd.pph_amount
					,grnd.discount_amount
					,grn.receive_date
			from	dbo.good_receipt_note_detail					grnd
					left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
					left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.good_receipt_note_detail_id	  = grnd.id)
					left join dbo.final_good_receipt_note			fgrn on (fgrn.code							  = fgrnd.final_good_receipt_note_code)
					left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
					left join dbo.sys_general_subcode				sgs on (sgs.code							  = grnd.type_asset_code)
																		   and	 sgs.company_code				  = 'DSF'
					left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
					left join dbo.purchase_order_detail				pod on (
																			   pod.po_code						  = po.code
																			   and pod.id						  = grnd.purchase_order_detail_id
																		   )
					left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
					left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
					left join dbo.procurement						prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no))
					left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
			where	fgrn.code				  = @p_final_grn_code
					and grnd.receive_quantity <> 0 ;

			open curr_asset ;


			fetch next from curr_asset
			into @po_quantity
				 ,@recive_quantity
				 ,@type_code
				 ,@type_name
				 ,@chassis_no
				 ,@plat_no
				 ,@engine_no
				 ,@serial_no
				 ,@invoice_no
				 ,@domain
				 ,@imei
				 ,@category_desc
				 ,@merk_code
				 ,@merk_desc
				 ,@model_code
				 ,@model_desc
				 ,@type_item_code
				 ,@type_item_desc
				 ,@item_code
				 ,@item_name
				 ,@category_code
				 ,@category_name
				 ,@price_amount
				 ,@original_price
				 ,@purchase_price
				 ,@good_receipt_note_detail_id
				 ,@is_rent
				 ,@opl_code
				 ,@spesification
				 ,@proc_req_code
				 ,@procurement_type
				 ,@supplier_code
				 ,@supplier_name
				 ,@ppn_amount
				 ,@pph_amount
				 ,@currency
				 ,@discount_amount
				 ,@branch_code
				 ,@branch_name
				 ,@spaf_amount
				 ,@subvention_amount
				 ,@purchase_order_detail_id
				 ,@cover_note
				 ,@bpkb_no
				 ,@cover_note_date
				 ,@cover_exp_date
				 ,@cover_file_name
				 ,@cover_file_path
				 ,@stnk_no
				 ,@stnk_date
				 ,@stnk_exp_date
				 ,@stck_no
				 ,@stck_date
				 ,@stck_exp_date
				 ,@keur_no
				 ,@keur_date
				 ,@keur_exp_date
				 ,@object_info_id
				 ,@mobilisasi_type
				 ,@branch_code_asset
				 ,@branch_name_asset
				 ,@tax_scheme_code
				 ,@tax_scheme_name
				 ,@ppn_grn
				 ,@pph_grn
				 ,@discount_grn
				 ,@receive_date ;

			while @@fetch_status = 0
			begin
			
				begin -- Update PO ketika barang diterima berkala
					set @remaining_qty = @po_quantity - @recive_quantity ;

					update	dbo.purchase_order_detail
					set		order_remaining = @remaining_qty
							--
							,mod_date = @p_mod_date
							,mod_by = @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	id = @purchase_order_detail_id ;
				end ;

				begin -- Update status Order jadi CLOSED
					select	@sum_order_remaining = sum(pod.order_remaining)
					from	dbo.purchase_order					 po
							inner join dbo.purchase_order_detail pod on (pod.po_code = po.code)
					where	po.code = @po_no ;

					if (@sum_order_remaining = 0)
					begin
						update	dbo.purchase_order
						set		status = 'CLOSED'
								--
								,mod_date = @p_mod_date
								,mod_by = @p_mod_by
								,mod_ip_address = @p_mod_ip_address
						where	code = @po_no ;
					end ;
				end ;
			
				begin -- Cek apakah type procurementnya MOBILISASI atau tidak
					if (@procurement_type = 'PURCHASE')
					begin
						declare curr_proc_type cursor fast_forward read_only for

						select	category_type
						from	dbo.procurement_request_item
						where	procurement_request_code = @proc_req_code
								and item_code			 = @item_code ;

						open curr_proc_type ;

						fetch next from curr_proc_type
						into @cat_type_proc_request ;

						while @@fetch_status = 0
						begin
							if (@cat_type_proc_request = 'ASSET')
							begin
								set @item_name_for_journal = @item_name ;

								if (@opl_code is null)
								begin
									set @asset_purpose = N'INTERNAL' ;
								end ;
								else
								begin
									set @asset_purpose = N'LEASE' ;
								end ;

								if (@bpkb_no is null)
								begin
									set @document_type = N'COVERNOTE' ;
								end ;
								else
								begin
									set @document_type = N'BPKB' ;
								end ;

								--insert ke interface asset
								exec dbo.xsp_eproc_interface_asset_insert @p_code = @code output
																		  ,@p_company_code = @p_company_code
																		  ,@p_item_code = @item_code
																		  ,@p_item_name = @item_name
																		  ,@p_item_group_code = @item_group_code
																		  ,@p_condition = 'NEW'
																		  ,@p_barcode = null
																		  ,@p_status = 'HOLD'
																		  ,@p_po_no = @po_no
																		  ,@p_requestor_code = @requestor_code
																		  ,@p_requestor_name = @requestor_name
																		  ,@p_vendor_code = @vendor_code
																		  ,@p_vendor_name = @vendor_name
																		  ,@p_type_code = @type_code
																		  ,@p_type_name = @type_name
																		  ,@p_category_code = @category_code
																		  ,@p_category_name = @category_name
																		  ,@p_purchase_date = @receive_date --@purchase_date
																		  ,@p_purchase_price = @price_amount
																		  ,@p_invoice_no = null
																		  ,@p_invoice_date = null
																		  ,@p_original_price = @original_price
																		  ,@p_branch_code = @branch_code_asset
																		  ,@p_branch_name = @branch_name_asset
																		  ,@p_division_code = @division_code
																		  ,@p_division_name = @division_name
																		  ,@p_department_code = @department_code
																		  ,@p_department_name = @department_name
																		  ,@p_merk_code = @merk_code
																		  ,@p_merk_name = @merk_desc
																		  ,@p_model_code = @model_code
																		  ,@p_model_name = @model_desc
																		  ,@p_type_item_code = @type_item_code
																		  ,@p_type_item_name = @type_item_desc
																		  ,@p_pph = @pph_pct
																		  ,@p_ppn = @ppn_pct
																		  ,@p_is_po = '1'
																		  ,@p_is_rental = '0'
																		  ,@p_plat_no = @plat_no
																		  ,@p_chassis_no = @chassis_no
																		  ,@p_engine_no = @engine_no
																		  ,@p_serial = @serial_no
																		  ,@p_invoice = @invoice_no
																		  ,@p_domain = @domain
																		  ,@p_imei = @imei
																		  ,@p_asset_from = @is_rent
																		  ,@p_asset_purpose = @asset_purpose
																		  ,@p_remarks = @spesification
																		  ,@p_spaf_amount = @spaf_amount
																		  ,@p_subvention_amount = @subvention_amount
																		  ,@p_bpkb_no = @bpkb_no
																		  ,@p_cover_note = @cover_note
																		  ,@p_cover_note_date = @cover_note_date
																		  ,@p_cover_note_exp_date = @cover_exp_date
																		  ,@p_file_name = @cover_file_name
																		  ,@p_file_path = @file_path
																		  ,@p_reff_no = @opl_code
																		  ,@p_document_type = @document_type
																		  ,@p_stnk_no = @stnk_no
																		  ,@p_stnk_date = @stnk_date
																		  ,@p_stnk_exp_date = @stnk_exp_date
																		  ,@p_stck_no = @stck_no
																		  ,@p_stck_date = @stck_date
																		  ,@p_stck_exp_date = @stck_exp_date
																		  ,@p_keur_no = @keur_no
																		  ,@p_keur_date = @keur_date
																		  ,@p_keur_exp_date = @keur_exp_date
																											--Raffy 12/12/2023 (+) penambahan field baru 
																		  ,@p_ppn_amount = @ppn_grn
																		  ,@p_pph_amount = @pph_grn
																		  ,@p_discount_amount = @discount_grn
																		  ,@p_posting_date = @purchase_date --@p_mod_date
																		  ,@p_grn_detail = @good_receipt_note_detail_id
																											--
																		  ,@p_cre_date = @p_mod_date
																		  ,@p_cre_by = @p_mod_by
																		  ,@p_cre_ip_address = @p_mod_ip_address
																		  ,@p_mod_date = @p_mod_date
																		  ,@p_mod_by = @p_mod_by
																		  ,@p_mod_ip_address = @p_mod_ip_address ;

								begin -- update interface OPL
									select	@interface_purchase_request_code = isnull(pirr.asset_no, pirr2.asset_no)
											,@unit_from						 = isnull(prc.unit_from, prc2.unit_from)
									from	dbo.good_receipt_note_detail				  grnd
											left join dbo.purchase_order_detail			  pod on (pod.id										= grnd.purchase_order_detail_id)
											left join dbo.supplier_selection_detail		  ssd on (ssd.id										= pod.supplier_selection_detail_id)
											left join dbo.quotation_review_detail		  qrd on (qrd.id										= ssd.quotation_detail_id)
											left join dbo.procurement					  prc on (prc.code collate sql_latin1_general_cp1_ci_as = qrd.reff_no)
											left join procurement						  prc2 on (prc2.code									= ssd.reff_no)
											left join dbo.procurement_request			  pr on (pr.code										= prc.procurement_request_code)
											left join dbo.procurement_request			  pr2 on (pr2.code										= prc2.procurement_request_code)
											left join dbo.proc_interface_purchase_request pirr on (pirr.code									= pr.reff_no)
											left join dbo.proc_interface_purchase_request pirr2 on (pirr2.code									= pr2.reff_no)
									where	grnd.id = @good_receipt_note_detail_id ;

									update	dbo.proc_interface_purchase_request
									set		result_fa_code = @code
											,result_fa_name = @item_name
											,result_date = dbo.xfn_get_system_date()
											,request_status = 'POST'
											,fa_reff_no_01 = @plat_no
											,fa_reff_no_02 = @chassis_no
											,fa_reff_no_03 = @engine_no
											--
											,mod_date = @p_mod_date
											,mod_by = @p_mod_by
											,mod_ip_address = @p_mod_ip_address
									where	asset_no	  = @interface_purchase_request_code
											and unit_from = @unit_from ;
								end ;

								begin --update code asset insurance
									update	dbo.ifinproc_interface_asset_insurance
									set		asset_code = @code
											--
											,mod_date = @p_mod_date
											,mod_by = @p_mod_by
											,mod_ip_address = @p_mod_ip_address
									where	asset_no = @interface_purchase_request_code ;

								end ;

								begin -- update asset code di object info
									update	dbo.purchase_order_detail_object_info
									set		asset_code = @code
											--
											,mod_by = @p_mod_by
											,mod_date = @p_mod_date
											,mod_ip_address = @p_mod_ip_address
									where	id = @object_info_id ;
								end ;
							end ;
							else
							begin

								select	@interface_purchase_request_code = isnull(pirr.code, pirr2.code)
										,@unit_from						 = isnull(prc.unit_from, prc2.unit_from)
										,@date							= grn.receive_date
								from	dbo.good_receipt_note_detail				  grnd
										inner join dbo.good_receipt_note				grn on grn.code = grnd.good_receipt_note_code
										left join dbo.purchase_order_detail			  pod on (pod.id										= grnd.purchase_order_detail_id)
										left join dbo.supplier_selection_detail		  ssd on (ssd.id										= pod.supplier_selection_detail_id)
										left join dbo.quotation_review_detail		  qrd on (qrd.id										= ssd.quotation_detail_id)
										left join dbo.procurement					  prc on (prc.code collate sql_latin1_general_cp1_ci_as = qrd.reff_no)
										left join procurement						  prc2 on (prc2.code									= ssd.reff_no)
										left join dbo.procurement_request			  pr on (pr.code										= prc.procurement_request_code)
										left join dbo.procurement_request			  pr2 on (pr2.code										= prc2.procurement_request_code)
										left join dbo.proc_interface_purchase_request pirr on (pirr.code									= pr.reff_no)
										left join dbo.proc_interface_purchase_request pirr2 on (pirr2.code									= pr2.reff_no)
								where	grnd.id = @good_receipt_note_detail_id ;

								update	dbo.proc_interface_purchase_request
								set		result_fa_code = @code
										,result_fa_name = @item_name
										,result_date = dbo.xfn_get_system_date()
										,request_status = 'POST'
										,fa_reff_no_01 = @plat_no
										,fa_reff_no_02 = @chassis_no
										,fa_reff_no_03 = @engine_no
										--
										,mod_date = @p_mod_date
										,mod_by = @p_mod_by
										,mod_ip_address = @p_mod_ip_address
								where	asset_no	  = @interface_purchase_request_code
										and unit_from = @unit_from ;

								begin --insert ke adjustment
									declare cursor_name cursor fast_forward read_only for
									select	pr.branch_code
											,pr.branch_name
											,pri.fa_code
											,pri.fa_name
											,pr.division_code
											,pr.division_name
											,pr.department_code
											,pr.department_name
											,pri.specification
											,pri.item_code
											,pri.item_name
											,pri.uom_name
											,pri.approved_quantity
									from	dbo.procurement_request				   pr
											left join dbo.procurement_request_item pri on (pr.code = pri.procurement_request_code)
									where	pr.code			  = @proc_req_code
											and pri.item_code = @item_code ;

									open cursor_name ;

									fetch next from cursor_name
									into @branch_code_adjust
										 ,@branch_name_adjust
										 ,@fa_code_adjust
										 ,@fa_name_adjust
										 ,@division_code_adjust
										 ,@division_name_adjust
										 ,@department_code_adjust
										 ,@department_name_adjust
										 ,@specification_adjust
										 ,@item_code_adj
										 ,@item_name_adj
										 ,@uom_name_adj
										 ,@quantity_adj ;

									while @@fetch_status = 0
									begin
										set @code_asset_for_adjustment = isnull(@fa_code_adjust, @code) ;
										set @name_asset_for_adjustment = isnull(@fa_name_adjust, @item_name) ;

										exec dbo.xsp_ifinproc_interface_adjustment_asset_insert @p_id = 0
																								,@p_code = @p_code
																								,@p_branch_code = @branch_code_adjust
																								,@p_branch_name = @branch_name_adjust
																								,@p_date = @date
																								,@p_fa_code = @code_asset_for_adjustment
																								,@p_fa_name = @name_asset_for_adjustment
																								,@p_item_code = @item_code_adj
																								,@p_item_name = @item_name_adj
																								,@p_division_code = @division_code_adjust
																								,@p_division_name = @division_name_adjust
																								,@p_department_code = @department_code_adjust
																								,@p_department_name = @department_name_adjust
																								,@p_description = @specification_adjust
																								,@p_adjustment_amount = @price_amount	--@purchase_price
																								,@p_quantity = @quantity_adj
																								,@p_uom = @uom_name_adj
																								,@p_type_asset = 'SINGLE'
																								,@p_job_status = 'HOLD'
																								,@p_failed_remarks = ''
																								,@p_adjust_type = 'GRN'
																																		--
																								,@p_cre_date = @p_mod_date
																								,@p_cre_by = @p_mod_by
																								,@p_cre_ip_address = @p_mod_ip_address
																								,@p_mod_date = @p_mod_date
																								,@p_mod_by = @p_mod_by
																								,@p_mod_ip_address = @p_mod_ip_address ;

										fetch next from cursor_name
										into @branch_code_adjust
											 ,@branch_name_adjust
											 ,@fa_code_adjust
											 ,@fa_name_adjust
											 ,@division_code_adjust
											 ,@division_name_adjust
											 ,@department_code_adjust
											 ,@department_name_adjust
											 ,@specification_adjust
											 ,@item_code_adj
											 ,@item_name_adj
											 ,@uom_name_adj
											 ,@quantity_adj ;
									end ;

									close cursor_name ;
									deallocate cursor_name ;
								end ;
							end ;

							fetch next from curr_proc_type
							into @cat_type_proc_request ;
						end ;

						close curr_proc_type ;
						deallocate curr_proc_type ;

					end ;
					else if (@procurement_type = 'MOBILISASI')
					begin -- insert ke handover, expense ledger, additional invoice
						--if(@opl_code is null)
						declare curr_mobilisasi cursor fast_forward read_only for
						select	pr.branch_code
								,pr.branch_name
								,pr.to_province_code
								,pr.to_province_name
								,pr.to_city_code
								,pr.to_city_name
								,pr.to_area_phone_no
								,pr.to_phone_no
								,pr.to_address
								,pr.eta_date
								,pri.fa_code
								,pri.fa_name
								,pr.requestor_name
								,pr.is_reimburse
								,pr.from_city_name
						from	dbo.good_receipt_note_detail			 grnd
								inner join dbo.good_receipt_note		 grn on (grn.code							   = grnd.good_receipt_note_code)
								inner join dbo.purchase_order			 po on (po.code								   = grn.purchase_order_code)
								inner join dbo.purchase_order_detail	 pod on (
																					pod.po_code						   = po.code
																					and pod.id						   = grnd.purchase_order_detail_id
																				)
								inner join dbo.supplier_selection_detail ssd on (ssd.id								   = pod.supplier_selection_detail_id)
								left join dbo.quotation_review_detail	 qrd on (qrd.id								   = ssd.quotation_detail_id)
								inner join dbo.procurement				 prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
								inner join dbo.procurement_request		 pr on (pr.code								   = prc.procurement_request_code)
								inner join dbo.procurement_request_item	 pri on (
																					pri.procurement_request_code	   = pr.code
																					and pri.item_code				   = grnd.item_code
																				)
						where	grnd.good_receipt_note_code = @p_code
								and grnd.receive_quantity	<> 0 ;

						--from dbo.procurement_request pr
						--left join dbo.procurement_request_item pri on (pr.code = pri.procurement_request_code)
						--where pr.code = @proc_req_code

						open curr_mobilisasi ;

						fetch next from curr_mobilisasi
						into @branch_code_mobilisasi
							 ,@branch_name_mobilisasi
							 ,@to_province_code_mobilisasi
							 ,@to_province_name_mobilisasi
							 ,@to_city_code_mobilisasi
							 ,@to_city_name_mobilisasi
							 ,@to_area_phone_no_mobilisasi
							 ,@to_phone_no_mobilisasi
							 ,@to_address_mobilisasi
							 ,@eta_date_mobilisasi
							 ,@fa_code_mobilisasi
							 ,@fa_name_mobilisasi
							 ,@requestor_name_mobilisasi
							 ,@is_reimburse_mobilisasi
							 ,@from_city_name ;

						while @@fetch_status = 0
						begin
							if (@mobilisasi_type = 'OTHERS')
							begin
								--Insert ke Handover
								set @handover_remark = N'Mobilisasi Asset ' + isnull(@fa_code_mobilisasi, '') + N' ' + isnull(@fa_name_mobilisasi, '') ;

								exec dbo.xsp_ifinproc_interface_handover_request_insert @p_code = 0
																						,@p_branch_code = @branch_code_mobilisasi
																						,@p_branch_name = @branch_name_mobilisasi
																						,@p_status = 'HOLD'
																						,@p_transaction_date = @date
																						,@p_type = 'MOBILISASI'
																						,@p_remark = @handover_remark
																						,@p_fa_code = @fa_code_mobilisasi
																						,@p_fa_name = @fa_name_mobilisasi
																						,@p_handover_from = 'INTERNAL'
																						,@p_handover_to = @supplier_name
																						,@p_unit_condition = ''
																						,@p_reff_no = @proc_req_code
																						,@p_reff_name = 'PROCUREMENT MOBILISASI'
																						,@p_handover_address = @to_address_mobilisasi
																						,@p_handover_phone_area = @to_area_phone_no_mobilisasi
																						,@p_handover_phone_no = @to_phone_no_mobilisasi
																						,@p_handover_eta_date = @eta_date_mobilisasi
																						,@p_handover_code = null
																						,@p_handover_bast_date = null
																						,@p_handover_remark = ''
																						,@p_handover_status = ''
																						,@p_asset_status = null
																						,@p_settle_date = null
																						,@p_job_status = 'HOLD'
																						,@p_failed_remarks = ''
																						,@p_cre_date = @p_mod_date
																						,@p_cre_by = @p_mod_by
																						,@p_cre_ip_address = @p_mod_ip_address
																						,@p_mod_date = @p_mod_date
																						,@p_mod_by = @p_mod_by
																						,@p_mod_ip_address = @p_mod_ip_address ;
							end ;

							--if(@is_reimburse_mobilisasi = '0')
							--begin
							--		select	@agreement_no	= agreement_no
							--				,@client_name	= client_name
							--		from	ifinams.dbo.asset
							--		where	code = @fa_code_mobilisasi ;
							--		set @asset_expense_remark = 'Mobilisasi Asset ' + isnull(@fa_code_mobilisasi,'') + ' ' + isnull(@fa_name_mobilisasi,'');
							--		exec dbo.xsp_ifinproc_interface_asset_expense_ledger_insert @p_id					= 0
							--																	,@p_asset_code			= @fa_code_mobilisasi
							--																	,@p_date				= @date
							--																	,@p_reff_code			= @proc_req_code
							--																	,@p_reff_name			= 'PROCUREMENT MOBILISASI'
							--																	,@p_reff_remark			= @asset_expense_remark
							--																	,@p_expense_amount		= @price_amount--@purchase_price
							--																	,@p_agreement_no		= @agreement_no
							--																	,@p_client_name			= @client_name
							--																	,@p_settle_date			= null
							--																	,@p_job_status			= 'HOLD'
							--																	,@p_cre_date			= @p_mod_date
							--																	,@p_cre_by				= @p_mod_by
							--																	,@p_cre_ip_address		= @p_mod_ip_address
							--																	,@p_mod_date			= @p_mod_date
							--																	,@p_mod_by				= @p_mod_by
							--																	,@p_mod_ip_address		= @p_mod_ip_address

							--	end
							--else
							--begin
							--		select	@agreement_no	= agreement_no
							--				,@asset_no		= asset_no
							--				,@client_no		= client_no
							--				,@client_name	= client_name
							--		from	ifinams.dbo.asset
							--		where	code = @fa_code_mobilisasi ;

							--		set @description_mobilisasi = 'Mobilisasi Asset ' + @fa_code_mobilisasi + ' - ' + @fa_name_mobilisasi + '. From ' + @from_city_name + '. To ' + @to_city_name_mobilisasi

							--		set @additional_amount = @original_price - @discount_amount --((@original_price - @discount_amount) * @recive_quantity) + @ppn_amount - @pph_amount
							--		exec dbo.xsp_ifinproc_interface_additional_invoice_request_insert @p_id							= 0
							--																		  ,@p_agreement_no				= @agreement_no
							--																		  ,@p_asset_no					= @asset_no
							--																		  ,@p_branch_code				= @branch_code_mobilisasi
							--																		  ,@p_branch_name				= @branch_name_mobilisasi
							--																		  ,@p_invoice_type				= 'MBLS'
							--																		  ,@p_invoice_date				= @date
							--																		  ,@p_invoice_name				= 'Mobilisasi Asset'
							--																		  ,@p_client_no					= @client_no
							--																		  ,@p_client_name				= @client_name
							--																		  ,@p_client_address			= ''
							--																		  ,@p_client_area_phone_no		= ''
							--																		  ,@p_client_phone_no			= ''
							--																		  ,@p_client_npwp				= ''
							--																		  ,@p_currency_code				= @currency
							--																		  ,@p_tax_scheme_code			= ''
							--																		  ,@p_tax_scheme_name			= ''
							--																		  ,@p_billing_no				= 0
							--																		  ,@p_description				= @description_mobilisasi
							--																		  ,@p_quantity					= @recive_quantity
							--																		  ,@p_billing_amount			= @additional_amount
							--																		  ,@p_discount_amount			= 0
							--																		  ,@p_ppn_pct					= 0
							--																		  ,@p_ppn_amount				= 0
							--																		  ,@p_pph_pct					= 0
							--																		  ,@p_pph_amount				= 0
							--																		  ,@p_total_amount				= @additional_amount
							--																		  ,@p_reff_code					= @p_code
							--																		  ,@p_reff_name					= 'MOBILISASI ASSET'
							--																		  ,@p_settle_date				= null
							--																		  ,@p_job_status				= 'HOLD'
							--																		  ,@p_failed_remarks			= ''
							--																		  ,@p_cre_date					= @p_mod_date
							--																		  ,@p_cre_by					= @p_mod_by
							--																		  ,@p_cre_ip_address			= @p_mod_ip_address
							--																		  ,@p_mod_date					= @p_mod_date
							--																		  ,@p_mod_by					= @p_mod_by
							--																		  ,@p_mod_ip_address			= @p_mod_ip_address								
							--	end

							fetch next from curr_mobilisasi
							into @branch_code_mobilisasi
								 ,@branch_name_mobilisasi
								 ,@to_province_code_mobilisasi
								 ,@to_province_name_mobilisasi
								 ,@to_city_code_mobilisasi
								 ,@to_city_name_mobilisasi
								 ,@to_area_phone_no_mobilisasi
								 ,@to_phone_no_mobilisasi
								 ,@to_address_mobilisasi
								 ,@eta_date_mobilisasi
								 ,@fa_code_mobilisasi
								 ,@fa_name_mobilisasi
								 ,@requestor_name_mobilisasi
								 ,@is_reimburse_mobilisasi
								 ,@from_city_name ;
						end ;

						close curr_mobilisasi ;
						deallocate curr_mobilisasi ;
					end ;
					ELSE IF (@procurement_type = 'EXPENSE')
					begin
						declare curr_expense cursor fast_forward read_only for
						select	pri.fa_code
								,grn.supplier_code
								,grn.supplier_name
								,grn.receive_date
						from	dbo.good_receipt_note_detail			 grnd
								inner join dbo.good_receipt_note		 grn on (grn.code							   = grnd.good_receipt_note_code)
								inner join dbo.purchase_order			 po on (po.code								   = grn.purchase_order_code)
								inner join dbo.purchase_order_detail	 pod on (
																					pod.po_code						   = po.code
																					and pod.id						   = grnd.purchase_order_detail_id
																				)
								inner join dbo.supplier_selection_detail ssd on (ssd.id								   = pod.supplier_selection_detail_id)
								left join dbo.quotation_review_detail	 qrd on (qrd.id								   = ssd.quotation_detail_id)
								inner join dbo.procurement				 prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
								inner join dbo.procurement_request		 pr on (pr.code								   = prc.procurement_request_code)
								inner join dbo.procurement_request_item	 pri on (
																					pri.procurement_request_code	   = pr.code
																					and pri.item_code				   = grnd.item_code
																				)
						where	grnd.good_receipt_note_code = @p_code
						and		grnd.receive_quantity	<> 0 ;

						open curr_expense ;

						fetch next from curr_expense			
						into @fa_code_expense
							,@supplier_code_expense
							,@supplier_name_expense
							,@receive_date_expense

						while @@fetch_status = 0
						begin
								update	ifinams.dbo.asset
								set		is_gps = '1'
										,gps_status			= 'SUBSCRIBE'
										,gps_vendor_code	= @supplier_code_expense
										,gps_vendor_name	= @supplier_name_expense	
										,gps_received_date	= @receive_date_expense
										,mod_date			= @p_mod_date
										,mod_ip_address		= @p_mod_ip_address
										,mod_by				= @p_mod_by
								where	code = @fa_code_expense

								exec	ifinams.dbo.xsp_monitoring_gps_insert @p_id						= 0,                        -- bigint
																			   @p_fa_code				= @fa_code_expense,                            -- nvarchar(50)
																			   @p_vendor_code			= @supplier_code_expense,                        -- nvarchar(50)
																			   @p_vendor_name			= @supplier_name_expense,                        -- nvarchar(250)
																			   @p_total_paid			= 0,                        -- decimal(18, 2)
																			   @p_status				= N'SUBSCRIBE',                             -- nvarchar(50)
																			   @p_unsubscribe_date		= NULL, -- datetime
																			   @p_grn_date				= @receive_date_expense,         -- datetime
																			   @p_cre_date				= @p_mod_date,         -- datetime
																			   @p_cre_by				= @p_mod_by,                             -- nvarchar(15)
																			   @p_cre_ip_address		=  @p_mod_ip_address,                     -- nvarchar(15)
																			   @p_mod_date				= @p_mod_date,         -- datetime
																			   @p_mod_by				= @p_mod_by,                             -- nvarchar(15)
																			   @p_mod_ip_address		=  @p_mod_ip_address                      -- nvarchar(15)

							fetch next from curr_expense
							into @fa_code_expense
								,@supplier_code_expense
								,@supplier_name_expense
								,@receive_date_expense

						end ;

						close curr_expense ;
						deallocate curr_expense ;
					end ;
				end ;

				fetch next from curr_asset
				into @po_quantity
					 ,@recive_quantity
					 ,@type_code
					 ,@type_name
					 ,@chassis_no
					 ,@plat_no
					 ,@engine_no
					 ,@serial_no
					 ,@invoice_no
					 ,@domain
					 ,@imei
					 ,@category_desc
					 ,@merk_code
					 ,@merk_desc
					 ,@model_code
					 ,@model_desc
					 ,@type_item_code
					 ,@type_item_desc
					 ,@item_code
					 ,@item_name
					 ,@category_code
					 ,@category_name
					 ,@price_amount
					 ,@original_price
					 ,@purchase_price
					 ,@good_receipt_note_detail_id
					 ,@is_rent
					 ,@opl_code
					 ,@spesification
					 ,@proc_req_code
					 ,@procurement_type
					 ,@supplier_code
					 ,@supplier_name
					 ,@ppn_amount
					 ,@pph_amount
					 ,@currency
					 ,@discount_amount
					 ,@branch_code
					 ,@branch_name
					 ,@spaf_amount
					 ,@subvention_amount
					 ,@purchase_order_detail_id
					 ,@cover_note
					 ,@bpkb_no
					 ,@cover_note_date
					 ,@cover_exp_date
					 ,@cover_file_name
					 ,@cover_file_path
					 ,@stnk_no
					 ,@stnk_date
					 ,@stnk_exp_date
					 ,@stck_no
					 ,@stck_date
					 ,@stck_exp_date
					 ,@keur_no
					 ,@keur_date
					 ,@keur_exp_date
					 ,@object_info_id
					 ,@mobilisasi_type
					 ,@branch_code_asset
					 ,@branch_name_asset
					 ,@tax_scheme_code
					 ,@tax_scheme_name
					 ,@ppn_grn
					 ,@pph_grn
					 ,@discount_grn
					 ,@receive_date ;

			end ;

			close curr_asset ;
			deallocate curr_asset ;
		end ;

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

				select	@asset_no = isnull(reff_no, '')
				from	dbo.final_good_receipt_note
				where	code = @p_final_grn_code ;

				select	@asset_code_expense = podo.asset_code
				from	dbo.final_good_receipt_note						fgrn
						left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code = fgrn.code)
						left join dbo.good_receipt_note_detail			grnd on (grnd.id							 = fgrnd.good_receipt_note_detail_id)
						left join dbo.good_receipt_note					grn on (grn.code							 = grnd.good_receipt_note_code)
						left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	 = grnd.id)
						left join ifinbam.dbo.master_item				mi on (mi.code								 = fgrnd.item_code)
				where	fgrn.reff_no		 = @asset_no
						and mi.category_type = 'ASSET'
						and fgrn.status		 = 'POST' ;

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
							and pr.procurement_type		= 'PURCHASE'

				group by	pr.branch_code
							,pr.branch_name ;

				open curr_branch_request ;

				fetch next from curr_branch_request
				into @branch_code_request
					 ,@branch_name_request ;

				while @@fetch_status = 0
				begin

					--Pembentukan Journal Final GRN
					set @transaction_name = N'Final Good Receipt Note ' + @p_final_grn_code + N' From PO ' + @po_no + N'.' + N' Vendor ' + @vendor_name ;

					exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_insert @p_code = @journal_final output
																					   ,@p_company_code = 'DSF'
																					   ,@p_branch_code = @branch_code_request
																					   ,@p_branch_name = @branch_name_request
																					   ,@p_transaction_status = 'HOLD'
																					   ,@p_transaction_date = @journal_date
																					   ,@p_transaction_value_date = @journal_date
																					   ,@p_transaction_code = @p_final_grn_code
																					   ,@p_transaction_name = 'Final Good Receipt Note'
																					   ,@p_reff_module_code = 'IFINPROC'
																					   ,@p_reff_source_no = @p_final_grn_code
																					   ,@p_reff_source_name = @transaction_name
																					   ,@p_is_journal_reversal = '0'
																					   ,@p_transaction_type = null
																					   ,@p_cre_date = @p_mod_date
																					   ,@p_cre_by = @p_mod_by
																					   ,@p_cre_ip_address = @p_mod_ip_address
																					   ,@p_mod_date = @p_mod_date
																					   ,@p_mod_by = @p_mod_by
																					   ,@p_mod_ip_address = @p_mod_ip_address ;

					declare curr_jur_grn cursor fast_forward read_only for
					select		distinct mt.sp_name
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
								,grnd.pph_amount
								,grnd.receive_quantity
								,podoi.id
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
					where		mtp.process_code		  = 'SGS230600003'
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
						 ,@asset_code
						 ,@pph_for_expense
						 ,@recive_quantity 
						 ,@purchase_order_detail_id

					while @@fetch_status = 0
					begin
						set @asset = isnull(isnull(@asset_code, @asset_code_final), @asset_code_expense) ;

						--SELECT @sp_name'@sp_name',@return_value'@return_value',@transaction_code'@transaction_code',@transaction_name'@transaction_name'

						-- nilainya exec dari MASTER_TRANSACTION.sp_name
						exec @return_value = @sp_name @grn_id, @purchase_order_detail_id ;

						-- sp ini mereturn value angka 

						--update journal ke GRN Detail
						update	dbo.good_receipt_note_detail
						set		final_journal_code = @journal_final
								,final_journal_date = @journal_date
								--
								,mod_date = @p_mod_date
								,mod_by = @p_mod_by
								,mod_ip_address = @p_mod_ip_address
						where	id = @grn_id ;

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


						--untuk membedakan jika expense memiliki pph atau tidak
						if (
							   @gl_link_code = 'ASTEXPS'
							   and	@pph_for_expense = 0
						   )
						begin
							set @gl_link_code = N'ASTEXPSWTHT' ;
						end ;

						--untuk membedakan jika mobilisasi memiliki pph atau tidak
						if (
							   @gl_link_code = 'ASMBLSCOST'
							   and	@pph_for_expense = 0
						   )
						begin
							set @gl_link_code = N'ASMBLSCOST WTPPH' ;
						end ;

						--jika unit from nya BUY maka bentuk jurnal
						if (@is_rent = 'BUY')
						begin
							if @return_value <> 0
							begin
								set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(convert(nvarchar(3), @recive_quantity), '') + N' ' + isnull(@uom_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO No : ' + isnull(@po_no, '') ;
								set @counter = 0 ;

								--while (@counter < @recive_quantity)
								begin

									-- jurnal asset digabung pada saat insert ke journal detail

									if (@transaction_code = 'ASTGRN')
									begin
										if not exists
										(
											select	1
											from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
											where	gl_link_transaction_code = @journal_final
													and gl_link_code		 = @gl_link_code
										)
										begin
											set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO No : ' + isnull(@po_no, '') ;

											exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code = @journal_final
																													  ,@p_company_code = 'DSF'
																													  ,@p_branch_code = @branch_code_request
																													  ,@p_branch_name = @branch_name_request
																													  ,@p_cost_center_code = null
																													  ,@p_cost_center_name = null
																													  ,@p_gl_link_code = @gl_link_code
																													  ,@p_agreement_no = @asset --@asset_code
																													  ,@p_facility_code = null
																													  ,@p_facility_name = null
																													  ,@p_purpose_loan_code = null
																													  ,@p_purpose_loan_name = null
																													  ,@p_purpose_loan_detail_code = null
																													  ,@p_purpose_loan_detail_name = null
																													  ,@p_orig_currency_code = 'IDR'
																													  ,@p_orig_amount_db = @orig_amount_db
																													  ,@p_orig_amount_cr = @orig_amount_cr
																													  ,@p_exch_rate = 1
																													  ,@p_base_amount_db = @orig_amount_db
																													  ,@p_base_amount_cr = @orig_amount_cr
																													  ,@p_division_code = @division_code
																													  ,@p_division_name = @division_name
																													  ,@p_department_code = @department_code
																													  ,@p_department_name = @department_name
																													  ,@p_remarks = @remarks_journal
																													  ,@p_cre_date = @p_mod_date
																													  ,@p_cre_by = @p_mod_by
																													  ,@p_cre_ip_address = @p_mod_ip_address
																													  ,@p_mod_date = @p_mod_date
																													  ,@p_mod_by = @p_mod_by
																													  ,@p_mod_ip_address = @p_mod_ip_address ;
										end ;
										else
										begin
											update	dbo.ifinproc_interface_journal_gl_link_transaction_detail
											set		orig_amount_db = orig_amount_db + @orig_amount_db
													,orig_amount_cr = orig_amount_cr + @orig_amount_cr
													,base_amount_db = base_amount_db + @orig_amount_db
													,base_amount_cr = base_amount_cr + @orig_amount_cr
											where	gl_link_code				 = @gl_link_code
													and gl_link_transaction_code = @journal_final ;
										end ;

									end ;
									else if (@transaction_code = 'AUCF')
									begin
										--if not exists
										--(
										--	select	1
										--	from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
										--	where	gl_link_transaction_code = @journal_final
										--			and gl_link_code		 = @gl_link_code
										--)
										--begin
											set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(@item_name_for_journal, '') ;

											exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code = @journal_final
																													  ,@p_company_code = 'DSF'
																													  ,@p_branch_code = @branch_code_request
																													  ,@p_branch_name = @branch_name_request
																													  ,@p_cost_center_code = null
																													  ,@p_cost_center_name = null
																													  ,@p_gl_link_code = @gl_link_code
																													  ,@p_agreement_no = @po_no
																													  ,@p_facility_code = null
																													  ,@p_facility_name = null
																													  ,@p_purpose_loan_code = null
																													  ,@p_purpose_loan_name = null
																													  ,@p_purpose_loan_detail_code = null
																													  ,@p_purpose_loan_detail_name = null
																													  ,@p_orig_currency_code = 'IDR'
																													  ,@p_orig_amount_db = @orig_amount_db
																													  ,@p_orig_amount_cr = @orig_amount_cr
																													  ,@p_exch_rate = 1
																													  ,@p_base_amount_db = @orig_amount_db
																													  ,@p_base_amount_cr = @orig_amount_cr
																													  ,@p_division_code = @division_code
																													  ,@p_division_name = @division_name
																													  ,@p_department_code = @department_code
																													  ,@p_department_name = @department_name
																													  ,@p_remarks = @remarks_journal
																													  ,@p_cre_date = @p_mod_date
																													  ,@p_cre_by = @p_mod_by
																													  ,@p_cre_ip_address = @p_mod_ip_address
																													  ,@p_mod_date = @p_mod_date
																													  ,@p_mod_by = @p_mod_by
																													  ,@p_mod_ip_address = @p_mod_ip_address ;
										--end ;
										--else
										--begin
										--	update	dbo.ifinproc_interface_journal_gl_link_transaction_detail
										--	set		orig_amount_db = orig_amount_db + @orig_amount_db
										--			,orig_amount_cr = orig_amount_cr + @orig_amount_cr
										--			,base_amount_db = base_amount_db + @orig_amount_db
										--			,base_amount_cr = base_amount_cr + @orig_amount_cr
										--	where	gl_link_code				 = @gl_link_code
										--			and gl_link_transaction_code = @journal_final ;
										--end ;
									end ;
									else
									begin
										exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code = @journal_final
																												  ,@p_company_code = 'DSF'
																												  ,@p_branch_code = @branch_code_request
																												  ,@p_branch_name = @branch_name_request
																												  ,@p_cost_center_code = null
																												  ,@p_cost_center_name = null
																												  ,@p_gl_link_code = @gl_link_code
																												  ,@p_agreement_no = @po_no
																												  ,@p_facility_code = null
																												  ,@p_facility_name = null
																												  ,@p_purpose_loan_code = null
																												  ,@p_purpose_loan_name = null
																												  ,@p_purpose_loan_detail_code = null
																												  ,@p_purpose_loan_detail_name = null
																												  ,@p_orig_currency_code = 'IDR'
																												  ,@p_orig_amount_db = @orig_amount_db
																												  ,@p_orig_amount_cr = @orig_amount_cr
																												  ,@p_exch_rate = 1
																												  ,@p_base_amount_db = @orig_amount_db
																												  ,@p_base_amount_cr = @orig_amount_cr
																												  ,@p_division_code = @division_code
																												  ,@p_division_name = @division_name
																												  ,@p_department_code = @department_code
																												  ,@p_department_name = @department_name
																												  ,@p_remarks = @remarks_journal
																												  ,@p_cre_date = @p_mod_date
																												  ,@p_cre_by = @p_mod_by
																												  ,@p_cre_ip_address = @p_mod_ip_address
																												  ,@p_mod_date = @p_mod_date
																												  ,@p_mod_by = @p_mod_by
																												  ,@p_mod_ip_address = @p_mod_ip_address ;
									end ;

									set @counter = @counter + 1 ;
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
							 ,@asset_code
							 ,@pph_for_expense
							 ,@recive_quantity 

							 ,@purchase_order_detail_id
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

		begin --update cover note status
			update	dbo.good_receipt_note
			set		cover_note_status = 'HOLD'
			where	code = @p_code ;
		end ;

		begin --insert sys document upload  
			declare curr_doc_upload cursor fast_forward read_only for
			select	reff_no
					,reff_name
					,reff_trx_code
					,file_name
					,doc_file
			from	dbo.sys_document_upload
			where	reff_no = @p_code ;

			open curr_doc_upload ;

			fetch next from curr_doc_upload
			into @upload_reff_no
				 ,@upload_reff_name
				 ,@upload_reff_trx_code
				 ,@upload_file_name
				 ,@upload_doc_file ;

			while @@fetch_status = 0
			begin
				exec dbo.xsp_ifinproc_interface_document_upload_insert @p_id = 0
																	   ,@p_reff_no = @p_code
																	   ,@p_reff_name = @upload_reff_name
																	   ,@p_reff_trx_code = @upload_reff_trx_code
																	   ,@p_file_name = @upload_file_name
																	   ,@p_doc_file = @upload_doc_file
																	   ,@p_cre_date = @p_mod_date
																	   ,@p_cre_by = @p_mod_by
																	   ,@p_cre_ip_address = @p_mod_ip_address
																	   ,@p_mod_date = @p_mod_date
																	   ,@p_mod_by = @p_mod_by
																	   ,@p_mod_ip_address = @p_mod_ip_address ;

				fetch next from curr_doc_upload
				into @upload_reff_no
					 ,@upload_reff_name
					 ,@upload_reff_trx_code
					 ,@upload_file_name
					 ,@upload_doc_file ;
			end ;

			close curr_doc_upload ;
			deallocate curr_doc_upload ;
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

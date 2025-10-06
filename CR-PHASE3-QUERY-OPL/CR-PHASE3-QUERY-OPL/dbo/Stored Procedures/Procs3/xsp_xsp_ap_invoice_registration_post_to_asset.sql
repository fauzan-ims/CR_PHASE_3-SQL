
-- Stored Procedure

-- Stored Procedure


CREATE PROCEDURE [dbo].[xsp_xsp_ap_invoice_registration_post_to_asset]
(
	@p_code				nvarchar(50) -- jika dari final grn maka grn code, jika dari invoice maka invoice code
	,@p_final_grn_code	nvarchar(50)
	,@p_company_code	nvarchar(50)
	--  
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
	,@p_po_object_id	nvarchar(50) = null
)
as
begin

	declare	@msg							  nvarchar(max)
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
			,@purchase_order_detail_id		  bigint
			,@price_amount_final_grn		  decimal(18, 2)
			,@original_amount_final_grn		  decimal(18, 2)
			,@item_code_adj					  nvarchar(50)
			,@item_name_adj					  nvarchar(250)
			,@adj_amount					  decimal(18, 2)
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
			,@grn_code_from_final			  nvarchar(50)
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
			,@branch_code_asset				  nvarchar(50)
			,@branch_name_asset				  nvarchar(250)
			,@transaction_code				  nvarchar(50)
			,@item_name_for_journal			  nvarchar(250)
			,@journal_date					  datetime		= dbo.xfn_get_system_date()
			,@ppn_grn						  decimal(18, 2)
			,@pph_grn						  decimal(18, 2)
			,@discount_grn					  decimal(18, 2)
			,@asset							  nvarchar(50)
			,@asset_code_final				  nvarchar(50)
			,@receive_date					  datetime
			,@pph_for_expense				  decimal(18, 2)
			,@asset_code_for_gps			  nvarchar(50)
			,@fgrn_code						  nvarchar(50) 
			,@built_year					  nvarchar(4)
			,@asset_colour					  nvarchar(50)
			,@final_grn_request_no			  nvarchar(50)
			,@fgrn_detail_id				  bigint
			,@invoice_detail_id				  bigint
			,@grn_detail_id_asset				bigint
			,@application_no					nvarchar(50)
			,@urutan							int
            ,@is_from_unit						nvarchar(1)
			,@final_grn_request_detail_id_unit	bigint
            ,@all_invoice_paid					nvarchar(1) = '0'

	begin try

		declare @loopingorder table (category_type varchar(50), urutan int);

		insert into @loopingorder (category_type, urutan)
		values	('ASSET',1)
				,('ACCESSORIES',2)
				,('KAROSERI',3)
				,('MOBILISASI',4)
				,('GPS',5)

		if not exists (	select	1
						from	dbo.final_good_receipt_note_detail fgrnd
								left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrnd.good_receipt_note_detail_id
								left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
						where	fgrnd.final_good_receipt_note_code = @p_final_grn_code
						and		isnull(inv.status,'') not in ('APPROVE','POST')
						)
		begin
		    set @all_invoice_paid = '1'
		end

		begin --push to Asset, push to adjustment, Update Remaining QTY di Purchase Order	
			declare curr_asset cursor fast_forward read_only for
			select	distinct grnd.po_quantity
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
					,pri.category_type
					,pr.division_code
					,pr.division_name
					,pr.department_code
					,pr.department_name
					,pri.specification
					,pri.item_code
					,pri.item_name
					,pri.uom_name
					,pri.approved_quantity
					,fgrnd.price_amount
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
					,isnull(fgr.branch_code,pr.branch_code)
					,isnull(fgr.branch_name,pr.branch_name)
					,grnd.ppn_amount
					,grnd.pph_amount
					,grnd.discount_amount
					,grn.receive_date
					,isnull(pr.built_year,'')										
					,isnull(pr.asset_colour,'')		
					,grnd.invoice_detail_id
					,fgrd.grn_detail_id_asset
					,fgrd.id
					,lo.urutan
			from	dbo.final_good_receipt_note						fgrn
					inner join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code  = fgrn.code)
					inner join dbo.final_grn_request_detail			fgrd on fgrd.id								  = fgrnd.reff_no
					inner join dbo.final_grn_request				fgr on fgr.final_grn_request_no				= fgrd.final_grn_request_no
					left join dbo.good_receipt_note_detail			grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
					left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)

					left join dbo.sys_general_subcode				sgs on (sgs.code							  = grnd.type_asset_code)
																		   and	 sgs.company_code				  = 'DSF'
					left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
					left join dbo.purchase_order_detail				pod on (
																			   pod.po_code						  = po.code
																			   and pod.id						  = grnd.purchase_order_detail_id
																		   )
					left join dbo.purchase_order_detail_object_info podo on (
																					grnd.id								= podo.good_receipt_note_detail_id
																			and		podo.purchase_order_detail_id		= pod.id
																			and		podo.id								= fgrnd.po_object_id
																			)
					left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
					left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
					left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
					left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
					left join dbo.procurement_request_item			pri on pri.procurement_request_code			  = pr.code and	grnd.item_code = pri.item_code
					inner join @loopingorder						lo on lo.category_type = pri.category_type --untuk urutin asset paling atas
			where	fgrn.code				  = @p_final_grn_code
			and		grnd.receive_quantity <> 0 
			--and	grnd.invoice_detail_id is not null -- 07082025(sepria) terinput ke asset setelah final di post dan semua invoice dari komponen telah post
			and		fgrnd.po_object_id = @p_po_object_id
			order by lo.urutan asc

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
				 ,@cat_type_proc_request
				 ,@division_code_adjust
				 ,@division_name_adjust
				 ,@department_code_adjust
				 ,@department_name_adjust
				 ,@specification_adjust
				 ,@item_code_adj
				 ,@item_name_adj
				 ,@uom_name_adj
				 ,@quantity_adj
				 ,@adj_amount
				 ,@cover_note
				 ,@bpkb_no
				 ,@cover_note_date
				 ,@cover_exp_date
				 ,@cover_file_path
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
				 ,@ppn_grn
				 ,@pph_grn
				 ,@discount_grn
				 ,@receive_date 
				 ,@built_year
				 ,@asset_colour
				 ,@invoice_detail_id
				 ,@grn_detail_id_asset
				 ,@fgrn_detail_id
				 ,@urutan

			while @@fetch_status = 0
			begin

				--and pri.category_type = 'ASSET'
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

				begin -- CLOSED PO when full received
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
				begin -- cek apakah MOBILISASI atau tidak
					if (@procurement_type = 'PURCHASE')-- and @invoice_detail_id is not null)
					begin

						if (@cat_type_proc_request = 'ASSET')
						begin
							if(not exists (select 1 from dbo.eproc_interface_asset where grn_detail_id = @grn_detail_id_asset and final_grn_request_detail_id = @fgrn_detail_id))
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

								if (isnull(@all_invoice_paid,'0') = '1') --- final confirm cr priority, jika sudah di bayar all invoicenya, ambil dr nilai invoice, jika belum ambil dari nilai grn
								begin
									-- ambil nilai dari invoice langsung jika semua invoice sudah di bayar
									select  @price_amount_final_grn		= sum(invd.purchase_amount) - sum(invd.discount)
											,@original_amount_final_grn = sum(invd.purchase_amount)
											,@ppn_grn					= sum(invd.ppn)
											,@pph_grn					= sum(invd.pph)
											,@discount_grn				= sum(invd.discount)
									from	dbo.final_good_receipt_note					  fgrn
											inner join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code	= fgrn.code)
											left join dbo.good_receipt_note_detail		  grnd on (grnd.id								= fgrnd.good_receipt_note_detail_id)
											left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = grnd.id
											left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
									where	fgrn.code = @p_final_grn_code
									and		isnull(inv.status,'') in ( 'APPROVE','POST')
								end
                                else
                                begin
									select  @price_amount_final_grn		= sum(grnd.price_amount) - sum(grnd.discount_amount)
											,@original_amount_final_grn = sum(grnd.price_amount) 
											,@ppn_grn					= sum(grnd.ppn_amount)
											,@pph_grn					= sum(grnd.pph_amount)
											,@discount_grn				= sum(grnd.discount_amount)
									from	dbo.final_good_receipt_note					  fgrn
											inner join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code	= fgrn.code)
											left join dbo.good_receipt_note_detail		  grnd on (grnd.id								= fgrnd.good_receipt_note_detail_id)
									where	fgrn.code = @p_final_grn_code
                                end

							--(+ 17022025) sepria: cek jika sudah di input saat grn, maka saat final tidak usah input asset lagi
							if not exists (select 1 from dbo.eproc_interface_asset where po_no = @po_no and grn_detail_id = @good_receipt_note_detail_id and final_grn_request_detail_id = @fgrn_detail_id)
							begin
								if  exists (	select	1
												from	dbo.final_good_receipt_note_detail fgrnd
														left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrnd.good_receipt_note_detail_id
														left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
												where	fgrnd.final_good_receipt_note_code = @p_final_grn_code
												and		isnull(inv.status,'') not in ('APPROVE','POST')
											)
								begin
									set @all_invoice_paid = '0'
								end
								else
								begin
									set @all_invoice_paid = '1'
								end

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
																		  ,@p_purchase_date = @receive_date				--@purchase_date
																		  ,@p_purchase_price = @price_amount_final_grn
																		  ,@p_invoice_no = null
																		  ,@p_invoice_date = null
																		  ,@p_original_price = @original_amount_final_grn
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
																		  ,@p_file_path = @file_path
																		  ,@p_file_name = @file_name
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
																		  ,@p_pph_amount = @ppn_grn
																		  ,@p_ppn_amount = @pph_grn
																		  ,@p_discount_amount = @discount_grn
																		  ,@p_posting_date = @purchase_date				--@p_mod_date -- (+) Ari 2024-03-26 ket : add posting date
																		  ,@p_grn_detail = @good_receipt_note_detail_id -- (+) Ari 2024-04-04 ket : add grn id for checking
																		  --
																		  ----sepria 04/06/2025: 
																		  ,@p_built_year	= @built_year
																		  ,@p_colour		= @asset_colour
																														--
																		  ,@p_cre_date = @p_mod_date
																		  ,@p_cre_by = @p_mod_by
																		  ,@p_cre_ip_address = @p_mod_ip_address
																		  ,@p_mod_date = @p_mod_date
																		  ,@p_mod_by = @p_mod_by
																		  ,@p_mod_ip_address = @p_mod_ip_address 
																		  ,@p_fgrn_detail_id	= @fgrn_detail_id
																		  ,@p_is_final_all		= @all_invoice_paid
								end
							else
							begin--(+ 17022025) sepria: jika sudah ada ambil code dari asset
								select	@code = code 
								from 	dbo.eproc_interface_asset eia
								where	eia.grn_detail_id = @good_receipt_note_detail_id 
								and		eia.final_grn_request_detail_id = @fgrn_detail_id;
							end

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

								--update code asset insurance
								update	dbo.ifinproc_interface_asset_insurance
								set		asset_code = @code
										--
										,mod_date = @p_mod_date
										,mod_by = @p_mod_by
										,mod_ip_address = @p_mod_ip_address
								where	asset_no = @interface_purchase_request_code ;

								-- update asset code di object info
								update	dbo.purchase_order_detail_object_info
								set		asset_code		= @code
										,mod_by			= @p_mod_by
										,mod_date		= @p_mod_date
										,mod_ip_address = @p_mod_ip_address
								where	id in (select po_object_id from dbo.final_good_receipt_note_detail where final_good_receipt_note_code = @p_final_grn_code)-- @object_info_id ;

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
																							   ,@p_reff_trx_code = @code
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
							end
						end ;
						else
						begin --item category (aksesoris, karosesi, mobilisasi)

							select	@interface_purchase_request_code = isnull(pirr.code, pirr2.code)
									,@unit_from						 = isnull(prc.unit_from, prc2.unit_from)
									,@date							 = grn.receive_date
							from	dbo.good_receipt_note_detail				  grnd
									inner join dbo.good_receipt_note			grn on grn.code = grnd.good_receipt_note_code
									left join dbo.purchase_order_detail			  pod on (pod.id										= grnd.purchase_order_detail_id)
									left join dbo.supplier_selection_detail		  ssd on (ssd.id										= pod.supplier_selection_detail_id)
									left join dbo.quotation_review_detail		  qrd on (qrd.id										= ssd.quotation_detail_id)
									left join dbo.procurement					  prc on (prc.code collate sql_latin1_general_cp1_ci_as = qrd.reff_no)
									left join procurement						  prc2 on (prc2.code									= ssd.reff_no)
									left join dbo.procurement_request			  pr on (pr.code										= prc.procurement_request_code)
									left join dbo.procurement_request			  pr2 on (pr2.code										= prc2.procurement_request_code)
									left join dbo.proc_interface_purchase_request pirr on (pirr.code									= pr.reff_no)
									left join dbo.proc_interface_purchase_request pirr2 on (pirr2.code									= pr2.reff_no)
							where	grnd.id = @good_receipt_note_detail_id 
							--and		grnd.invoice_detail_id is not null

							-- ambil nilai dari invoice langsung
							select  @adj_amount		= sum(invd.purchase_amount) - sum(invd.discount)
							from	dbo.final_good_receipt_note					  fgrn
									inner join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code	= fgrn.code)
									left join dbo.good_receipt_note_detail		  grnd on (grnd.id								= fgrnd.good_receipt_note_detail_id)
									left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = grnd.id
									left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
							where	fgrn.code = @p_final_grn_code
							and		invd.id = @invoice_detail_id
							and		inv.status = 'APPROVE'

							select	@fa_code_adjust						= code 
									,@item_name							= eia.item_name
									,@final_grn_request_detail_id_unit	= eia.final_grn_request_detail_id
							from 	dbo.eproc_interface_asset eia
							where	eia.final_grn_request_detail_id = @fgrn_detail_id;

							if (isnull(@fa_code_adjust,'') = '')
							begin
							    select	@fa_code_adjust = asset_code
										,@item_name		= asset_name
								from	dbo.final_grn_request_detail 
								where	id = @fgrn_detail_id
							end

							--select @fa_code_adjust = code from dbo.eproc_interface_asset where grn_detail_id = @grn_detail_id_asset

							update	dbo.proc_interface_purchase_request
							set		result_fa_code	= @fa_code_adjust
									,result_fa_name	= @item_name
									,result_date	= dbo.xfn_get_system_date()
									,request_status = 'POST'
									,fa_reff_no_01	= @plat_no
									,fa_reff_no_02	= @chassis_no
									,fa_reff_no_03	= @engine_no
									--
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	asset_no		= @interface_purchase_request_code
									and unit_from	= @unit_from ;

							set @code_asset_for_adjustment = isnull(@fa_code_adjust, @code) ;
							set @name_asset_for_adjustment = isnull(@fa_name_adjust, @item_name) ;

							-- update asset code di object info
							update	dbo.purchase_order_detail_object_info
							set		asset_code		= @code_asset_for_adjustment
									,mod_by			= @p_mod_by
									,mod_date		= @p_mod_date
									,mod_ip_address = @p_mod_ip_address
							where	id = @object_info_id ;

							if isnull(@code_asset_for_adjustment,'') <> ''
							begin

								set @date = isnull(@date,@p_mod_date)
								exec dbo.xsp_ifinproc_interface_adjustment_asset_insert @p_id = 0
																						,@p_code = @p_code
																						,@p_branch_code = @branch_code
																						,@p_branch_name = @branch_name
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
																						,@p_adjustment_amount = @adj_amount
																						,@p_quantity = @quantity_adj
																						,@p_uom = @uom_name_adj
																						,@p_type_asset = 'MULTIPLE'
																						,@p_job_status = 'HOLD'
																						,@p_failed_remarks = ''
																						,@p_adjust_type = 'GRN'
																						--
																						,@p_cre_date = @p_mod_date
																						,@p_cre_by = @p_mod_by
																						,@p_cre_ip_address = @p_mod_ip_address
																						,@p_mod_date = @p_mod_date
																						,@p_mod_by = @p_mod_by
																						,@p_mod_ip_address = @p_mod_ip_address 

							end
						end ;
					end ;
					else if (@procurement_type = 'MOBILISASI')
					begin
						--if(@opl_code = null)
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
						from	dbo.procurement_request				   pr
								left join dbo.procurement_request_item pri on (pr.code = pri.procurement_request_code)
						where	pr.code = @proc_req_code ;

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
							 ,@is_reimburse_mobilisasi ;

						while @@fetch_status = 0
						begin
							set @handover_remark = N'Mobilisasi Asset ' + isnull(@fa_code_mobilisasi, '') + N' ' + isnull(@fa_name_mobilisasi, '') ;

							if (@mobilisasi_type = 'OTHERS')
							begin
								--Insert ke Handover
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
								 ,@is_reimburse_mobilisasi ;
						end ;

						close curr_mobilisasi ;
						deallocate curr_mobilisasi ;
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
					 ,@cat_type_proc_request
					 ,@division_code_adjust
					 ,@division_name_adjust
					 ,@department_code_adjust
					 ,@department_name_adjust
					 ,@specification_adjust
					 ,@item_code_adj
					 ,@item_name_adj
					 ,@uom_name_adj
					 ,@quantity_adj
					 ,@adj_amount
					 ,@cover_note
					 ,@bpkb_no
					 ,@cover_note_date
					 ,@cover_exp_date
					 ,@cover_file_path
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
					 ,@ppn_grn
					 ,@pph_grn
					 ,@discount_grn
					 ,@receive_date 
					 ,@built_year
					,@asset_colour
					,@invoice_detail_id
					 ,@grn_detail_id_asset
					 ,@fgrn_detail_id
					,@urutan
			end ;

			close curr_asset ;
			deallocate curr_asset ;
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

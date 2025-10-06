
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_good_receipt_note_post_request_manual]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	--sepria 04/06/2025: sepria koment2 semua variable dan select dan join yg gk perlu, biar gk lemot

	declare @msg							  nvarchar(max)
			--,@code							  nvarchar(50)
			--,@branch_code					  nvarchar(50)
			--,@branch_name					  nvarchar(250)
			--,@division_code					  nvarchar(50)
			--,@division_name					  nvarchar(250)
			--,@department_code				  nvarchar(50)
			--,@department_name				  nvarchar(250)
			--,@item_code						  nvarchar(50)
			--,@item_name						  nvarchar(250)
			,@po_quantity					  decimal(18, 2)
			,@recive_quantity				  int
			,@po_no							  nvarchar(50)
			--,@purchase_date					  datetime		= dbo.xfn_get_system_date()
			--,@purchase_price				  decimal(18, 2)
			--,@original_price				  decimal(18, 2)
			--,@vendor_code					  nvarchar(50)
			--,@vendor_name					  nvarchar(250)
			--,@category_code					  nvarchar(50)
			--,@price_amount					  decimal(18, 2)
			--,@type_code						  nvarchar(50)
			--,@requestor_code				  nvarchar(50)
			--,@requestor_name				  nvarchar(250)
			--,@category_name					  nvarchar(250)
			--,@interface_purchase_request_code nvarchar(50)
			--,@good_receipt_note_detail_id	  bigint
			--,@merk_code						  nvarchar(50)
			--,@model_code					  nvarchar(50)
			--,@type_item_code				  nvarchar(50)
			--,@merk_desc						  nvarchar(50)
			--,@model_desc					  nvarchar(50)
			--,@type_item_desc				  nvarchar(50)
			,@remaining_qty					  int
			--,@type_name						  nvarchar(250)
			--,@ppn_pct						  decimal(9, 6)
			--,@pph_pct						  decimal(9, 6)
			--,@sp_name						  nvarchar(250)
			--,@debet_or_credit				  nvarchar(10)
			--,@gl_link_code					  nvarchar(50)
			--,@transaction_name				  nvarchar(250)
			--,@gl_link_transaction_code		  nvarchar(50)
			--,@orig_amount_cr				  decimal(18, 2)
			--,@orig_amount_db				  decimal(18, 2)
			--,@return_value					  decimal(18, 2)
			--,@remarks_journal				  nvarchar(4000)
			--,@grn_id						  bigint
			--,@uom_name						  nvarchar(50)
			--,@plat_no						  nvarchar(50)
			--,@engine_no						  nvarchar(50)
			--,@chassis_no					  nvarchar(50)
			--,@category_desc					  nvarchar(250)
			--,@item_code_for_jrnl			  nvarchar(50)
			--,@item_name_for_jrnl			  nvarchar(250)
			,@sum_order_remaining			  int
			--,@is_rent						  nvarchar(25)
			--,@unit_from						  nvarchar(25)
			--,@item_group_code				  nvarchar(50)
			--,@branch_code_header			  nvarchar(50)
			--,@branch_name_header			  nvarchar(250)
			--,@opl_code						  nvarchar(50)
			--,@asset_purpose					  nvarchar(50)
			--,@spesification					  nvarchar(4000)
			--,@serial_no						  nvarchar(50)
			--,@asset_code					  nvarchar(50)
			--,@invoice_no					  nvarchar(50)
			--,@domain						  nvarchar(50)
			--,@imei							  nvarchar(50)
			--,@proc_req_code					  nvarchar(50)
			--,@document_pending_code			  nvarchar(50)
			--,@date							  datetime
			--,@document_code					  nvarchar(50)
			--,@document_name					  nvarchar(250)
			--,@file_name						  nvarchar(250)
			--,@file_path						  nvarchar(250)
			--,@exp_date_doc					  datetime
			--,@procurement_type				  nvarchar(50)
			--,@branch_code_mobilisasi		  nvarchar(50)
			--,@branch_name_mobilisasi		  nvarchar(250)
			--,@to_province_code_mobilisasi	  nvarchar(50)
			--,@to_province_name_mobilisasi	  nvarchar(250)
			--,@to_city_code_mobilisasi		  nvarchar(50)
			--,@to_city_name_mobilisasi		  nvarchar(250)
			--,@to_area_phone_no_mobilisasi	  nvarchar(4)
			--,@to_phone_no_mobilisasi		  nvarchar(15)
			--,@to_address_mobilisasi			  nvarchar(4000)
			--,@eta_date_mobilisasi			  datetime
			--,@fa_code_mobilisasi			  nvarchar(50)
			--,@fa_name_mobilisasi			  nvarchar(250)
			--,@requestor_name_mobilisasi		  nvarchar(50)
			--,@is_reimburse_mobilisasi		  nvarchar(1)
			--,@handover_remark				  nvarchar(4000)
			--,@supplier_code					  nvarchar(50)
			--,@supplier_name					  nvarchar(250)
			--,@ppn_amount					  decimal(18, 2)
			--,@pph_amount					  decimal(18, 2)
			--,@currency						  nvarchar(3)
			--,@discount_amount				  decimal(18, 2)
			--,@branch_code_adjust			  nvarchar(50)
			--,@branch_name_adjust			  nvarchar(250)
			--,@fa_code_adjust				  nvarchar(50)
			--,@fa_name_adjust				  nvarchar(250)
			--,@division_code_adjust			  nvarchar(50)
			--,@division_name_adjust			  nvarchar(250)
			--,@department_code_adjust		  nvarchar(50)
			--,@department_name_adjust		  nvarchar(250)
			--,@specification_adjust			  nvarchar(4000)
			--,@cat_type_proc_request			  nvarchar(50)
			--,@yang_diterima					  int
			--,@gl_link_transaction_final_code  nvarchar(50)
			--,@process_code					  nvarchar(50)
			--,@journal_grn					  nvarchar(50)
			--,@journal_final					  nvarchar(50)
			--,@spaf_amount					  decimal(18, 2)
			--,@subvention_amount				  decimal(18, 2)
			--,@code_asset_for_adjustment		  nvarchar(50)
			--,@name_asset_for_adjustment		  nvarchar(250)
			,@purchase_order_detail_id		  int
			--,@cover_note					  nvarchar(50)
			--,@bpkb_no						  nvarchar(50)
			--,@cover_note_date				  datetime
			--,@cover_exp_date				  datetime
			--,@cover_file_name				  nvarchar(250)
			--,@cover_file_path				  nvarchar(250)
			--,@upload_reff_no				  nvarchar(50)
			--,@upload_reff_name				  nvarchar(250)
			--,@upload_reff_trx_code			  nvarchar(50)
			--,@upload_file_name				  nvarchar(250)
			--,@upload_doc_file				  varbinary(max)
			--,@item_code_adj					  nvarchar(50)
			--,@item_name_adj					  nvarchar(250)
			--,@document_type					  nvarchar(15)
			--,@agreement_no					  nvarchar(50)
			--,@asset_no						  nvarchar(50)
			--,@client_no						  nvarchar(50)
			--,@client_name					  nvarchar(250)
			--,@stnk_no						  nvarchar(50)
			--,@stnk_date						  datetime
			--,@stnk_exp_date					  datetime
			--,@stck_no						  nvarchar(50)
			--,@stck_date						  datetime
			--,@stck_exp_date					  datetime
			--,@keur_no						  nvarchar(50)
			--,@keur_date						  datetime
			--,@keur_exp_date					  datetime
			--,@object_info_id				  bigint
			--,@mobilisasi_type				  nvarchar(50)
			--,@uom_name_adj					  nvarchar(15)
			--,@quantity_adj					  int
			--,@is_validate					  nvarchar(1)
			--,@asset_expense_remark			  nvarchar(250)
			--,@branch_code_asset				  nvarchar(50)
			--,@branch_name_asset				  nvarchar(250)
			--,@branch_code_request			  nvarchar(50)
			--,@branch_name_request			  nvarchar(250)
			--,@tax_scheme_code				  nvarchar(50)
			--,@tax_scheme_name				  nvarchar(250)
			--,@description_mobilisasi		  nvarchar(4000)
			--,@from_city_name				  nvarchar(250)
			--,@additional_amount				  decimal(18, 2)
			--,@transaction_code				  nvarchar(50)
			--,@item_name_for_journal			  nvarchar(250)
			--,@journal_date					  datetime		= dbo.xfn_get_system_date()
			--,@ppn_grn						  decimal(18, 2)
			--,@pph_grn						  decimal(18, 2)
			--,@discount_grn					  decimal(18, 2)
			--,@asset_code_final				  nvarchar(50)
			--,@asset							  nvarchar(50)
			--,@receive_date					  datetime
			--,@asset_code_expense			  nvarchar(50)
			--,@pph_for_expense				  decimal(18, 2) ;

	begin try
		--set @date = dbo.xfn_get_system_date() ;

		--select	@division_code		 = grn.division_code
		--		,@division_name		 = grn.division_name
		--		,@department_code	 = grn.department_code
		--		,@department_name	 = grn.department_name
		--		,@po_no				 = grn.purchase_order_code
		--		--,@purchase_date			= po.order_date 
		--		,@vendor_code		 = grn.supplier_code
		--		,@vendor_name		 = grn.supplier_name
		--		,@requestor_code	 = po.requestor_code
		--		,@requestor_name	 = po.requestor_name
		--		,@ppn_pct			 = pod.ppn_pct
		--		,@pph_pct			 = pod.pph_pct
		--		,@unit_from			 = po.unit_from
		--		,@branch_code_header = grn.branch_code
		--		,@branch_name_header = grn.branch_name
		--		,@asset_code		 = grnd.type_asset_code
		--from	dbo.good_receipt_note							   grn
		--		left join dbo.purchase_order					   po on grn.purchase_order_code = po.code
		--		left join dbo.purchase_order_detail				   pod on (pod.po_code			 = po.code)
		--		left join dbo.good_receipt_note_detail			   grnd on (grn.code			 = grnd.good_receipt_note_code)
		--		left join dbo.good_receipt_note_detail_object_info grndoi on (grnd.id			 = grndoi.good_receipt_note_detail_id)
		--where	grn.code = @p_code ;

		update	dbo.good_receipt_note
		set		status					= 'APPROVE'
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code = @p_code ;

		begin --push ke asset
			declare curr_asset cursor fast_forward read_only for
			select	DISTINCT grnd.po_quantity
					,grnd.receive_quantity
					--,grnd.type_asset_code
					--,sgs.description
					--,podo.chassis_no
					--,podo.plat_no
					--,podo.engine_no
					--,podo.serial_no
					--,podo.invoice_no
					--,podo.domain
					--,podo.imei
					--,grnd.item_category_name
					--,grnd.item_merk_code
					--,grnd.item_merk_name
					--,grnd.item_model_code
					--,grnd.item_model_name
					--,grnd.item_type_code
					--,grnd.item_type_name
					--,grnd.item_code
					--,grnd.item_name
					--,grnd.item_category_code
					--,grnd.item_category_name
					--,grnd.price_amount - pod.discount_amount
					--,grnd.price_amount
					--,grnd.price_amount * grnd.receive_quantity
					--,grnd.id
					--,po.unit_from
					--,isnull(pr.reff_no, pr2.reff_no)
					--,grnd.spesification
					--,isnull(pr.code, pr2.code)
					--,isnull(pr.procurement_type, pr2.procurement_type)
					--,po.supplier_code
					--,po.supplier_name
					--,pod.ppn_amount
					--,pod.pph_amount
					--,po.currency_code
					--,pod.discount_amount
					--,grn.branch_code
					--,grn.branch_name
					--,isnull(prc.spaf_amount, prc2.spaf_amount)
					--,isnull(prc.subvention_amount, prc2.subvention_amount)
					,pod.id
					--,podo.cover_note
					--,podo.bpkb_no
					--,podo.cover_note_date
					--,podo.exp_date
					--,podo.file_name
					--,podo.file_path
					--,podo.stnk
					--,podo.stnk_date
					--,podo.stnk_exp_date
					--,podo.stck
					--,podo.stck_date
					--,podo.stck_exp_date
					--,podo.keur
					--,podo.keur_date
					--,podo.keur_exp_date
					--,podo.id
					--,isnull(pr.mobilisasi_type, pr2.mobilisasi_type)
					--,isnull(pr.branch_code, pr2.branch_code)
					--,isnull(pr.branch_name, pr2.branch_name)
					--,pod.tax_code
					--,pod.tax_name
					--,grnd.ppn_amount
					--,grnd.pph_amount
					--,grnd.discount_amount
					--,grn.receive_date
			from	dbo.good_receipt_note_detail					grnd
					left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
					--left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.good_receipt_note_detail_id	  = grnd.id)
					--left join dbo.final_good_receipt_note			fgrn on (fgrn.code							  = fgrnd.final_good_receipt_note_code)
					--left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
					--left join dbo.sys_general_subcode				sgs on (sgs.code							  = grnd.type_asset_code)
					--													   and	 sgs.company_code				  = 'DSF'
					left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
					left join dbo.purchase_order_detail				pod on (
																			   pod.po_code						  = po.code
																			   and pod.id						  = grnd.purchase_order_detail_id
																		   )
					--left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
					--left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
					--left join dbo.procurement						prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
					--left join dbo.procurement						prc2 on (prc2.code							  = ssd.reff_no)
					--left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
					--left join dbo.procurement_request				pr2 on (pr2.code							  = prc2.procurement_request_code)
			where	grnd.good_receipt_note_code = @p_code
					and grnd.receive_quantity	<> 0 ;

			open curr_asset ;

			fetch next from curr_asset
			into @po_quantity
				 ,@recive_quantity
				 --,@type_code
				 --,@type_name
				 --,@chassis_no
				 --,@plat_no
				 --,@engine_no
				 --,@serial_no
				 --,@invoice_no
				 --,@domain
				 --,@imei
				 --,@category_desc
				 --,@merk_code
				 --,@merk_desc
				 --,@model_code
				 --,@model_desc
				 --,@type_item_code
				 --,@type_item_desc
				 --,@item_code
				 --,@item_name
				 --,@category_code
				 --,@category_name
				 --,@price_amount
				 --,@original_price
				 --,@purchase_price
				 --,@good_receipt_note_detail_id
				 --,@is_rent
				 --,@opl_code
				 --,@spesification
				 --,@proc_req_code
				 --,@procurement_type
				 --,@supplier_code
				 --,@supplier_name
				 --,@ppn_amount
				 --,@pph_amount
				 --,@currency
				 --,@discount_amount
				 --,@branch_code
				 --,@branch_name
				 --,@spaf_amount
				 --,@subvention_amount
				 ,@purchase_order_detail_id
				 --,@cover_note
				 --,@bpkb_no
				 --,@cover_note_date
				 --,@cover_exp_date
				 --,@cover_file_name
				 --,@cover_file_path
				 --,@stnk_no
				 --,@stnk_date
				 --,@stnk_exp_date
				 --,@stck_no
				 --,@stck_date
				 --,@stck_exp_date
				 --,@keur_no
				 --,@keur_date
				 --,@keur_exp_date
				 --,@object_info_id
				 --,@mobilisasi_type
				 --,@branch_code_asset
				 --,@branch_name_asset
				 --,@tax_scheme_code
				 --,@tax_scheme_name
				 --,@ppn_grn
				 --,@pph_grn
				 --,@discount_grn
				 --,@receive_date ;

			while @@fetch_status = 0
			begin
				begin -- Update PO ketika barang diterima berkala
					set @remaining_qty = @po_quantity - @recive_quantity ;

					update	dbo.purchase_order_detail
					set		order_remaining		= @remaining_qty
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	id = @purchase_order_detail_id ;
				END ;

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

				fetch next from curr_asset
				into @po_quantity
					 ,@recive_quantity
					 --,@type_code
					 --,@type_name
					 --,@chassis_no
					 --,@plat_no
					 --,@engine_no
					 --,@serial_no
					 --,@invoice_no
					 --,@domain
					 --,@imei
					 --,@category_desc
					 --,@merk_code
					 --,@merk_desc
					 --,@model_code
					 --,@model_desc
					 --,@type_item_code
					 --,@type_item_desc
					 --,@item_code
					 --,@item_name
					 --,@category_code
					 --,@category_name
					 --,@price_amount
					 --,@original_price
					 --,@purchase_price
					 --,@good_receipt_note_detail_id
					 --,@is_rent
					 --,@opl_code
					 --,@spesification
					 --,@proc_req_code
					 --,@procurement_type
					 --,@supplier_code
					 --,@supplier_name
					 --,@ppn_amount
					 --,@pph_amount
					 --,@currency
					 --,@discount_amount
					 --,@branch_code
					 --,@branch_name
					 --,@spaf_amount
					 --,@subvention_amount
					 ,@purchase_order_detail_id
					 --,@cover_note
					 --,@bpkb_no
					 --,@cover_note_date
					 --,@cover_exp_date
					 --,@cover_file_name
					 --,@cover_file_path
					 --,@stnk_no
					 --,@stnk_date
					 --,@stnk_exp_date
					 --,@stck_no
					 --,@stck_date
					 --,@stck_exp_date
					 --,@keur_no
					 --,@keur_date
					 --,@keur_exp_date
					 --,@object_info_id
					 --,@mobilisasi_type
					 --,@branch_code_asset
					 --,@branch_name_asset
					 --,@tax_scheme_code
					 --,@tax_scheme_name
					 --,@ppn_grn
					 --,@pph_grn
					 --,@discount_grn
					 --,@receive_date ;
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

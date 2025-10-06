-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE dbo.xsp_good_receipt_note_post_for_multiple_asset_for_manual
(
	@p_code			   nvarchar(50)
	,@p_final_grn_code nvarchar(50)
	,@p_company_code   nvarchar(50)
	,@p_application_no nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
	,@p_po_object_id	bigint = 0

)
as
BEGIN

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
			--,@asset							  nvarchar(50)
			,@asset_code_final				  nvarchar(50)
			,@receive_date					  datetime
			,@pph_for_expense				  decimal(18, 2)
			,@asset_code_for_gps			  nvarchar(50)
			,@fgrn_code						  nvarchar(50) 
			,@built_year					  nvarchar(4)
			,@asset_colour					  nvarchar(50)
			,@final_grn_request_no				nvarchar(50)
			,@good_receipt_note_code		nvarchar(50)
			,@podoi_id						bigint

	begin try
		set @date = dbo.xfn_get_system_date() ; --getdate()

		select	@division_code	  = grn.division_code
				,@division_name	  = grn.division_name
				,@department_code = grn.department_code
				,@department_name = grn.department_name
				,@po_no			  = grn.purchase_order_code
				--,@purchase_date			= po.order_date 
				,@vendor_code	  = grn.supplier_code
				,@vendor_name	  = grn.supplier_name
				,@requestor_code  = po.requestor_code
				,@requestor_name  = po.requestor_name
				,@ppn_pct		  = pod.ppn_pct
				,@pph_pct		  = pod.pph_pct
				,@unit_from		  = po.unit_from
				--,@branch_code_header	= grn.branch_code
				--,@branch_name_header	= grn.branch_name
				,@asset_code	  = grnd.type_asset_code
		from	dbo.good_receipt_note							   grn
				left join dbo.purchase_order					   po on grn.purchase_order_code = po.code
				left join dbo.purchase_order_detail				   pod on (pod.po_code			 = po.code)
				left join dbo.good_receipt_note_detail			   grnd on (grn.code			 = grnd.good_receipt_note_code)
				left join dbo.good_receipt_note_detail_object_info grndoi on (grnd.id			 = grndoi.good_receipt_note_detail_id)
		where	grn.code = @p_code ;

		if (isnull(@p_po_object_id,0) <> 0)
		begin
			exec dbo.xsp_xsp_ap_invoice_registration_post_to_asset @p_code = @p_code,                       -- nvarchar(50)
																	@p_final_grn_code = @p_final_grn_code,
																   @p_company_code = @p_company_code,               -- nvarchar(50)
																   @p_mod_date = @p_mod_date, -- datetime
																   @p_mod_by = @p_mod_by,                     -- nvarchar(15)
																   @p_mod_ip_address = @p_mod_ip_address              -- nvarchar(15)
																   ,@p_po_object_id	= @p_po_object_id
		end

		-- jika unit from nya BUY maka bentuk jurnal
		if (@unit_from = 'BUY')
		begin
			select	@asset_code_final = isnull(podo.asset_code, pri.FA_CODE)
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

			where	fgrn.code				  = @p_final_grn_code
					and
					(
						pri.category_type	  = 'ASSET'
						or	pri.category_type = 'MOBILISASI'
					) ;

			select		@final_grn_request_no = fgrd.final_grn_request_no
			from		dbo.final_good_receipt_note_detail			fgrnd
						left join dbo.final_grn_request_detail		fgrd on fgrd.id	= fgrnd.reff_no
			where		fgrnd.final_good_receipt_note_code = @p_final_grn_code

			if( isnull(@final_grn_request_no,'') <> '')
			begin

				declare curr_branch_jour_final cursor fast_forward read_only for
				select		fgr.branch_code
							,fgr.branch_name
				from		dbo.final_good_receipt_note_detail		fgrnd
							left join dbo.final_grn_request_detail	fgrd on fgrd.id		= fgrnd.reff_no
							left join dbo.final_grn_request			fgr on fgr.final_grn_request_no = fgrd.final_grn_request_no
				where		fgrnd.final_good_receipt_note_code = @p_final_grn_code
				group by	fgr.branch_code
							,fgr.branch_name
			end
			else
            begin
				declare curr_branch_jour_final cursor fast_forward read_only FOR
				select		pr.branch_code
							,pr.branch_name
				from		dbo.final_good_receipt_note_detail		fgrnd
							inner join dbo.good_receipt_note_detail grnd on grnd.id								  = fgrnd.good_receipt_note_detail_id
							inner join dbo.good_receipt_note		grn on (grn.code							  = grnd.good_receipt_note_code)
							inner join dbo.purchase_order			po on (po.code								  = grn.purchase_order_code)
							left join dbo.purchase_order_detail		pod on (
																			   pod.po_code						  = po.code
																			   and pod.id						  = grnd.purchase_order_detail_id
																		   )
							left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
							inner join dbo.procurement				prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
							inner join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
				where		fgrnd.final_good_receipt_note_code = @p_final_grn_code
							and grnd.receive_quantity		   <> 0
				group by	pr.branch_code
							,pr.branch_name
            end

			open curr_branch_jour_final ;

			fetch next from curr_branch_jour_final
			into @branch_code_header
				 ,@branch_name_header ;

			while @@fetch_status = 0
			begin
				--Pembentukan Journal Final GRN
				set @transaction_name = N'Final Good Receipt Note ' + @p_final_grn_code + N' From PO ' + @po_no + N'.' + N' Vendor ' + @vendor_name ;

					exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_insert @p_code = @journal_final output
																					   ,@p_company_code = 'DSF'
																					   ,@p_branch_code = @branch_code_header
																					   ,@p_branch_name = @branch_name_header
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

				fetch next from curr_branch_jour_final
				into @branch_code_header
					 ,@branch_name_header ;
			end ;

			close curr_branch_jour_final ;
			deallocate curr_branch_jour_final ;

		--insert journal final grn
			declare curr_jur_grn cursor fast_forward read_only for
			--ambil semua code GRN yang memiliki reff no yang sama
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
						,isnull(fgr.branch_code,prc.branch_code)
						,isnull(fgr.branch_name,prc.branch_name)
						,mtp.process_code
						,podoi.asset_code
						,grnd.pph_amount
						,grnd.good_receipt_note_code
						,fgrnd.po_object_id
			from		dbo.master_transaction_parameter				mtp
						left join dbo.sys_general_subcode				sgs on (sgs.code									  = mtp.process_code)
						left join dbo.master_transaction				mt on (mt.code										  = mtp.transaction_code)
						inner join dbo.final_good_receipt_note			fgrn on (fgrn.code									  = @p_final_grn_code)
						inner join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code		  = fgrn.code)
						left join dbo.final_grn_request_detail			fgrd on convert(nvarchar(10),fgrd.id)				  = fgrnd.reff_no
						left join dbo.final_grn_request					fgr on fgr.final_grn_request_no							= fgrd.final_grn_request_no

						inner join dbo.good_receipt_note_detail			grnd on (grnd.id									  = fgrnd.good_receipt_note_detail_id)
						left join dbo.purchase_order_detail				pod on (pod.id										  = grnd.purchase_order_detail_id)
						left join dbo.purchase_order_detail_object_info podoi on (
																					 pod.id									  = podoi.purchase_order_detail_id
																					 and   grnd.id							  = podoi.good_receipt_note_detail_id
																					 and   fgrnd.po_object_id				= podoi.id
																				 )
						left join dbo.supplier_selection_detail			ssd on (ssd.id										  = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail			qrd on (qrd.id										  = ssd.quotation_detail_id)
						left join dbo.procurement						prc on (prc.code collate sql_latin1_general_cp1_ci_as = isnull(qrd.reff_no,ssd.reff_no))
			where		mtp.process_code = 'SGS230600003'
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
				 ,@branch_code
				 ,@branch_name
				 ,@process_code
				 ,@asset_code
				 ,@pph_for_expense 
				 ,@good_receipt_note_code
				 ,@podoi_id

			while @@fetch_status = 0
			begin

				--update journal ke GRN Detail
				update	dbo.good_receipt_note_detail
				set		final_journal_code = @journal_final
						,final_journal_date = @journal_date
						--
						,mod_date = @p_mod_date
						,mod_by = @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	id = @grn_id ;

				-- nilainya exec dari MASTER_TRANSACTION.sp_name
				exec @return_value = @sp_name @grn_id, @podoi_id ; -- sp ini mereturn value angka 

				SELECT @gl_link_code'@gl_link_code',@transaction_code'@transaction_code',@debet_or_credit'@debet_or_credit',@transaction_name'@transaction_name',@sp_name'@sp_name',@return_value'@return_value',@grn_id'@grn_id',@podoi_id'@podoi_id'

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

				select	@asset_no = reff_no
				from	dbo.final_good_receipt_note
				where	code = @p_final_grn_code ;

				select	@fgrn_code = code
				from	dbo.final_good_receipt_note
				where	reff_no	 = @asset_no
						and code <> @p_final_grn_code ;


				select	@asset_code_for_gps = podoi.asset_code
				from	dbo.final_good_receipt_note_detail				fgrnd
						inner join dbo.good_receipt_note_detail			grnd on grnd.id								  = fgrnd.good_receipt_note_detail_id
						inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
						inner join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
						inner join dbo.purchase_order_detail			pod on (
																				   pod.po_code						  = po.code
																				   and pod.id						  = grnd.purchase_order_detail_id
																			   )
						left join dbo.purchase_order_detail_object_info podoi on (
																					 grnd.id							= podoi.good_receipt_note_detail_id
																					 and podoi.purchase_order_detail_id	  = pod.id
																				 )
						inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
						inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
						inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
						inner join dbo.procurement_request_item			pri on (
																				   pr.code							  = pri.procurement_request_code
																				   and pri.item_code				  = grnd.item_code
																			   )
				where	fgrnd.final_good_receipt_note_code = @fgrn_code
						and grnd.receive_quantity		   <> 0
						and pri.category_type			   = 'ASSET' ;


				select @asset_code = ast.code from dbo.eproc_interface_asset ast
				inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.reff_no = convert(nvarchar(15), ast.final_grn_request_detail_id)

				where fgrnd.good_receipt_note_detail_id = @grn_id and fgrnd.po_object_id = @podoi_id

				----jika unit from nya buy maka bentuk jurnal
				--set @asset = isnull(isnull(@asset_code, @asset_code_final), @asset_code_for_gps) ;
				--set @asset = isnull(@asset,isnull(@good_receipt_note_code,@po_no))

				if (@unit_from = 'BUY')
				begin
					if @return_value <> 0
					begin

						set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(convert(nvarchar(3), @recive_quantity), '') + N' ' + isnull(@uom_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO NO : ' + isnull(@po_no, '') + '. GRN NO : ' + ISNULL(@good_receipt_note_code,'') ;

						if (@transaction_code in ('ASTGRN','ASTFGRN'))--,'AOIP'--,'FINTRANSIT','AUC','MOBAUC'
						begin

							if not exists
							(
								select	1
								from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
								where	gl_link_transaction_code = @journal_final
										and gl_link_code		 = @gl_link_code
							)
							begin

								set @remarks_journal = isnull((isnull(@transaction_name, '') + N' ASSET CODE : ' + @asset_code),isnull(@transaction_name, '') + N'. FINAL CODE : ' + isnull(@p_final_grn_code,''))

								exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code = @journal_final
																										  ,@p_company_code = 'DSF'
																										  ,@p_branch_code = @branch_code
																										  ,@p_branch_name = @branch_name
																										  ,@p_cost_center_code = null
																										  ,@p_cost_center_name = null
																										  ,@p_gl_link_code = @gl_link_code
																										  ,@p_agreement_no = @asset_code --@asset_code
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
								set		orig_amount_db		= orig_amount_db + @orig_amount_db
										,orig_amount_cr		= orig_amount_cr + @orig_amount_cr
										,base_amount_db		= base_amount_db + @orig_amount_db
										,base_amount_cr		= base_amount_cr + @orig_amount_cr
										,agreement_no		= @asset_code
								where	gl_link_code		= @gl_link_code
										and gl_link_transaction_code = @journal_final ;
							end ;

						end ;
						else if (@transaction_code = 'AUC')
						begin
							--IF not exists (select 1 from dbo.ifinproc_interface_journal_gl_link_transaction_detail where gl_link_transaction_code = @journal_final and gl_link_code = @gl_link_code)
							begin
								set @remarks_journal = isnull(@transaction_name, '') + N'. GRN NO : ' + isnull(@good_receipt_note_code, '') + '. ITEM : ' + ISNULL(@item_name_for_jrnl,'') ;

								exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code = @journal_final
																										  ,@p_company_code = 'DSF'
																										  ,@p_branch_code = @branch_code
																										  ,@p_branch_name = @branch_name
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
						--  else
						--begin
						--	--sum if multiple code final grn
						--	update dbo.ifinproc_interface_journal_gl_link_transaction_detail
						--	set orig_amount_db	= orig_amount_db + @orig_amount_db
						--		,orig_amount_cr	= orig_amount_cr + @orig_amount_cr
						--		,base_amount_db = base_amount_db + @orig_amount_db
						--		,base_amount_cr = base_amount_cr + @orig_amount_cr
						--	where gl_link_code = @gl_link_code
						--	and gl_link_transaction_code = @journal_final
						--end
						end ;
						else
						begin
							exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code = @journal_final
																									  ,@p_company_code = 'DSF'
																									  ,@p_branch_code = @branch_code
																									  ,@p_branch_name = @branch_name
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
					 ,@branch_code
					 ,@branch_name
					 ,@process_code
					 ,@asset_code
					 ,@pph_for_expense 
					 ,@good_receipt_note_code	
					,@podoi_id		

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
		end ;

		--sepria tutup, gk tau buat apa, kenapa kondisinya gk pake primary ?
		--begin -- update interface adjustment
		--	if exists
		--	(
		--		select	1
		--		from	dbo.ifinproc_interface_adjustment_asset
		--		where	fa_code is null
		--	)
		--	begin
		--		update	dbo.ifinproc_interface_adjustment_asset
		--		set		fa_code = @code
		--		where	code = @p_code ;
		--	end ;
		--end ;

		begin --update cover note status
			update	dbo.good_receipt_note
			set		cover_note_status = 'HOLD'
			where	code = @p_code ;
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

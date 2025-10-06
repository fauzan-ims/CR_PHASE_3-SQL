CREATE PROCEDURE dbo.xsp_crp_reverse_journal_grn
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@date						datetime
			,@remark					nvarchar(4000)
			,@code_final				nvarchar(50)
			,@item_code					nvarchar(50)
			,@item_name					nvarchar(250)
			,@type_asset_code			nvarchar(50)
			,@item_category_code		nvarchar(50)
			,@item_category_name		nvarchar(250)
			,@item_merk_code			nvarchar(50)
			,@item_merk_name			nvarchar(250)
			,@item_model_code			nvarchar(50)
			,@item_model_name			nvarchar(250)
			,@item_type_code			nvarchar(50)
			,@item_type_name			nvarchar(250)
			,@uom_code					nvarchar(50)
			,@uom_name					nvarchar(50)
			,@price_amount				decimal(18, 2)
			,@spesification				nvarchar(4000)
			,@po_quantity				int
			,@receive_quantity			decimal(18, 2)
			,@shipper_code				nvarchar(50)
			,@no_resi					nvarchar(50)
			,@reff_no_opl				nvarchar(50)
			,@reff_no_mnl				nvarchar(50)
			,@temp_reff					nvarchar(50)
			,@total_request				int
			,@total_final				int
			,@grn_detail_id				int
			,@procurement_type			nvarchar(50)
			,@handover_remark			nvarchar(4000)
			,@to_province_code			nvarchar(50)
			,@to_province_name			nvarchar(250)
			,@to_city_code				nvarchar(50)
			,@to_city_name				nvarchar(250)
			,@to_area_phone_no			nvarchar(4)
			,@to_phone_no				nvarchar(15)
			,@to_address				nvarchar(4000)
			,@eta_date					datetime
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@fa_code					nvarchar(50)
			,@fa_name					nvarchar(250)
			,@requestor_name			nvarchar(250)
			,@supplier_name				nvarchar(250)
			,@is_reimburse				nvarchar(1)
			,@expense_amount			decimal(18, 2)
			,@ppn_amount				decimal(18, 2)
			,@pph_amount				decimal(18, 2)
			,@discount_amount			decimal(18, 2)
			,@document_pending_code		nvarchar(50)
			,@count						int
			,@document_code				nvarchar(50)
			,@document_name				nvarchar(250)
			,@file_name					nvarchar(250)
			,@file_path					nvarchar(250)
			,@exp_date_doc				datetime
			,@count_item				int
			,@purchase_order_code		nvarchar(50)
			,@grn_detail_id_object_info int
			,@unit_from					nvarchar(25)
			,@po_no						nvarchar(50)
			,@vendor_name				nvarchar(250)
			,@transaction_name			nvarchar(4000)
			,@journal_grn				nvarchar(50)
			,@branch_code_header		nvarchar(50)
			,@branch_name_header		nvarchar(250)
			,@sp_name					nvarchar(250)
			,@debet_or_credit			nvarchar(10)
			,@gl_link_code				nvarchar(50)
			,@gl_link_transaction_code	nvarchar(50)
			,@orig_amount_cr			decimal(18, 2)
			,@orig_amount_db			decimal(18, 2)
			,@return_value				decimal(18, 2)
			,@remarks_journal			nvarchar(4000)
			,@grn_id					bigint
			,@item_code_for_jrnl		nvarchar(50)
			,@item_name_for_jrnl		nvarchar(250)
			,@item_group_code			nvarchar(50)
			,@process_code				nvarchar(50)
			,@division_code				nvarchar(50)
			,@division_name				nvarchar(250)
			,@department_code			nvarchar(50)
			,@department_name			nvarchar(250)
			,@recive_quantity			int
			,@id_object					decimal(18, 2)
			,@category_type				nvarchar(50)
			,@code_grn					nvarchar(50)
			,@purchase_order_detail_id	int
			,@remaining_qty				int
			,@sum_order_remaining		int
			,@rcv_qty					int
			,@rent_or_buy				nvarchar(50)
			,@upload_reff_no			nvarchar(50)
			,@upload_reff_name			nvarchar(250)
			,@upload_reff_trx_code		nvarchar(50)
			,@upload_file_name			nvarchar(250)
			,@upload_doc_file			varbinary(max)
			,@bpkb_no					nvarchar(50)
			,@cover_note				nvarchar(50)
			,@receive_date				datetime
			,@count2					int
			,@proc_type					nvarchar(50)
			,@is_validate				nvarchar(1)
			,@branch_code_request		nvarchar(50)
			,@branch_name_request		nvarchar(250)
			,@journal_date				datetime	  = dbo.xfn_get_system_date()
			,@total_amount_grn			decimal(18, 2)
			,@nett_price_quo			decimal(18, 2)
			,@type						nvarchar(50)
			,@transaction_code			nvarchar(50)

	begin try
		select	@remark		  = grn.remark
				,@rent_or_buy = po.unit_from
		from	dbo.good_receipt_note		  grn
				inner join dbo.purchase_order po on (po.code = grn.purchase_order_code)
		where	grn.code = @p_code ;

		if (@rent_or_buy = 'BUY') -- jika unit nya BUY
		begin
			declare curr_grn_proc cursor fast_forward read_only for
			select	pr.asset_no
					,pr.code
					,pr.procurement_type
					,po.supplier_name
					,grnd.price_amount
					,po.unit_from
					,po.code
					,grn.branch_code
					,grn.branch_name
					,grn.division_code
					,grn.division_name
					,grn.department_code
					,grn.department_name
					,grnd.id
					,grnd.item_code
					,grnd.item_name
					,grnd.type_asset_code
					,grnd.item_category_code
					,grnd.item_category_name
					,grnd.item_merk_code
					,grnd.item_merk_name
					,grnd.item_model_code
					,grnd.item_model_name
					,grnd.item_type_code
					,grnd.item_type_name
					,grnd.uom_code
					,grnd.uom_name
					,grnd.price_amount
					,grnd.spesification
					,grnd.po_quantity
					,grnd.receive_quantity
					,grnd.shipper_code
					,grnd.no_resi
					,pod.ppn_amount
					,pod.pph_amount
					,pod.discount_amount
					,grn.branch_code
					,grn.branch_name
					,pr.procurement_type
			from	dbo.good_receipt_note_detail					   grnd
					inner join dbo.good_receipt_note				   grn on (grn.code								 = grnd.good_receipt_note_code)
					left join dbo.good_receipt_note_detail_object_info grndoi on (grndoi.good_receipt_note_detail_id = grnd.id)
					inner join dbo.purchase_order					   po on (po.code								 = grn.purchase_order_code)
					left join dbo.purchase_order_detail				   pod on (
																				  pod.po_code						 = po.code
																				  and pod.id						 = grnd.purchase_order_detail_id
																			  )
					left join dbo.supplier_selection_detail			   ssd on (ssd.id								 = pod.supplier_selection_detail_id)
					left join dbo.quotation_review_detail			   qrd on (qrd.id								 = ssd.quotation_detail_id)
					inner join dbo.procurement						   prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no))
					inner join dbo.procurement_request				   pr on (pr.code								 = prc.procurement_request_code)
			where	grnd.good_receipt_note_code = @p_code
					and grnd.receive_quantity	<> 0 ;

			open curr_grn_proc ;

			fetch next from curr_grn_proc
			into @reff_no_opl
				 ,@reff_no_mnl
				 ,@procurement_type
				 ,@supplier_name
				 ,@expense_amount
				 ,@unit_from
				 ,@po_no
				 ,@branch_code_header
				 ,@branch_name_header
				 ,@division_code
				 ,@division_name
				 ,@department_code
				 ,@department_name
				 ,@grn_detail_id
				 ,@item_code
				 ,@item_name
				 ,@type_asset_code
				 ,@item_category_code
				 ,@item_category_name
				 ,@item_merk_code
				 ,@item_merk_name
				 ,@item_model_code
				 ,@item_model_name
				 ,@item_type_code
				 ,@item_type_name
				 ,@uom_code
				 ,@uom_name
				 ,@price_amount
				 ,@spesification
				 ,@po_quantity
				 ,@receive_quantity
				 ,@shipper_code
				 ,@no_resi
				 ,@ppn_amount
				 ,@pph_amount
				 ,@discount_amount
				 ,@branch_code
				 ,@branch_name
				 ,@proc_type ;

			while @@fetch_status = 0
			begin
				set @date = dbo.xfn_get_system_date() ;
				set @temp_reff = isnull(@reff_no_opl, '') ;

				-- tapi cek terlebih dahulu apakah ada teman yang sama yang belum masuk ke final GRN
				select	@total_request = count(pr.code)
				from	dbo.procurement_request	   pr
						inner join dbo.procurement prc on (pr.code = prc.procurement_request_code)
				where	pr.asset_no				= @reff_no_opl
						and pr.status not in
				(
					'CANCEL', 'REJECT'
				)	--<> 'CANCEL'
						and prc.unit_from		= @unit_from
						and pr.procurement_type = @procurement_type ;

				select	@total_final = count(fgrnd.id)
				from	dbo.final_good_receipt_note_detail		fgrnd
						inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrnd.good_receipt_note_detail_id
						inner join dbo.good_receipt_note		grn on grn.code = grnd.good_receipt_note_code
						inner join dbo.purchase_order			po on po.code	= grn.purchase_order_code
				where	fgrnd.reff_no			= @temp_reff
						and po.unit_from		= @unit_from
						and po.procurement_type = @procurement_type ;

				fetch next from curr_grn_proc
				into @reff_no_opl
					 ,@reff_no_mnl
					 ,@procurement_type
					 ,@supplier_name
					 ,@expense_amount
					 ,@unit_from
					 ,@po_no
					 ,@branch_code_header
					 ,@branch_name_header
					 ,@division_code
					 ,@division_name
					 ,@department_code
					 ,@department_name
					 ,@grn_detail_id
					 ,@item_code
					 ,@item_name
					 ,@type_asset_code
					 ,@item_category_code
					 ,@item_category_name
					 ,@item_merk_code
					 ,@item_merk_name
					 ,@item_model_code
					 ,@item_model_name
					 ,@item_type_code
					 ,@item_type_name
					 ,@uom_code
					 ,@uom_name
					 ,@price_amount
					 ,@spesification
					 ,@po_quantity
					 ,@receive_quantity
					 ,@shipper_code
					 ,@no_resi
					 ,@ppn_amount
					 ,@pph_amount
					 ,@discount_amount
					 ,@branch_code
					 ,@branch_name
					 ,@proc_type ;
			end ;

			close curr_grn_proc ;
			deallocate curr_grn_proc ;
		end ;

		--Bentuk jurnal GRN
		if (@rent_or_buy = 'BUY')
		begin
			declare curr_branch_request cursor fast_forward read_only for
			select		pr.branch_code
						,pr.branch_name
			from		dbo.good_receipt_note_detail					   grnd
						inner join dbo.good_receipt_note				   grn on (grn.code								 = grnd.good_receipt_note_code)
						left join dbo.good_receipt_note_detail_object_info grndoi on (grndoi.good_receipt_note_detail_id = grnd.id)
						inner join dbo.purchase_order					   po on (po.code								 = grn.purchase_order_code)
						left join dbo.purchase_order_detail				   pod on (
																					  pod.po_code						 = po.code
																					  and pod.id						 = grnd.purchase_order_detail_id
																				  )
						left join dbo.supplier_selection_detail			   ssd on (ssd.id								 = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail			   qrd on (qrd.id								 = ssd.quotation_detail_id)
						inner join dbo.procurement						   prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no))
						inner join dbo.procurement_request				   pr on (pr.code								 = prc.procurement_request_code)
			where		grnd.good_receipt_note_code = @p_code
						and grnd.receive_quantity	<> 0
			group by	pr.branch_code
						,pr.branch_name ;

			open curr_branch_request ;

			fetch next from curr_branch_request
			into @branch_code_request
				 ,@branch_name_request ;

			while @@fetch_status = 0
			begin
				--Pembentukan Journal GRN
				set @transaction_name = N'Reverse Good Receipt Note ' + @p_code + N' From PO ' + @po_no + N'.' + N' Vendor ' + @supplier_name ;

				exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_insert @p_code						= @journal_grn output
																				   ,@p_company_code				= 'DSF'
																				   ,@p_branch_code				= @branch_code_request
																				   ,@p_branch_name				= @branch_name_request
																				   ,@p_transaction_status		= 'HOLD'
																				   ,@p_transaction_date			= @journal_date
																				   ,@p_transaction_value_date	= @journal_date
																				   ,@p_transaction_code			= 'RVSGRNAST'
																				   ,@p_transaction_name			= 'Reverse Good Receipt Note'
																				   ,@p_reff_module_code			= 'IFINPROC'
																				   ,@p_reff_source_no			= @p_code
																				   ,@p_reff_source_name			= @transaction_name
																				   ,@p_is_journal_reversal		= '0'
																				   ,@p_transaction_type			= null
																				   ,@p_cre_date					= @p_mod_date
																				   ,@p_cre_by					= @p_mod_by
																				   ,@p_cre_ip_address			= @p_mod_ip_address
																				   ,@p_mod_date					= @p_mod_date
																				   ,@p_mod_by					= @p_mod_by
																				   ,@p_mod_ip_address			= @p_mod_ip_address ;

				--update code jurnal reverse
				update dbo.good_receipt_note_detail
				set		reverse_journal_code	= @journal_grn
						,reverse_journal_date	= @journal_date
						--
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	good_receipt_note_code	= @p_code

				declare curr_grn_detail cursor fast_forward read_only for
				select	grnd.id
				from	dbo.good_receipt_note_detail					   grnd
						inner join dbo.good_receipt_note				   grn on (grn.code								 = grnd.good_receipt_note_code)
						left join dbo.good_receipt_note_detail_object_info grndoi on (grndoi.good_receipt_note_detail_id = grnd.id)
						inner join dbo.purchase_order					   po on (po.code								 = grn.purchase_order_code)
						left join dbo.purchase_order_detail				   pod on (
																					  pod.po_code						 = po.code
																					  and pod.id						 = grnd.purchase_order_detail_id
																				  )
						left join dbo.supplier_selection_detail			   ssd on (ssd.id								 = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail			   qrd on (qrd.id								 = ssd.quotation_detail_id)
						inner join dbo.procurement						   prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
						inner join dbo.procurement_request				   pr on (pr.code								 = prc.procurement_request_code)
				where	grnd.good_receipt_note_code = @p_code
						and pr.branch_code			= @branch_code_request ;

				open curr_grn_detail ;

				fetch next from curr_grn_detail
				into @grn_detail_id ;

				while @@fetch_status = 0
				begin
					--insert journal GRN
					--ambil yang direceived saja
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
								,prc.branch_code
								,prc.branch_name
								,mtp.process_code
								,pod.po_code
					from		dbo.master_transaction_parameter				mtp
								left join dbo.master_transaction				mt on (mt.code										  = mtp.transaction_code)
								inner join dbo.good_receipt_note_detail			grnd on (grnd.id									  = @grn_detail_id)
								inner join dbo.purchase_order_detail			pod on (pod.id										  = grnd.purchase_order_detail_id)
								left join dbo.purchase_order_detail_object_info podoi on (
																							 pod.id									  = podoi.purchase_order_detail_id
																							 and   grnd.id							  = podoi.good_receipt_note_detail_id
																						 )
								left join dbo.supplier_selection_detail			ssd on (ssd.id										  = pod.supplier_selection_detail_id)
								left join dbo.quotation_review_detail			qrd on (qrd.id										  = ssd.quotation_detail_id)
								inner join dbo.procurement						prc on (prc.code collate sql_latin1_general_cp1_ci_as = isnull(qrd.reff_no, ssd.reff_no))
					where		mtp.process_code		  = 'CRPSGS230100004'
								and grnd.receive_quantity <> 0
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
						 ,@purchase_order_code ;

					while @@fetch_status = 0
					begin
						-- nilainya exec dari MASTER_TRANSACTION.sp_name
						exec @return_value = @sp_name @grn_id ; -- sp ini mereturn value angka 

						if (@return_value <> 0)
						begin
							if (@debet_or_credit = 'DEBIT')
							begin
								--set @orig_amount_cr = 0 ;
								--set @orig_amount_db = @return_value ;
								set @orig_amount_cr = @return_value ;
								set @orig_amount_db = 0 ;
							end ;
							else
							begin
								--set @orig_amount_cr = abs(@return_value) ;
								--set @orig_amount_db = 0 ;
								set @orig_amount_cr = 0 ;
								set @orig_amount_db = abs(@return_value) ;
							end ;
						end ;

						-- Jika GL Code  = ASSET, cek di master category berdasarkan ASSET
						if (@gl_link_code = 'ASSET')
						begin
							--Jika asset nya BUY
							--if(@unit_from = 'BUY')
							begin
								select	@gl_link_code = dbo.xfn_get_asset_gl_code_by_item(@item_group_code) ;
							end ;
						--else
						--begin
						--	select @gl_link_code = dbo.xfn_get_asset_gl_code_by_item_rent(@item_group_code)
						--end
						end ;

						if (isnull(@gl_link_code, '') = '')
						begin
							set @msg = N'Please Setting GL Link For ' + @transaction_name ;

							raiserror(@msg, 16, -1) ;
						end ;


						if (@return_value <> 0)
						begin
							if(@transaction_code = 'APT')
							begin
								if not exists (select 1 from dbo.ifinproc_interface_journal_gl_link_transaction_detail where gl_link_code = @gl_link_code and gl_link_transaction_code = @journal_grn)
								begin
									set @remarks_journal = N'Reverse ' + isnull(@transaction_name, '') + N' ' + isnull(convert(nvarchar(3), @recive_quantity), '') + N' ' + isnull(@uom_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO No : ' + isnull(@po_no, '') ;

									exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @journal_grn
																											  ,@p_company_code					= 'DSF'
																											  ,@p_branch_code					= @branch_code
																											  ,@p_branch_name					= @branch_name
																											  ,@p_cost_center_code				= null
																											  ,@p_cost_center_name				= null
																											  ,@p_gl_link_code					= @gl_link_code
																											  ,@p_agreement_no					= @purchase_order_code
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
									and gl_link_transaction_code = @journal_grn
								end
							end
							else
							begin
									set @remarks_journal = N'Reverse ' + isnull(@transaction_name, '') + N' ' + isnull(convert(nvarchar(3), @recive_quantity), '') + N' ' + isnull(@uom_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO No : ' + isnull(@po_no, '') ;

									exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @journal_grn
																											  ,@p_company_code					= 'DSF'
																											  ,@p_branch_code					= @branch_code
																											  ,@p_branch_name					= @branch_name
																											  ,@p_cost_center_code				= null
																											  ,@p_cost_center_name				= null
																											  ,@p_gl_link_code					= @gl_link_code
																											  ,@p_agreement_no					= @purchase_order_code
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
							 ,@purchase_order_code ;
					end ;

					close curr_jur_grn ;
					deallocate curr_jur_grn ;

					select	@orig_amount_db	 = sum(orig_amount_db)
							,@orig_amount_cr = sum(orig_amount_cr)
					from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
					where	gl_link_transaction_code = @journal_grn ;

					--+ validasi : total detail =  payment_amount yang di header
					if (@orig_amount_db <> @orig_amount_cr)
					begin
						set @msg = N'Journal does not balance' ;

						raiserror(@msg, 16, -1) ;
					end ;

					fetch next from curr_grn_detail
					into @grn_detail_id ;
				end ;

				close curr_grn_detail ;
				deallocate curr_grn_detail ;

				fetch next from curr_branch_request
				into @branch_code_request
					 ,@branch_name_request ;
			end ;

			close curr_branch_request ;
			deallocate curr_branch_request ;
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

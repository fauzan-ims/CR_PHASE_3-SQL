CREATE procedure dbo.xsp_ap_invoice_registration_return_0511
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
			,@grn_code					nvarchar(50)
			,@sp_name					nvarchar(250)
			,@debet_or_credit			nvarchar(10)
			,@gl_link_code				nvarchar(50)
			,@transaction_name			nvarchar(250)
			,@gl_link_transaction_code	nvarchar(50)
			,@orig_amount_cr			decimal(18, 2)
			,@orig_amount_db			decimal(18, 2)
			,@return_value				decimal(18, 2)
			,@remarks_journal			nvarchar(4000)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@purchase_order_code		nvarchar(50)
			,@vendor_code				nvarchar(50)
			,@vendor_name				nvarchar(250)
			,@vendor_address			nvarchar(4000)
			,@invoice_id				bigint
			,@unit_from					nvarchar(25)
			,@item_code					nvarchar(50)
			,@transaction_code			nvarchar(50)
			,@item_category_code		nvarchar(50)
			,@item_name					nvarchar(50)
			,@item_group_code			nvarchar(50)
			,@faktur_no					nvarchar(50)
			,@ppn						decimal(18, 2)
			,@income_type				nvarchar(250)
			,@income_bruto_amount		decimal(18, 2)
			,@tax_rate					decimal(5, 2)
			,@ppn_pph_amount			decimal(18, 2)
			,@ppn_pct					decimal(9, 6)
			,@pph_pct					decimal(9, 6)
			,@vendor_type				nvarchar(25)
			,@pph_type					nvarchar(20)
			,@total_amount				decimal(18, 2)
			,@remarks_tax				nvarchar(4000)
			,@vendor_npwp				nvarchar(20)
			,@procurement_type			nvarchar(50)
			,@journal_date				datetime	  = dbo.xfn_get_system_date()
			,@asset_code				nvarchar(50)
			,@invoice_register_code		nvarchar(50)
			,@id						int
			,@po_code					nvarchar(50)
			,@code_jrn					nvarchar(50)
			,@code_grn					nvarchar(50)
			,@temp_grn_code				nvarchar(50)
			,@temp_final_code			nvarchar(50)
			,@purchase					decimal(18, 2)
			,@amount_invoice			decimal(18, 2)
			,@proc_req_code				nvarchar(50)
			,@proc_type					nvarchar(50)
			,@category_type				nvarchar(50)
			,@branch_code_adjust		nvarchar(50)
			,@branch_name_adjust		nvarchar(250)
			,@fa_code_adjust			nvarchar(50)
			,@fa_name_adjust			nvarchar(250)
			,@division_code_adjust		nvarchar(50)
			,@division_name_adjust		nvarchar(250)
			,@department_code_adjust	nvarchar(50)
			,@department_name_adjust	nvarchar(250)
			,@specification_adjust		nvarchar(4000)
			,@code_asset_for_adjustment nvarchar(50)
			,@name_asset_for_adjustment nvarchar(250)
			,@date						datetime	  = dbo.xfn_get_system_date()
			,@item_code_adj				nvarchar(50)
			,@item_name_adj				nvarchar(250)
			,@uom_name_adj				nvarchar(15)
			,@quantity_adj				int
			,@adjustment_amount			decimal(18, 2)
			,@reff_no					nvarchar(50)
			,@amount_grn				decimal(18, 2)
			,@id_detail					int
			,@id_grn					int
			,@discount					decimal(18, 2)
			,@pph						decimal(18, 2)
			,@grn_detail_id				int ;

	begin try
		if exists
		(
			select	1
			from	dbo.ap_invoice_registration air
			where	air.code	   = @p_code
					and air.status = 'POST'
					and air.code not in
						(
							select	aprd.invoice_register_code
							from	dbo.ap_payment_request_detail	  aprd
									inner join dbo.ap_payment_request apr on apr.code = aprd.payment_request_code
							where	apr.status in
		(
			'HOLD', 'ON PROCESS', 'APPROVE', 'PAID'
		)
						)
		)
		begin
			-- Pembentukan Journal Invoice Register
			select	@purchase_order_code = purchase_order_code
					,@vendor_name		 = supplier_name
			from	dbo.ap_invoice_registration
			where	code = @p_code ;

			declare curr_invoice_branch_request cursor fast_forward read_only for
			select		pr.branch_code
						,pr.branch_name
			from		dbo.ap_invoice_registration_detail		aird
						left join dbo.good_receipt_note			grn on (grn.code							  = aird.grn_code)
						--inner join dbo.good_receipt_note_detail			grnd on (grnd.good_receipt_note_code		  = grn.code)
						--left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
						left join dbo.purchase_order			po on (po.code								  = grn.purchase_order_code)
						left join dbo.purchase_order_detail		pod on (
																	--pod.po_code						  = po.code
																	--and pod.id						  = grnd.purchase_order_detail_id
																	aird.PURCHASE_ORDER_ID					  = pod.id
																	   )
						left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
						inner join dbo.procurement				prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
						inner join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
			where		aird.invoice_register_code = @p_code
			group by	pr.branch_code
						,pr.branch_name ;

			open curr_invoice_branch_request ;

			fetch next from curr_invoice_branch_request
			into @branch_code
				 ,@branch_name ;

			while @@fetch_status = 0
			begin
				set @transaction_name = N'Reverse Invoice Register ' + @p_code + N' From PO ' + @purchase_order_code + N'.' + N' Vendor ' + @vendor_name ;

				exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_insert @p_code = @gl_link_transaction_code output
																				   ,@p_company_code = 'DSF'
																				   ,@p_branch_code = @branch_code
																				   ,@p_branch_name = @branch_name
																				   ,@p_transaction_status = 'HOLD'
																				   ,@p_transaction_date = @journal_date
																				   ,@p_transaction_value_date = @journal_date
																				   ,@p_transaction_code = 'INRGST'
																				   ,@p_transaction_name = 'Reverse Invoice Register'
																				   ,@p_reff_module_code = 'IFINPROC'
																				   ,@p_reff_source_no = @p_code
																				   ,@p_reff_source_name = @transaction_name
																				   ,@p_is_journal_reversal = '0'
																				   ,@p_transaction_type = null
																				   ,@p_cre_date = @p_mod_date
																				   ,@p_cre_by = @p_mod_by
																				   ,@p_cre_ip_address = @p_mod_ip_address
																				   ,@p_mod_date = @p_mod_date
																				   ,@p_mod_by = @p_mod_by
																				   ,@p_mod_ip_address = @p_mod_ip_address ;

				declare cursor_name cursor fast_forward read_only for
				select		distinct
							mt.sp_name
							,mtp.debet_or_credit
							,mtp.gl_link_code
							,mt.transaction_name
							,ird.id
							,mtp.transaction_code
							,grnd.item_category_code
							,ird.item_name
							,prc.item_group_code
							,po.unit_from
							,pod.ppn_pct
							,pod.pph_pct
							,(ird.purchase_amount - ird.discount) * ird.quantity
							,ssd.supplier_code
							,ssd.supplier_name
							,ssd.supplier_address
							,ssd.supplier_npwp
							,air.faktur_no
							,pr.procurement_type
							,podoi.asset_code
							,ird.purchase_order_id
							,po.code
				from		dbo.master_transaction_parameter				mtp
							left join dbo.sys_general_subcode				sgs on (sgs.code								  = mtp.process_code)
							left join dbo.master_transaction				mt on (mt.code									  = mtp.transaction_code)
							left join dbo.ap_invoice_registration_detail	ird on (ird.invoice_register_code				  = @p_code)
							inner join dbo.ap_invoice_registration			air on (air.code								  = ird.invoice_register_code)
							inner join dbo.good_receipt_note				grn on grn.code									  = ird.grn_code
							--outer apply (select top 1 detail.receive_quantity, detail.id, detail.item_category_code from dbo.good_receipt_note_detail detail where detail.good_receipt_note_code = grn.code) detailgrn
							--inner join dbo.good_receipt_note_detail grnd on (grnd.good_receipt_note_code = grn.code)
							left join dbo.purchase_order					po on (po.code									  = grn.purchase_order_code)
							left join dbo.purchase_order_detail				pod on (
																				--pod.po_code									  = po.code
																				--and pod.id										  = grnd.purchase_order_detail_id
																				ird.purchase_order_id						  = pod.id
																				   )
							left join dbo.good_receipt_note_detail			grnd on (
																						grnd.GOOD_RECEIPT_NOTE_CODE			  = grn.CODE
																						and grnd.receive_quantity			  <> 0
																					)
							left join dbo.purchase_order_detail_object_info podoi on (
																						 pod.id								  = podoi.purchase_order_detail_id
																						 and   grnd.ID						  = podoi.good_receipt_note_detail_id
																						 and   podoi.purchase_order_detail_id = ird.purchase_order_id
																						 and   podoi.ASSET_CODE				  <> null
																					 )
							left join dbo.supplier_selection_detail			ssd on (ssd.id									  = pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail			qrd on (qrd.id									  = ssd.quotation_detail_id)
							inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as	  = isnull(qrd.reff_no, ssd.reff_no))
							inner join dbo.procurement_request				pr on (pr.code									  = prc.procurement_request_code)
				where		mtp.process_code   = 'SGS230600004'
							and pr.branch_code = @branch_code
				--and grnd.receive_quantity <> 0
				order by	ird.purchase_order_id ;

				open cursor_name ;

				fetch next from cursor_name
				into @sp_name
					 ,@debet_or_credit
					 ,@gl_link_code
					 ,@transaction_name
					 ,@invoice_id
					 ,@transaction_code
					 ,@item_category_code
					 ,@item_name
					 ,@item_group_code
					 ,@unit_from
					 ,@ppn_pct
					 ,@pph_pct
					 ,@total_amount
					 ,@vendor_code
					 ,@vendor_name
					 ,@vendor_address
					 ,@vendor_npwp
					 ,@faktur_no
					 ,@procurement_type
					 ,@asset_code
					 ,@id
					 ,@po_code ;

				while @@fetch_status = 0
				begin
					set @code_jrn = isnull(@asset_code, @po_code) ;

					-- nilainya exec dari MASTER_TRANSACTION.sp_name
					exec @return_value = @sp_name @invoice_id ;

					-- sp ini mereturn value angka 

					-- (+) Ari 2023-12-30 ket : get npwp name & npwp address (bukan name dan address,logic diatas dibiarin aja)
					select	@vendor_name	 = mv.npwp_name
							,@vendor_address = mv.npwp_address
					from	ifinbam.dbo.master_vendor mv
					where	mv.code = @vendor_code ;

					-- (+) Ari 2023-12-30
					if (@return_value > 0)
					begin

						-- Hari - 18.Jul.2023 06:37 PM --	logic khusus untuk AP temporary untuk mendapatkan gl link
						--if @transaction_code = 'INVAPS' -- AP TEMPORARY, untuk unit dengan tipe rental/sewa ambil gl nya berbeda
						--begin

						--	IF ( @unit_from = 'BUY')  
						--	begin	
						--		select @gl_link_code =  dbo.xfn_get_asset_gl_code_by_item(@item_group_code)
						--	end 
						--	else-- RENT
						--	begin
						--		select @gl_link_code =  dbo.xfn_get_asset_gl_code_by_item_rent(@item_group_code)
						--	end

						--end
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

						if (isnull(@gl_link_code, '') = '')
						begin
							set @msg = N'Please Setting GL Link For ' + @transaction_name ;

							raiserror(@msg, 16, -1) ;
						end ;

						set @remarks_journal = @transaction_name + N' ' + N'. Invoice No : ' + @p_code ;
						set @remarks_tax = @remarks_journal ;

						if (@transaction_code = 'INVVAT')
						begin
							if (@return_value > 0)
							begin
								set @pph_type = N'PPN MASUKAN' ;
								set @income_type = N'PPN MASUKAN ' + convert(nvarchar(10), cast(@ppn_pct as int)) + N'%' ;
								set @income_bruto_amount = @total_amount ;
								set @tax_rate = @ppn_pct ;
								set @ppn_pph_amount = @return_value ;
							end ;
						end ;
						else if (@transaction_code = 'INVPPH')
						begin
							if (@return_value > 0)
							begin
								-- jika sewa
								if (
									   @procurement_type = 'PURCHASE'
									   and	@unit_from = 'RENT'
								   )
								begin
									set @pph_type = N'PPH PASAL 23' ;
									set @income_type = N'SEWA HARTA' ;
								end ;
								-- jika pembelian unit
								else if (
											@procurement_type = 'PURCHASE'
											and @unit_from = 'BUY'
										)
								begin
									set @pph_type = N'PPH PASAL 23' ;
									set @income_type = N'' ;
								end ;
								-- jika mobilisasi
								else if (@procurement_type = 'MOBILISASI')
								begin
									set @pph_type = N'PPH PASAL 23' ;
									set @income_type = N'JASA LOGISTIK' ;
								end ;

								set @income_bruto_amount = @total_amount ;
								set @tax_rate = @pph_pct ;
								set @ppn_pph_amount = @return_value ;
							end ;
						end ;
						else
						begin
							set @income_type = N'' ;
							set @pph_type = N'' ;
							set @vendor_code = N'' ;
							set @vendor_name = N'' ;
							set @vendor_npwp = N'' ;
							set @vendor_address = N'' ;
							set @income_bruto_amount = 0 ;
							set @tax_rate = 0 ;
							set @ppn_pph_amount = 0 ;
							set @remarks_tax = N'' ;
							set @faktur_no = N'' ;
						end ;

						if (@gl_link_code = 'AP TEMP')
						begin
							set @code_jrn = @po_code ;
						end ;

						exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code = @gl_link_transaction_code
																								  ,@p_company_code = 'DSF'
																								  ,@p_branch_code = @branch_code
																								  ,@p_branch_name = @branch_name
																								  ,@p_cost_center_code = null
																								  ,@p_cost_center_name = null
																								  ,@p_gl_link_code = @gl_link_code
																								  ,@p_agreement_no = @code_jrn			--@asset_code
																								  ,@p_facility_code = null
																								  ,@p_facility_name = null
																								  ,@p_purpose_loan_code = null
																								  ,@p_purpose_loan_name = null
																								  ,@p_purpose_loan_detail_code = null
																								  ,@p_purpose_loan_detail_name = null
																								  ,@p_orig_currency_code = 'IDR'
																								  ,@p_orig_amount_db = @orig_amount_cr	--@orig_amount_db
																								  ,@p_orig_amount_cr = @orig_amount_db	--@orig_amount_cr
																								  ,@p_exch_rate = 1
																								  ,@p_base_amount_db = @orig_amount_cr	--@orig_amount_db
																								  ,@p_base_amount_cr = @orig_amount_db	--@orig_amount_cr
																								  ,@p_division_code = ''
																								  ,@p_division_name = ''
																								  ,@p_department_code = ''
																								  ,@p_department_name = ''
																								  ,@p_remarks = @remarks_journal
																								  ,@p_ext_pph_type = @pph_type
																								  ,@p_ext_vendor_code = @vendor_code
																								  ,@p_ext_vendor_name = @vendor_name
																								  ,@p_ext_vendor_npwp = @vendor_npwp
																								  ,@p_ext_vendor_address = @vendor_address
																								  ,@p_ext_income_type = @income_type
																								  ,@p_ext_income_bruto_amount = @income_bruto_amount
																								  ,@p_ext_tax_rate_pct = @tax_rate
																								  ,@p_ext_pph_amount = @ppn_pph_amount
																								  ,@p_ext_description = @remarks_tax
																								  ,@p_ext_tax_number = @faktur_no
																								  ,@p_ext_sale_type = ''
																								  ,@p_cre_date = @p_mod_date
																								  ,@p_cre_by = @p_mod_by
																								  ,@p_cre_ip_address = @p_mod_ip_address
																								  ,@p_mod_date = @p_mod_date
																								  ,@p_mod_by = @p_mod_by
																								  ,@p_mod_ip_address = @p_mod_ip_address ;
					end ;

					fetch next from cursor_name
					into @sp_name
						 ,@debet_or_credit
						 ,@gl_link_code
						 ,@transaction_name
						 ,@invoice_id
						 ,@transaction_code
						 ,@item_category_code
						 ,@item_name
						 ,@item_group_code
						 ,@unit_from
						 ,@ppn_pct
						 ,@pph_pct
						 ,@total_amount
						 ,@vendor_code
						 ,@vendor_name
						 ,@vendor_address
						 ,@vendor_npwp
						 ,@faktur_no
						 ,@procurement_type
						 ,@asset_code
						 ,@id
						 ,@po_code ;
				end ;

				close cursor_name ;
				deallocate cursor_name ;

				-- balancing
				begin
					if ((
							select	sum(orig_amount_db) - sum(orig_amount_cr)
							from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
							where	gl_link_transaction_code = @gl_link_transaction_code
						) <> 0
					   )
					begin
						set @msg = N'Journal is not balance' ;

						raiserror(@msg, 16, -1) ;
					end ;
				end ;

				fetch next from curr_invoice_branch_request
				into @branch_code
					 ,@branch_name ;
			end ;

			close curr_invoice_branch_request ;
			deallocate curr_invoice_branch_request ;

			create table #TempGrnCode
			(
				code_grn nvarchar(50)
				,id_grn	 int
			) ;

			declare curr_diff_purchase cursor fast_forward read_only for
			select	ard.id
					,grnd.id
					,grnd.good_receipt_note_code
			from	dbo.ap_invoice_registration_detail				ard
					inner join dbo.ap_invoice_registration			air on ard.invoice_register_code		   = air.code
					inner join dbo.good_receipt_note_detail			grnd on grnd.good_receipt_note_code		   = ard.grn_code
																			and grnd.receive_quantity		   <> 0
																			and grnd.purchase_order_detail_id  = ard.purchase_order_id
					inner join dbo.final_good_receipt_note_detail	fgrnd on grnd.id						   = fgrnd.good_receipt_note_detail_id
					left join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id = grnd.id
			where	air.code = @p_code ;

			open curr_diff_purchase ;

			fetch next from curr_diff_purchase
			into @id_detail
				 ,@id_grn
				 ,@code_grn ;

			while @@fetch_status = 0
			begin
				select	@amount_invoice = purchase_amount
				from	dbo.ap_invoice_registration_detail
				where	id = @id_detail ;

				select	@amount_grn = orig_price_amount --price_amount 
				from	dbo.good_receipt_note_detail
				where	id = @id_grn ;

				if (@amount_invoice <> @amount_grn)
				begin
					insert into #TempGrnCode
					(
						code_grn
						,id_grn
					)
					values
					(
						@code_grn
						,@id_grn
					) ;
				end ;

				fetch next from curr_diff_purchase
				into @id_detail
					 ,@id_grn
					 ,@code_grn ;
			end ;

			close curr_diff_purchase ;
			deallocate curr_diff_purchase ;

			--reverse jurnal GRN
			declare curr_rev_jour cursor fast_forward read_only for
			select	distinct
					code_grn
			--,temp.id_grn --new
			from	#TempGrnCode temp ;

			open curr_rev_jour ;

			fetch next from curr_rev_jour
			into @temp_grn_code ;

			--,@grn_detail_id
			while @@fetch_status = 0
			begin
				-- create jurnal reverse GRN yang baru
				exec dbo.xsp_reverse_new_journal_grn @p_code = @temp_grn_code
													 ,@p_invoice_code = @p_code
													 ,@p_mod_date = @p_mod_date
													 ,@p_mod_by = @p_mod_by
													 ,@p_mod_ip_address = @p_mod_ip_address ;

				-- create jurnal lama
				exec dbo.xsp_old_journal_grn @p_code = @temp_grn_code
											 ,@p_mod_date = @p_mod_date
											 ,@p_mod_by = @p_mod_by
											 ,@p_mod_ip_address = @p_mod_ip_address ;

				declare curr_rev_final cursor fast_forward read_only for
				select	distinct
						fgrnd.final_good_receipt_note_code
				--,podoi.asset_code
				from	dbo.good_receipt_note_detail					grnd
						inner join dbo.final_good_receipt_note_detail	fgrnd on fgrnd.good_receipt_note_detail_id	  = grnd.id
						inner join dbo.purchase_order_detail			pod on pod.id								  = grnd.purchase_order_detail_id
						left join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id	  = grnd.id
																				 and   podoi.purchase_order_detail_id = pod.id
				where	grnd.good_receipt_note_code = @temp_grn_code
						and grnd.receive_quantity	<> 0 ;

				open curr_rev_final ;

				fetch next from curr_rev_final
				into @temp_final_code ;

				--,@asset_code
				while @@fetch_status = 0
				begin
					if exists
					(
						select	1
						from	dbo.ifinproc_interface_journal_gl_link_transaction
						where	reff_source_no		 = @temp_final_code
								and transaction_name = 'Final Good Receipt Note'
					)
					begin
						select	@reff_no		  = isnull(pr.asset_no, '')
								,@item_group_code = mi.item_group_code
								,@category_type	  = mi.category_type
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
								left join ifinbam.dbo.master_item				   mi on mi.code collate latin1_general_ci_as	 = grnd.item_code
						where	grnd.good_receipt_note_code = @temp_grn_code
								and grnd.receive_quantity	<> 0 ;

						if (@reff_no <> '')
						begin
							--create jurnal reverse new finl
							exec dbo.xsp_reverse_new_journal_multiple_final @p_code = @temp_grn_code
																			,@p_final_grn_code = @temp_final_code
																			,@p_company_code = 'DSF'
																			,@p_mod_date = @p_mod_date
																			,@p_mod_by = @p_mod_by
																			,@p_mod_ip_address = @p_mod_ip_address ;

							exec dbo.xsp_old_journal_final_multiple @p_code = @temp_grn_code
																	,@p_final_grn_code = @temp_final_code
																	,@p_company_code = 'DSF'
																	,@p_mod_date = @p_mod_date
																	,@p_mod_by = @p_mod_by
																	,@p_mod_ip_address = @p_mod_ip_address ;

						--exec dbo.xsp_reverse_new_journal_final @p_code				= @temp_grn_code
						--									   ,@p_final_grn_code	= @temp_final_code
						--									   ,@p_invoice_code		= @p_code
						--									   ,@p_company_code		= 'DSF'
						--									   ,@p_mod_date			= @p_mod_date
						--									   ,@p_mod_by			= @p_mod_by
						--									   ,@p_mod_ip_address	= @p_mod_ip_address

						--create jurnal final
						--exec dbo.xsp_old_journal_final @p_code				= @temp_grn_code
						--							   ,@p_final_grn_code	= @temp_final_code
						--							   ,@p_company_code		= 'DSF'
						--							   ,@p_mod_date			= @p_mod_date
						--							   ,@p_mod_by			= @p_mod_by
						--							   ,@p_mod_ip_address	= @p_mod_ip_address
						end ;
						else
						begin
							--create jurnal reverse new finl
							exec dbo.xsp_reverse_new_journal_final @p_code = @temp_grn_code
																   ,@p_final_grn_code = @temp_final_code
																   ,@p_invoice_code = @p_code
																   ,@p_company_code = 'DSF'
																   ,@p_mod_date = @p_mod_date
																   ,@p_mod_by = @p_mod_by
																   ,@p_mod_ip_address = @p_mod_ip_address ;

							--create jurnal final
							exec dbo.xsp_old_journal_final @p_code = @temp_grn_code
														   ,@p_final_grn_code = @temp_final_code
														   ,@p_company_code = 'DSF'
														   ,@p_mod_date = @p_mod_date
														   ,@p_mod_by = @p_mod_by
														   ,@p_mod_ip_address = @p_mod_ip_address ;
						end ;

						--declare curr_category_type cursor fast_forward read_only for
						----select	mi.category_type
						----		,mi.item_group_code
						----from	dbo.ap_invoice_registration_detail aird
						----		left join ifinbam.dbo.master_item  mi on mi.code collate Latin1_General_CI_AS = aird.item_code
						----where	aird.invoice_register_code = @p_code ;

						--select	mi.category_type
						--		,mi.item_group_code
						--from	dbo.good_receipt_note_detail	  grnd
						--		left join ifinbam.dbo.master_item mi on mi.code collate latin1_general_ci_as = grnd.item_code
						--where grnd.good_receipt_note_code = @temp_grn_code
						--and grnd.receive_quantity <> 0
						----where	id = @grn_detail_id ;

						--open curr_category_type

						--fetch next from curr_category_type 
						--into @category_type
						--	,@item_group_code

						--while @@fetch_status = 0
						--begin
						if (@item_group_code <> 'EXPS')
						begin
							if (@category_type = 'ASSET')
							begin
								declare curr_update_asset cursor fast_forward read_only for
								--select	distinct
								--		podoi.asset_code
								--from	dbo.good_receipt_note_detail				  grnd
								--		inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
								--		inner join dbo.purchase_order_detail			 pod on pod.id								  = grnd.purchase_order_detail_id
								--		inner join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id	  = grnd.id
								--											  and  podoi.purchase_order_detail_id = pod.id
								--where	grnd.good_receipt_note_code = @temp_grn_code
								--and grnd.receive_quantity	<> 0 ;
								select	podoi.asset_code
								from	dbo.final_good_receipt_note_detail				fgrnd
										inner join dbo.good_receipt_note_detail			grnd on grnd.id								  = fgrnd.good_receipt_note_detail_id
										inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
										inner join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
										inner join dbo.purchase_order_detail			pod on (
																								   pod.po_code						  = po.code
																								   and pod.id						  = grnd.purchase_order_detail_id
																							   )
										left join dbo.purchase_order_detail_object_info podoi on (
																									 podoi.purchase_order_detail_id	  = pod.id
																									 and   grnd.id					  = podoi.good_receipt_note_detail_id
																								 )
										inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
										left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
										inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
										inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
										inner join dbo.procurement_request_item			pri on (
																								   pr.code							  = pri.procurement_request_code
																								   and pri.item_code				  = grnd.item_code
																							   )
								where	fgrnd.final_good_receipt_note_code = @temp_final_code
										and grnd.receive_quantity		   <> 0
										and pri.category_type			   = 'ASSET' ;

								open curr_update_asset ;

								fetch next from curr_update_asset
								into @asset_code ;

								while @@fetch_status = 0
								begin
									--update harga asset
									select	@purchase = sum(grnd.orig_price_amount - grnd.orig_discount_amount)
									from	dbo.final_good_receipt_note					  fgrn
											inner join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code	= fgrn.code)
											left join dbo.good_receipt_note_detail		  grnd on (grnd.id								= fgrnd.good_receipt_note_detail_id)
											left join dbo.good_receipt_note				  grn on (grn.code								= grnd.good_receipt_note_code)
											left join dbo.purchase_order				  po on (po.code								= grn.purchase_order_code)
											left join dbo.purchase_order_detail			  pod on (
																									 pod.po_code						= po.code
																									 and pod.id							= grnd.purchase_order_detail_id
																								 )
											inner join dbo.supplier_selection_detail	  ssd on (ssd.id								= pod.supplier_selection_detail_id)
											left join dbo.quotation_review_detail		  qrd on (qrd.id								= ssd.quotation_detail_id)
											inner join dbo.procurement					  prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
											inner join dbo.procurement_request			  pr on (prc.procurement_request_code			= pr.code)
											inner join dbo.procurement_request_item		  pri on (
																									 pr.code							= pri.procurement_request_code
																									 and pri.item_code					= grnd.item_code
																								 )
									where	fgrn.code = @temp_final_code ;

									select	@amount_invoice = sum(grnd.orig_price_amount)
									from	dbo.final_good_receipt_note					  fgrn
											inner join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code	= fgrn.code)
											left join dbo.good_receipt_note_detail		  grnd on (grnd.id								= fgrnd.good_receipt_note_detail_id)
											left join dbo.good_receipt_note				  grn on (grn.code								= grnd.good_receipt_note_code)
											left join dbo.purchase_order				  po on (po.code								= grn.purchase_order_code)
											left join dbo.purchase_order_detail			  pod on (
																									 pod.po_code						= po.code
																									 and pod.id							= grnd.purchase_order_detail_id
																								 )
											inner join dbo.supplier_selection_detail	  ssd on (ssd.id								= pod.supplier_selection_detail_id)
											left join dbo.quotation_review_detail		  qrd on (qrd.id								= ssd.quotation_detail_id)
											inner join dbo.procurement					  prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
											inner join dbo.procurement_request			  pr on (prc.procurement_request_code			= pr.code)
											inner join dbo.procurement_request_item		  pri on (
																									 pr.code							= pri.procurement_request_code
																									 and pri.item_code					= grnd.item_code
																								 )
									where	fgrn.code = @temp_final_code ;

									--insert ke interface harga asset yang baru
									exec dbo.xsp_ifinproc_new_asset_insert @p_id = 0
																		   ,@p_asset_code = @asset_code
																		   ,@p_purchase_price = @purchase
																		   ,@p_orig_amount = @amount_invoice
																		   ,@p_type = 'ASSET'
																		   ,@p_posting_date = null
																		   ,@p_return_date = @date
																		   ,@p_invoice_date_type = 'RETURN'
																		   ,@p_invoice_code = @p_code
																			--
																		   ,@p_cre_date = @p_mod_date
																		   ,@p_cre_by = @p_mod_by
																		   ,@p_cre_ip_address = @p_mod_ip_address
																		   ,@p_mod_date = @p_mod_date
																		   ,@p_mod_by = @p_mod_by
																		   ,@p_mod_ip_address = @p_mod_ip_address ;

									fetch next from curr_update_asset
									into @asset_code ;
								end ;

								close curr_update_asset ;
								deallocate curr_update_asset ;
							end ;
							else
							begin
								--select asset jika tidak adjust manual dari proc request
								select	@asset_code = isnull(podoi.asset_code, '')
										,@item_name = pri.item_name
								from	dbo.final_good_receipt_note_detail				fgrnd
										inner join dbo.good_receipt_note_detail			grnd on grnd.id								  = fgrnd.good_receipt_note_detail_id
										inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
										inner join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
										inner join dbo.purchase_order_detail			pod on (
																								   pod.po_code						  = po.code
																								   and pod.id						  = grnd.purchase_order_detail_id
																							   )
										left join dbo.purchase_order_detail_object_info podoi on (
																									 podoi.purchase_order_detail_id	  = pod.id
																									 and   grnd.id					  = podoi.good_receipt_note_detail_id
																								 )
										inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
										left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
										inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
										inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
										inner join dbo.procurement_request_item			pri on (
																								   pr.code							  = pri.procurement_request_code
																								   and pri.item_code				  = grnd.item_code
																							   )
								where	fgrnd.final_good_receipt_note_code = @temp_final_code
										and grnd.receive_quantity		   <> 0
										and pri.category_type			   = 'ASSET' ;

								--if(@asset_code <> '')
								begin
									declare curr_diff_amount cursor fast_forward read_only for
									--select	ard.id
									--		,grnd.id
									--from	dbo.ap_invoice_registration_detail		ard
									--		inner join dbo.ap_invoice_registration	air on ard.invoice_register_code		  = air.code
									--		inner join dbo.good_receipt_note_detail grnd on grnd.good_receipt_note_code		  = ard.grn_code
									--														and grnd.receive_quantity		  <> 0
									--														and grnd.purchase_order_detail_id = ard.purchase_order_id
									--where	air.code = @p_code ;
									select	ard.id
											,grnd.id
									from	dbo.ap_invoice_registration_detail			  ard
											inner join dbo.ap_invoice_registration		  air on ard.invoice_register_code			 = air.code
											inner join dbo.good_receipt_note_detail		  grnd on grnd.good_receipt_note_code		 = ard.grn_code
																								  and grnd.receive_quantity			 <> 0
																								  and grnd.purchase_order_detail_id	 = ard.purchase_order_id
											inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
									where	fgrnd.final_good_receipt_note_code = @temp_final_code
											and ard.invoice_register_code	   = @p_code ;

									open curr_diff_amount ;

									fetch next from curr_diff_amount
									into @id_detail
										 ,@id_grn ;

									while @@fetch_status = 0
									begin
										select	@proc_req_code = pr.code
												,@item_code	   = pri.item_code
										from	dbo.final_good_receipt_note_detail				fgrnd
												inner join dbo.good_receipt_note_detail			grnd on grnd.id								  = fgrnd.good_receipt_note_detail_id
												inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
												inner join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
												inner join dbo.purchase_order_detail			pod on (
																										   pod.po_code						  = po.code
																										   and pod.id						  = grnd.purchase_order_detail_id
																									   )
												left join dbo.purchase_order_detail_object_info podoi on (
																											 podoi.purchase_order_detail_id	  = pod.id
																											 and   grnd.id					  = podoi.good_receipt_note_detail_id
																										 )
												inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
												left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
												inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
												inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
												inner join dbo.procurement_request_item			pri on (
																										   pr.code							  = pri.procurement_request_code
																										   and pri.item_code				  = grnd.item_code
																									   )
										where	grnd.id = @id_grn ;

										select	@amount_grn = grnd.orig_price_amount
										from	dbo.good_receipt_note_detail grnd
										where	grnd.ID = @id_grn ;

										select	@amount_invoice = purchase_amount
										from	dbo.ap_invoice_registration_detail
										where	id = @id_detail ;

										declare curr_adj cursor fast_forward read_only for
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

										open curr_adj ;

										fetch next from curr_adj
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
											set @code_asset_for_adjustment = isnull(@fa_code_adjust, @asset_code) ;
											set @name_asset_for_adjustment = isnull(@fa_name_adjust, @item_name) ;

											if (@amount_grn <> @amount_invoice)
											begin
												set @adjustment_amount = (@amount_invoice - @amount_grn) * -1 ;

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
																										,@p_adjustment_amount = @adjustment_amount
																										,@p_quantity = @quantity_adj
																										,@p_uom = @uom_name_adj
																										,@p_type_asset = 'SINGLE'
																										,@p_job_status = 'HOLD'
																										,@p_failed_remarks = ''
																										,@p_adjust_type = 'INVOICE'
																										--
																										,@p_cre_date = @p_mod_date
																										,@p_cre_by = @p_mod_by
																										,@p_cre_ip_address = @p_mod_ip_address
																										,@p_mod_date = @p_mod_date
																										,@p_mod_by = @p_mod_by
																										,@p_mod_ip_address = @p_mod_ip_address ;

												--insert ke interface harga asset yang baru
												exec dbo.xsp_ifinproc_new_asset_insert @p_id = 0
																					   ,@p_asset_code = @code_asset_for_adjustment
																					   ,@p_purchase_price = @purchase
																					   ,@p_orig_amount = @adjustment_amount
																					   ,@p_type = 'NOT ASSET'
																					   ,@p_posting_date = null
																					   ,@p_return_date = @date
																					   ,@p_invoice_date_type = 'RETURN'
																					   ,@p_invoice_code = @p_code
																						--
																					   ,@p_cre_date = @p_mod_date
																					   ,@p_cre_by = @p_mod_by
																					   ,@p_cre_ip_address = @p_mod_ip_address
																					   ,@p_mod_date = @p_mod_date
																					   ,@p_mod_by = @p_mod_by
																					   ,@p_mod_ip_address = @p_mod_ip_address ;
											end ;

											fetch next from curr_adj
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

										close curr_adj ;
										deallocate curr_adj ;

										fetch next from curr_diff_amount
										into @id_detail
											 ,@id_grn ;
									end ;

									close curr_diff_amount ;
									deallocate curr_diff_amount ;
								end ;
							end ;
						end ;

					--    fetch next from curr_category_type 
					--	into @category_type
					--		,@item_group_code
					--end

					--	close curr_category_type
					--	deallocate curr_category_type
					end ;

					fetch next from curr_rev_final
					into @temp_final_code ;
				--,@asset_code
				end ;

				close curr_rev_final ;
				deallocate curr_rev_final ;

				fetch next from curr_rev_jour
				into @temp_grn_code ;
			--,@grn_detail_id
			end ;

			close curr_rev_jour ;
			deallocate curr_rev_jour ;

			declare curr_return_invoice cursor fast_forward read_only for
			select	aird.grn_code
			from	dbo.ap_invoice_registration					  air
					inner join dbo.ap_invoice_registration_detail aird on (air.code = aird.invoice_register_code)
			where	code = @p_code ;

			open curr_return_invoice ;

			fetch next from curr_return_invoice
			into @grn_code ;

			while @@fetch_status = 0
			begin
				update	dbo.good_receipt_note
				set		reff_no = ''
						--
						,mod_date = @p_mod_date
						,mod_by = @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code = @grn_code ;

				fetch next from curr_return_invoice
				into @grn_code ;
			end ;

			close curr_return_invoice ;
			deallocate curr_return_invoice ;

			update	dbo.ap_invoice_registration
			set		status = 'CANCEL'
					--
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;

			--update nilai GRN yang baru
			declare curr_update_grn cursor fast_forward read_only for
			select	ard.id
					,grnd.id
			from	dbo.ap_invoice_registration_detail		ard
					inner join dbo.ap_invoice_registration	air on ard.invoice_register_code		  = air.code
					inner join dbo.good_receipt_note_detail grnd on grnd.good_receipt_note_code		  = ard.grn_code
																	and grnd.receive_quantity		  <> 0
																	and grnd.purchase_order_detail_id = ard.purchase_order_id
			where	air.code = @p_code ;

			open curr_update_grn ;

			fetch next from curr_update_grn
			into @id_detail
				 ,@id_grn ;

			while @@fetch_status = 0
			begin
				select	@amount_invoice = orig_price_amount
						,@ppn			= orig_ppn_amount
						,@pph			= orig_pph_amount
						,@discount		= orig_discount_amount
						,@total_amount	= orig_total_amount
				from	dbo.good_receipt_note_detail
				where	id = @id_grn ;

				update	dbo.good_receipt_note_detail
				set		price_amount = @amount_invoice
						,ppn_amount = @ppn
						,pph_amount = @pph
						,discount_amount = @discount
						,total_amount = @total_amount
				where	id = @id_grn ;

				fetch next from curr_update_grn
				into @id_detail
					 ,@id_grn ;
			end ;

			close curr_update_grn ;
			deallocate curr_update_grn ;
		end ;
		else
		begin
			set @msg = N'Cannot return this data, data already proceed.' ;

			raiserror(@msg, 16, 1) ;
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

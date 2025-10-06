CREATE PROCEDURE dbo.xsp_ap_payment_request_post_mtn
(
	@p_code			   NVARCHAR(50)
	--
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	declare @msg								nvarchar(max)
			,@code								nvarchar(50)
			,@invoice_date						datetime
			,@currency_code						nvarchar(50)
			,@supplier_code						nvarchar(50)
			,@invoice_amount					decimal(18, 2)
			,@ppn								decimal(18, 2)
			,@pph								decimal(18, 2)
			,@fee								decimal(18, 2)
			,@discount							decimal(18, 2)
			,@due_date							datetime
			,@tax_invoice_date					datetime
			,@purchase_order_code				nvarchar(50)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@to_bank_code						nvarchar(50)
			,@to_bank_account_name				nvarchar(250)
			,@to_bank_account_no				nvarchar(50)
			,@payment_by						nvarchar(25)
			,@status							nvarchar(25)
			,@remark							nvarchar(4000)
			,@interface_code					nvarchar(50)
			,@supplier_name						nvarchar(250)
			,@remarks							nvarchar(4000)
			,@to_bank_name						nvarchar(250)
			,@sp_name							nvarchar(250)
			,@debet_or_credit					nvarchar(10)
			,@gl_link_code						nvarchar(50)
			,@transaction_name					nvarchar(250)
			,@gl_link_transaction_code			nvarchar(50)
			,@orig_amount_cr					decimal(18, 2)
			,@orig_amount_db					decimal(18, 2)
			,@return_value						decimal(18, 2)
			,@payment_request_detail_id			bigint
			,@invoice_register_code				nvarchar(50)
			,@division_code						nvarchar(50)
			,@division_name						nvarchar(250)
			,@department_code					nvarchar(50)
			,@department_name					nvarchar(250)
			,@header_amount						decimal(18,2)
			,@detail_amount						decimal(18,2)
			,@branch_code_request				nvarchar(50)
			,@branch_name_request				nvarchar(250)
			,@asset_code						nvarchar(50)
			,@proc_type							nvarchar(50)
			,@branch_code_mobilisasi			nvarchar(50)
			,@branch_name_mobilisasi			nvarchar(250)
			,@to_province_code_mobilisasi		nvarchar(50)
			,@to_province_name_mobilisasi		nvarchar(250)
			,@to_city_code_mobilisasi			nvarchar(50)
			,@to_city_name_mobilisasi			nvarchar(250)
			,@to_area_phone_no_mobilisasi		nvarchar(4)
			,@to_phone_no_mobilisasi			nvarchar(15)
			,@to_address_mobilisasi				nvarchar(4000)
			,@eta_date_mobilisasi				datetime
			,@fa_code_mobilisasi				nvarchar(50)
			,@fa_name_mobilisasi				nvarchar(250)
			,@requestor_name_mobilisasi			nvarchar(50)
			,@is_reimburse_mobilisasi			nvarchar(1)
			,@code_final						nvarchar(50)
			,@code_grn							nvarchar(50)
			,@agreement_no						nvarchar(50)
			,@asset_no							nvarchar(50)
			,@client_no							nvarchar(50)
			,@client_name						nvarchar(250)
			,@date								datetime		= dbo.xfn_get_system_date()
			,@asset_expense_remark				nvarchar(250)
			,@proc_req_code						nvarchar(50)
			,@price_amount						decimal(18,2)
			,@description_mobilisasi			nvarchar(4000)
			,@from_city_name					nvarchar(250)
			,@additional_amount					decimal(18,2)
			,@original_price					decimal(18,2)
			,@discount_amount					decimal(18,2)
			,@recive_quantity					int
			,@invoice_name						nvarchar(250)
			,@plat_no							nvarchar(50)
			,@code_asset						nvarchar(50)
			,@asset_name						nvarchar(250)
			,@name_asset						nvarchar(250)
			,@code_asset_for_expense			nvarchar(50)
			,@id_grn_detail						INT
            ,@podoi_id							int

	begin try
		if exists
		(
			select	1
			from	dbo.ap_payment_request
			where	code	   = @p_code
					and status = 'ON PROCESS'
		)
		begin
			select	@invoice_date			= apr.invoice_date
					,@currency_code			= apr.currency_code
					,@supplier_code			= apr.supplier_code
					,@supplier_name			= apr.supplier_name
					,@ppn					= apr.ppn
					,@pph					= apr.pph
					,@fee					= apr.fee
					,@discount				= apr.discount
					,@due_date				= apr.due_date
					,@tax_invoice_date		= apr.tax_invoice_date
					,@purchase_order_code	= apr.purchase_order_code
					,@branch_code			= apr.branch_code
					,@branch_name			= apr.branch_name
					,@to_bank_code			= apr.to_bank_code
					,@to_bank_account_name	= apr.to_bank_account_name
					,@to_bank_account_no	= apr.to_bank_account_no
					,@payment_by			= apr.payment_by
					,@status				= apr.status
					,@remark				= apr.remark
					,@to_bank_name			= apr.to_bank_name
			from	dbo.ap_payment_request apr
			where	apr.code = @p_code ;

			select @invoice_amount = apr.invoice_amount
			from dbo.ap_payment_request apr
			where apr.code = @p_code

			set @remarks = 'INVOICE ' + ' to ' + @supplier_name + '. ' + @remark

			exec dbo.xsp_ifinproc_interface_payment_request_insert @p_code						= @interface_code output
																   ,@p_branch_code				= @branch_code
																   ,@p_branch_name				= @branch_name
																   ,@p_payment_source			= 'PROCUREMENT INVOICE PAYMENT'
																   ,@p_payment_request_date		= @p_mod_date
																   ,@p_payment_source_no		= @p_code
																   ,@p_payment_currency_code	= @currency_code
																   ,@p_payment_status			= 'HOLD'
																   ,@p_payment_amount			= @invoice_amount
																   ,@p_payment_to				= @supplier_name
																   ,@p_payment_remarks			= @remarks
																   ,@p_to_bank_account_name		= @to_bank_account_name
																   ,@p_to_bank_name				= @to_bank_name
																   ,@p_to_bank_account_no		= @to_bank_account_no
																   ,@p_process_date				= null
																   ,@p_process_reff_no			= null
																   ,@p_process_reff_name		= null
																   ,@p_tax_payer_reff_code		= null
																   ,@p_tax_type					= null
																   ,@p_tax_file_no				= null
																   ,@p_tax_file_name			= null
																   ,@p_settle_date				= null
																   ,@p_job_status				= 'HOLD'
																   ,@p_failed_remarks			= ''
																   ,@p_cre_date					= @p_mod_date	  
																   ,@p_cre_by					= @p_mod_by		  
																   ,@p_cre_ip_address			= @p_mod_ip_address
																   ,@p_mod_date					= @p_mod_date	  
																   ,@p_mod_by					= @p_mod_by		  
																   ,@p_mod_ip_address			= @p_mod_ip_address

			declare cursor_name cursor fast_forward read_only for
			select	distinct
					mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
					,ird.id
					,invr.division_code
					,invr.division_name
					,invr.department_code
					,invr.department_name
					,pr.branch_code
					,pr.branch_name
					,podoi.asset_code
					,podoi.id
			from	dbo.master_transaction_parameter			 mtp
					left join dbo.sys_general_subcode			 sgs on (sgs.code = mtp.process_code)
					left join dbo.master_transaction			 mt on (mt.code = mtp.transaction_code)
					inner join dbo.ap_payment_request_detail	 ard on (ard.payment_request_code = @p_code)
					left join dbo.ap_invoice_registration		 invr on (invr.code collate sql_latin1_general_cp1_ci_as = ard.invoice_register_code)
					left join dbo.ap_invoice_registration_detail ird on (ird.invoice_register_code = invr.code)
					inner join dbo.good_receipt_note			 grn on grn.code = ird.grn_code
					outer apply
			(
				select	top 1
						detail.id
				from	dbo.good_receipt_note_detail detail
				where	detail.good_receipt_note_code = grn.code
			)													 detailgrn
					left join dbo.purchase_order_detail				pod on (ird.purchase_order_id						 = pod.id)
					left join dbo.purchase_order_detail_object_info podoi on (
																				 pod.id									 = podoi.purchase_order_detail_id
																				 --and   podoi.good_receipt_note_detail_id = detailgrn.id --(13052025) ini sebelumnya di comment, sepria buka comment ini karena bikin double detail yang belum di GRN juga ikut terjurnal
																			 )
					left join dbo.supplier_selection_detail			ssd on (ssd.id										 = pod.supplier_selection_detail_id)
					left join dbo.quotation_review_detail			qrd on (qrd.id										 = ssd.quotation_detail_id)
					inner join dbo.procurement						prc on (prc.code collate Latin1_General_CI_AS		 = isnull(qrd.reff_no, ssd.reff_no))
					inner join dbo.procurement_request				pr on (pr.code										 = prc.procurement_request_code)
			where	mtp.process_code = 'SGS230700001' ;
			--and		isnull(podoi.asset_code,'') <> '' -- (+) Ari 2023-12-27 ket : takeout null
			
			open cursor_name
			
			fetch next from cursor_name 
			into @sp_name
				,@debet_or_credit
				,@gl_link_code
				,@transaction_name
				,@payment_request_detail_id
				,@division_code
				,@division_name
				,@department_code
				,@department_name
				,@branch_code_request
				,@branch_name_request
				,@asset_code
				,@podoi_id
			
			while @@fetch_status = 0
			begin
			    exec @return_value = @sp_name @payment_request_detail_id; -- sp ini mereturn value angka 
				
				if (@debet_or_credit ='DEBIT')
				begin
					set @orig_amount_db = @return_value
				end
				else
				begin
					set @orig_amount_db = @return_value * -1
				end
				
				exec dbo.xsp_ifinproc_interface_payment_request_detail_insert @p_id								= 0
																			  ,@p_payment_request_code			= @interface_code
																			  ,@p_branch_code					= @branch_code_request
																			  ,@p_branch_name					= @branch_name_request
																			  ,@p_gl_link_code					= @gl_link_code
																			  ,@p_agreement_no					= @asset_code
																			  ,@p_facility_code					= ''
																			  ,@p_facility_name					= ''
																			  ,@p_purpose_loan_code				= ''
																			  ,@p_purpose_loan_name				= ''
																			  ,@p_purpose_loan_detail_code		= ''
																			  ,@p_purpose_loan_detail_name		= ''
																			  ,@p_orig_currency_code			= @currency_code
																			  ,@p_orig_amount					= @orig_amount_db
																			  ,@p_division_code					= @division_code
																			  ,@p_division_name					= @division_name
																			  ,@p_department_code				= @department_code
																			  ,@p_department_name				= @department_name
																			  ,@p_remarks						= @remarks
																			  ,@p_is_taxable					= '0'
																			  ,@p_cre_date						= @p_mod_date	  
																			  ,@p_cre_by						= @p_mod_by		  
																			  ,@p_cre_ip_address				= @p_mod_ip_address
																			  ,@p_mod_date						= @p_mod_date	  
																			  ,@p_mod_by						= @p_mod_by		  
																			  ,@p_mod_ip_address				= @p_mod_ip_address
				
			
			    fetch next from cursor_name 
				into @sp_name
					,@debet_or_credit
					,@gl_link_code
					,@transaction_name
					,@payment_request_detail_id
					,@division_code
					,@division_name
					,@department_code
					,@department_name
					,@branch_code_request
					,@branch_name_request
					,@asset_code
					,@podoi_id
			end
			
			close cursor_name
			deallocate cursor_name

			--validasi payment
			if	(isnull(@interface_code,'') <> '')
			begin
				select @header_amount = ISNULL(payment_amount,0)
				from	dbo.ifinproc_interface_payment_request
				where	code = @interface_code

				select @detail_amount = ISNULL(sum(orig_amount),0)
				from	dbo.ifinproc_interface_payment_request_detail
				where	payment_request_code = @interface_code

				--+ validasi : total detail =  payment_amount yang di header
				if (@header_amount <> @detail_amount)			
				begin
					set @msg = 'Payment does not balance';
    				raiserror(@msg, 16, -1) ;
				end
			end


			declare curr_code_grn cursor fast_forward read_only for
			select	distinct
					--grnd.good_receipt_note_code
					grnd.id
			from	dbo.ap_payment_request						  apr
					inner join dbo.ap_payment_request_detail	  aprd on apr.code					  = aprd.payment_request_code
					inner join dbo.ap_invoice_registration_detail aird on aird.invoice_register_code  = aprd.invoice_register_code
					inner join dbo.good_receipt_note_detail		  grnd on grnd.good_receipt_note_code = aird.grn_code
			where	apr.code = @p_code
			and grnd.receive_quantity <> 0

			open curr_code_grn
			
			fetch next from curr_code_grn 
			into @id_grn_detail
			
			while @@fetch_status = 0
			begin
			    declare curr_code_grn_final cursor fast_forward read_only for
				--select	distinct
				--		fgrnd.final_good_receipt_note_code
				--from	dbo.good_receipt_note_detail				  grnd
				--		inner join dbo.final_good_receipt_note_detail fgrnd on grnd.id = fgrnd.good_receipt_note_detail_id
				--where	grnd.good_receipt_note_code = @code_grn ;

				select	final_good_receipt_note_code
				from	dbo.final_good_receipt_note_detail
				where	good_receipt_note_detail_id = @id_grn_detail ;
			
				open curr_code_grn_final
			
				fetch next from curr_code_grn_final 
				into @code_final
				
			
				while @@fetch_status = 0
				begin
					select	@proc_type = pr.procurement_type
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
							left join dbo.procurement						prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no,ssd.reff_no))
							left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
					where	fgrn.code				  = @code_final
							and grnd.receive_quantity <> 0 ;
					
					if(@proc_type = 'MOBILISASI')
					begin
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
								,pr.code
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
						where	--grnd.good_receipt_note_code = @code_grn
								grnd.id = @id_grn_detail
								and grnd.receive_quantity	<> 0 ;
				
						open curr_mobilisasi
				
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
							,@from_city_name
							,@proc_req_code
				
						while @@fetch_status = 0
						begin
						
						--select @recive_quantity		= aird.quantity
						--		,@additional_amount = aird.purchase_amount - aprd.discount
						--from dbo.ap_payment_request_detail aprd
						--inner join dbo.ap_invoice_registration_detail aird on aird.invoice_register_code = aprd.invoice_register_code
						--where aprd.payment_request_code = @p_code

						select	@additional_amount = price_amount - discount_amount
								,@recive_quantity	= receive_quantity
						from	dbo.good_receipt_note_detail
						where	id = @id_grn_detail ;

					    if(@is_reimburse_mobilisasi = '0')
						begin
								select	@agreement_no	= agreement_no
										,@client_name	= client_name
								from	ifinams.dbo.asset
								where	code = @fa_code_mobilisasi ;

								set @asset_expense_remark = 'Mobilisasi Asset ' + isnull(@fa_code_mobilisasi,'') + ' ' + isnull(@fa_name_mobilisasi,'');
								exec dbo.xsp_ifinproc_interface_asset_expense_ledger_insert @p_id					= 0
																							,@p_asset_code			= @fa_code_mobilisasi
																							,@p_date				= @date
																							,@p_reff_code			= @proc_req_code
																							,@p_reff_name			= 'PROCUREMENT MOBILISASI'
																							,@p_reff_remark			= @asset_expense_remark
																							,@p_expense_amount		= @additional_amount
																							,@p_agreement_no		= @agreement_no
																							,@p_client_name			= @client_name
																							,@p_settle_date			= null
																							,@p_job_status			= 'HOLD'
																							,@p_cre_date			= @p_mod_date
																							,@p_cre_by				= @p_mod_by
																							,@p_cre_ip_address		= @p_mod_ip_address
																							,@p_mod_date			= @p_mod_date
																							,@p_mod_by				= @p_mod_by
																							,@p_mod_ip_address		= @p_mod_ip_address
						
						end
						else
						begin
								select	@agreement_no	= agreement_no
										,@asset_no		= asset_no
										,@client_no		= client_no
										,@client_name	= client_name
										,@plat_no		= avh.plat_no
								from	ifinams.dbo.asset ass
								inner join ifinams.dbo.asset_vehicle avh on avh.asset_code = ass.code
								where	code = @fa_code_mobilisasi ;
								
								set @invoice_name = 'Mobilisasi Asset ' + @agreement_no + ' ' + @plat_no
								set @description_mobilisasi = 'Mobilisasi Asset ' + @fa_code_mobilisasi + ' - ' + @fa_name_mobilisasi + '. From ' + @from_city_name + '. To ' + @to_city_name_mobilisasi
								exec dbo.xsp_ifinproc_interface_additional_invoice_request_insert @p_id							= 0
																								  ,@p_agreement_no				= @agreement_no
																								  ,@p_asset_no					= @asset_no
																								  ,@p_branch_code				= @branch_code_mobilisasi
																								  ,@p_branch_name				= @branch_name_mobilisasi
																								  ,@p_invoice_type				= 'MBLS'
																								  ,@p_invoice_date				= @date
																								  ,@p_invoice_name				= @invoice_name
																								  ,@p_client_no					= @client_no
																								  ,@p_client_name				= @client_name
																								  ,@p_client_address			= ''
																								  ,@p_client_area_phone_no		= ''
																								  ,@p_client_phone_no			= ''
																								  ,@p_client_npwp				= ''
																								  ,@p_currency_code				= 'IDR'
																								  ,@p_tax_scheme_code			= ''
																								  ,@p_tax_scheme_name			= ''
																								  ,@p_billing_no				= 0
																								  ,@p_description				= @description_mobilisasi
																								  ,@p_quantity					= @recive_quantity
																								  ,@p_billing_amount			= @additional_amount
																								  ,@p_discount_amount			= 0
																								  ,@p_ppn_pct					= 0
																								  ,@p_ppn_amount				= 0
																								  ,@p_pph_pct					= 0
																								  ,@p_pph_amount				= 0
																								  ,@p_total_amount				= @additional_amount
																								  ,@p_reff_code					= @p_code
																								  ,@p_reff_name					= 'MOBILISASI ASSET'
																								  ,@p_settle_date				= null
																								  ,@p_job_status				= 'HOLD'
																								  ,@p_failed_remarks			= ''
																								  ,@p_cre_date					= @p_mod_date
																								  ,@p_cre_by					= @p_mod_by
																								  ,@p_cre_ip_address			= @p_mod_ip_address
																								  ,@p_mod_date					= @p_mod_date
																								  ,@p_mod_by					= @p_mod_by
																								  ,@p_mod_ip_address			= @p_mod_ip_address								
						end
					
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
							,@from_city_name
							,@proc_req_code
					end
					
						close curr_mobilisasi
						deallocate curr_mobilisasi
					end
					else if(@proc_type = 'EXPENSE')
					begin
						declare curr_expense cursor fast_forward read_only for
						select	pri.fa_code
								,pri.fa_name
								,pr.code
								,grnd.item_name
								,pr.asset_no
						from	dbo.good_receipt_note_detail			 grnd
								inner join dbo.good_receipt_note		 grn on (grn.code							   = grnd.good_receipt_note_code)
								inner join dbo.purchase_order			 po on (po.code								   = grn.purchase_order_code)
								inner join dbo.purchase_order_detail	 pod on (
																					pod.po_code						   = po.code
																					and pod.id						   = grnd.purchase_order_detail_id
																				)
								left join dbo.supplier_selection_detail ssd on (ssd.id								   = pod.supplier_selection_detail_id)
								left join dbo.quotation_review_detail	 qrd on (qrd.id								   = ssd.quotation_detail_id)
								inner join dbo.procurement				 prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
								inner join dbo.procurement_request		 pr on (pr.code								   = prc.procurement_request_code)
								inner join dbo.procurement_request_item	 pri on (
																					pri.procurement_request_code	   = pr.code
																					and pri.item_code				   = grnd.item_code
																				)
						where	--grnd.good_receipt_note_code = @code_grn
								grnd.id = @id_grn_detail
								and grnd.receive_quantity	<> 0 ;
					
						open curr_expense
						
						fetch next from curr_expense 
						into @fa_code_mobilisasi
							,@fa_name_mobilisasi
							,@proc_req_code
							,@name_asset
							,@asset_no
					
						while @@fetch_status = 0
						begin
							select	@asset_code = podo.asset_code
							from	dbo.final_good_receipt_note						fgrn
									left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code = fgrn.code)
									left join dbo.good_receipt_note_detail			grnd on (grnd.id							 = fgrnd.good_receipt_note_detail_id)
									left join dbo.good_receipt_note					grn on (grn.code							 = grnd.good_receipt_note_code)
									left join dbo.purchase_order					po on (po.code								 = grn.purchase_order_code)
									left join dbo.purchase_order_detail				pod on (
																							   pod.po_code						 = po.code
																							   and pod.id						 = grnd.purchase_order_detail_id
																						   )
									left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	 = grnd.id)
									left join ifinbam.dbo.master_item mi on mi.code = fgrnd.item_code
							where	fgrn.reff_no = @asset_no
							and mi.category_type = 'ASSET'
							and fgrn.status = 'POST'

							set @code_asset = isnull(@fa_code_mobilisasi, @asset_code)
							set @asset_name = isnull(@fa_name_mobilisasi, @name_asset)

							select	@agreement_no	= agreement_no
									,@client_name	= client_name
							from	ifinams.dbo.asset
							where	code = @code_asset ;

							--select	@additional_amount = aird.purchase_amount - aprd.discount
							--from	dbo.ap_payment_request_detail				  aprd
							--		inner join dbo.ap_invoice_registration_detail aird on aird.invoice_register_code = aprd.invoice_register_code
							--where	aprd.payment_request_code = @p_code ;

							select	@additional_amount = price_amount - discount_amount
							from	dbo.good_receipt_note_detail
							where	id = @id_grn_detail ;


							set @asset_expense_remark = 'Expense Asset ' + isnull(@code_asset,'') + ' ' + isnull(@asset_name,'');

							exec dbo.xsp_ifinproc_interface_asset_expense_ledger_insert @p_id					= 0
																						,@p_asset_code			= @code_asset
																						,@p_date				= @date
																						,@p_reff_code			= @proc_req_code
																						,@p_reff_name			= 'PROCUREMENT EXPENSE'
																						,@p_reff_remark			= @asset_expense_remark
																						,@p_expense_amount		= @additional_amount
																						,@p_agreement_no		= @agreement_no
																						,@p_client_name			= @client_name
																						,@p_settle_date			= null
																						,@p_job_status			= 'HOLD'
																						,@p_cre_date			= @p_mod_date
																						,@p_cre_by				= @p_mod_by
																						,@p_cre_ip_address		= @p_mod_ip_address
																						,@p_mod_date			= @p_mod_date
																						,@p_mod_by				= @p_mod_by
																						,@p_mod_ip_address		= @p_mod_ip_address
					
					    fetch next from curr_expense 
						into @fa_code_mobilisasi
							,@fa_name_mobilisasi
							,@proc_req_code
							,@name_asset
							,@asset_no
					end
						
						close curr_expense
						deallocate curr_expense
					end
			
					fetch next from curr_code_grn_final
					into @code_final
				end
			
				close curr_code_grn_final
				deallocate curr_code_grn_final
			
			    fetch next from curr_code_grn 
				into @id_grn_detail
			end
			
			close curr_code_grn
			deallocate curr_code_grn

			update	dbo.ap_payment_request
			set		status				= 'APPROVE'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;
		end ;
		else
		begin
			set @msg = 'Data already process' ;

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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_ap_payment_request_post_mtn] TO [ims-raffyanda]
    AS [dbo];


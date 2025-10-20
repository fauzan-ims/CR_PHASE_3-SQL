-- Stored Procedure


CREATE PROCEDURE dbo.xsp_ap_invoice_registration_post
(
	@p_code			   nvarchar(50)
	,@p_company_code   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@invoice_detail_id					bigint
			,@purchase_order_id					bigint
			,@invoice_register_code				nvarchar(50)
			,@grn_code							nvarchar(50)
			,@sp_name							nvarchar(250)
			,@debet_or_credit					nvarchar(10)
			,@gl_link_code						nvarchar(50)
			,@transaction_name					nvarchar(250)
			,@gl_link_transaction_code			nvarchar(50)
			,@orig_amount_cr					decimal(18, 2)
			,@orig_amount_db					decimal(18, 2)
			,@return_value						decimal(18, 2)
			,@remarks_journal					nvarchar(4000)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@purchase_order_code				nvarchar(50)
			,@vendor_code						nvarchar(50)
			,@vendor_name						nvarchar(250)
			,@vendor_address					nvarchar(4000)
			,@invoice_id						bigint
			,@unit_from							nvarchar(25)
			,@item_code							nvarchar(50)
			,@transaction_code					nvarchar(50)
			,@item_category_code				nvarchar(50)
			,@item_name							nvarchar(50)
			,@item_group_code					nvarchar(50)
			,@faktur_no							nvarchar(50)
			,@ppn								decimal(18,2)
			,@income_type						nvarchar(250)
			,@income_bruto_amount				decimal(18,2)
			,@tax_rate							decimal(5,2)
			,@ppn_pph_amount					decimal(18,2)
			,@ppn_pct							decimal(9,6)
			,@pph_pct							decimal(9,6)
			,@vendor_type						nvarchar(25)
			,@pph_type							nvarchar(20)
			,@total_amount						decimal(18,2)
			,@remarks_tax						nvarchar(4000)
			,@vendor_npwp						nvarchar(20)
			,@procurement_type					nvarchar(50)
			,@journal_date						datetime = dbo.xfn_get_system_date()
			,@asset_code						nvarchar(50)
			,@id								int
            ,@po_code							nvarchar(50)
			,@code_jrn							nvarchar(50)
			,@file_invoice_no					nvarchar(50) -- (+) Ari 2024-01-22
			,@receive_quantity					int
			,@count								int
            ,@category_type						nvarchar(50)
			,@good_receipt_note_code			nvarchar(50)
			,@asset_no							nvarchar(50)
			,@id_fgrnr_asset					int
            ,@recive_quantity					decimal(18,2)
			,@uom_name							nvarchar(250)
			,@item_name_for_jrnl				nvarchar(250)
			,@po_no								nvarchar(50)
			------
			,@code							  nvarchar(50)
			,@division_code					  nvarchar(50)
			,@division_name					  nvarchar(250)
			,@department_code				  nvarchar(50)
			,@department_name				  nvarchar(250)
			,@po_quantity					  decimal(18, 2)
			,@purchase_date					  datetime		= dbo.xfn_get_system_date()
			,@purchase_price				  decimal(18, 2)
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
			,@grn_id						  bigint
			,@plat_no						  nvarchar(50)
			,@engine_no						  nvarchar(50)
			,@chassis_no					  nvarchar(50)
			,@category_desc					  nvarchar(250)
			,@item_code_for_jrnl			  nvarchar(50)
			,@sum_order_remaining			  int
			,@is_rent						  nvarchar(25)
			,@branch_code_header			  nvarchar(50)
			,@branch_name_header			  nvarchar(250)
			,@opl_code						  nvarchar(50)
			,@asset_purpose					  nvarchar(50)
			,@spesification					  nvarchar(4000)
			,@serial_no						  nvarchar(50)
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
			,@item_name_for_journal			  nvarchar(250)
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
			--
			,@final_grn_code					nvarchar(50)
			,@application_no					nvarchar(50)
			,@grn_detail_id						bigint
            ,@intransit_pembalik				nvarchar(1)='0'
			,@p_final_grn_code					nvarchar(50)
			,@fgrn_detail_id					bigint
            ,@id_inv_lain						bigint
            ,@podoi_id							bigint
            ,@id_intransitinst_balik			bigint
            ,@po_object_id						bigint

	begin try
		if exists (select 1 from dbo.ap_invoice_registration where code = @p_code and status <> 'ON PROCESS')
		begin
			set @msg = 'Invoice already post' ;
			raiserror(@msg, 16, 1) ;
        end

		declare c_invoice_register_detail cursor for
		select	id
				,purchase_order_id
				,invoice_register_code
				,grn_code
				,grn_detail_id
		from	dbo.ap_invoice_registration_detail
		where	invoice_register_code = @p_code ;

		open c_invoice_register_detail ;

		fetch c_invoice_register_detail
		into @invoice_detail_id
			 ,@purchase_order_id
			 ,@invoice_register_code
			 ,@grn_code
			 ,@grn_detail_id

		while @@fetch_status = 0
		begin
			update	dbo.purchase_order_detail
			set		invoice_no				= @invoice_register_code
					,invoice_detail_id		= @invoice_detail_id
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	id						= @purchase_order_id ;

			--update ke grn detail juga
			update dbo.good_receipt_note_detail
			set		invoice_detail_id		= @invoice_detail_id
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	id = @grn_detail_id

			update	dbo.good_receipt_note
			set		reff_no = @p_code
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code = @grn_code

			fetch c_invoice_register_detail
			into @invoice_detail_id
				 ,@purchase_order_id
				 ,@invoice_register_code
				 ,@grn_code 
				 ,@grn_detail_id
		end ;

		close c_invoice_register_detail ;
		deallocate c_invoice_register_detail ;


		update	dbo.ap_invoice_registration
		set		status			= 'APPROVE'
				,mod_date		= @p_mod_date		
				,mod_by			= @p_mod_by			
				,mod_ip_address = @p_mod_ip_address
		where	code	= @p_code ;



		----sepria final cr priority, asset terbentuk saat final. invoice di bayar atau tidak gk ngaruh. hanya ngaruh ke depre schedule saja (sepria, jadikan asset/adjust asset di 1 sp)
		--declare curr_invoice_branch_request cursor fast_forward read_only for
		--select	distinct fgrd.final_good_receipt_note_code, fgrd.po_object_id
		--from	dbo.ap_invoice_registration_detail invd
		--		inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
		--		inner join dbo.final_good_receipt_note_detail fgrd on fgrd.po_object_id = invdf.purchase_order_detail_object_info_id
		--		inner join dbo.final_grn_request_detail fgrnd on convert(nvarchar(50),fgrnd.id) = fgrd.reff_no
		--where	invd.invoice_register_code =  @p_code
		--and		fgrnd.status = 'POST'


		--open curr_invoice_branch_request

		--fetch next from curr_invoice_branch_request 

		--into	@p_final_grn_code, @po_object_id

		--while @@fetch_status = 0
		--begin

		--		exec dbo.xsp_xsp_ap_invoice_registration_post_to_asset @p_code = @p_code,                       -- nvarchar(50)
		--																@p_final_grn_code = @p_final_grn_code,
		--															   @p_company_code = @p_company_code,               -- nvarchar(50)
		--															   @p_mod_date = @p_mod_date, -- datetime
		--															   @p_mod_by = @p_mod_by,                     -- nvarchar(15)
		--															   @p_mod_ip_address = @p_mod_ip_address              -- nvarchar(15)
		--																,@p_po_object_id	= @po_object_id


		--fetch next from curr_invoice_branch_request 
		--into	@p_final_grn_code, @po_object_id

		--end ;

		--close curr_invoice_branch_request ;
		--deallocate curr_invoice_branch_request ;

		-- Pembentukan Journal Invoice Register
		begin
		select	@purchase_order_code	= purchase_order_code
				,@vendor_name			= supplier_name
		from dbo.ap_invoice_registration
		where code = @p_code

		select	@unit_from = unit_from
		from	dbo.purchase_order
		where	code = @purchase_order_code

		select @branch_code		= value
				,@branch_name	= description
		from dbo.sys_global_param
		where code = 'HO'

		declare curr_invoice_branch_request cursor fast_forward read_only for
		select		pr.branch_code
					--,pr.branch_name
					,sb.name
		from		dbo.ap_invoice_registration_detail				aird
					left join dbo.good_receipt_note					grn on (grn.code							  = aird.grn_code)
					inner join dbo.good_receipt_note_detail			grnd on (grnd.good_receipt_note_code		  = grn.code)
					left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
					left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
					left join dbo.purchase_order_detail				pod on (
																			   --pod.po_code						  = po.code
																			   --and pod.id						  = grnd.purchase_order_detail_id
																			   aird.PURCHASE_ORDER_ID						  = pod.id
																		   )
					left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
					left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
					inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
					inner join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
					inner join ifinsys.dbo.sys_branch sb on (sb.code = pr.branch_code)
		where		aird.invoice_register_code = @p_code
		group by	pr.branch_code
					,sb.name
					--,pr.branch_name ;

		open curr_invoice_branch_request

		fetch next from curr_invoice_branch_request 
		into @branch_code
			,@branch_name

		while @@fetch_status = 0
		begin
		    set @transaction_name = 'Invoice Register ' + @p_code + ' From PO ' + @purchase_order_code + '.' + ' Vendor ' + @vendor_name
			exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_insert @p_code						= @gl_link_transaction_code output
																			   ,@p_company_code				= 'DSF'
																			   ,@p_branch_code				= @branch_code
																			   ,@p_branch_name				= @branch_name
																			   ,@p_transaction_status		= 'HOLD'
																			   ,@p_transaction_date			= @journal_date
																			   ,@p_transaction_value_date	= @journal_date
																			   ,@p_transaction_code			= 'INRGST'
																			   ,@p_transaction_name			= 'Invoice Register'
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
																			   ,@p_mod_ip_address			= @p_mod_ip_address





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
						,grnd.master_tax_ppn_pct	--pod.ppn_pct
						,grnd.master_tax_pph_pct	--pod.pph_pct
						,(ird.purchase_amount - ird.discount) * ird.quantity
						,ssd.supplier_code
						,ssd.supplier_name
						,ssd.supplier_address
						,ssd.supplier_npwp
						--,airdk.faktur_no
						,pr.procurement_type
						--,podoi.asset_code
						,ird.purchase_order_id
						,po.code
						,air.file_invoice_no		-- (+) Ari 2024-01-22 ket : get file invoice no jika faktur kosong
						,ird.quantity
						,pri.category_type
						,grnd.good_receipt_note_code
						,pr.asset_no
						,isnull(podoi.asset_code,pri.fa_code)
						,grnd.receive_quantity
						,grnd.uom_name
						,grnd.item_name
						,grn.purchase_order_code
						,grnd.fgrn_detail_id
						,podoi.id
			from		dbo.master_transaction_parameter					mtp
						left join dbo.sys_general_subcode					sgs on (sgs.code											  = mtp.process_code)
						left join dbo.master_transaction					mt on (mt.code												  = mtp.transaction_code)
						left join dbo.ap_invoice_registration_detail		ird on (ird.invoice_register_code							  = @p_code)
						inner join dbo.ap_invoice_registration				air on (air.code											  = ird.invoice_register_code)
						inner join dbo.ap_invoice_registration_detail_faktur	airf on (airf.invoice_registration_detail_id			  = ird.id)
						inner join dbo.good_receipt_note					grn on grn.code												  = ird.grn_code
						left join dbo.purchase_order						po on (po.code												  = grn.purchase_order_code)
						left join dbo.purchase_order_detail					pod on (ird.purchase_order_id								  = pod.id)
						left join dbo.good_receipt_note_detail				grnd on (
																						grnd.good_receipt_note_code						  = grn.code
																						and grnd.receive_quantity						  <> 0
																						and grnd.id = ird.grn_detail_id
																					)
						left join dbo.purchase_order_detail_object_info podoi on (
																				podoi.purchase_order_detail_id	  = pod.id
																				and   grnd.id					  = podoi.good_receipt_note_detail_id
																				and	podoi.id						= airf.purchase_order_detail_object_info_id
																			)
						left join dbo.supplier_selection_detail				ssd on (ssd.id												  = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail				qrd on (qrd.id												  = ssd.quotation_detail_id)
						inner join dbo.procurement							prc on (prc.code collate latin1_general_ci_as				  = isnull(qrd.reff_no, ssd.reff_no))
						inner join dbo.procurement_request					pr on (pr.code												  = prc.procurement_request_code)
						inner join dbo.procurement_request_item				pri on (pr.code = pri.procurement_request_code AND pri.item_code				  = grnd.item_code)
			where		mtp.process_code   =  'SGS230600004'-- S250100001(INI CASE 1&4) --'SGS230600004'(INI YG LAMA)
			--'S250600001' ---
						and pr.branch_code = @branch_code
			order by	pri.category_type;

			open cursor_name

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
				--,@faktur_no
				,@procurement_type
				--,@asset_code
				,@id
				,@po_code
				,@file_invoice_no -- (+) Ari 2024-01-22 ket : get file invoice no jika faktur kosong
				,@receive_quantity
				,@category_type
				,@good_receipt_note_code
				,@asset_no
				,@asset_code
				,@recive_quantity	
				,@uom_name	
				,@item_name_for_jrnl
				,@po_no
				,@fgrn_detail_id
				,@podoi_id

			WHILE @@fetch_status = 0
			begin

				 -- nilainya exec dari master_transaction.sp_name
				exec @return_value = @sp_name @invoice_id, @podoi_id; -- sp ini mereturn value angka 

				--SELECT @sp_name'@sp_name',@invoice_id'@invoice_id',@podoi_id'@podoi_id',@return_value'@return_value',@transaction_code'@transaction_code',@gl_link_code'@gl_link_code'

				if (@category_type = 'ASSET' and @transaction_code IN ('NGRNINV'))
				begin

						select	@id_fgrnr_asset = fgrnd.id
						from	dbo.final_grn_request_detail fgrnd 
						where	fgrnd.asset_no = @asset_no 

						update	dbo.final_grn_request_detail
						set		is_journal_asset	= '1'
						where	id	= @id_fgrnr_asset
				end

				if  @gl_link_code in ('ASSET')
				begin
					if @asset_code is null
					begin
					    select @asset_code = grnr.asset_code from dbo.final_good_receipt_note_detail fgrn
						inner join dbo.final_grn_request_detail grnr on convert(nvarchar(50),grnr.id) = fgrn.reff_no
						where fgrn.po_object_id = @podoi_id
					end

					set @code_jrn = isnull(@asset_code, @po_no)
				end
				else
                begin
					set @code_jrn = @po_no	
                end

				-- (+) Ari 2023-12-30 ket : get npwp name & npwp address (bukan name dan address,logic diatas dibiarin aja)
				--select	@vendor_name = mv.npwp_name
				--		,@vendor_address = mv.npwp_address
				--from	ifinbam.dbo.master_vendor mv
				--where	mv.code = @vendor_code
				-- (+) Ari 2023-12-30

				--(+ SEPRIA, 07012025: tambah logic jika nilai yg di ambil Minus)
				if(@return_value < 0)
				begin
					if (@debet_or_credit ='DEBIT')
					begin
						set @orig_amount_cr = abs(@return_value)
						set @orig_amount_db = 0 
						set @debet_or_credit = 'CREDIT'
						set @return_value = abs(@return_value)
					end
					else
					begin
						set @orig_amount_cr = 0
						set @orig_amount_db = abs(@return_value)
						set @debet_or_credit ='DEBIT'
						set @return_value = abs(@return_value)
					end
				end

				if(@return_value > 0)
				begin

					-- Jurnal APS untuk RENT langsung ke biaya sewa, selain itu tetap ke APS
					-- (+) Ari 2023-12-29 ket : dicomment karena seharusnya ke APS 
					-- Hari - 18.Jul.2023 06:37 PM --	logic khusus untuk AP temporary untuk mendapatkan gl link
					if @transaction_code = 'INVAPS' -- AP TEMPORARY, untuk unit dengan tipe rental/sewa ambil gl nya berbeda
					begin

						--IF ( @unit_from = 'BUY')  
						--begin	
						--	select @gl_link_code =  dbo.xfn_get_asset_gl_code_by_item(@item_group_code)
						--end 
						--else-- RENT
						if @unit_from = 'RENT'
						begin
							select @gl_link_code =  dbo.xfn_get_asset_gl_code_by_item_rent(@item_group_code)
						end

					end

					if (@debet_or_credit ='DEBIT')
					begin
						set @orig_amount_cr = 0
						set @orig_amount_db = @return_value
					end
					else
					begin
						set @orig_amount_cr = abs(@return_value)
						set @orig_amount_db = 0 
					END



					if (isnull(@gl_link_code, '') = '')
					begin
						set @msg = 'Please Setting GL Link For ' + @transaction_name;
						raiserror(@msg, 16, -1);
					end




					if(@transaction_code = 'INVVAT')
					begin
						if(@return_value > 0)
						begin
							set @pph_type				= 'PPN MASUKAN'
							set @income_type			= 'PPN MASUKAN ' + convert(nvarchar(10), cast(@ppn_pct as int)) + '%'
							set @income_bruto_amount	= @total_amount
							set @tax_rate				= @ppn_pct
							set @ppn_pph_amount			= @return_value
						end
					end
					else if(@transaction_code = 'INVPPH')
					begin
						if(@return_value > 0)
						begin
								-- jika sewa
								if(@procurement_type = 'PURCHASE' and @unit_from = 'RENT')
								begin
									set @pph_type				= 'PPH PASAL 23'
									set @income_type			= 'SEWA HARTA'
								end
								-- jika pembelian unit
								else if(@procurement_type = 'PURCHASE' and @unit_from = 'BUY')
								begin
									set @pph_type				= 'PPH PASAL 23'
									set @income_type			= ''
								end
								-- jika mobilisasi
								else if (@procurement_type = 'MOBILISASI')
								begin
									set @pph_type				= 'PPH PASAL 23'
									set @income_type			= 'JASA LOGISTIK'
								end

								set @income_bruto_amount	= @total_amount
								set @tax_rate				= @pph_pct
								set @ppn_pph_amount			= @return_value
						end
					end
					else
					begin
						set @income_type			= ''
						set @pph_type				= ''
						set @vendor_code			= ''
						set @vendor_name			= ''
						set @vendor_npwp			= ''
						set @vendor_address			= ''
						set @income_bruto_amount	= 0
						set @tax_rate				= 0
						set @ppn_pph_amount			= 0
						set @remarks_tax			= ''
						set @faktur_no				= ''
					end

					--(+) Ari 2024-01-22 ket : jika faktur no null atau 000000 , set dengan no invoice
					if (isnull(@faktur_no,'') = '' or @faktur_no = '0000000000000000')
					begin
						set @faktur_no = @file_invoice_no
					end

					select @p_final_grn_code = final_good_receipt_note_code from dbo.final_good_receipt_note_detail where po_object_id = @podoi_id

					if (@transaction_code IN ('NGRNINV'))
					begin
						if not exists (	select	1
						from	dbo.final_good_receipt_note_detail fgrnd
								left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrnd.good_receipt_note_detail_id
								left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
						where	fgrnd.final_good_receipt_note_code = @p_final_grn_code
						and		isnull(inv.status,'') not in ('APPROVE','POST')
						)
						begin
							--jika sudah coa asset, update final asset agar depre schedule job bisa jalan
							update	dbo.eproc_interface_asset
							set		
									is_final_all		= '1'
									,purchase_price		= isnull(@return_value,0) - isnull(@discount_amount,0)
									,original_price		= isnull(@return_value,0)
									,mod_by				= @p_mod_by
									,mod_date			= @p_mod_date
									,mod_ip_address		= @p_mod_ip_address
							where	code = @asset_code
							and		isnull(is_final_all,'0') = '0'
						end
					end

					-- (+)Sepria CR Priority: 20082025: bikin intransit balik sebanyak item yang sudah pernah di jurnal
					IF (@transaction_code = 'INTRANSIT' AND @debet_or_credit = 'CREDIT')
					begin

						declare cursor_balikintransit cursor fast_forward read_only FOR
						select	jd.id
						from	dbo.final_good_receipt_note_detail fgr 
								inner join dbo.final_good_receipt_note fgrn on fgrn.code = fgr.final_good_receipt_note_code
								inner join dbo.ifinproc_interface_journal_gl_link_transaction_detail jd on jd.po_detail_object_id = fgr.po_object_id
						where	fgrn.code = @p_final_grn_code
						and		fgr.po_object_id <> @podoi_id
						and		fgrn.status = 'POST' 
						and		jd.gl_link_code = 'INTRANSITINST'
						and		jd.orig_amount_db > 0

                        open cursor_balikintransit

						fetch next from cursor_balikintransit 
						into	@id_intransitinst_balik

						while @@fetch_status = 0
						begin

							insert into dbo.ifinproc_interface_journal_gl_link_transaction_detail
							(
							    gl_link_transaction_code,
							    company_code,
							    branch_code,
							    branch_name,
							    cost_center_code,
							    cost_center_name,
							    gl_link_code,
							    contra_gl_link_code,
							    agreement_no,
							    facility_code,
							    facility_name,
							    purpose_loan_code,
							    purpose_loan_name,
							    purpose_loan_detail_code,
							    purpose_loan_detail_name,
							    orig_currency_code,
							    orig_amount_db,
							    orig_amount_cr,
							    exch_rate,
							    base_amount_db,
							    base_amount_cr,
							    division_code,
							    division_name,
							    department_code,
							    department_name,
							    remarks,
							    cre_date,
							    cre_by,
							    cre_ip_address,
							    mod_date,
							    mod_by,
							    mod_ip_address,
							    ext_pph_type,
							    ext_vendor_code,
							    ext_vendor_name,
							    ext_vendor_npwp,
							    ext_vendor_address,
							    ext_income_type,
							    ext_income_bruto_amount,
							    ext_tax_rate_pct,
							    ext_pph_amount,
							    ext_description,
							    ext_tax_number,
							    ext_sale_type,
							    ext_vendor_nitku,
							    ext_vendor_npwp_pusat,
							    po_detail_object_id
							)
							select	@gl_link_transaction_code,
                                    company_code,
                                    branch_code,
                                    branch_name,
                                    cost_center_code,
                                    cost_center_name,
                                    gl_link_code,
                                    contra_gl_link_code,
                                    agreement_no,
                                    facility_code,
                                    facility_name,
                                    purpose_loan_code,
                                    purpose_loan_name,
                                    purpose_loan_detail_code,
                                    purpose_loan_detail_name,
                                    orig_currency_code,
                                    orig_amount_cr,-- balik
                                    orig_amount_db,-- balik
                                    exch_rate,
                                    base_amount_cr,-- balik
                                    base_amount_db,-- balik
                                    division_code,
                                    division_name,
                                    department_code,
                                    department_name,
                                    remarks,
                                    @p_mod_date,
                                    @p_mod_by,
                                    @p_mod_ip_address,
                                    @p_mod_date,
                                    @p_mod_by,
                                    @p_mod_ip_address,
                                    ext_pph_type,
                                    ext_vendor_code,
                                    ext_vendor_name,
                                    ext_vendor_npwp,
                                    ext_vendor_address,
                                    ext_income_type,
                                    ext_income_bruto_amount,
                                    ext_tax_rate_pct,
                                    ext_pph_amount,
                                    ext_description,
                                    ext_tax_number,
                                    ext_sale_type,
                                    ext_vendor_nitku,
                                    ext_vendor_npwp_pusat,
                                    po_detail_object_id 
							from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
							where	id = @id_intransitinst_balik

						  fetch next from cursor_balikintransit 
							into	@id_intransitinst_balik

						end	

						close cursor_balikintransit
						deallocate cursor_balikintransit

					end
					else
					begin
						if(@transaction_code NOT IN ('INVPPH','INVVAT','INVAPSP','NGRNINV'))-- detail jurnal hanya 1 nilai di total ,'INTRANSIT' -- ,'INVAPS','NGRNINV','CINVAPS','AOIPINV'
						begin

							if @transaction_code = 'INTRANSIT' 
							begin
							set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(convert(nvarchar(5), @recive_quantity), '') + N' ' + isnull(@uom_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO NO : ' + isnull(@po_no, '') + '. GRN NO : ' + ISNULL(@code_jrn,'')

							end
							else
                            begin
								set @remarks_journal = isnull(@transaction_name, '')  + ' ' + ISNULL(@code_jrn,'')
                            end
							set @remarks_tax = @remarks_journal


							begin
								exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @gl_link_transaction_code
																										  ,@p_company_code					= 'DSF'
																										  ,@p_branch_code					= @branch_code
																										  ,@p_branch_name					= @branch_name
																										  ,@p_cost_center_code				= null
																										  ,@p_cost_center_name				= null
																										  ,@p_gl_link_code					= @gl_link_code
																										  ,@p_agreement_no					= @code_jrn --@asset_code
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
																										  ,@p_division_code					= ''
																										  ,@p_division_name					= ''
																										  ,@p_department_code				= ''
																										  ,@p_department_name				= ''
																										  ,@p_remarks						= @remarks_journal
																										  ,@p_ext_pph_type					= @pph_type		
																										  ,@p_ext_vendor_code				= @vendor_code
																										  ,@p_ext_vendor_name				= @vendor_name
																										  ,@p_ext_vendor_npwp				= @vendor_npwp
																										  ,@p_ext_vendor_address			= @vendor_address
																										  ,@p_ext_income_type				= @income_type
																										  ,@p_ext_income_bruto_amount		= @income_bruto_amount
																										  ,@p_ext_tax_rate_pct				= @tax_rate
																										  ,@p_ext_pph_amount				= @ppn_pph_amount
																										  ,@p_ext_description				= @remarks_tax
																										  ,@p_ext_tax_number				= @faktur_no
																										  ,@p_ext_sale_type					= ''
																										  ,@p_cre_date						= @p_mod_date
																										  ,@p_cre_by						= @p_mod_by
																										  ,@p_cre_ip_address				= @p_mod_ip_address
																										  ,@p_mod_date						= @p_mod_date
																										  ,@p_mod_by						= @p_mod_by
																										  ,@p_mod_ip_address				= @p_mod_ip_address
																										  ,@p_po_detail_object_id				= @podoi_id
							end
						end
						else if(@transaction_code NOT IN ('INVVAT','NGRNINV'))--,'INTRANSIT'
						begin -- detail jurnal di catat persatuan dari jumlah quantity received

							set @remarks_journal = isnull(@transaction_name, '')  + ' ' + ISNULL(@p_code,'')
							set @remarks_tax = @remarks_journal

							if not exists (select 1 from dbo.ifinproc_interface_journal_gl_link_transaction_detail where gl_link_code = @gl_link_code and gl_link_transaction_code = @gl_link_transaction_code)
							begin
								exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @gl_link_transaction_code
																										  ,@p_company_code					= 'DSF'
																										  ,@p_branch_code					= @branch_code
																										  ,@p_branch_name					= @branch_name
																										  ,@p_cost_center_code				= null
																										  ,@p_cost_center_name				= null
																										  ,@p_gl_link_code					= @gl_link_code
																										  ,@p_agreement_no					= @code_jrn --@asset_code
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
																										  ,@p_division_code					= ''
																										  ,@p_division_name					= ''
																										  ,@p_department_code				= ''
																										  ,@p_department_name				= ''
																										  ,@p_remarks						= @remarks_journal
																										  ,@p_ext_pph_type					= @pph_type		
																										  ,@p_ext_vendor_code				= @vendor_code
																										  ,@p_ext_vendor_name				= @vendor_name
																										  ,@p_ext_vendor_npwp				= @vendor_npwp
																										  ,@p_ext_vendor_address			= @vendor_address
																										  ,@p_ext_income_type				= @income_type
																										  ,@p_ext_income_bruto_amount		= @income_bruto_amount
																										  ,@p_ext_tax_rate_pct				= @tax_rate
																										  ,@p_ext_pph_amount				= @ppn_pph_amount
																										  ,@p_ext_description				= @remarks_tax
																										  ,@p_ext_tax_number				= @faktur_no
																										  ,@p_ext_sale_type					= ''
																										  ,@p_cre_date						= @p_mod_date
																										  ,@p_cre_by						= @p_mod_by
																										  ,@p_cre_ip_address				= @p_mod_ip_address
																										  ,@p_mod_date						= @p_mod_date
																										  ,@p_mod_by						= @p_mod_by
																										  ,@p_mod_ip_address				= @p_mod_ip_address
																										  ,@p_po_detail_object_id			= @podoi_id
							end
							else
							begin
								update	dbo.ifinproc_interface_journal_gl_link_transaction_detail
								set		orig_amount_db = orig_amount_db + @orig_amount_db
										,orig_amount_cr = orig_amount_cr + @orig_amount_cr
										,base_amount_db = base_amount_db + @orig_amount_db
										,base_amount_cr = base_amount_cr + @orig_amount_cr
										,remarks		= remarks + ' - ' +  isnull(@code_jrn,'')
								where	gl_link_code				 = @gl_link_code
										and gl_link_transaction_code = @gl_link_transaction_code ;
							end
						end

						else	

						-- detail jurnal diganung per nomor faktur
						if(@transaction_code = 'INVVAT')
						begin							

									set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(convert(nvarchar(5), @recive_quantity), '') + N' ' + isnull(@uom_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO NO : ' + isnull(@po_no, '') + '. INVOICE NO : ' + @invoice_register_code ;
									set @remarks_tax = @remarks_journal

									select	distinct @faktur_no = ardf.faktur_no --(+ sepria 07012025) di distinct jika ada faktur yg sama, di jumlahin jadi 1 row coa aja
									from	dbo.ap_invoice_registration_detail					 ard
											inner join dbo.ap_invoice_registration_detail_faktur ardf on ard.id = ardf.invoice_registration_detail_id
									where	ard.invoice_register_code = @p_code 
									and		ard.id = @invoice_detail_id

									if (isnull(@faktur_no,'') = '' or @faktur_no = '0000000000000000')
									begin
										set @faktur_no = @file_invoice_no
									end

									if not exists (
										select 1 from dbo.ifinproc_interface_journal_gl_link_transaction_detail 
										where gl_link_code = @gl_link_code 
										and gl_link_transaction_code = @gl_link_transaction_code
										and ext_tax_number = @faktur_no
									)
									begin
										exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @gl_link_transaction_code
																												  ,@p_company_code					= 'DSF'
																												  ,@p_branch_code					= @branch_code
																												  ,@p_branch_name					= @branch_name
																												  ,@p_cost_center_code				= null
																												  ,@p_cost_center_name				= null
																												  ,@p_gl_link_code					= @gl_link_code
																												  ,@p_agreement_no					= @code_jrn --@asset_code
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
																												  ,@p_division_code					= ''
																												  ,@p_division_name					= ''
																												  ,@p_department_code				= ''
																												  ,@p_department_name				= ''
																												  ,@p_remarks						= @remarks_journal
																												  ,@p_ext_pph_type					= @pph_type		
																												  ,@p_ext_vendor_code				= @vendor_code
																												  ,@p_ext_vendor_name				= @vendor_name
																												  ,@p_ext_vendor_npwp				= @vendor_npwp
																												  ,@p_ext_vendor_address			= @vendor_address
																												  ,@p_ext_income_type				= @income_type
																												  ,@p_ext_income_bruto_amount		= @income_bruto_amount
																												  ,@p_ext_tax_rate_pct				= @tax_rate
																												  ,@p_ext_pph_amount				= @ppn_pph_amount
																												  ,@p_ext_description				= @remarks_tax
																												  ,@p_ext_tax_number				= @faktur_no
																												  ,@p_ext_sale_type					= ''
																												  ,@p_cre_date						= @p_mod_date
																												  ,@p_cre_by						= @p_mod_by
																												  ,@p_cre_ip_address				= @p_mod_ip_address
																												  ,@p_mod_date						= @p_mod_date
																												  ,@p_mod_by						= @p_mod_by
																												  ,@p_mod_ip_address				= @p_mod_ip_address
																												  ,@p_po_detail_object_id				= @podoi_id
									end
									else
									begin
										update	dbo.ifinproc_interface_journal_gl_link_transaction_detail
										set		orig_amount_db = orig_amount_db + @orig_amount_db
												,orig_amount_cr = orig_amount_cr + @orig_amount_cr
												,base_amount_db = base_amount_db + @orig_amount_db
												,base_amount_cr = base_amount_cr + @orig_amount_cr
										where	gl_link_code				 = @gl_link_code
												and gl_link_transaction_code = @gl_link_transaction_code
												and ext_tax_number			 = @faktur_no
									end

						END

						else
						-- untuk jurnal asset pembalik  hanya masuk sekali karna nilai langsung sum
						if(@transaction_code  in ('NGRNINV'))--,'INTRANSIT'
						begin
							set @remarks_journal = isnull(@transaction_name, '') + ' ASSET CODE : ' + ISNULL(@asset_code,'')
							set @remarks_tax = @remarks_journal

							-- dikelompokinnya per final code
							if not exists (select	fgrnd.final_good_receipt_note_code,* 
							from	dbo.ifinproc_interface_journal_gl_link_transaction_detail a
									inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.po_object_id = a.po_detail_object_id
							where	gl_link_transaction_code = @gl_link_transaction_code 
							and		gl_link_code = @gl_link_code)
							begin
								    exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code				= @gl_link_transaction_code
																											  ,@p_company_code					= 'DSF'
																											  ,@p_branch_code					= @branch_code
																											  ,@p_branch_name					= @branch_name
																											  ,@p_cost_center_code				= null
																											  ,@p_cost_center_name				= null
																											  ,@p_gl_link_code					= @gl_link_code
																											  ,@p_agreement_no					= @code_jrn --@asset_code
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
																											  ,@p_division_code					= ''
																											  ,@p_division_name					= ''
																											  ,@p_department_code				= ''
																											  ,@p_department_name				= ''
																											  ,@p_remarks						= @remarks_journal
																											  ,@p_ext_pph_type					= @pph_type		
																											  ,@p_ext_vendor_code				= @vendor_code
																											  ,@p_ext_vendor_name				= @vendor_name
																											  ,@p_ext_vendor_npwp				= @vendor_npwp
																											  ,@p_ext_vendor_address			= @vendor_address
																											  ,@p_ext_income_type				= @income_type
																											  ,@p_ext_income_bruto_amount		= @income_bruto_amount
																											  ,@p_ext_tax_rate_pct				= @tax_rate
																											  ,@p_ext_pph_amount				= @ppn_pph_amount
																											  ,@p_ext_description				= @remarks_tax
																											  ,@p_ext_tax_number				= @faktur_no
																											  ,@p_ext_sale_type					= ''
																											  ,@p_cre_date						= @p_mod_date
																											  ,@p_cre_by						= @p_mod_by
																											  ,@p_cre_ip_address				= @p_mod_ip_address
																											  ,@p_mod_date						= @p_mod_date
																											  ,@p_mod_by						= @p_mod_by
																											  ,@p_mod_ip_address				= @p_mod_ip_address
																											  ,@p_po_detail_object_id				= @podoi_id
							end
						end
					end
				end
						set @count  = @count  + 1

				update dbo.purchase_order_detail_object_info
				set		invoice_id		= @invoice_id
						,mod_by			= @p_mod_by
						,mod_date		= @p_mod_date
						,mod_ip_address	= @p_mod_ip_address
				where	id = @podoi_id

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
					--,@faktur_no
					,@procurement_type
					--,@asset_code
					,@id
					,@po_code
					,@file_invoice_no -- (+) Ari 2024-01-22 ket : get file invoice no jika faktur kosong
					,@receive_quantity
					,@category_type	
					,@good_receipt_note_code
					,@asset_no
					,@asset_code
					,@recive_quantity	
					,@uom_name	
					,@item_name_for_jrnl
					,@po_no
					,@fgrn_detail_id
					,@podoi_id
			end	

			close cursor_name
			deallocate cursor_name


			-- balancing
			begin
				if ((
						select	sum(orig_amount_db) - sum(orig_amount_cr)
						from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
						where	gl_link_transaction_code = @gl_link_transaction_code
					) <> 0
					)
				begin
					set @msg = 'Journal is not balance' ;

					close curr_invoice_branch_request
					deallocate curr_invoice_branch_request	

					raiserror(@msg, 16, -1) ;
				end ;
			end

		    fetch next from curr_invoice_branch_request 
			into @branch_code
				,@branch_name
		end

		close curr_invoice_branch_request
		deallocate curr_invoice_branch_request		
		end

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
    ON OBJECT::[dbo].[xsp_ap_invoice_registration_post] TO [DSF\raffy.ananda]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_ap_invoice_registration_post] TO [ims-raffyanda]
    AS [dbo];


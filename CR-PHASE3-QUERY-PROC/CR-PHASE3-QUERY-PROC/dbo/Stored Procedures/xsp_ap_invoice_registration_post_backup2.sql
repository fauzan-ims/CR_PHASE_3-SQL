CREATE PROCEDURE dbo.xsp_ap_invoice_registration_post_backup2
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

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM dbo.AP_INVOICE_REGISTRATION WHERE CODE = @p_code AND STATUS = 'ON PROCESS')
		BEGIN
			set @msg = 'Invoice already post' ;
			RAISERROR(@msg, 16, 1) ;
        END
        
		--select	@faktur_no = faktur_no
		--		,@ppn	   = ppn
		--from	dbo.ap_invoice_registration
		--where	code = @p_code ;

		--if (isnull(@faktur_no,'') = '') and (@ppn > 0)
		--begin
		--	SET @msg = 'Faktur Number cant be empty.';
		--	RAISERROR(@msg ,16,-1);
		--END

		declare c_invoice_register_detail cursor for
		select	id
				,purchase_order_id
				,invoice_register_code
				,grn_code
		from	dbo.ap_invoice_registration_detail
		where	invoice_register_code = @p_code ;

		open c_invoice_register_detail ;

		fetch c_invoice_register_detail
		into @invoice_detail_id
			 ,@purchase_order_id
			 ,@invoice_register_code
			 ,@grn_code ;

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

			update dbo.good_receipt_note
			set reff_no = @p_code
			where code = @grn_code

			FETCH c_invoice_register_detail
			INTO @invoice_detail_id
				 ,@purchase_order_id
				 ,@invoice_register_code
				 ,@grn_code ;
		END ;

		close c_invoice_register_detail ;
		deallocate c_invoice_register_detail ;


		update	dbo.ap_invoice_registration
		set		status	= 'POST'
		where	code	= @p_code ;

		-- Pembentukan Journal Invoice Register
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
		
		WHILE @@fetch_status = 0
		BEGIN
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

			DECLARE cursor_name CURSOR FAST_FORWARD READ_ONLY FOR
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
						,airdk.faktur_no
						,pr.procurement_type
						,podoi.asset_code
						,ird.purchase_order_id
						,po.code
						,air.file_invoice_no		-- (+) Ari 2024-01-22 ket : get file invoice no jika faktur kosong
			from		dbo.master_transaction_parameter					mtp
						left join dbo.sys_general_subcode					sgs on (sgs.code											  = mtp.process_code)
						left join dbo.master_transaction					mt on (mt.code												  = mtp.transaction_code)
						left join dbo.ap_invoice_registration_detail		ird on (ird.invoice_register_code							  = @p_code)
						inner join dbo.ap_invoice_registration				air on (air.code											  = ird.invoice_register_code)
						inner join dbo.good_receipt_note					grn on grn.code												  = ird.grn_code
						left join dbo.purchase_order						po on (po.code												  = grn.purchase_order_code)
						left join dbo.purchase_order_detail					pod on (ird.purchase_order_id								  = pod.id)
						left join dbo.good_receipt_note_detail				grnd on (
																						grnd.GOOD_RECEIPT_NOTE_CODE						  = grn.CODE
																						and grnd.receive_quantity						  <> 0
																					)
						left join dbo.purchase_order_detail_object_info		podoi on (
																						 pod.id											  = podoi.purchase_order_detail_id
																						 and   grnd.ID									  = podoi.good_receipt_note_detail_id
																						 and   podoi.purchase_order_detail_id			  = ird.purchase_order_id
																						 and   podoi.ASSET_CODE <> null --ISNULL(podoi.ASSET_CODE,'')							  <> ''
																					 )
						left join dbo.ap_invoice_registration_detail_faktur airdk on (
																						 airdk.invoice_registration_detail_id			  = ird.id
																						 --and   airdk.purchase_order_detail_object_info_id = podoi.id
																					 )
						left join dbo.supplier_selection_detail				ssd on (ssd.id												  = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail				qrd on (qrd.id												  = ssd.quotation_detail_id)
						inner join dbo.procurement							prc on (prc.code collate latin1_general_ci_as				  = isnull(qrd.reff_no, ssd.reff_no))
						inner join dbo.procurement_request					pr on (pr.code												  = prc.procurement_request_code)
			where		mtp.process_code   = 'SGS230600004'
						and pr.branch_code = @branch_code
			--and grnd.receive_quantity <> 0
			order by	ird.purchase_order_id ;

			OPEN cursor_name
			
			FETCH NEXT FROM cursor_name 
			INTO @sp_name
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
				,@po_code
				,@file_invoice_no -- (+) Ari 2024-01-22 ket : get file invoice no jika faktur kosong

			WHILE @@fetch_status = 0
			begin
				set @code_jrn = isnull(@asset_code, @po_code)

			    -- nilainya exec dari MASTER_TRANSACTION.sp_name
				EXEC @return_value = @sp_name @invoice_id ; -- sp ini mereturn value angka 

				-- (+) Ari 2023-12-30 ket : get npwp name & npwp address (bukan name dan address,logic diatas dibiarin aja)
				--select	@vendor_name = mv.npwp_name
				--		,@vendor_address = mv.npwp_address
				--from	ifinbam.dbo.master_vendor mv
				--where	mv.code = @vendor_code
				-- (+) Ari 2023-12-30

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
					end

					if (isnull(@gl_link_code, '') = '')
					begin
						set @msg = 'Please Setting GL Link For ' + @transaction_name;
						raiserror(@msg, 16, -1);
					end

					set @remarks_journal = @transaction_name + ' ' + '. Invoice No : ' + @invoice_register_code
					set @remarks_tax = @remarks_journal

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

					if(@gl_link_code = 'AP TEMP')
					begin
						set @code_jrn = @po_code
					end

					--(+) Ari 2024-01-22 ket : jika faktur no null atau 000000 , set dengan no invoice
					if (isnull(@faktur_no,'') = '' or @faktur_no = '0000000000000000')
					begin
						set @faktur_no = @file_invoice_no
					end
					
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
				end
			
			    fetch next from cursor_name 
				into  @sp_name
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
					 ,@po_code
					 ,@file_invoice_no -- (+) Ari 2024-01-22 ket : get file invoice no jika faktur kosong
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

					raiserror(@msg, 16, -1) ;
				end ;
			end

		    fetch next from curr_invoice_branch_request 
			into @branch_code
				,@branch_name
		end
		
		close curr_invoice_branch_request
		deallocate curr_invoice_branch_request		
		
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

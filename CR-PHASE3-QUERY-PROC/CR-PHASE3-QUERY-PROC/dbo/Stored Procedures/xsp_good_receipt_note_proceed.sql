CREATE PROCEDURE dbo.xsp_good_receipt_note_proceed
(
	@p_code			   nvarchar(50)
	--  
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg										 nvarchar(max)
			,@date										 datetime
			,@remark									 nvarchar(4000)
			,@code_final								 nvarchar(50)
			,@item_code									 nvarchar(50)
			,@item_name									 nvarchar(250)
			,@type_asset_code							 nvarchar(50)
			,@item_category_code						 nvarchar(50)
			,@item_category_name						 nvarchar(250)
			,@item_merk_code							 nvarchar(50)
			,@item_merk_name							 nvarchar(250)
			,@item_model_code							 nvarchar(50)
			,@item_model_name							 nvarchar(250)
			,@item_type_code							 nvarchar(50)
			,@item_type_name							 nvarchar(250)
			,@uom_code									 nvarchar(50)
			,@uom_name									 nvarchar(50)
			,@price_amount								 decimal(18, 2)
			,@spesification								 nvarchar(4000)
			,@po_quantity								 int
			,@receive_quantity							 decimal(18, 2)
			,@shipper_code								 nvarchar(50)
			,@no_resi									 nvarchar(50)
			,@reff_no_opl								 nvarchar(50)
			,@reff_no_mnl								 nvarchar(50)
			,@temp_reff									 nvarchar(50)
			,@total_request								 int
			,@total_final								 int
			,@grn_detail_id								 int
			,@procurement_type							 nvarchar(50)
			,@handover_remark							 nvarchar(4000)
			,@to_province_code							 nvarchar(50)
			,@to_province_name							 nvarchar(250)
			,@to_city_code								 nvarchar(50)
			,@to_city_name								 nvarchar(250)
			,@to_area_phone_no							 nvarchar(4)
			,@to_phone_no								 nvarchar(15)
			,@to_address								 nvarchar(4000)
			,@eta_date									 datetime
			,@branch_code								 nvarchar(50)
			,@branch_name								 nvarchar(250)
			,@fa_code									 nvarchar(50)
			,@fa_name									 nvarchar(250)
			,@requestor_name							 nvarchar(250)
			,@supplier_name								 nvarchar(250)
			,@is_reimburse								 nvarchar(1)
			,@expense_amount							 decimal(18, 2)
			,@ppn_amount								 decimal(18, 2)
			,@pph_amount								 decimal(18, 2)
			,@discount_amount							 decimal(18, 2)
			,@document_pending_code						 nvarchar(50)
			,@count										 int
			,@document_code								 nvarchar(50)
			,@document_name								 nvarchar(250)
			,@file_name									 nvarchar(250)
			,@file_path									 nvarchar(250)
			,@exp_date_doc								 datetime
			,@count_item								 int
			,@purchase_order_code						 nvarchar(50)
			,@grn_detail_id_object_info					 int
			,@unit_from									 nvarchar(25)
			,@po_no										 nvarchar(50)
			,@vendor_name								 nvarchar(250)
			,@transaction_name							 nvarchar(4000)
			,@journal_grn								 nvarchar(50)
			,@branch_code_header						 nvarchar(50)
			,@branch_name_header						 nvarchar(250)
			,@sp_name									 nvarchar(250)
			,@debet_or_credit							 nvarchar(10)
			,@gl_link_code								 nvarchar(50)
			,@gl_link_transaction_code					 nvarchar(50)
			,@orig_amount_cr							 decimal(18, 2)
			,@orig_amount_db							 decimal(18, 2)
			,@return_value								 decimal(18, 2)
			,@remarks_journal							 nvarchar(4000)
			,@grn_id									 bigint
			,@item_code_for_jrnl						 nvarchar(50)
			,@item_name_for_jrnl						 nvarchar(250)
			,@item_group_code							 nvarchar(50)
			,@process_code								 nvarchar(50)
			,@division_code								 nvarchar(50)
			,@division_name								 nvarchar(250)
			,@department_code							 nvarchar(50)
			,@department_name							 nvarchar(250)
			,@recive_quantity							 int
			,@id_object									 decimal(18, 2)
			,@category_type								 nvarchar(50)
			,@code_grn									 nvarchar(50)
			,@purchase_order_detail_id					 int
			,@remaining_qty								 int
			,@sum_order_remaining						 int
			,@rcv_qty									 int
			,@rent_or_buy								 nvarchar(50)
			,@upload_reff_no							 nvarchar(50)
			,@upload_reff_name							 nvarchar(250)
			,@upload_reff_trx_code						 nvarchar(50)
			,@upload_file_name							 nvarchar(250)
			,@upload_doc_file							 varbinary(max)
			,@bpkb_no									 nvarchar(50)
			,@cover_note								 nvarchar(50)
			,@receive_date								 datetime
			,@count2									 int
			,@proc_type									 nvarchar(50)
			,@is_validate								 nvarchar(1)
			,@branch_code_request						 nvarchar(50)
			,@branch_name_request						 nvarchar(250)
			,@journal_date								 datetime	   = dbo.xfn_get_system_date()
			,@total_amount_grn							 decimal(18, 2)
			,@nett_price_quo							 decimal(18, 2)
			,@type										 nvarchar(50)
			,@month										 nvarchar(25)
			,@year										 nvarchar(4)
			,@transaction_code							 nvarchar(50)
			,@value										 int
			--
			,@final_grn_request_detail_id				 int
			,@final_grn_request_detail_karoseri_lookup	 int
			,@application_no							 nvarchar(50)
			,@final_grn_request_detrail_karoseri		 int		   = 0
			,@final_grn_request_detail_accesories		 int		   = 0
			,@final_grn_request_detail_accesories_lookup int
			,@proc_request_id							 int
			,@proc_request_fa_code						 nvarchar(50)
			,@final_grn_request_no						 nvarchar(50)
			,@proc_request_date							 datetime
			,@proc_request_code							 nvarchar(50)
			,@proc_branch_code							 nvarchar(50)
			,@proc_branch_name							 nvarchar(50)
			,@receive_qty								 int
			,@plat_no									 nvarchar(50)
			,@chasis_no									 nvarchar(50)
			,@engine_no									 nvarchar(50) 
			,@purchase_date								 datetime		= dbo.xfn_get_system_date()
			,@spaf_amount								 decimal(18,2)
			,@subvention_amount							 decimal(18,2)
			--,@bpkb_no									 nvarchar(50)	
			--,@cover_note								 nvarchar(50)
			,@cover_note_date							 datetime
			,@cover_exp_date							 datetime
			--,@file_path									 nvarchar(250)
			--,@file_name									 nvarchar(250)
			,@opl_code									 nvarchar(50)
			,@document_type								 nvarchar(50)
			,@stnk_no									 nvarchar(50)
			,@stnk_date									 datetime
			,@stnk_exp_date								 datetime
			,@stck_no									 nvarchar(50)
			,@stck_date									 datetime
			,@stck_exp_date								 datetime
			,@keur_no									 nvarchar(50)
			,@keur_date									 datetime
			,@keur_exp_date								 datetime
			,@ppn_grn									 decimal(18,2)
			,@pph_grn									 decimal(18,2)
			,@discount_grn								 decimal(18,2)
			,@good_receipt_note_detail_id				 bigint				 
			,@built_year								 nvarchar(4)
			,@asset_colour								 nvarchar(50)
			--,@item_group_code							 nvarchar(50)
			,@requestor_code							 nvarchar(50)
			--,@requestor_name							 nvarchar(250)
			,@vendor_code								 nvarchar(50)
			--,@vendor_name								 nvarchar(250)
			,@type_code									 nvarchar(50)
			,@type_name									 nvarchar(250)
			,@category_code								 nvarchar(50)
			,@category_name								 nvarchar(250)
			--,@receive_date								 datetime
			,@branch_code_asset							 nvarchar(50)
			,@branch_name_asset							 nvarchar(250)
			,@pph_pct									 decimal(18,2)
			,@ppn_pct									 decimal(18,2)
			,@invoice_no								 nvarchar(50)
			,@domain									 nvarchar(50)
			,@imei										 nvarchar(50)
			,@is_rent									 nvarchar(50)
			,@asset_purpose								 nvarchar(50)
			--,@spesification							nvarchar(250)
			,@original_amount_final_grn					decimal(18,2)
			,@price_amount_final_grn					decimal(18,2)
			,@code_asset								nvarchar(50)
			,@podoi_id									bigint
			,@po_object_id								bigint	
		
	begin try
    if exists (select 1 from dbo.good_receipt_note where code = @p_code and status <> 'ON PROCESS')--HOLD')
	begin
	    raiserror ('Transaction Already Process', 16,1)
		return
	end
		
		select	@value = value
		from	dbo.sys_global_param
		where	CODE = 'GRNRD' ;

		begin --validasi tanggal receive date kurang dari bulan ini  
			select	@month = case
								 when month(dbo.xfn_get_system_date()) = 1 then 'Januari'
								 when month(dbo.xfn_get_system_date()) = 2 then 'Febuari'
								 when month(dbo.xfn_get_system_date()) = 3 then 'Maret'
								 when month(dbo.xfn_get_system_date()) = 4 then 'April'
								 when month(dbo.xfn_get_system_date()) = 5 then 'Mei'
								 when month(dbo.xfn_get_system_date()) = 6 then 'Juni'
								 when month(dbo.xfn_get_system_date()) = 7 then 'Juli'
								 when month(dbo.xfn_get_system_date()) = 8 then 'Agustus'
								 when month(dbo.xfn_get_system_date()) = 9 then 'September'
								 when month(dbo.xfn_get_system_date()) = 10 then 'Oktober'
								 when month(dbo.xfn_get_system_date()) = 11 then 'November'
								 when month(dbo.xfn_get_system_date()) = 12 then 'Desember'
								 else ''
							 end ;

			select	@year = year(dbo.xfn_get_system_date()) ;

			select	@receive_date = receive_date
			from	dbo.good_receipt_note
			where	code = @p_code ;

			if (@receive_date < dateadd(month, -@value, dbo.xfn_get_system_date()))
			begin
				if (@value <> 0)
				begin
					set @msg = N'Receive date cannot be back dated for more than ' + convert(varchar(1), @value) + N' months.' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (@value = 0)
				begin
					set @msg = N'Receive date must be equal than system date.' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;
		end ;

		--if exists
		--(
		--	select	1
		--	from	dbo.good_receipt_note
		--	where	code			 = @p_code
		--			and receive_date < datefromparts(year(dbo.xfn_get_system_date()), month(dbo.xfn_get_system_date()), 1)
		--)
		--begin
		--	set @msg = 'Receive Date Must be Greater or Equal Than, 1 ' + @month + ' ' + @year ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		begin --validasi jika total amount yang di GRN <> NETT PRICE yang di quotation  
			select	@total_amount_grn = ((grnd.price_amount - grnd.discount_amount) * grnd.receive_quantity) + grnd.ppn_amount - grnd.pph_amount
					,@nett_price_quo  = ((ssd.amount - ssd.discount_amount) * grnd.receive_quantity) + ssd.ppn_amount - ssd.pph_amount	--qrd.nett_price
					,@type			  = po.procurement_type																				-- (+) Ari 2023-12-13 ket : get type  
			from	dbo.good_receipt_note_detail			grnd
					inner join dbo.good_receipt_note		grn on (grn.code							  = grnd.good_receipt_note_code)
					--left join dbo.good_receipt_note_detail_object_info grndoi on (grndoi.good_receipt_note_detail_id = grnd.id)  
					inner join dbo.purchase_order			po on (po.code								  = grn.purchase_order_code)
					left join dbo.purchase_order_detail		pod on (
																	   pod.po_code						  = po.code
																	   and pod.id						  = grnd.purchase_order_detail_id
																   )
					left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.supplier_selection_detail_id)
					--left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
					---- (+) Ari 2023-12-13 ket : get type     
					--left join dbo.procurement				pro on (pro.code collate latin1_general_ci_as = qrd.reff_no)
					--left join dbo.procurement_request		pr on (pr.code								  = pro.procurement_request_code)
			where	grn.code				  = @p_code
					and grnd.receive_quantity <> 0 ;

			if (@type <> 'MOBILISASI') -- (+) Ari 2023-12-13 ket : validasi hanya untuk purchase saja  
			begin
				if (@total_amount_grn <> @nett_price_quo)
				begin
					set @msg = N'Total amount did not match with nett price in quotation : ' + format(@nett_price_quo, '#,###.00', 'DE-de') ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;

			if (@type = 'EXPENSE')
			begin
				if exists (  select	1
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
										inner join ifinams.dbo.asset ast on ast.code = pri.fa_code
								where	grnd.good_receipt_note_code = @p_code
								and		isnull(ast.is_gps,'0') = '1' 
								and		isnull(ast.gps_status,'') not in ('','UNSUBSCRIBE')
								and		grnd.receive_quantity	<> 0 )
					begin
						set @msg = N'Assets Already Have Active GPS';
						raiserror(@msg, 16, -1) ;
					end
			end
		end ;

		begin --validasi harus dilakukan validate
			select	@is_validate = is_validate
			from	dbo.good_receipt_note
			where	code = @p_code ;

			if (@is_validate <> 1)
			begin
				set @msg = N'Validate First' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		begin --validasi tanggal penerimaan harus kurang dari system date
			select	@receive_date = receive_date
			from	dbo.good_receipt_note
			where	code = @p_code ;

			if @receive_date > dbo.xfn_get_system_date()
			begin
				set @msg = N'Receive date must be less or equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		begin --validasi jika receive qty = 0  
			select	@count = count(id)
			from	dbo.good_receipt_note_detail
			where	good_receipt_note_code = @p_code ;

			select	@count2 = count(id)
			from	dbo.good_receipt_note_detail
			where	good_receipt_note_code = @p_code
					and receive_quantity   = 0 ;

			if (@count = 1)
			begin
				if exists
				(
					select	1
					from	dbo.good_receipt_note_detail
					where	good_receipt_note_code = @p_code
							and receive_quantity   = 0
				)
				begin
					set @msg = N'Please input receive quantity.' ;

					raiserror(@msg, 16, 1) ;
				end ;
			end ;
			else if (@count = @count2)
			begin
				set @msg = N'Please input receive quantity.' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;

		begin
			if exists
			(
				select	1
				from	dbo.good_receipt_note_detail
				where	good_receipt_note_code = @p_code
						and receive_quantity   <> 0
			)
			begin

				--validasi jika object info nya tidak dipilih  
				select	@grn_detail_id_object_info = podo.good_receipt_note_detail_id
				from	dbo.good_receipt_note							grn
						left join dbo.purchase_order					po on (po.code						   = grn.purchase_order_code)
						left join dbo.purchase_order_detail				pod on (pod.po_code					   = po.code)
						left join dbo.purchase_order_detail_object_info podo on (podo.purchase_order_detail_id = pod.id)
						left join dbo.good_receipt_note_detail			grnd on (grnd.good_receipt_note_code   = grn.code)
				where	grn.code							 = @p_code
						and podo.good_receipt_note_detail_id <> 0 ;

				if (@grn_detail_id_object_info = 0)
				begin
					set @msg = N'Please input object info.' ;

					raiserror(@msg, 16, 1) ;
				end ;

				--validasi jika yang diterima dengan asset nya tidak sama  
				if exists
				(
					select	1
					from	dbo.good_receipt_note_detail	 grnd
							inner join dbo.good_receipt_note grn on (grn.code = grnd.good_receipt_note_code)
							outer apply
					(
						select	count(isnull(podo.id, 0)) 'id'
						from	dbo.purchase_order_detail_object_info podo
						where	podo.good_receipt_note_detail_id = grnd.id
					)										 podo
							inner join dbo.purchase_order			 po on (po.code								   = grn.purchase_order_code)
							inner join dbo.purchase_order_detail	 pod on (
																				pod.po_code						   = po.code
																				and pod.id						   = grnd.purchase_order_detail_id
																			)
							inner join dbo.supplier_selection_detail ssd on (ssd.id								   = pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail	 qrd on (qrd.id								   = ssd.quotation_detail_id)
							inner join dbo.procurement				 prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
							inner join dbo.procurement_request		 pr on (prc.procurement_request_code		   = pr.code)
							inner join dbo.procurement_request_item	 pri on (
																				pr.code							   = pri.procurement_request_code
																				and pri.item_code				   = grnd.item_code
																			)
					where	grnd.good_receipt_note_code = @p_code
							and grnd.receive_quantity	<> 0
							and podo.id					<> isnull(grnd.receive_quantity, 0)
							and pri.category_type		= 'ASSET'
				)
				begin
					set @msg = N'Object info must be equal to Receive Quantity.' ;

					raiserror(@msg, 16, 1) ;
				end ;

				--validasi jika tidak diinputkan date  
				if exists
				(
					select	1
					from	dbo.good_receipt_note_detail					 grnd
							inner join dbo.good_receipt_note				 grn on (grn.code									= grnd.good_receipt_note_code)
							inner join dbo.purchase_order					 po on (po.code										= grn.purchase_order_code)
							inner join dbo.purchase_order_detail			 pod on (
																						pod.po_code								= po.code
																						and pod.id								= grnd.purchase_order_detail_id
																					)
							inner join dbo.purchase_order_detail_object_info podo on (
																						 podo.purchase_order_detail_id			= pod.id
																						 and   podo.good_receipt_note_detail_id = grnd.id
																					 )
							inner join dbo.supplier_selection_detail		 ssd on (ssd.id										= pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail			 qrd on (qrd.id										= ssd.quotation_detail_id)
							inner join dbo.procurement						 prc on (prc.code collate latin1_general_ci_as		= isnull(qrd.reff_no, ssd.reff_no))
							inner join dbo.procurement_request				 pr on (pr.code										= prc.procurement_request_code)
							inner join dbo.procurement_request_item			 pri on (
																						pri.procurement_request_code			= pr.code
																						and pri.item_code						= grnd.item_code
																					)
					where	grnd.good_receipt_note_code			   = @p_code
							and grnd.receive_quantity			   <> 0
							and
							(
								isnull(podo.stnk_exp_date, '')	   = ''
								and isnull(podo.stck_exp_date, '') = ''
								and isnull(podo.keur_exp_date, '') = ''
								and isnull(podo.stnk_date, '')	   = ''
								and isnull(podo.stck_date, '')	   = ''
								and isnull(podo.keur_date, '')	   = ''
							)
							and pri.category_type				   = 'ASSET'
				)
				begin
					set @msg = N'Please Input STNK Date or  STCK Date or KEUR Date.' ;

					raiserror(@msg, 16, 1) ;
				end ;

				--validasi stnk 1
				if exists
				(
					select	1
					from	dbo.good_receipt_note_detail					 grnd
							inner join dbo.good_receipt_note				 grn on (grn.code									= grnd.good_receipt_note_code)
							inner join dbo.purchase_order					 po on (po.code										= grn.purchase_order_code)
							inner join dbo.purchase_order_detail			 pod on (
																						pod.po_code								= po.code
																						and pod.id								= grnd.purchase_order_detail_id
																					)
							inner join dbo.purchase_order_detail_object_info podo on (
																						 podo.purchase_order_detail_id			= pod.id
																						 and   podo.good_receipt_note_detail_id = grnd.id
																					 )
							inner join dbo.supplier_selection_detail		 ssd on (ssd.id										= pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail			 qrd on (qrd.id										= ssd.quotation_detail_id)
							inner join dbo.procurement						 prc on (prc.code collate latin1_general_ci_as		= isnull(qrd.reff_no, ssd.reff_no))
							inner join dbo.procurement_request				 pr on (pr.code										= prc.procurement_request_code)
							inner join dbo.procurement_request_item			 pri on (
																						pri.procurement_request_code			= pr.code
																						and pri.item_code						= grnd.item_code
																					)
					where	grnd.good_receipt_note_code		   = @p_code
							and grnd.receive_quantity		   <> 0
							and isnull(podo.stnk_date, '')	   <> ''
							and isnull(podo.stnk_exp_date, '') = ''
							--and (
							--		isnull(podo.stnk_exp_date, '')	   = ''
							--		or isnull(podo.stnk_date, '')	   = ''
							--	)
							and pri.category_type			   = 'ASSET'
				)
				begin
					set @msg = N'Please Input STNK Exp Date.' ;

					raiserror(@msg, 16, 1) ;
				end ;

				--validasi stnk 2
				if exists
				(
					select	1
					from	dbo.good_receipt_note_detail					 grnd
							inner join dbo.good_receipt_note				 grn on (grn.code									= grnd.good_receipt_note_code)
							inner join dbo.purchase_order					 po on (po.code										= grn.purchase_order_code)
							inner join dbo.purchase_order_detail			 pod on (
																						pod.po_code								= po.code
																						and pod.id								= grnd.purchase_order_detail_id
																					)
							inner join dbo.purchase_order_detail_object_info podo on (
																						 podo.purchase_order_detail_id			= pod.id
																						 and   podo.good_receipt_note_detail_id = grnd.id
																					 )
							inner join dbo.supplier_selection_detail		 ssd on (ssd.id										= pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail			 qrd on (qrd.id										= ssd.quotation_detail_id)
							inner join dbo.procurement						 prc on (prc.code collate latin1_general_ci_as		= isnull(qrd.reff_no, ssd.reff_no))
							inner join dbo.procurement_request				 pr on (pr.code										= prc.procurement_request_code)
							inner join dbo.procurement_request_item			 pri on (
																						pri.procurement_request_code			= pr.code
																						and pri.item_code						= grnd.item_code
																					)
					where	grnd.good_receipt_note_code		   = @p_code
							and grnd.receive_quantity		   <> 0
							and isnull(podo.stnk_exp_date, '') <> ''
							and isnull(podo.stnk_date, '')	   = ''
							--and (
							--		isnull(podo.stnk_exp_date, '')	   = ''
							--		or isnull(podo.stnk_date, '')	   = ''
							--	)
							and pri.category_type			   = 'ASSET'
				)
				begin
					set @msg = N'Please Input STNK Date.' ;

					raiserror(@msg, 16, 1) ;
				end ;

				--validasi stck
				if exists
				(
					select	1
					from	dbo.good_receipt_note_detail					 grnd
							inner join dbo.good_receipt_note				 grn on (grn.code									= grnd.good_receipt_note_code)
							inner join dbo.purchase_order					 po on (po.code										= grn.purchase_order_code)
							inner join dbo.purchase_order_detail			 pod on (
																						pod.po_code								= po.code
																						and pod.id								= grnd.purchase_order_detail_id
																					)
							inner join dbo.purchase_order_detail_object_info podo on (
																						 podo.purchase_order_detail_id			= pod.id
																						 and   podo.good_receipt_note_detail_id = grnd.id
																					 )
							inner join dbo.supplier_selection_detail		 ssd on (ssd.id										= pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail			 qrd on (qrd.id										= ssd.quotation_detail_id)
							inner join dbo.procurement						 prc on (prc.code collate latin1_general_ci_as		= isnull(qrd.reff_no, ssd.reff_no))
							inner join dbo.procurement_request				 pr on (pr.code										= prc.procurement_request_code)
							inner join dbo.procurement_request_item			 pri on (
																						pri.procurement_request_code			= pr.code
																						and pri.item_code						= grnd.item_code
																					)
					where	grnd.good_receipt_note_code		   = @p_code
							and grnd.receive_quantity		   <> 0
							and
							(
								isnull(podo.stck, '')		   <> ''
								or	isnull(podo.stck_date, '') <> ''
							)
							and isnull(podo.stck_exp_date, '') = ''
							and pri.category_type			   = 'ASSET'
				)
				begin
					set @msg = N'Please Input STCK Exp Date.' ;

					raiserror(@msg, 16, 1) ;
				end ;

				--validasi keur
				if exists
				(
					select	1
					from	dbo.good_receipt_note_detail					 grnd
							inner join dbo.good_receipt_note				 grn on (grn.code									= grnd.good_receipt_note_code)
							inner join dbo.purchase_order					 po on (po.code										= grn.purchase_order_code)
							inner join dbo.purchase_order_detail			 pod on (
																						pod.po_code								= po.code
																						and pod.id								= grnd.purchase_order_detail_id
																					)
							inner join dbo.purchase_order_detail_object_info podo on (
																						 podo.purchase_order_detail_id			= pod.id
																						 and   podo.good_receipt_note_detail_id = grnd.id
																					 )
							inner join dbo.supplier_selection_detail		 ssd on (ssd.id										= pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail			 qrd on (qrd.id										= ssd.quotation_detail_id)
							inner join dbo.procurement						 prc on (prc.code collate latin1_general_ci_as		= isnull(qrd.reff_no, ssd.reff_no))
							inner join dbo.procurement_request				 pr on (pr.code										= prc.procurement_request_code)
							inner join dbo.procurement_request_item			 pri on (
																						pri.procurement_request_code			= pr.code
																						and pri.item_code						= grnd.item_code
																					)
					where	grnd.good_receipt_note_code		   = @p_code
							and grnd.receive_quantity		   <> 0
							and
							(
								isnull(podo.keur, '')		   <> ''
								or	isnull(podo.keur_date, '') <> ''
							)
							and isnull(podo.keur_exp_date, '') = ''
							and pri.category_type			   = 'ASSET'
				)
				begin
					set @msg = N'Please Input Keur Exp Date.' ;

					raiserror(@msg, 16, 1) ;
				end ;

				--jika belum input chasis atau engine  
				if exists
				(
					select	1
					from	dbo.good_receipt_note_detail					 grnd
							inner join dbo.good_receipt_note				 grn on (grn.code									= grnd.good_receipt_note_code)
							inner join dbo.purchase_order					 po on (po.code										= grn.purchase_order_code)
							inner join dbo.purchase_order_detail			 pod on (
																						pod.po_code								= po.code
																						and pod.id								= grnd.purchase_order_detail_id
																					)
							inner join dbo.purchase_order_detail_object_info podo on (
																						 podo.purchase_order_detail_id			= pod.id
																						 and   podo.good_receipt_note_detail_id = grnd.id
																					 )
							left join dbo.supplier_selection_detail			 ssd on (ssd.id										= pod.supplier_selection_detail_id)
							left join dbo.quotation_review_detail			 qrd on (qrd.id										= ssd.quotation_detail_id)
							left join dbo.procurement						 prc on (prc.code collate latin1_general_ci_as		= isnull(qrd.reff_no, ssd.reff_no))
							left join dbo.procurement_request				 pr on (pr.code										= prc.procurement_request_code)
							left join dbo.procurement_request_item			 pri on (
																						pr.code									= pri.procurement_request_code
																						and	 pri.item_code						= grnd.item_code
																					)
					where	grnd.good_receipt_note_code			= @p_code
							and grnd.receive_quantity			<> 0
							and
							(
								isnull(podo.engine_no, '')		= ''
								and isnull(podo.chassis_no, '') = ''
							)
							and pri.category_type				= 'ASSET'
				)
				begin
					set @msg = N'Please input Engine and Chasis first.' ;

					raiserror(@msg, 16, 1) ;
				end ;
			end ;
		end ;

		
		select	@remark			= grn.remark
				,@rent_or_buy	= po.unit_from
				,@po_no			= grn.purchase_order_code
				,@supplier_name = grn.supplier_name
		from	dbo.good_receipt_note		  grn
				inner join dbo.purchase_order po on (po.code = grn.purchase_order_code)
		where	grn.code = @p_code ;
		
		--begin
		--	if exists
		--	(
		--		select	1
		--		from	dbo.good_receipt_note
		--		where	code	   = @p_code
		--				and status = 'HOLD'
		--	)
		--	begin
		--		update	dbo.good_receipt_note
		--		set		status = 'ON PROCESS'
		--				--  
		--				,mod_date = @p_mod_date
		--				,mod_by = @p_mod_by
		--				,mod_ip_address = @p_mod_ip_address
		--		where	code = @p_code ;
		--	end ;
		--	else
		--	begin
		--		set @msg = N'Data already process' ;

		--		raiserror(@msg, 16, 1) ;
		--	end ;
		--end ;
		
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
				set @transaction_name = N'Good Receipt Note ' + @p_code + N' From PO ' + @po_no + N'.' + N' Vendor ' + @supplier_name ;

				exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_insert @p_code						= @journal_grn output
																				   ,@p_company_code				= 'DSF'
																				   ,@p_branch_code				= @branch_code_request
																				   ,@p_branch_name				= @branch_name_request
																				   ,@p_transaction_status		= 'HOLD'
																				   ,@p_transaction_date			= @journal_date
																				   ,@p_transaction_value_date	= @journal_date
																				   ,@p_transaction_code			= 'GRNAST'
																				   ,@p_transaction_name			= 'Good Receipt Note'
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
				BEGIN
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
								,grnd.receive_quantity
								,podoi.id
					from		dbo.master_transaction_parameter		mtp
								left join dbo.master_transaction		mt on (mt.code										  = mtp.transaction_code)
								inner join dbo.good_receipt_note_detail grnd on (grnd.id									  = @grn_detail_id)
								inner join dbo.purchase_order_detail	pod on (pod.id										  = grnd.purchase_order_detail_id)
								left join dbo.purchase_order_detail_object_info podoi on (
																							 pod.id								= podoi.purchase_order_detail_id
																							 and   grnd.id						= podoi.good_receipt_note_detail_id
																						 )
								left join dbo.supplier_selection_detail ssd on (ssd.id										  = pod.supplier_selection_detail_id)
								left join dbo.quotation_review_detail	qrd on (qrd.id										  = ssd.quotation_detail_id)
								inner join dbo.procurement				prc on (prc.code collate sql_latin1_general_cp1_ci_as = isnull(qrd.reff_no, ssd.reff_no))
					where		mtp.process_code		  = 'SGS230100004'
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
						 ,@purchase_order_code
						 ,@receive_quantity 
						 ,@po_object_id

					while @@fetch_status = 0
					begin
						--update journal ke GRN Detail  
						update	dbo.good_receipt_note_detail
						set		grn_journal_code = @journal_grn
								,grn_journal_date = @journal_date
								--  
								,mod_date = @p_mod_date
								,mod_by = @p_mod_by
								,mod_ip_address = @p_mod_ip_address
						where	id = @grn_id ;

						-- nilainya exec dari MASTER_TRANSACTION.sp_name  
						exec @return_value = @sp_name @grn_id, @po_object_id ; -- sp ini mereturn value angka   

						--SELECT @sp_name'@sp_name',@return_value'@return_value',@transaction_code'@transaction_code',@transaction_name'@transaction_name'

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
						if (@gl_link_code = 'ASSET')
						begin
							--Jika asset nya BUY  
							--if(@unit_from = 'BUY')  
							begin
								select	@gl_link_code = dbo.xfn_get_asset_gl_code_by_item(@item_group_code) ;
							end ;
						--else  
						--begin  
						-- select @gl_link_code = dbo.xfn_get_asset_gl_code_by_item_rent(@item_group_code)  
						--end  
						end ;

						if (isnull(@gl_link_code, '') = '')
						begin
							set @msg = N'Please Setting GL Link For ' + @transaction_name ;

							raiserror(@msg, 16, -1) ;
						end ;

						set @count = 0 ;

						--while @count < @receive_quantity
						begin
							if (@return_value <> 0)
							BEGIN
								--cr pRIOrity sepria 25082025: gk ada yang di gabung
								--if (@transaction_code IN ('APT'))
								--begin
								--	if not exists
								--	(
								--		select	1
								--		from	dbo.ifinproc_interface_journal_gl_link_transaction_detail
								--		where	gl_link_code				 = @gl_link_code
								--				and gl_link_transaction_code = @journal_grn
								--	)
								--	begin
								--		set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(convert(nvarchar(3), @recive_quantity), '') + N' ' + isnull(@uom_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO No : ' + isnull(@po_no, '') ;

								--		exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @journal_grn
								--																				  ,@p_company_code				= 'DSF'
								--																				  ,@p_branch_code				= @branch_code
								--																				  ,@p_branch_name				= @branch_name
								--																				  ,@p_cost_center_code			= null
								--																				  ,@p_cost_center_name			= null
								--																				  ,@p_gl_link_code				= @gl_link_code
								--																				  ,@p_agreement_no				= @purchase_order_code
								--																				  ,@p_facility_code				= null
								--																				  ,@p_facility_name				= null
								--																				  ,@p_purpose_loan_code			= null
								--																				  ,@p_purpose_loan_name			= null
								--																				  ,@p_purpose_loan_detail_code	= null
								--																				  ,@p_purpose_loan_detail_name	= null
								--																				  ,@p_orig_currency_code		= 'IDR'
								--																				  ,@p_orig_amount_db			= @orig_amount_db
								--																				  ,@p_orig_amount_cr			= @orig_amount_cr
								--																				  ,@p_exch_rate					= 1
								--																				  ,@p_base_amount_db			= @orig_amount_db
								--																				  ,@p_base_amount_cr			= @orig_amount_cr
								--																				  ,@p_division_code				= @division_code
								--																				  ,@p_division_name				= @division_name
								--																				  ,@p_department_code			= @department_code
								--																				  ,@p_department_name			= @department_name
								--																				  ,@p_remarks					= @remarks_journal
								--																				  ,@p_cre_date					= @p_mod_date
								--																				  ,@p_cre_by					= @p_mod_by
								--																				  ,@p_cre_ip_address			= @p_mod_ip_address
								--																				  ,@p_mod_date					= @p_mod_date
								--																				  ,@p_mod_by					= @p_mod_by
								--																				  ,@p_mod_ip_address			= @p_mod_ip_address ;
								--	end ;
								--	else
								--	begin
								--		update	dbo.ifinproc_interface_journal_gl_link_transaction_detail
								--		set		orig_amount_db = orig_amount_db + @orig_amount_db
								--				,orig_amount_cr = orig_amount_cr + @orig_amount_cr
								--				,base_amount_db = base_amount_db + @orig_amount_db
								--				,base_amount_cr = base_amount_cr + @orig_amount_cr
								--		where	gl_link_code				 = @gl_link_code
								--				and gl_link_transaction_code = @journal_grn ;
								--	end ;
								--end ;
								--else
								begin
									set @remarks_journal = isnull(@transaction_name, '') + N' ' + isnull(convert(nvarchar(3), @recive_quantity), '') + N' ' + isnull(@uom_name, '') + N' ' + isnull(@item_name_for_jrnl, '') + N'. PO No : ' + isnull(@po_no, '') ;

									exec dbo.xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @journal_grn
																											  ,@p_company_code				= 'DSF'
																											  ,@p_branch_code				= @branch_code
																											  ,@p_branch_name				= @branch_name
																											  ,@p_cost_center_code			= null
																											  ,@p_cost_center_name			= null
																											  ,@p_gl_link_code				= @gl_link_code
																											  ,@p_agreement_no				= @purchase_order_code
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
								end ;
							end ;

							--set @count = @count + 1 ;
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
							 ,@purchase_order_code
							 ,@receive_quantity 
							 ,@po_object_id
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
					,replace(ssd.application_no, '.', '/')
					,podoi.plat_no
					,podoi.engine_no
					,podoi.chassis_no
					--
					,prc.item_group_code
					,po.requestor_code
					,po.requestor_name
					,grn.supplier_code
					,grn.supplier_name
					,grnd.item_type_code
					,grnd.item_type_name
					,grnd.item_category_code
					,grnd.item_category_name
					,grn.receive_date
					,pr.branch_code
					,pr.branch_name
					,pod.pph_pct
					,pod.ppn_pct
					,podoi.invoice_no
					,podoi.domain
					,podoi.imei
					,po.unit_from
					,case when pr.reff_no is null THEN 'INTERNAL' else 'LEASE' END
                    ,grnd.spesification
					,prc.spaf_amount		
					,prc.subvention_amount	
					,podoi.bpkb_no			
					,podoi.cover_note		
					,podoi.cover_note_date	
					,podoi.exp_date			
					,podoi.file_path		
					,podoi.file_name		
					,pr.reff_no								
					,podoi.stnk				
					,podoi.stnk_date		
					,podoi.stnk_exp_date	
					,podoi.stck				
					,podoi.stck_date		
					,podoi.stck_exp_date	
					,podoi.keur				
					,podoi.keur_date		
					,podoi.keur_exp_date	
					,grnd.ppn_amount		
					,grnd.pph_amount		
					,grnd.discount_amount	
					,grnd.id				
					,pr.built_year			
					,pr.asset_colour	
					,sgs.description	
					,podoi.id
			from	dbo.good_receipt_note_detail					   grnd
					inner join dbo.good_receipt_note				   grn on (grn.code								 = grnd.good_receipt_note_code)
					--left join dbo.good_receipt_note_detail_object_info grndoi on (grndoi.good_receipt_note_detail_id = grnd.id)
					inner join dbo.purchase_order					   po on (po.code								 = grn.purchase_order_code)
					left join dbo.purchase_order_detail				   pod on (
																				  pod.po_code						 = po.code
																				  and pod.id						 = grnd.purchase_order_detail_id
																			  )
					left join dbo.purchase_order_detail_object_info    podoi on podoi.good_receipt_note_detail_id = grnd.id
					left join dbo.supplier_selection_detail			   ssd on (ssd.id								 = pod.supplier_selection_detail_id)
					left join dbo.quotation_review_detail			   qrd on (qrd.id								 = ssd.quotation_detail_id)
					inner join dbo.procurement						   prc on (prc.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no))
					inner join dbo.procurement_request				   pr on (pr.code								 = prc.procurement_request_code)
					left join dbo.sys_general_subcode					sgs on (sgs.code							  = grnd.type_asset_code)
																		   and	 sgs.company_code				  = 'DSF'
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
				 ,@proc_type
				 ,@application_no
				 ,@plat_no
				 ,@engine_no
				 ,@chasis_no
				 --
				 ,@item_group_code
				 ,@requestor_code
				 ,@requestor_name
				 ,@vendor_code	
				 ,@vendor_name	
				 ,@type_code	
				 ,@type_name	
				 ,@category_code
				 ,@category_name
				 ,@receive_date
				 ,@branch_code_asset	
				 ,@branch_name_asset	
				 ,@pph_pct
				 ,@ppn_pct
				 ,@invoice_no
				 ,@domain
				 ,@imei
				 ,@is_rent
				 ,@asset_purpose
				 ,@spesification
				 ,@spaf_amount
				 ,@subvention_amount
				 ,@bpkb_no
				 ,@cover_note
				 ,@cover_note_date
				 ,@cover_exp_date
				 ,@file_path
				 ,@file_name
				 ,@opl_code
				 ,@stnk_no
				 ,@stnk_date
				 ,@stnk_exp_date
				 ,@stck_no
				 ,@stck_date
				 ,@stck_exp_date
				 ,@keur_no
				 ,@keur_date
				 ,@keur_exp_date
				 ,@ppn_grn
				 ,@pph_grn
				 ,@discount_grn
				 ,@good_receipt_note_detail_id
				 ,@built_year
				 ,@asset_colour
				 ,@type_name
				 ,@podoi_id

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
						)	
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

				--jika jumlah yang di request dan yang diterima sudah sama  
				--cek dulu apakah ada kode refference, jika tidak ada auto push ke AMS 
				--di comment workaround
				--if (@temp_reff <> '' and @procurement_type <> 'EXPENSE')
				--di comment workaround
				
				if (@temp_reff <> '')
				begin
               
					--jika type nya ASSET update ke final grn request detail langsung by asset no
					select	@category_type = category_type
					from	ifinbam.dbo.master_item
					where	code = @item_code ;
					
					select	@final_grn_request_detail_id = id
					from	dbo.final_grn_request_detail
					where	asset_no = @temp_reff ;

					select	@price_amount_final_grn			= sum(grnd.price_amount) - sum(grnd.discount_amount)
							,@original_amount_final_grn		= sum(grnd.price_amount) 
					from	dbo.good_receipt_note_detail grnd 
					where	id = @grn_detail_id
					
					if (@category_type = 'ASSET')
					BEGIN
					
						update	dbo.final_grn_request_detail
						set		grn_detail_id_asset		= @grn_detail_id
								,grn_code_asset			= @p_code
								,po_code_asset			= @purchase_order_code
								,supplier_name_asset	= @supplier_name
								,grn_receive_date		= @receive_date
								,plat_no				= @plat_no
								,engine_no				= @engine_no
								,chasis_no				= @chasis_no
								,grn_po_detail_id		= @podoi_id
								--
								,mod_by					= @p_mod_by
								,mod_date				= @p_mod_date
								,mod_ip_address			= @p_mod_ip_address
						where	id = @final_grn_request_detail_id ;

						if (@bpkb_no is null)
						begin
							set @document_type = N'COVERNOTE' ;
						end ;
						else
						begin
							set @document_type = N'BPKB' ;
						end ;
					end ;
					--jika type nya KAROSERI update ke final grn request detail langsung by asset no dan masuk ke table lookup karoseri
					else if (@category_type = 'KAROSERI')
					begin
					
					
						exec dbo.xsp_final_grn_request_detail_karoseri_lookup_insert @p_id					= @final_grn_request_detail_karoseri_lookup output
																					 ,@p_po_no				= @purchase_order_code
																					 ,@p_grn_code			= @p_code
																					 ,@p_grn_detail_id		= @grn_detail_id
																					 ,@p_item_code			= @item_code
																					 ,@p_item_name			= @item_name
																					 ,@p_supplier_name		= @supplier_name
																					 ,@p_application_no		= @application_no
																					 ,@p_cre_date			= @p_mod_date
																					 ,@p_cre_by				= @p_mod_by
																					 ,@p_cre_ip_address		= @p_mod_ip_address
																					 ,@p_mod_date			= @p_mod_date
																					 ,@p_mod_by				= @p_mod_by
																					 ,@p_mod_ip_address		= @p_mod_ip_address 
																					 ,@p_grn_po_detail_id	= @podoi_id

						if not exists
						(
							select	1
							from	dbo.final_grn_request_detail_karoseri
							where	final_grn_request_detail_id = @final_grn_request_detail_id
						)
						begin
							exec dbo.xsp_final_grn_request_detail_karoseri_insert @p_id										= @final_grn_request_detrail_karoseri
																				  ,@p_final_grn_request_detail_id			= @final_grn_request_detail_id
																				  ,@p_application_no						= @application_no
																				  ,@p_final_grn_request_detail_karoseri_id	= @final_grn_request_detail_karoseri_lookup
																				  ,@p_cre_date								= @p_mod_date
																				  ,@p_cre_by								= @p_mod_by
																				  ,@p_cre_ip_address						= @p_mod_ip_address
																				  ,@p_mod_date								= @p_mod_date
																				  ,@p_mod_by								= @p_mod_by
																				  ,@p_mod_ip_address						= @p_mod_ip_address 
																				  ,@p_grn_po_detail_id	= @podoi_id
						end ;
					end ;
					--jika type nya ACCESORIES update ke final grn request detail langsung by asset no dan masuk ke table lookup karoseri
					else if (@category_type = 'ACCESSORIES')
					begin
						exec dbo.xsp_final_grn_request_detail_accesories_lookup_insert @p_id				= @final_grn_request_detail_accesories_lookup output
																					   ,@p_po_no			= @purchase_order_code
																					   ,@p_grn_code			= @p_code
																					   ,@p_grn_detail_id	= @grn_detail_id
																					   ,@p_item_code		= @item_code
																					   ,@p_item_name		= @item_name
																					   ,@p_supplier_name	= @supplier_name
																					   ,@p_application_no	= @application_no
																					   ,@p_cre_date			= @p_mod_date
																					   ,@p_cre_by			= @p_mod_by
																					   ,@p_cre_ip_address	= @p_mod_ip_address
																					   ,@p_mod_date			= @p_mod_date
																					   ,@p_mod_by			= @p_mod_by
																					   ,@p_mod_ip_address	= @p_mod_ip_address 
																					    ,@p_grn_po_detail_id	= @podoi_id

						if not exists
						(
							select	1
							from	dbo.final_grn_request_detail_accesories
							where	final_grn_request_detail_id = @final_grn_request_detail_id
						)
						begin
							exec dbo.xsp_final_grn_request_detail_accesories_insert @p_id										= @final_grn_request_detail_accesories
																					,@p_final_grn_request_detail_id				= @final_grn_request_detail_id
																					,@p_application_no							= @application_no
																					,@p_final_grn_request_detail_accesories_id	= @final_grn_request_detail_accesories_lookup
																					,@p_cre_date								= @p_mod_date
																					,@p_cre_by									= @p_mod_by
																					,@p_cre_ip_address							= @p_mod_ip_address
																					,@p_mod_date								= @p_mod_date
																					,@p_mod_by									= @p_mod_by
																					,@p_mod_ip_address							= @p_mod_ip_address 
																					 ,@p_grn_po_detail_id	= @podoi_id
						end ;
					end ;
					else if (@category_type = 'MOBILISASI')
					begin
						begin -- create data final
							if not exists
							(
								select	1
								from	dbo.final_good_receipt_note					 fgrn
										left join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code = fgrn.code)
										left join dbo.good_receipt_note_detail		 grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
										left join dbo.good_receipt_note				 grn on (grn.code							  = grnd.good_receipt_note_code)
										left join dbo.purchase_order				 po on (po.code								  = grn.purchase_order_code)
								where	fgrn.reff_no			= @temp_reff
										and po.unit_from		= @unit_from
										and po.procurement_type = @procurement_type
							)
							begin
								--insert into FINAL GRN  
								exec dbo.xsp_final_good_receipt_note_insert @p_code = @code_final output
																			,@p_date = @date
																			,@p_complate_date = @date
																			,@p_status = 'HOLD'
																			,@p_reff_no = @temp_reff
																			,@p_total_amount = 0
																			,@p_total_item = 0
																			,@p_receive_item = 0
																			,@p_remark = @remark
																			,@p_cre_date = @p_mod_date
																			,@p_cre_by = @p_mod_by
																			,@p_cre_ip_address = @p_mod_ip_address
																			,@p_mod_date = @p_mod_date
																			,@p_mod_by = @p_mod_by
																			,@p_mod_ip_address = @p_mod_ip_address ;
							end ;
							else
							begin
								select	@code_final = fgrn.code
								from	dbo.final_good_receipt_note					 fgrn
										left join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code = fgrn.code)
										left join dbo.good_receipt_note_detail		 grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
										left join dbo.good_receipt_note				 grn on (grn.code							  = grnd.good_receipt_note_code)
										left join dbo.purchase_order				 po on (po.code								  = grn.purchase_order_code)
								where	fgrn.reff_no			= @temp_reff
										and po.unit_from		= @unit_from
										and po.procurement_type = @procurement_type ;
							end ;

							exec dbo.xsp_final_good_receipt_note_detail_insert @p_id							= 0
																			   ,@p_final_good_receipt_note_code = @code_final
																			   ,@p_good_receipt_note_detail_id	= @grn_detail_id
																			   ,@p_reff_no						= @temp_reff
																			   ,@p_reff_name					= 'GOOD RECEIPT NOTE'
																			   ,@p_item_code					= @item_code
																			   ,@p_item_name					= @item_name
																			   ,@p_type_asset_code				= @type_asset_code
																			   ,@p_item_category_code			= @item_category_code
																			   ,@p_item_category_name			= @item_category_name
																			   ,@p_item_merk_code				= @item_merk_code
																			   ,@p_item_merk_name				= @item_merk_name
																			   ,@p_item_model_code				= @item_model_code
																			   ,@p_item_model_name				= @item_model_name
																			   ,@p_item_type_code				= @item_type_code
																			   ,@p_item_type_name				= @item_type_name
																			   ,@p_uom_code						= @uom_code
																			   ,@p_uom_name						= @uom_name
																			   ,@p_price_amount					= @price_amount
																			   ,@p_specification				= @spesification
																			   ,@p_po_quantity					= @po_quantity
																			   ,@p_receive_quantity				= @receive_quantity
																			   ,@p_location_code				= ''
																			   ,@p_location_name				= ''
																			   ,@p_warehouse_code				= ''
																			   ,@p_warehouse_name				= ''
																			   ,@p_shipper_code					= @shipper_code
																			   ,@p_no_resi						= @no_resi
																			   ,@p_cre_date						= @p_mod_date
																			   ,@p_cre_by						= @p_mod_by
																			   ,@p_cre_ip_address				= @p_mod_ip_address
																			   ,@p_mod_date						= @p_mod_date
																			   ,@p_mod_by						= @p_mod_by
																			   ,@p_mod_ip_address				= @p_mod_ip_address 
																			    ,@p_po_object_id			= @podoi_id
						end ;

						-- push ke grn post
						exec dbo.xsp_good_receipt_note_post @p_code				= @p_code
															,@p_final_grn_code	= @code_final
															,@p_company_code	= 'DSF'
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address ;
					end ;

					--if (@total_request = @total_final)
					--begin
					--ini dicomment workaround
					--if (@proc_type <> 'MOBILISASI')
					--begin
					--	--cek dulu mana yang asset utamanya  
					--	select	@code_grn = grn.code
					--	from	dbo.final_good_receipt_note fgrn
					--			left join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.final_good_receipt_note_code = fgrn.code)
					--			left join dbo.good_receipt_note_detail grnd on (grnd.id									  = fgrnd.good_receipt_note_detail_id)
					--			left join dbo.good_receipt_note grn on (grn.code										  = grnd.good_receipt_note_code)
					--			left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id = grnd.id)
					--			left join dbo.sys_general_subcode sgs on (sgs.code										  = grnd.type_asset_code)
					--													 and   sgs.company_code							  = 'DSF'
					--			left join dbo.purchase_order po on (po.code												  = grn.purchase_order_code)
					--			--tambahan untuk ambil reff no di proc request  
					--			left join dbo.purchase_order_detail pod on (
					--														   pod.po_code								  = po.code
					--														   and pod.id								  = grnd.purchase_order_detail_id
					--													   )
					--			left join dbo.supplier_selection_detail ssd on (ssd.id									  = pod.supplier_selection_detail_id)
					--			left join dbo.quotation_review_detail qrd on (qrd.id									  = ssd.quotation_detail_id)
					--			left join dbo.procurement prc on (prc.code collate latin1_general_ci_as					  = qrd.reff_no)
					--			left join dbo.procurement prc2 on (prc2.code											  = ssd.reff_no)
					--			left join dbo.procurement_request pr on (pr.code										  = prc.procurement_request_code)
					--			left join dbo.procurement_request pr2 on (pr2.code										  = prc2.procurement_request_code)
					--			left join dbo.procurement_request_item pri on (pr.code									  = pri.procurement_request_code)
					--			left join dbo.procurement_request_item pri2 on (pr2.code								  = pri2.procurement_request_code)
					--	where	fgrn.code										  = @code_final
					--			and isnull(pri.category_type, pri2.category_type) = 'ASSET' ;
					--end ;
					--else
					--begin
					--	set @code_grn = @p_code ;
					--end ;
					--ini dicomment workaround

					-- push ke AMS, bikin journal  
					--exec dbo.xsp_good_receipt_note_post @p_code    = @code_grn  
					--         ,@p_company_code = 'DSF'  
					--         ,@p_mod_date  = @p_mod_date  
					--         ,@p_mod_by   = @p_mod_by  
					--         ,@p_mod_ip_address = @p_mod_ip_address  

					--ini dicomment workaround
					--exec dbo.xsp_good_receipt_note_post_for_multiple_asset @p_code				= @code_grn
					--													   ,@p_final_grn_code	= @code_final
					--													   ,@p_company_code		= 'DSF'
					--													   ,@p_mod_date			= @p_mod_date
					--													   ,@p_mod_by			= @p_mod_by
					--													   ,@p_mod_ip_address	= @p_mod_ip_address ;
					--ini dicomment workaround

					--ini dicomment workaround
					--update status di GRN  
					--update	dbo.good_receipt_note
					--set		status			= 'POST'
					--		--  
					--		,mod_date		= @p_mod_date
					--		,mod_by			= @p_mod_by
					--		,mod_ip_address = @p_mod_ip_address
					--where	code			= @p_code ;
					--ini dicomment workaround

					--ini dicomment workaround
					--update status di FINAL GRN  
					--update	dbo.final_good_receipt_note
					--set		status			= 'POST'
					--		,complate_date	= @journal_date
					--		--  
					--		,mod_date		= @p_mod_date
					--		,mod_by			= @p_mod_by
					--		,mod_ip_address = @p_mod_ip_address
					--where	code			= @code_final ;
					--ini dicomment workaround
					--end ;
					--else
				
					begin
						update	dbo.good_receipt_note
						set		status			= 'APPROVE' --POST'
								--  
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address = @p_mod_ip_address
						where	code = @p_code ;

						begin -- Update PO ketika barang diterima berkala  
							declare curr_update_po cursor fast_forward read_only for
							select	grnd.receive_quantity
									,grnd.po_quantity
									,pod.id
							from	dbo.good_receipt_note_detail		grnd
									left join dbo.good_receipt_note		grn on (grn.code							 = grnd.good_receipt_note_code)
									left join dbo.purchase_order		po on (po.code								 = grn.purchase_order_code)
									left join dbo.purchase_order_detail pod on (
																				   pod.po_code						 = po.code
																				   and grnd.purchase_order_detail_id = pod.id
																			   )
							where	grn.code				  = @p_code
									and grnd.receive_quantity <> 0 ;

							open curr_update_po ;

							fetch next from curr_update_po
							into @rcv_qty
								 ,@po_quantity
								 ,@purchase_order_detail_id ;

							while @@fetch_status = 0
							begin
								set @remaining_qty = @po_quantity - @rcv_qty ;

								update	dbo.purchase_order_detail
								set		order_remaining = @remaining_qty
										--  
										,mod_date		= @p_mod_date
										,mod_by			= @p_mod_by
										,mod_ip_address = @p_mod_ip_address
								where	id = @purchase_order_detail_id ;

								-- Update status Order jadi CLOSED  
								select	@sum_order_remaining = sum(pod.order_remaining)
								from	dbo.purchase_order					 po
										inner join dbo.purchase_order_detail pod on (pod.po_code = po.code)
								where	po.code = @po_no ;

								if (@sum_order_remaining = 0)
								begin
									update	dbo.purchase_order
									set		status			= 'CLOSED'
											--  
											,mod_date		= @p_mod_date
											,mod_by			= @p_mod_by
											,mod_ip_address = @p_mod_ip_address
									where	code = @po_no ;
								end ;

								fetch next from curr_update_po
								into @rcv_qty
									 ,@po_quantity
									 ,@purchase_order_detail_id ;
							end ;

							close curr_update_po ;
							deallocate curr_update_po ;
						end ;
					end ;
				end ;

				--else
				--begin
				--	-- cek dulu apakah sudah ada code asset nya untuk accesories/karoseri
				--	-- jika tidak ada maka masuk final grn request, jika ada maka akan langsung final
				--	declare curr_fa_code cursor fast_forward read_only for
				--	select	distinct
				--			pri.id
				--			,isnull(pri.fa_code,'')
				--			,pr.code
				--			,pr.request_date
				--			,pr.requestor_name
				--			,pr.branch_code
				--			,pr.branch_name
				--	from	dbo.good_receipt_note_detail					grnd
				--			left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
				--			left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
				--			left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
				--			left join dbo.purchase_order_detail				pod on (
				--																	   pod.po_code						  = po.code
				--																	   and pod.id						  = grnd.purchase_order_detail_id
				--																   )
				--			left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
				--			left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
				--			left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
				--			left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
				--			left join dbo.procurement_request_item			pri on (pr.code								  = pri.procurement_request_code)
				--	where	grnd.id = @grn_detail_id

				--	open curr_fa_code

				--	fetch next from curr_fa_code 
				--	into @proc_request_id
				--		,@proc_request_fa_code
				--		,@proc_request_code
				--		,@proc_request_date
				--		,@requestor_name
				--		,@proc_branch_code
				--		,@proc_branch_name

				--	while @@fetch_status = 0
				--	begin
				--			if(@proc_request_fa_code <> '')
				--			begin
				--				--insert into FINAL GRN  
				--				exec dbo.xsp_final_good_receipt_note_insert @p_code				= @code_final output
				--															,@p_date			= @date
				--															,@p_complate_date	= @date
				--															,@p_status			= 'HOLD'
				--															,@p_reff_no			= @temp_reff
				--															,@p_total_amount	= 0
				--															,@p_total_item		= 0
				--															,@p_receive_item	= 0
				--															,@p_remark			= @remark
				--															,@p_cre_date		= @p_mod_date
				--															,@p_cre_by			= @p_mod_by
				--															,@p_cre_ip_address	= @p_mod_ip_address
				--															,@p_mod_date		= @p_mod_date
				--															,@p_mod_by			= @p_mod_by
				--															,@p_mod_ip_address	= @p_mod_ip_address ;

				--				exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
				--															   ,@p_final_good_receipt_note_code		= @code_final
				--															   ,@p_good_receipt_note_detail_id		= @grn_detail_id
				--															   ,@p_reff_no							= @temp_reff
				--															   ,@p_reff_name						= 'GOOD RECEIPT NOTE'
				--															   ,@p_item_code						= @item_code
				--															   ,@p_item_name						= @item_name
				--															   ,@p_type_asset_code					= @type_asset_code
				--															   ,@p_item_category_code				= @item_category_code
				--															   ,@p_item_category_name				= @item_category_name
				--															   ,@p_item_merk_code					= @item_merk_code
				--															   ,@p_item_merk_name					= @item_merk_name
				--															   ,@p_item_model_code					= @item_model_code
				--															   ,@p_item_model_name					= @item_model_name
				--															   ,@p_item_type_code					= @item_type_code
				--															   ,@p_item_type_name					= @item_type_name
				--															   ,@p_uom_code							= @uom_code
				--															   ,@p_uom_name							= @uom_name
				--															   ,@p_price_amount						= @price_amount
				--															   ,@p_specification					= @spesification
				--															   ,@p_po_quantity						= @po_quantity
				--															   ,@p_receive_quantity					= @receive_quantity
				--															   ,@p_location_code					= ''
				--															   ,@p_location_name					= ''
				--															   ,@p_warehouse_code					= ''
				--															   ,@p_warehouse_name					= ''
				--															   ,@p_shipper_code						= @shipper_code
				--															   ,@p_no_resi							= @no_resi
				--															   ,@p_cre_date							= @p_mod_date
				--															   ,@p_cre_by							= @p_mod_by
				--															   ,@p_cre_ip_address					= @p_mod_ip_address
				--															   ,@p_mod_date							= @p_mod_date
				--															   ,@p_mod_by							= @p_mod_by
				--															   ,@p_mod_ip_address					= @p_mod_ip_address ;

				--				select	@code_grn = grn.code
				--				from	dbo.final_good_receipt_note						fgrn
				--						left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code  = fgrn.code)
				--						left join dbo.good_receipt_note_detail			grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
				--						left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
				--						left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id	  = grnd.id)
				--						left join dbo.sys_general_subcode				sgs on (sgs.code							  = grnd.type_asset_code)
				--																			   and	 sgs.company_code				  = 'DSF'
				--						left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
				--						--tambahan untuk ambil reff no di proc request  
				--						left join dbo.purchase_order_detail				pod on (
				--																				   pod.po_code						  = po.code
				--																				   and pod.id						  = grnd.purchase_order_detail_id
				--																			   )
				--						left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
				--						left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
				--						left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = qrd.reff_no)
				--						left join dbo.procurement						prc2 on (prc2.code							  = ssd.reff_no)
				--						left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
				--						left join dbo.procurement_request				pr2 on (pr2.code							  = prc2.procurement_request_code)
				--						left join dbo.procurement_request_item			pri on (pr.code								  = pri.procurement_request_code)
				--						left join dbo.procurement_request_item			pri2 on (pr2.code							  = pri2.procurement_request_code)
				--				where	fgrn.code = @code_final ;

				--				-- push ke AMS, bikin journal  
				--				exec dbo.xsp_good_receipt_note_post @p_code				= @p_code
				--													,@p_final_grn_code	= @code_final
				--													,@p_company_code	= 'DSF'
				--													,@p_mod_date		= @p_mod_date
				--													,@p_mod_by			= @p_mod_by
				--													,@p_mod_ip_address	= @p_mod_ip_address ;

				--				--exec dbo.xsp_good_receipt_note_post @p_code    = @p_code  
				--				--         ,@p_company_code = 'DSF'  
				--				--         ,@p_mod_date  = @p_mod_date  
				--				--         ,@p_mod_by   = @p_mod_by  
				--				--         ,@p_mod_ip_address = @p_mod_ip_address  

				--				--update status di FINAL GRN  
				--				update	dbo.final_good_receipt_note
				--				set		status			= 'POST'
				--						--  
				--						,mod_date		= @p_mod_date
				--						,mod_by			= @p_mod_by
				--						,mod_ip_address = @p_mod_ip_address
				--				where	code			= @code_final ;
				--			end
				--			else
				--			begin
				--				exec dbo.xsp_final_grn_request_insert @p_final_grn_request_no		= @final_grn_request_no output
				--													  ,@p_application_no			= ''
				--													  ,@p_procurement_request_code	= @proc_request_code
				--													  ,@p_branch_code				= @proc_branch_code
				--													  ,@p_branch_name				= @proc_branch_name
				--													  ,@p_requestor_name			= @requestor_name
				--													  ,@p_application_date			= null
				--													  ,@p_procurement_request_date	= @proc_request_date
				--													  ,@p_total_purchase_data		= 1
				--													  ,@p_status					= 'INCOMPLETE'
				--													  ,@p_is_manual					= '1'
				--													  ,@p_cre_date					= @p_mod_date
				--													  ,@p_cre_by					= @p_mod_by
				--													  ,@p_cre_ip_address			= @p_mod_ip_address
				--													  ,@p_mod_date					= @p_mod_date
				--													  ,@p_mod_by					= @p_mod_by
				--													  ,@p_mod_ip_address			= @p_mod_ip_address

				--				select @category_type = category_type 
				--				from ifinbam.dbo.master_item
				--				where code = @item_code

				--				if(@category_type = 'ASSET')
				--				begin
				--					exec dbo.xsp_final_grn_request_detail_insert @p_id						= 0
				--																 ,@p_final_grn_request_no	= @final_grn_request_no
				--																 ,@p_asset_no				= ''
				--																 ,@p_delivery_to			= ''
				--																 ,@p_year					= ''
				--																 ,@p_colour					= ''
				--																 ,@p_po_code_asset			= @purchase_order_code
				--																 ,@p_grn_code_asset			= @p_code
				--																 ,@p_grn_detail_id_asset	= @grn_detail_id
				--																 ,@p_supplier_name_asset	= @supplier_name
				--																 ,@p_grn_receive_date		= @receive_date
				--																 ,@p_status					= 'HOLD'
				--																 ,@p_cre_date				= @p_mod_date
				--																 ,@p_cre_by					= @p_mod_by
				--																 ,@p_cre_ip_address			= @p_mod_ip_address
				--																 ,@p_mod_date				= @p_mod_date
				--																 ,@p_mod_by					= @p_mod_by
				--																 ,@p_mod_ip_address			= @p_mod_ip_address
				--				end
				--				else if(@category_type in ('ACCESSORIES', 'KAROSERI'))
				--				begin
				--					exec dbo.xsp_final_grn_request_detail_insert @p_id						= 0
				--																 ,@p_final_grn_request_no	= @final_grn_request_no
				--																 ,@p_asset_no				= ''
				--																 ,@p_delivery_to			= ''
				--																 ,@p_year					= ''
				--																 ,@p_colour					= ''
				--																 ,@p_po_code_asset			= ''
				--																 ,@p_grn_code_asset			= ''
				--																 ,@p_grn_detail_id_asset	= ''
				--																 ,@p_supplier_name_asset	= ''
				--																 ,@p_grn_receive_date		= @receive_date
				--																 ,@p_status					= 'POST'
				--																 ,@p_cre_date				= @p_mod_date
				--																 ,@p_cre_by					= @p_mod_by
				--																 ,@p_cre_ip_address			= @p_mod_ip_address
				--																 ,@p_mod_date				= @p_mod_date
				--																 ,@p_mod_by					= @p_mod_by
				--																 ,@p_mod_ip_address			= @p_mod_ip_address
				--				end

				--			end

				--	    fetch next from curr_fa_code 
				--		into @proc_request_id
				--			,@proc_request_fa_code
				--			,@proc_request_code
				--			,@proc_request_date
				--			,@requestor_name
				--			,@proc_branch_code
				--			,@proc_branch_name
				--	end

				--	close curr_fa_code
				--	deallocate curr_fa_code
				--end ;
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
					 ,@proc_type
					 ,@application_no
					 ,@plat_no
					 ,@engine_no
					 ,@chasis_no
					 --
					 ,@item_group_code
					 ,@requestor_code
					 ,@requestor_name
					 ,@vendor_code	
					 ,@vendor_name	
					 ,@type_code	
					 ,@type_name	
					 ,@category_code
					 ,@category_name
					 ,@receive_date
					 ,@branch_code_asset	
					 ,@branch_name_asset	
					 ,@pph_pct
					 ,@ppn_pct
					 ,@invoice_no
					 ,@domain
					 ,@imei
					 ,@is_rent
					 ,@asset_purpose
					 ,@spesification
					 ,@spaf_amount
					 ,@subvention_amount
					 ,@bpkb_no
					 ,@cover_note
					 ,@cover_note_date
					 ,@cover_exp_date
					 ,@file_path
					 ,@file_name
					 ,@opl_code
					 ,@stnk_no
					 ,@stnk_date
					 ,@stnk_exp_date
					 ,@stck_no
					 ,@stck_date
					 ,@stck_exp_date
					 ,@keur_no
					 ,@keur_date
					 ,@keur_exp_date
					 ,@ppn_grn
					 ,@pph_grn
					 ,@discount_grn
					 ,@good_receipt_note_detail_id
					 ,@built_year
					 ,@asset_colour
					 ,@type_name
					 ,@podoi_id
			end ;

			close curr_grn_proc ;
			deallocate curr_grn_proc ;
			
			begin -- jika purchase manual
				declare curr_fa_code cursor fast_forward read_only for
				select	pri.id
						,isnull(pri.fa_code, '')
						,pr.code
						,pr.request_date
						,pr.requestor_name
						,pr.branch_code
						,pr.branch_name
						,po.code
						,grnd.id
						,pri.item_code
						,pri.item_name
						,grn.supplier_name
						,grn.receive_date
						,grnd.receive_quantity
						,podoi.plat_no
						,podoi.engine_no
						,podoi.chassis_no
						,isnull(pr.asset_no, '')
						,podoi.id
				from	dbo.good_receipt_note_detail					grnd
						left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
						left join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
						left join dbo.purchase_order_detail				pod on (
																				   pod.po_code						  = po.code
																				   and pod.id						  = grnd.purchase_order_detail_id
																			   )
						left join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id	  = grnd.id
																				 and   pod.id						  = podoi.purchase_order_detail_id
						left join dbo.supplier_selection_detail			ssd on (ssd.id								  = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
						left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
						left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
						left join dbo.procurement_request_item			pri on (
																				   pr.code							  = pri.procurement_request_code
																				   and	grnd.item_code				  = pri.item_code
																			   )
				where	grn.code = @p_code
				and		grnd.receive_quantity <> 0

				open curr_fa_code ;

				fetch next from curr_fa_code
				into @proc_request_id
					 ,@proc_request_fa_code
					 ,@proc_request_code
					 ,@proc_request_date
					 ,@requestor_name
					 ,@proc_branch_code
					 ,@proc_branch_name
					 ,@purchase_order_code
					 ,@grn_detail_id
					 ,@item_code
					 ,@item_name
					 ,@supplier_name
					 ,@receive_date
					 ,@receive_qty
					 ,@plat_no
					 ,@engine_no
					 ,@chasis_no
					 ,@temp_reff 
					 ,@podoi_id

				while @@fetch_status = 0
				BEGIN
				
					if (@temp_reff = '')
					begin
						if (@proc_request_fa_code <> '')
						BEGIN
							--insert into FINAL GRN  
							exec dbo.xsp_final_good_receipt_note_insert @p_code				= @code_final output
																		,@p_date			= @date
																		,@p_complate_date	= @date
																		,@p_status			= 'HOLD'
																		,@p_reff_no			= @temp_reff
																		,@p_total_amount	= 0
																		,@p_total_item		= 0
																		,@p_receive_item	= 0
																		,@p_remark			= @remark
																		,@p_cre_date		= @p_mod_date
																		,@p_cre_by			= @p_mod_by
																		,@p_cre_ip_address	= @p_mod_ip_address
																		,@p_mod_date		= @p_mod_date
																		,@p_mod_by			= @p_mod_by
																		,@p_mod_ip_address	= @p_mod_ip_address ;

							exec dbo.xsp_final_good_receipt_note_detail_insert @p_id							= 0
																			   ,@p_final_good_receipt_note_code = @code_final
																			   ,@p_good_receipt_note_detail_id	= @grn_detail_id
																			   ,@p_reff_no						= @temp_reff
																			   ,@p_reff_name					= 'GOOD RECEIPT NOTE'
																			   ,@p_item_code					= @item_code
																			   ,@p_item_name					= @item_name
																			   ,@p_type_asset_code				= @type_asset_code
																			   ,@p_item_category_code			= @item_category_code
																			   ,@p_item_category_name			= @item_category_name
																			   ,@p_item_merk_code				= @item_merk_code
																			   ,@p_item_merk_name				= @item_merk_name
																			   ,@p_item_model_code				= @item_model_code
																			   ,@p_item_model_name				= @item_model_name
																			   ,@p_item_type_code				= @item_type_code
																			   ,@p_item_type_name				= @item_type_name
																			   ,@p_uom_code						= @uom_code
																			   ,@p_uom_name						= @uom_name
																			   ,@p_price_amount					= @price_amount
																			   ,@p_specification				= @spesification
																			   ,@p_po_quantity					= @po_quantity
																			   ,@p_receive_quantity				= @receive_quantity
																			   ,@p_location_code				= ''
																			   ,@p_location_name				= ''
																			   ,@p_warehouse_code				= ''
																			   ,@p_warehouse_name				= ''
																			   ,@p_shipper_code					= @shipper_code
																			   ,@p_no_resi						= @no_resi
																			   ,@p_cre_date						= @p_mod_date
																			   ,@p_cre_by						= @p_mod_by
																			   ,@p_cre_ip_address				= @p_mod_ip_address
																			   ,@p_mod_date						= @p_mod_date
																			   ,@p_mod_by						= @p_mod_by
																			   ,@p_mod_ip_address				= @p_mod_ip_address 
																			    ,@p_po_object_id			= @podoi_id

							select	@code_grn = grn.code
							from	dbo.final_good_receipt_note						fgrn
									left join dbo.final_good_receipt_note_detail	fgrnd on (fgrnd.final_good_receipt_note_code  = fgrn.code)
									left join dbo.good_receipt_note_detail			grnd on (grnd.id							  = fgrnd.good_receipt_note_detail_id)
									left join dbo.good_receipt_note					grn on (grn.code							  = grnd.good_receipt_note_code)
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
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = qrd.reff_no)
									left join dbo.procurement						prc2 on (prc2.code							  = ssd.reff_no)
									left join dbo.procurement_request				pr on (pr.code								  = prc.procurement_request_code)
									left join dbo.procurement_request				pr2 on (pr2.code							  = prc2.procurement_request_code)
									left join dbo.procurement_request_item			pri on (pr.code								  = pri.procurement_request_code)
									left join dbo.procurement_request_item			pri2 on (pr2.code							  = pri2.procurement_request_code)
							where	fgrn.code = @code_final ;
							  
							-- push ke AMS, bikin journal  
							exec dbo.xsp_good_receipt_note_post @p_code				= @p_code
																,@p_final_grn_code	= @code_final
																,@p_company_code	= 'DSF'
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address ;
  
							--exec dbo.xsp_good_receipt_note_post @p_code    = @p_code  
							--         ,@p_company_code = 'DSF'  
							--         ,@p_mod_date  = @p_mod_date  
							--         ,@p_mod_by   = @p_mod_by  
							--         ,@p_mod_ip_address = @p_mod_ip_address  

							--update status di FINAL GRN  
							update	dbo.final_good_receipt_note
							set		status			= 'POST'
									--  
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code = @code_final ;
						end ;
						else
						begin   
							if not exists
							(
								select	1
								from	dbo.final_grn_request
								where	procurement_request_code = @proc_request_code
										and status				 = 'INCOMPLETE'
							)
							BEGIN
                            
								exec dbo.xsp_final_grn_request_insert @p_final_grn_request_no		= @final_grn_request_no output
																	  ,@p_application_no			= ''
																	  ,@p_procurement_request_code	= @proc_request_code
																	  ,@p_branch_code				= @proc_branch_code
																	  ,@p_branch_name				= @proc_branch_name
																	  ,@p_requestor_name			= @requestor_name
																	  ,@p_application_date			= null
																	  ,@p_procurement_request_date	= @proc_request_date
																	  ,@p_total_purchase_data		= 1
																	  ,@p_status					= 'INCOMPLETE'
																	  ,@p_is_manual					= '1'
																	  ,@p_cre_date					= @p_mod_date
																	  ,@p_cre_by					= @p_mod_by
																	  ,@p_cre_ip_address			= @p_mod_ip_address
																	  ,@p_mod_date					= @p_mod_date
																	  ,@p_mod_by					= @p_mod_by
																	  ,@p_mod_ip_address			= @p_mod_ip_address 
																	   
							end ;
							else
							begin
								select	@final_grn_request_no = final_grn_request_no
								from	dbo.final_grn_request
								where	procurement_request_code = @proc_request_code
										and status				 = 'INCOMPLETE' ;

								update	dbo.final_grn_request
								set		total_purchase_data = isnull(total_purchase_data,0) +1
								where	final_grn_request_no = @final_grn_request_no

							end ;

							select	@category_type = category_type
							from	ifinbam.dbo.master_item
							where	code = @item_code ;
							
							if (@category_type = 'ASSET')
							begin
								--set @count = 0
								--while @count < @receive_qty
								--begin
								exec dbo.xsp_final_grn_request_detail_insert @p_id						= 0
																			 ,@p_final_grn_request_no	= @final_grn_request_no
																			 ,@p_asset_no				= ''
																			 ,@p_delivery_to			= ''
																			 ,@p_year					= ''
																			 ,@p_colour					= ''
																			 ,@p_po_code_asset			= @purchase_order_code
																			 ,@p_grn_code_asset			= @p_code
																			 ,@p_grn_detail_id_asset	= @grn_detail_id
																			 ,@p_supplier_name_asset	= @supplier_name
																			 ,@p_grn_receive_date		= @receive_date
																			 ,@p_plat_no				= @plat_no
																			 ,@p_engine_no				= @engine_no
																			 ,@p_chasis_no				= @chasis_no
																			 ,@p_status					= 'HOLD'
																			 ,@p_cre_date				= @p_mod_date
																			 ,@p_cre_by					= @p_mod_by
																			 ,@p_cre_ip_address			= @p_mod_ip_address
																			 ,@p_mod_date				= @p_mod_date
																			 ,@p_mod_by					= @p_mod_by
																			 ,@p_mod_ip_address			= @p_mod_ip_address 
																			  ,@p_grn_po_detail_id		= @podoi_id
							--    set @count = @count + 1						 
							--end
							end ;
							else if (@category_type = 'KAROSERI')
							begin
								--set @count = 0 ;
								--while @count < @receive_qty
								begin
									exec dbo.xsp_final_grn_request_detail_insert @p_id						= @final_grn_request_detail_id output
																				 ,@p_final_grn_request_no	= @final_grn_request_no
																				 ,@p_asset_no				= ''
																				 ,@p_delivery_to			= ''
																				 ,@p_year					= ''
																				 ,@p_colour					= ''
																				 ,@p_po_code_asset			= ''
																				 ,@p_grn_code_asset			= ''
																				 ,@p_grn_detail_id_asset	= ''
																				 ,@p_supplier_name_asset	= ''
																				 ,@p_grn_receive_date		= null
																				 ,@p_plat_no				= ''
																				 ,@p_engine_no				= ''
																				 ,@p_chasis_no				= ''
																				 ,@p_status					= 'HOLD'
																				 ,@p_cre_date				= @p_mod_date
																				 ,@p_cre_by					= @p_mod_by
																				 ,@p_cre_ip_address			= @p_mod_ip_address
																				 ,@p_mod_date				= @p_mod_date
																				 ,@p_mod_by					= @p_mod_by
																				 ,@p_mod_ip_address			= @p_mod_ip_address 
																				  ,@p_grn_po_detail_id		= @podoi_id

									exec dbo.xsp_final_grn_request_detail_karoseri_lookup_insert @p_id					= @final_grn_request_detail_karoseri_lookup output
																								 ,@p_po_no				= @purchase_order_code
																								 ,@p_grn_code			= @p_code
																								 ,@p_grn_detail_id		= @grn_detail_id
																								 ,@p_item_code			= @item_code
																								 ,@p_item_name			= @item_name
																								 ,@p_supplier_name		= @supplier_name
																								 ,@p_application_no		= ''
																								 ,@p_cre_date			= @p_mod_date
																								 ,@p_cre_by				= @p_mod_by
																								 ,@p_cre_ip_address		= @p_mod_ip_address
																								 ,@p_mod_date			= @p_mod_date
																								 ,@p_mod_by				= @p_mod_by
																								 ,@p_mod_ip_address		= @p_mod_ip_address 
																								  ,@p_grn_po_detail_id	= @podoi_id

									if not exists
									(
										select	1
										from	dbo.final_grn_request_detail_karoseri
										where	final_grn_request_detail_id = @final_grn_request_detail_id
									)
									begin
										exec dbo.xsp_final_grn_request_detail_karoseri_insert @p_id										= @final_grn_request_detrail_karoseri
																							  ,@p_final_grn_request_detail_id			= @final_grn_request_detail_id
																							  ,@p_application_no						= ''
																							  ,@p_final_grn_request_detail_karoseri_id	= @final_grn_request_detail_karoseri_lookup
																							  ,@p_cre_date								= @p_mod_date
																							  ,@p_cre_by								= @p_mod_by
																							  ,@p_cre_ip_address						= @p_mod_ip_address
																							  ,@p_mod_date								= @p_mod_date
																							  ,@p_mod_by								= @p_mod_by
																							  ,@p_mod_ip_address						= @p_mod_ip_address 
																							   ,@p_grn_po_detail_id						= @podoi_id
									end ;

									--set @count = @count + 1 ;
								end ;
							end ;
							else if (@category_type = 'ACCESSORIES')
							begin
								--set @count = 0 ;
								--while @count < @receive_qty
								begin
									exec dbo.xsp_final_grn_request_detail_insert @p_id						= @final_grn_request_detail_id output
																				 ,@p_final_grn_request_no	= @final_grn_request_no
																				 ,@p_asset_no				= ''
																				 ,@p_delivery_to			= ''
																				 ,@p_year					= ''
																				 ,@p_colour					= ''
																				 ,@p_po_code_asset			= ''
																				 ,@p_grn_code_asset			= ''
																				 ,@p_grn_detail_id_asset	= ''
																				 ,@p_supplier_name_asset	= ''
																				 ,@p_grn_receive_date		= null
																				 ,@p_plat_no				= ''
																				 ,@p_engine_no				= ''
																				 ,@p_chasis_no				= ''
																				 ,@p_status					= 'HOLD'
																				 ,@p_cre_date				= @p_mod_date
																				 ,@p_cre_by					= @p_mod_by
																				 ,@p_cre_ip_address			= @p_mod_ip_address
																				 ,@p_mod_date				= @p_mod_date
																				 ,@p_mod_by					= @p_mod_by
																				 ,@p_mod_ip_address			= @p_mod_ip_address 
																				  ,@p_grn_po_detail_id		= @podoi_id

									exec dbo.xsp_final_grn_request_detail_accesories_lookup_insert @p_id				= @final_grn_request_detail_accesories_lookup output
																								   ,@p_po_no			= @purchase_order_code
																								   ,@p_grn_code			= @p_code
																								   ,@p_grn_detail_id	= @grn_detail_id
																								   ,@p_item_code		= @item_code
																								   ,@p_item_name		= @item_name
																								   ,@p_supplier_name	= @supplier_name
																								   ,@p_application_no	= ''
																								   ,@p_cre_date			= @p_mod_date
																								   ,@p_cre_by			= @p_mod_by
																								   ,@p_cre_ip_address	= @p_mod_ip_address
																								   ,@p_mod_date			= @p_mod_date
																								   ,@p_mod_by			= @p_mod_by
																								   ,@p_mod_ip_address	= @p_mod_ip_address 
																								    ,@p_grn_po_detail_id	= @podoi_id

									if not exists
									(
										select	1
										from	dbo.final_grn_request_detail_accesories
										where	final_grn_request_detail_id = @final_grn_request_detail_id
									)
									begin
										exec dbo.xsp_final_grn_request_detail_accesories_insert @p_id										= @final_grn_request_detail_accesories
																								,@p_final_grn_request_detail_id				= @final_grn_request_detail_id
																								,@p_application_no							= ''
																								,@p_final_grn_request_detail_accesories_id	= @final_grn_request_detail_accesories_lookup
																								,@p_cre_date								= @p_mod_date
																								,@p_cre_by									= @p_mod_by
																								,@p_cre_ip_address							= @p_mod_ip_address
																								,@p_mod_date								= @p_mod_date
																								,@p_mod_by									= @p_mod_by
																								,@p_mod_ip_address							= @p_mod_ip_address 
																								 ,@p_grn_po_detail_id						= @podoi_id
									end ;

									--set @count = @count + 1 ;
								end ;
							end ;
							
						-- sepria 04/06/2025: pindah ke luar lopping, karna dalam sp ini udah di looping per grn code
							--exec dbo.xsp_good_receipt_note_post_request_manual @p_code				= @p_code
							--												   ,@p_mod_date			= @p_mod_date
							--												   ,@p_mod_by			= @p_mod_by
							--												   ,@p_mod_ip_address	= @p_mod_ip_address ;
						end ;
					end ;

					fetch next from curr_fa_code
					into @proc_request_id
						 ,@proc_request_fa_code
						 ,@proc_request_code
						 ,@proc_request_date
						 ,@requestor_name
						 ,@proc_branch_code
						 ,@proc_branch_name
						 ,@purchase_order_code
						 ,@grn_detail_id
						 ,@item_code
						 ,@item_name
						 ,@supplier_name
						 ,@receive_date
						 ,@receive_qty
						 ,@plat_no
						 ,@engine_no
						 ,@chasis_no
						 ,@temp_reff 
						 ,@podoi_id

				end ;

				close curr_fa_code ;
				deallocate curr_fa_code ;

				-- sepria 04/06/2025: pindah ke luar lopping, karna dalam sp ini udah di looping per grn code
				exec dbo.xsp_good_receipt_note_post_request_manual @p_code				= @p_code
																	,@p_mod_date			= @p_mod_date
																	,@p_mod_by			= @p_mod_by
																	,@p_mod_ip_address	= @p_mod_ip_address ;

			end ;

		-- push ke AMS, bikin journal   
		-- diluar looping karena jika GRN lebih dari 1 item maka akan double  
		--exec dbo.xsp_good_receipt_note_post @p_code    = @p_code  
		--         ,@p_company_code = 'DSF'  
		--         ,@p_mod_date  = @p_mod_date  
		--         ,@p_mod_by   = @p_mod_by  
		--         ,@p_mod_ip_address = @p_mod_ip_address  
		end ;
		else --jika unit nya GTS atau RENT  
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
				 ,@branch_name ;

			while @@fetch_status = 0
			begin
				set @date = getdate() ;
				set @temp_reff = isnull(@reff_no_opl, '') ;

				begin --insert into FINAL GRN  
					exec dbo.xsp_final_good_receipt_note_insert @p_code				= @code_final output
																,@p_date			= @date
																,@p_complate_date	= @date
																,@p_status			= 'HOLD'
																,@p_reff_no			= @temp_reff
																,@p_total_amount	= 0
																,@p_total_item		= 0
																,@p_receive_item	= 0
																,@p_remark			= @remark
																,@p_cre_date		= @p_mod_date
																,@p_cre_by			= @p_mod_by
																,@p_cre_ip_address	= @p_mod_ip_address
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address ;

					exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																	   ,@p_final_good_receipt_note_code		= @code_final
																	   ,@p_good_receipt_note_detail_id		= @grn_detail_id
																	   ,@p_reff_no							= @temp_reff
																	   ,@p_reff_name						= 'GOOD RECEIPT NOTE'
																	   ,@p_item_code						= @item_code
																	   ,@p_item_name						= @item_name
																	   ,@p_type_asset_code					= @type_asset_code
																	   ,@p_item_category_code				= @item_category_code
																	   ,@p_item_category_name				= @item_category_name
																	   ,@p_item_merk_code					= @item_merk_code
																	   ,@p_item_merk_name					= @item_merk_name
																	   ,@p_item_model_code					= @item_model_code
																	   ,@p_item_model_name					= @item_model_name
																	   ,@p_item_type_code					= @item_type_code
																	   ,@p_item_type_name					= @item_type_name
																	   ,@p_uom_code							= @uom_code
																	   ,@p_uom_name							= @uom_name
																	   ,@p_price_amount						= @price_amount
																	   ,@p_specification					= @spesification
																	   ,@p_po_quantity						= @po_quantity
																	   ,@p_receive_quantity					= @receive_quantity
																	   ,@p_location_code					= ''
																	   ,@p_location_name					= ''
																	   ,@p_warehouse_code					= ''
																	   ,@p_warehouse_name					= ''
																	   ,@p_shipper_code						= @shipper_code
																	   ,@p_no_resi							= @no_resi
																	   ,@p_cre_date							= @p_mod_date
																	   ,@p_cre_by							= @p_mod_by
																	   ,@p_cre_ip_address					= @p_mod_ip_address
																	   ,@p_mod_date							= @p_mod_date
																	   ,@p_mod_by							= @p_mod_by
																	   ,@p_mod_ip_address					= @p_mod_ip_address 
																	   ,@p_po_object_id						= @podoi_id
				end ;
				
				begin
					--push ke AMS, bikin journal  
					exec dbo.xsp_good_receipt_note_post @p_code				= @p_code
														,@p_final_grn_code	= @code_final
														,@p_company_code	= 'DSF'
														,@p_mod_date		= @p_mod_date
														,@p_mod_by			= @p_mod_by
														,@p_mod_ip_address	= @p_mod_ip_address ;

					--update status di FINAL GRN  
					update	dbo.final_good_receipt_note
					set		status			= 'POST'
							--  
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	code = @code_final ;
				end ;

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
					 ,@branch_name ;
			end ;

			close curr_grn_proc ;
			deallocate curr_grn_proc ;

		--begin  
		-- -- push ke AMS, bikin journal  
		-- --exec dbo.xsp_good_receipt_note_post @p_code    = @p_code  
		-- --         ,@p_final_grn_code = @code_final  
		-- --         ,@p_company_code = 'DSF'  
		-- --         ,@p_mod_date  = @p_mod_date  
		-- --         ,@p_mod_by   = @p_mod_by  
		-- --         ,@p_mod_ip_address = @p_mod_ip_address  

		-- --update status di FINAL GRN  
		-- --update dbo.final_good_receipt_note  
		-- --set  status   = 'POST'  
		-- --  --  
		-- --  ,mod_date  = @p_mod_date  
		-- --  ,mod_by   = @p_mod_by  
		-- --  ,mod_ip_address = @p_mod_ip_address  
		-- --where code   = @code_final ;  
		--end  
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

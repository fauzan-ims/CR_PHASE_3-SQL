-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE dbo.xsp_good_receipt_note_proceed_appoval
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
			,@remark									 nvarchar(4000)
			,@procurement_type							 nvarchar(50)
			,@branch_code								 nvarchar(50)
			,@branch_name								 nvarchar(250)
			,@requestor_name							 nvarchar(250)
			,@count										 int
			,@grn_detail_id_object_info					 int
			,@receive_date								 datetime
			,@count2									 int
			,@is_validate								 nvarchar(1)
			,@total_amount_grn							 decimal(18, 2)
			,@nett_price_quo							 decimal(18, 2)
			,@type										 nvarchar(50)
			,@month										 nvarchar(25)
			,@year										 nvarchar(4)
			,@value										 int
			--
			,@request_code					nvarchar(50)
			,@request_code_doc				nvarchar(50)
			,@req_date						datetime
			,@interface_remarks				nvarchar(4000)
			,@reff_approval_category_code	nvarchar(50)
			,@table_name					nvarchar(50)
			,@primary_column				nvarchar(50)
			,@dimension_code				nvarchar(50)
			,@dim_value						nvarchar(50)
			,@approval_code					nvarchar(50)
			,@reff_dimension_code			nvarchar(50)
			,@reff_dimension_name			nvarchar(50)
			,@approval_path					nvarchar(4000)
			,@path							nvarchar(250)
			,@url_path						nvarchar(250)

	begin try

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


		-- sepria 12092025: pengecekan data gantung cr priority: validasi ini sementara saja, hingga konfirmasi kenapa bisa grn item ini status masih hold, namun di application assetnya sudah handover ke cust dengan asset code lain, padahal sebelum cr priority ini, gk bisa lakukan alokasi selain dr gts/replacement
		if exists (
			select	1						
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
					inner join ifinopl.dbo.application_asset aps on aps.asset_no = pr.asset_no
			where	grn.STATUS = 'HOLD' AND pr.PROCUREMENT_TYPE = 'PURCHASE' AND grn.CODE IN
					(
					N'DSF.GRN.2401.000164',
					N'DSF.GRN.2408.000007',
					N'DSF.GRN.2508.000050',
					N'DSF.GRN.2507.000134',
					N'DSF.GRN.2312.000369',
					N'DSF.GRN.2403.000049'
					)
					and	grn.code = @p_code
			)
			begin
			    raiserror ('Data Gantung ini sudah aktif kontrak pada Operating Lease(sudah Handover Asset) / Status Applikasi = Cancel. silahkan hub IT Dept untuk konfirmasi',16,1)
				return
			end



		-- INSERT KE APPROVAL INTERFACE
		begin
			if exists
			(
				select	1
				from	dbo.good_receipt_note
				where	code	   = @p_code
						and status = 'HOLD'
			)
			BEGIN

			declare curr_grn_appv cursor fast_forward read_only for
			select pr.branch_code
					,pr.branch_name
					,pr.remark
					,pr.receive_date
					,pr.mod_by
					,sem.name
					,po.procurement_type
			from dbo.good_receipt_note pr
			left join ifinsys.dbo.sys_employee_main sem on sem.code collate latin1_general_ci_as = pr.mod_by
			inner join dbo.purchase_order po on po.code = pr.purchase_order_code
			where pr.code = @p_code

			open curr_grn_appv

			fetch next from curr_grn_appv 
			into @branch_code
				,@branch_name
				,@remark
				,@req_date
				,@request_code
				,@requestor_name
				,@procurement_type

			while @@fetch_status = 0
			begin
			    set @interface_remarks = 'Approval ' + @procurement_type + ' good receipt note for ' + @p_code + ', branch ' + ': ' + @branch_name + ' ' + @remark ;

				select	@reff_approval_category_code = reff_approval_category_code
				from	dbo.master_approval
				where	code						 = 'GRNAPV' ;

				--select path di global param
				select	@url_path = value
				from	dbo.sys_global_param
				where	code = 'URL_PATH' ;

				select	@path = @url_path + value
				from	dbo.sys_global_param
				where	code = 'PATHGRN'

				--set approval path
				set	@approval_path = @path + @p_code

				exec dbo.xsp_proc_interface_approval_request_insert @p_code						= @request_code output
																	,@p_branch_code				= @branch_code
																	,@p_branch_name				= @branch_name
																	,@p_request_status			= 'HOLD'
																	,@p_request_date			= @req_date
																	,@p_request_amount			= 0
																	,@p_request_remarks			= @interface_remarks
																	,@p_reff_module_code		= 'IFINPROC'
																	,@p_reff_no					= @p_code
																	,@p_reff_name				= 'GOOD RECEIPT NOTE APPROVAL'
																	,@p_paths					= @approval_path
																	,@p_approval_category_code	= @reff_approval_category_code
																	,@p_approval_status			= 'HOLD'
																	,@p_requestor_code			= @request_code
																	,@p_requesttor_name			= @requestor_name
																	,@p_cre_date				= @p_mod_date	  
																	,@p_cre_by					= @p_mod_by		  
																	,@p_cre_ip_address			= @p_mod_ip_address
																	,@p_mod_date				= @p_mod_date	  
																	,@p_mod_by					= @p_mod_by		  
																	,@p_mod_ip_address			= @p_mod_ip_address

				declare curr_appv cursor fast_forward read_only for
				select 	approval_code
						,reff_dimension_code
						,reff_dimension_name
						,dimension_code
				from	dbo.master_approval_dimension
				where	approval_code = 'GRNAPV'

				open curr_appv

				fetch next from curr_appv 
				into @approval_code
					,@reff_dimension_code
					,@reff_dimension_name
					,@dimension_code

				while @@fetch_status = 0
				begin
					select	@table_name					 = table_name
							,@primary_column			 = primary_column
					from	dbo.sys_dimension
					where	code						 = @dimension_code
				
					exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
																,@p_reff_code	= @p_code
																,@p_reff_table	= 'GOOD_RECEIPT_NOTE'
																,@p_output		= @dim_value output ;

					exec dbo.xsp_proc_interface_approval_request_dimension_insert @p_id						= 0
																				  ,@p_request_code			= @request_code
																				  ,@p_dimension_code		= @reff_dimension_code
																				  ,@p_dimension_value		= @dim_value
																				  ,@p_cre_date				= @p_mod_date
																				  ,@p_cre_by				= @p_mod_by
																				  ,@p_cre_ip_address		= @p_mod_ip_address
																				  ,@p_mod_date				= @p_mod_date
																				  ,@p_mod_by				= @p_mod_by
																				  ,@p_mod_ip_address		= @p_mod_ip_address

					-- GRN TIDAK ADA DOCUMENT
					fetch next from curr_appv 
					into @approval_code
						,@reff_dimension_code
						,@reff_dimension_name
						,@dimension_code

				end

			close curr_appv
			deallocate curr_appv

			    fetch next from curr_grn_appv 
				into @branch_code
					,@branch_name
					,@remark
					,@req_date
					,@request_code
					,@requestor_name
					,@procurement_type

			end

			close curr_grn_appv
			deallocate curr_grn_appv

				update	dbo.good_receipt_note
				set		status = 'ON PROCESS'
						--  
						,mod_date = @p_mod_date
						,mod_by = @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code = @p_code ;
			end ;
			else
			begin
				set @msg = N'Data already process' ;

				raiserror(@msg, 16, 1) ;
			end ;
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

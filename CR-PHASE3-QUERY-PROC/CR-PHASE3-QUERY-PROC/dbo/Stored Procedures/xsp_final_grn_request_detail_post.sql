-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE dbo.xsp_final_grn_request_detail_post
(
	@p_id			   bigint
	--  
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
declare @msg									 nvarchar(max)
		,@date									 datetime	   = dbo.xfn_get_system_date()
		,@code_final							 nvarchar(50)
		,@asset_no								 nvarchar(50)
		,@grn_detail_id							 int
		,@item_code								 nvarchar(50)
		,@item_name								 nvarchar(250)
		,@type_asset_code						 nvarchar(50)
		,@item_category_code					 nvarchar(50)
		,@item_category_name					 nvarchar(250)
		,@item_merk_code						 nvarchar(50)
		,@item_merk_name						 nvarchar(250)
		,@item_model_code						 nvarchar(50)
		,@item_model_name						 nvarchar(250)
		,@item_type_code						 nvarchar(50)
		,@item_type_name						 nvarchar(250)
		,@uom_code								 nvarchar(50)
		,@uom_name								 nvarchar(250)
		,@price_amount							 decimal(18, 2)
		,@spesification							 nvarchar(4000)
		,@po_quantity							 int
		,@receive_quantity						 int
		,@procurement_type						 nvarchar(50)
		,@karoseri_grn_detail_id				 int
		,@karoseri_item_code					 nvarchar(50)
		,@karoseri_item_name					 nvarchar(250)
		,@karoseri_type_asset_code				 nvarchar(50)
		,@karoseri_item_category_code			 nvarchar(50)
		,@karoseri_item_category_name			 nvarchar(250)
		,@karoseri_item_merk_code				 nvarchar(50)
		,@karoseri_item_merk_name				 nvarchar(250)
		,@karoseri_item_model_code				 nvarchar(50)
		,@karoseri_item_model_name				 nvarchar(250)
		,@karoseri_item_type_code				 nvarchar(50)
		,@karoseri_item_type_name				 nvarchar(250)
		,@karoseri_uom_code						 nvarchar(50)
		,@karoseri_uom_name						 nvarchar(250)
		,@karoseri_price_amount					 decimal(18, 2)
		,@karoseri_spesification				 nvarchar(4000)
		,@karoseri_po_quantity					 int
		,@karoseri_receive_quantity				 int
		,@accesories_grn_detail_id				 int
		,@accesories_item_code					 nvarchar(50)
		,@accesories_item_name					 nvarchar(250)
		,@accesories_type_asset_code			 nvarchar(50)
		,@accesories_item_category_code			 nvarchar(50)
		,@accesories_item_category_name			 nvarchar(250)
		,@accesories_item_merk_code				 nvarchar(50)
		,@accesories_item_merk_name				 nvarchar(250)
		,@accesories_item_model_code			 nvarchar(50)
		,@accesories_item_model_name			 nvarchar(250)
		,@accesories_item_type_code				 nvarchar(50)
		,@accesories_item_type_name				 nvarchar(250)
		,@accesories_uom_code					 nvarchar(50)
		,@accesories_uom_name					 nvarchar(250)
		,@accesories_price_amount				 decimal(18, 2)
		,@accesories_spesification				 nvarchar(4000)
		,@accesories_po_quantity				 int
		,@accesories_receive_quantity			 int
		,@grn_code								 nvarchar(50)
		,@application_no						 nvarchar(50)
		,@code_final_grn_request				 nvarchar(50)
		,@category_type							 nvarchar(50)
		,@data_karoseri							 int
		,@data_accesories						 int
		,@data_request_karoseri					 int
		,@data_request_accesories				 int
		,@item_code_asset_proc					 nvarchar(50)
		,@item_code_asset_opl					 nvarchar(50)
		,@item_name_asset_opl					 nvarchar(250)
		,@is_manual								 nvarchar(1)
		,@accesories_id							 int
		,@karoseri_id							 int
		,@final_grn_request_no_others_accesories nvarchar(50)
		,@final_grn_request_no_others_karoseri	 nvarchar(50)
		,@final_grn_detail_id					 nvarchar(10)
		,@reff_no								 nvarchar(50)
		,@po_object_id_unit						bigint
		,@po_object_id_acc						bigint
		,@po_object_id_kar						bigint
		,@data_request_accesories_gps			int
		,@data_accesories_gps					int
		,@gps_vendor_code						nvarchar(50)
		,@gps_vendor_name						nvarchar(250)
		,@gps_received_date						datetime

	if exists (select 1 from final_grn_request_detail where id = @p_id and status <> 'HOLD')
	begin
	    set @msg = N'Transaction Already Post' ;
		raiserror(@msg, 16, 1) ;
	end

	begin try

	if exists 
			(
				select 1
				from	dbo.final_grn_request_detail a
				inner	join dbo.final_grn_request_detail_accesories b on b.final_grn_request_detail_id = a.id
				inner	join dbo.final_grn_request_detail_accesories_lookup c on c.id = b.final_grn_request_detail_accesories_id
				where	a.id = @p_id
				group by c.item_code
				having count(1)>1
			)
			begin
				set @msg = 'Asset cannot has same item accesories more than one'
				raiserror(@msg, 16, -1)
			end;


			if exists 
			(
				select count(1)
				from	dbo.final_grn_request_detail a
				inner	join dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI b on b.final_grn_request_detail_id = a.id
				inner	join dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI_LOOKUP c on c.id = b.FINAL_GRN_REQUEST_DETAIL_KAROSERI_ID
				where	a.id = @p_id
				group by c.item_code
				having count(1)>1
			)
			begin
				set @msg = 'Asset cannot has same item karoseri more than one'
				raiserror(@msg, 16, -1)
			end;

		select	@is_manual = fgr.is_manual
		from	dbo.final_grn_request_detail	 fgrd
				inner join dbo.final_grn_request fgr on fgr.final_grn_request_no = fgrd.final_grn_request_no
		where	fgrd.id = @p_id ;

		begin --validasi jika asset belum di GRN

			if exists
			(
				select	1
				from	dbo.final_grn_request_detail
				where	id = @p_id
						and isnull(PLAT_NO, '') = ''
			)
			begin
				set @msg = N'Please GRN or Choose Asset First.' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end

		if(@is_manual = '0')
		begin
			begin --validasi jika asset belum di GRN
				if exists
				(
					select	1
					from	dbo.final_grn_request_detail
					where	id							   = @p_id
							and isnull(po_code_asset, '')  = ''
							and isnull(grn_code_asset, '') = ''
				)
				begin
					set @msg = N'Please GRN asset first.' ;

					raiserror(@msg, 16, 1) ;
				end ;
			end

			begin --validasi jika karoseri/aksesoris belum di GRN			
				declare curr_validate cursor fast_forward read_only for
				select	mi.category_type
				from	dbo.final_grn_request_detail			fgrd
						inner join dbo.procurement_request		pr on fgrd.asset_no					= pr.asset_no
																	  and	pr.status				= 'APPROVE'
						inner join dbo.procurement_request_item pri on pri.procurement_request_code = pr.code
						inner join ifinbam.dbo.master_item		mi on mi.code						= pri.item_code
				where	fgrd.id = @p_id

				open curr_validate

				fetch next from curr_validate 
				into @category_type

				while @@fetch_status = 0
				begin
						if(@category_type = 'KAROSERI')
						begin
							if not exists
							(
								select	1
								from	dbo.final_grn_request_detail_karoseri
								where	final_grn_request_detail_id = @p_id
							)
							begin
								set @msg = N'Please add karoseri first.' ;

								raiserror(@msg, 16, 1) ;
							end ;
						end
						else if(@category_type = 'ACCESSORIES')
						begin
							if not exists
							(
								select	1
								from	dbo.final_grn_request_detail_accesories
								where	final_grn_request_detail_id = @p_id
							)
							begin
								set @msg = N'Please add accesories first.' ;

								raiserror(@msg, 16, 1) ;
							end ;
						end

				    fetch next from curr_validate 
					into @category_type
				end

				close curr_validate
				deallocate curr_validate
			end

			select	@asset_no = asset_no
			from	dbo.final_grn_request_detail
			where	id = @p_id ;

			begin -- validasi jumlah data karoseri
				select	@data_request_karoseri = count(a.code)
				from	dbo.procurement_request					a
						inner join dbo.procurement_request_item b on b.procurement_request_code = a.code
						inner join ifinbam.dbo.master_item mi on mi.code = b.item_code
				where	a.asset_no = @asset_no
				and mi.category_type = 'KAROSERI'
				and a.status = 'APPROVE'
				and a.procurement_type = 'PURCHASE'

				select	@data_karoseri = count(b.id)
				from	dbo.final_grn_request_detail					a
						left join dbo.final_grn_request_detail_karoseri b on a.id = b.final_grn_request_detail_id
				where	a.id = @p_id ;

				if(@data_request_karoseri <> @data_karoseri)
				begin
					set @msg = N'The data did not match with application, the data should be ' + convert(nvarchar(2), @data_request_karoseri) + ' karoseri.' ;

					raiserror(@msg, 16, 1) ;
				end
			end

			begin -- validasi jumlah data accesories
				select	@data_request_accesories = count(a.code)
				from	dbo.procurement_request					a
						inner join dbo.procurement_request_item b on b.procurement_request_code = a.code
						inner join ifinbam.dbo.master_item mi on mi.code = b.item_code
				where	a.asset_no = @asset_no 
				and		mi.category_type = 'ACCESSORIES'
				and		a.status = 'APPROVE'
				and		a.procurement_type = 'PURCHASE'

				select	@data_accesories = count(b.id)
				from	dbo.final_grn_request_detail					a
						left join dbo.final_grn_request_detail_accesories b on a.id = b.final_grn_request_detail_id
						left join dbo.final_grn_request_detail_accesories_lookup c on c.id = b.final_grn_request_detail_accesories_id
						left join dbo.purchase_order_detail_object_info podoi on podoi.id = c.grn_po_detail_id 
						left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
						--
						outer apply ( 
									select pr.procurement_type, mi.category_type
									from	dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code)
									left join ifinbam.dbo.master_item				mi ON mi.code = pri.item_code
									where ssd.id								  = pod.supplier_selection_detail_id
							)asv
				where	a.id = @p_id 
				and		category_type = 'ACCESSORIES'
				and		asv.procurement_type = 'PURCHASE'


				if(@data_request_accesories <> @data_accesories)
				begin
					set @msg = N'The data did not match with application, the data should be ' + convert(nvarchar(2), @data_request_accesories) + ' accesories.' ;

					raiserror(@msg, 16, 1) ;
				end
			END
            
			-- JIKA GPS MAU LANGSUNG DI FINAL, MAKA DIVALIDASI JUMLAHNYA
			begin
				select	@data_request_accesories_gps = count(a.code)
				from	dbo.procurement_request					a
						inner join dbo.procurement_request_item b on b.procurement_request_code = a.code
						inner join ifinbam.dbo.master_item mi on mi.code = b.item_code
				where	a.asset_no = @asset_no 
				and		mi.category_type = 'ACCESSORIES'
				and		a.status = 'APPROVE'
				and		a.procurement_type = 'EXPENSE'

				select	@data_accesories_gps = count(b.id)
				from	dbo.final_grn_request_detail					a
						left join dbo.final_grn_request_detail_accesories b on a.id = b.final_grn_request_detail_id
						left join dbo.final_grn_request_detail_accesories_lookup c on c.id = b.final_grn_request_detail_accesories_id
						left join dbo.purchase_order_detail_object_info podoi on podoi.id = c.grn_po_detail_id 
						left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
						--
						outer apply ( 
									select pr.procurement_type, mi.category_type, mi.description
									from	dbo.supplier_selection_detail		ssd 
									left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
									left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
									left join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
									left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code)
									left join ifinbam.dbo.master_item				mi ON mi.code = pri.item_code
									where ssd.id								  = pod.supplier_selection_detail_id
							)asv
				where	a.id = @p_id 
				and		category_type = 'ACCESSORIES'
				and		asv.procurement_type = 'EXPENSE'
				and		asv.description like '%GPS%'
			
				-- divalidasi hanya jika gpsnya di final bersamaan. 
				if(@data_accesories_gps > 0 and @data_request_accesories_gps <> @data_accesories_gps)
				begin
					set @msg = N'The data did not match with application, the data should be ' + convert(nvarchar(2), @data_request_accesories) + ' GPS accesories.' ;
					raiserror(@msg, 16, 1) ;
				end
				-- validasi jika asset yang di pasangkan (beli manual) sudah ada gps aktif   
				if isnull(@data_accesories_gps,0) <> 0
				begin
					if exists (   select 1
									from	dbo.final_grn_request_detail fgrn
											inner join ifinams.dbo.asset ast on ast.code = fgrn.asset_code
									where	id = @p_id
									and		isnull(ast.is_gps,'0') = '1'
									and		isnull(ast.gps_status,'') not in ('','UNSUBSCRIBE')
								)
					begin
						set @msg = N'Assets Already Have Active GPS';
						raiserror(@msg, 16, -1) ;   
					end
				end
			end

			begin --validasi item yang sama acessories
				declare curr_jml_item cursor fast_forward read_only for
				select	distinct
						c.item_code
				from	dbo.final_good_receipt_note_detail				   a
						inner join dbo.final_grn_request_detail_accesories b on a.id = b.final_grn_request_detail_id
						inner join dbo.final_grn_request_detail_accesories_lookup c on c.id = b.final_grn_request_detail_accesories_id
				where	a.id = @p_id ;

				open curr_jml_item

				fetch next from curr_jml_item 
				into @accesories_item_code

				while @@fetch_status = 0
				begin

					select	@data_accesories = count(b.id)
					from	dbo.final_grn_request_detail_accesories					  a
							inner join dbo.final_grn_request_detail_accesories_lookup b on a.final_grn_request_detail_accesories_id = b.id
					where	a.final_grn_request_detail_id = @p_id
					and b.item_code = @accesories_item_code

					if(@data_accesories > 1)
					begin
						set @msg = N'Cannot add the same item in 1 asset number.' ;
						raiserror(@msg, 16, 1) ;
					end

				    fetch next from curr_jml_item 
					into @accesories_item_code
				end

				begin -- close cursor
					if cursor_status('global', 'curr_jml_item') >= -1
					begin
						if cursor_status('global', 'curr_jml_item') > -1
						begin
							close curr_jml_item ;
						end ;

						deallocate curr_jml_item ;
					end ;
				end ;
			end

			begin -- validasi jika asset yang di proc nya beda dengan di application
			select	@item_code_asset_proc = grnd.item_code
			from	dbo.final_grn_request_detail			fgrd
					inner join dbo.good_receipt_note_detail grnd on fgrd.grn_detail_id_asset = grnd.id
			where	fgrd.id = @p_id ;


			select	@item_code_asset_opl = mvu.code
			from	ifinopl.dbo.application_asset_vehicle			 aav
					left join ifinopl.dbo.master_vehicle_category	 mvc on (mvc.code	= aav.vehicle_category_code)
					left join ifinopl.dbo.master_vehicle_subcategory mvs on (mvs.code	= aav.vehicle_subcategory_code)
					left join ifinopl.dbo.master_vehicle_merk		 mvm on (mvm.code	= aav.vehicle_merk_code)
					left join ifinopl.dbo.master_vehicle_model		 mvmo on (mvmo.code = aav.vehicle_model_code)
					left join ifinopl.dbo.master_vehicle_type		 mvt on (mvt.code	= aav.vehicle_type_code)
					left join ifinopl.dbo.master_vehicle_unit		 mvu on (mvu.code	= aav.vehicle_unit_code)
			where	aav.asset_no = @asset_no 

			if(@item_code_asset_proc <> @item_code_asset_opl)
			begin
				set @msg = N'Item for asset did not match with application.' ;
				raiserror(@msg, 16, 1) ;
			end
		end

			begin -- validasi jika karoseri yang dipilih tidak sesuai dengan di application

				--sepria 05/06/2025: ubah logic validasi
				if exists (	select	 mvu.code
							from	ifinopl.dbo.application_asset_detail	   aad
									inner join ifinopl.dbo.master_vehicle_unit mvu on aad.code = mvu.code
							where	aad.asset_no = @asset_no
							and aad.type = 'KAROSERI'
							and	aad.is_subject_to_purchase = '1'
							and mvu.code not in (	select fgrdkl.item_code
													from	dbo.final_grn_request_detail_karoseri					fgrdk
															inner join dbo.final_grn_request_detail_karoseri_lookup fgrdkl on fgrdk.final_grn_request_detail_karoseri_id = fgrdkl.id
													where	final_grn_request_detail_id = @p_id ))
				begin
					set @msg = N'Item for karoseri did not match'--' with application : ' + @item_name_asset_opl + '.';
					raiserror(@msg, 16, 1) ;
				end
			end

			begin -- validsai jika accesories yang dipilih tidak sesuai dengan di application

				--sepria 05/06/2025: ubah logic validasi
				if exists ( select	mvu.code
							from	ifinopl.dbo.application_asset_detail	   aad
									inner join ifinopl.dbo.master_vehicle_unit mvu on aad.code = mvu.code
							where	aad.asset_no = @asset_no
									and aad.type = 'ACCESSORIES'
									and	aad.is_subject_to_purchase = '1'
									and mvu.code not in (	select	fgrdal.item_code
															from	dbo.final_grn_request_detail_accesories					  fgrda
																	inner join dbo.final_grn_request_detail_accesories_lookup fgrdal on fgrda.final_grn_request_detail_accesories_id = fgrdal.id
															where	fgrda.final_grn_request_detail_id =  @p_id))
				begin
					set @msg = N'Item for accesories did not match'--' with application : ' + @item_name_asset_opl + '.' ;
					raiserror(@msg, 16, 1) ;
				end
			end

			declare curr_final_header cursor fast_forward read_only FOR
			--(-) sepria ubah select looping
            select	distinct
					fgrnd.asset_no
					,isnull(po.procurement_type,'')
					,fgrnd.grn_code_asset
					,fgr.application_no
					,fgrnd.id
			from	dbo.final_grn_request	fgr
					inner join dbo.final_grn_request_detail	fgrnd on fgr.final_grn_request_no			   = fgrnd.final_grn_request_no
					inner join dbo.purchase_order	po on po.code = fgrnd.po_code_asset
			where	fgrnd.id = @p_id ;

			open curr_final_header ;

			fetch next from curr_final_header
			into @asset_no
				 ,@procurement_type
				 ,@grn_code
				 ,@application_no
				 ,@final_grn_detail_id

			while @@fetch_status = 0
			begin
				set @reff_no = @final_grn_detail_id	--ISNULL(@asset_no, convert(nvarchar(10), @final_grn_detail_id))
			
				if (@procurement_type <> 'EXPENSE')
				BEGIN

					begin -- create final header
						exec dbo.xsp_final_good_receipt_note_insert @p_code				= @code_final output
																	,@p_date			= @date
																	,@p_complate_date	= @date
																	,@p_status			= 'POST'
																	,@p_reff_no			= @asset_no
																	,@p_total_amount	= 0
																	,@p_total_item		= 0
																	,@p_receive_item	= 0
																	,@p_remark			= ''
																	,@p_cre_date		= @p_mod_date
																	,@p_cre_by			= @p_mod_by
																	,@p_cre_ip_address	= @p_mod_ip_address
																	,@p_mod_date		= @p_mod_date
																	,@p_mod_by			= @p_mod_by
																	,@p_mod_ip_address	= @p_mod_ip_address ;
					end

					begin -- final detail untuk asset
						select	@grn_detail_id		 = grnd.id
								,@item_code			 = grnd.item_code
								,@item_name			 = grnd.item_name
								,@type_asset_code	 = grnd.type_asset_code
								,@item_category_code = grnd.item_category_code
								,@item_category_name = grnd.item_category_name
								,@item_merk_code	 = grnd.item_merk_code
								,@item_merk_name	 = grnd.item_merk_name
								,@item_model_code	 = grnd.item_model_code
								,@item_model_name	 = grnd.item_model_name
								,@item_type_code	 = grnd.item_type_code
								,@item_type_name	 = grnd.item_type_name
								,@uom_code			 = grnd.uom_code
								,@uom_name			 = grnd.uom_name
								,@price_amount		 = grnd.price_amount
								,@spesification		 = grnd.spesification
								,@po_quantity		 = grnd.po_quantity
								,@receive_quantity	 = grnd.receive_quantity
								,@po_object_id_unit		= fgrnd.grn_po_detail_id
						from	dbo.final_grn_request_detail			fgrnd
								inner join dbo.good_receipt_note_detail grnd on fgrnd.grn_detail_id_asset = grnd.id
						where	fgrnd.id = @p_id ;

						exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																		   ,@p_final_good_receipt_note_code		= @code_final
																		   ,@p_good_receipt_note_detail_id		= @grn_detail_id
																		   ,@p_reff_no							= @reff_no
																		   ,@p_reff_name						= 'FINAL GRN REQUEST'
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
																		   ,@p_shipper_code						= ''
																		   ,@p_no_resi							= ''
																		   ,@p_cre_date							= @p_mod_date
																		   ,@p_cre_by							= @p_mod_by
																		   ,@p_cre_ip_address					= @p_mod_ip_address
																		   ,@p_mod_date							= @p_mod_date
																		   ,@p_mod_by							= @p_mod_by
																		   ,@p_mod_ip_address					= @p_mod_ip_address 
																			,@p_po_object_id					= @po_object_id_unit

					end

					begin -- final detail untuk karoseri
						declare curr_final_detail cursor fast_forward read_only for
						select	grnd.id
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
								,fgrdk.grn_po_detail_id
						from	dbo.final_grn_request_detail			fgrnd
								inner join dbo.final_grn_request_detail_karoseri fgrdk on fgrnd.id = fgrdk.final_grn_request_detail_id
								inner join dbo.final_grn_request_detail_karoseri_lookup fgrdkn on fgrdkn.id = fgrdk.final_grn_request_detail_karoseri_id
								inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdkn.grn_detail_id
						where	fgrnd.id = @p_id ;

						open curr_final_detail ;

						fetch next from curr_final_detail
						into @karoseri_grn_detail_id
							 ,@karoseri_item_code
							 ,@karoseri_item_name
							 ,@karoseri_type_asset_code
							 ,@karoseri_item_category_code
							 ,@karoseri_item_category_name
							 ,@karoseri_item_merk_code
							 ,@karoseri_item_merk_name
							 ,@karoseri_item_model_code
							 ,@karoseri_item_model_name
							 ,@karoseri_item_type_code
							 ,@karoseri_item_type_name
							 ,@karoseri_uom_code
							 ,@karoseri_uom_name
							 ,@karoseri_price_amount
							 ,@karoseri_spesification
							 ,@karoseri_po_quantity
							 ,@karoseri_receive_quantity 
							 ,@po_object_id_kar

						while @@fetch_status = 0
						begin

							exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																			   ,@p_final_good_receipt_note_code		= @code_final
																			   ,@p_good_receipt_note_detail_id		= @karoseri_grn_detail_id
																			   ,@p_reff_no							= @reff_no
																			   ,@p_reff_name						= 'FINAL GRN REQUEST'
																			   ,@p_item_code						= @karoseri_item_code
																			   ,@p_item_name						= @karoseri_item_name
																			   ,@p_type_asset_code					= @karoseri_type_asset_code
																			   ,@p_item_category_code				= @karoseri_item_category_code
																			   ,@p_item_category_name				= @karoseri_item_category_name
																			   ,@p_item_merk_code					= @karoseri_item_merk_code
																			   ,@p_item_merk_name					= @karoseri_item_merk_name
																			   ,@p_item_model_code					= @karoseri_item_model_code
																			   ,@p_item_model_name					= @karoseri_item_model_name
																			   ,@p_item_type_code					= @karoseri_item_type_code
																			   ,@p_item_type_name					= @karoseri_item_type_name
																			   ,@p_uom_code							= @karoseri_uom_code
																			   ,@p_uom_name							= @karoseri_uom_name
																			   ,@p_price_amount						= @karoseri_price_amount
																			   ,@p_specification					= @karoseri_spesification
																			   ,@p_po_quantity						= @karoseri_po_quantity
																			   ,@p_receive_quantity					= @karoseri_receive_quantity
																			   ,@p_location_code					= ''
																			   ,@p_location_name					= ''
																			   ,@p_warehouse_code					= ''
																			   ,@p_warehouse_name					= ''
																			   ,@p_shipper_code						= ''
																			   ,@p_no_resi							= ''
																			   ,@p_cre_date							= @p_mod_date
																			   ,@p_cre_by							= @p_mod_by
																			   ,@p_cre_ip_address					= @p_mod_ip_address
																			   ,@p_mod_date							= @p_mod_date
																			   ,@p_mod_by							= @p_mod_by
																			   ,@p_mod_ip_address					= @p_mod_ip_address 
																				,@p_po_object_id					= @po_object_id_kar


						fetch next from curr_final_detail
						into @karoseri_grn_detail_id
							,@karoseri_item_code
							,@karoseri_item_name
							,@karoseri_type_asset_code
							,@karoseri_item_category_code
							,@karoseri_item_category_name
							,@karoseri_item_merk_code
							,@karoseri_item_merk_name
							,@karoseri_item_model_code
							,@karoseri_item_model_name
							,@karoseri_item_type_code
							,@karoseri_item_type_name
							,@karoseri_uom_code
							,@karoseri_uom_name
							,@karoseri_price_amount
							,@karoseri_spesification
							,@karoseri_po_quantity
							,@karoseri_receive_quantity 
							,@po_object_id_kar
						end ;

						close curr_final_detail ;
						deallocate curr_final_detail ;
					end
					
					begin --final detail untuk accesories
						declare curr_final_detail cursor fast_forward read_only for
						select	grnd.id
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
								,fgrda.grn_po_detail_id
						from	dbo.final_grn_request_detail			fgrnd
								inner join dbo.final_grn_request_detail_accesories fgrda on fgrnd.id = fgrda.final_grn_request_detail_id
								inner join dbo.final_grn_request_detail_accesories_lookup fgrdal on fgrdal.id = fgrda.final_grn_request_detail_accesories_id
								inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdal.grn_detail_id
								inner join dbo.good_receipt_note						  grn on (grn.code										  = fgrdal.grn_code)
								inner join dbo.purchase_order							  po on (po.code										  = grn.purchase_order_code)
								left join dbo.purchase_order_detail						  pod on (
																									 pod.po_code								  = po.code
																									 and pod.id									  = grnd.purchase_order_detail_id
																								 )
								left join dbo.supplier_selection_detail					  ssd on (ssd.id										  = pod.supplier_selection_detail_id)
								left join dbo.quotation_review_detail					  qrd on (qrd.id										  = ssd.quotation_detail_id)
								inner join dbo.procurement								  prc on (prc.code collate latin1_general_ci_as			  = isnull(qrd.reff_no, ssd.reff_no))
								inner join dbo.procurement_request						  pr on (pr.code										  = prc.procurement_request_code)
						where	fgrnd.id = @p_id
						and pr.procurement_type <> 'EXPENSE'

						open curr_final_detail ;

						fetch next from curr_final_detail
						into @accesories_grn_detail_id
							 ,@accesories_item_code
							 ,@accesories_item_name
							 ,@accesories_type_asset_code
							 ,@accesories_item_category_code
							 ,@accesories_item_category_name
							 ,@accesories_item_merk_code
							 ,@accesories_item_merk_name
							 ,@accesories_item_model_code
							 ,@accesories_item_model_name
							 ,@accesories_item_type_code
							 ,@accesories_item_type_name
							 ,@accesories_uom_code
							 ,@accesories_uom_name
							 ,@accesories_price_amount
							 ,@accesories_spesification
							 ,@accesories_po_quantity
							 ,@accesories_receive_quantity 
							 ,@po_object_id_acc

						while @@fetch_status = 0
						begin

							exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																			   ,@p_final_good_receipt_note_code		= @code_final
																			   ,@p_good_receipt_note_detail_id		= @accesories_grn_detail_id
																			   ,@p_reff_no							= @reff_no
																			   ,@p_reff_name						= 'FINAL GRN REQUEST'
																			   ,@p_item_code						= @accesories_item_code
																			   ,@p_item_name						= @accesories_item_name
																			   ,@p_type_asset_code					= @accesories_type_asset_code
																			   ,@p_item_category_code				= @accesories_item_category_code
																			   ,@p_item_category_name				= @accesories_item_category_name
																			   ,@p_item_merk_code					= @accesories_item_merk_code
																			   ,@p_item_merk_name					= @accesories_item_merk_name
																			   ,@p_item_model_code					= @accesories_item_model_code
																			   ,@p_item_model_name					= @accesories_item_model_name
																			   ,@p_item_type_code					= @accesories_item_type_code
																			   ,@p_item_type_name					= @accesories_item_type_name
																			   ,@p_uom_code							= @accesories_uom_code
																			   ,@p_uom_name							= @accesories_uom_name
																			   ,@p_price_amount						= @accesories_price_amount
																			   ,@p_specification					= @accesories_spesification
																			   ,@p_po_quantity						= @accesories_po_quantity
																			   ,@p_receive_quantity					= @accesories_receive_quantity
																			   ,@p_location_code					= ''
																			   ,@p_location_name					= ''
																			   ,@p_warehouse_code					= ''
																			   ,@p_warehouse_name					= ''
																			   ,@p_shipper_code						= ''
																			   ,@p_no_resi							= ''
																			   ,@p_cre_date							= @p_mod_date
																			   ,@p_cre_by							= @p_mod_by
																			   ,@p_cre_ip_address					= @p_mod_ip_address
																			   ,@p_mod_date							= @p_mod_date
																			   ,@p_mod_by							= @p_mod_by
																			   ,@p_mod_ip_address					= @p_mod_ip_address 
																				,@p_po_object_id					= @po_object_id_acc


						fetch next from curr_final_detail
						into @accesories_grn_detail_id
							,@accesories_item_code
							,@accesories_item_name
							,@accesories_type_asset_code
							,@accesories_item_category_code
							,@accesories_item_category_name
							,@accesories_item_merk_code
							,@accesories_item_merk_name
							,@accesories_item_model_code
							,@accesories_item_model_name
							,@accesories_item_type_code
							,@accesories_item_type_name
							,@accesories_uom_code
							,@accesories_uom_name
							,@accesories_price_amount
							,@accesories_spesification
							,@accesories_po_quantity
							,@accesories_receive_quantity 
							,@po_object_id_acc
						end ;

						close curr_final_detail ;
						deallocate curr_final_detail ;
					end
				
					begin -- jika kombinasi ada gps, set asset is_gps = 1
						if exists (	select	1
									from	dbo.final_grn_request_detail			fgrnd
											inner join dbo.final_grn_request_detail_accesories fgrda on fgrnd.id = fgrda.final_grn_request_detail_id
											inner join dbo.final_grn_request_detail_accesories_lookup fgrdal on fgrdal.id = fgrda.final_grn_request_detail_accesories_id
											inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdal.grn_detail_id
											inner join dbo.good_receipt_note						  grn on (grn.code										  = fgrdal.grn_code)
											inner join dbo.purchase_order							  po on (po.code										  = grn.purchase_order_code)
											left join dbo.purchase_order_detail						  pod on (
																												 pod.po_code								  = po.code
																												 and pod.id									  = grnd.purchase_order_detail_id
																											 )
											left join dbo.supplier_selection_detail					  ssd on (ssd.id										  = pod.supplier_selection_detail_id)
											left join dbo.quotation_review_detail					  qrd on (qrd.id										  = ssd.quotation_detail_id)
											inner join dbo.procurement								  prc on (prc.code collate latin1_general_ci_as			  = isnull(qrd.reff_no, ssd.reff_no))
											inner join dbo.procurement_request						  pr on (pr.code										  = prc.procurement_request_code)
									where	fgrnd.id = @p_id
									and		pr.procurement_type = 'EXPENSE'
									and		grnd.item_name like '%GPS%'
									)
								begin
								
									select	@gps_vendor_code	= grn.supplier_code
											,@gps_vendor_name	= grn.supplier_name
											,@gps_received_date	= grn.receive_date
									from	dbo.final_grn_request_detail			fgrnd
											inner join dbo.final_grn_request_detail_accesories fgrda on fgrnd.id = fgrda.final_grn_request_detail_id
											inner join dbo.final_grn_request_detail_accesories_lookup fgrdal on fgrdal.id = fgrda.final_grn_request_detail_accesories_id
											inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdal.grn_detail_id
											inner join dbo.good_receipt_note						  grn on (grn.code										  = fgrdal.grn_code)
											inner join dbo.purchase_order							  po on (po.code										  = grn.purchase_order_code)
											left join dbo.purchase_order_detail						  pod on (
																												 pod.po_code								  = po.code
																												 and pod.id									  = grnd.purchase_order_detail_id
																											 )
											left join dbo.supplier_selection_detail					  ssd on (ssd.id										  = pod.supplier_selection_detail_id)
											left join dbo.quotation_review_detail					  qrd on (qrd.id										  = ssd.quotation_detail_id)
											inner join dbo.procurement								  prc on (prc.code collate latin1_general_ci_as			  = isnull(qrd.reff_no, ssd.reff_no))
											inner join dbo.procurement_request						  pr on (pr.code										  = prc.procurement_request_code)
									where	fgrnd.id = @p_id
									and		pr.procurement_type = 'EXPENSE'
									and		grnd.item_name like '%GPS%'
								
									update	dbo.final_good_receipt_note
									set		is_gps = '1'
											,gps_vendor_code	= @gps_vendor_code
											,gps_vendor_name	= @gps_vendor_name
											,gps_received_date	= @gps_received_date
									where	code = @code_final
								end
					end

					begin -- grn post
						exec dbo.xsp_good_receipt_note_post_for_multiple_asset @p_code				= @grn_code
																			   ,@p_final_grn_code	= @code_final
																			   ,@p_company_code		= 'DSF'
																			   ,@p_application_no	= @application_no
																			   ,@p_mod_date			= @p_mod_date
																			   ,@p_mod_by			= @p_mod_by
																			   ,@p_mod_ip_address	= @p_mod_ip_address
																				,@p_po_object_id	= @po_object_id_unit



					end
				end 
				else
				begin

					exec dbo.xsp_final_good_receipt_note_insert @p_code				= @code_final output
																,@p_date			= @date
																,@p_complate_date	= @date
																,@p_status			= 'POST'
																,@p_reff_no			= @asset_no
																,@p_total_amount	= 0
																,@p_total_item		= 0
																,@p_receive_item	= 0
																,@p_remark			= ''
																,@p_cre_date		= @p_mod_date
																,@p_cre_by			= @p_mod_by
																,@p_cre_ip_address	= @p_mod_ip_address
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address ;

					begin--final detail untuk accesories
						declare curr_final_detail cursor fast_forward read_only for
						select	grnd.id
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
								,fgrda.grn_po_detail_id
						from	dbo.final_grn_request_detail			fgrnd
								inner join dbo.final_grn_request_detail_accesories fgrda on fgrnd.id = fgrda.final_grn_request_detail_id
								inner join dbo.final_grn_request_detail_accesories_lookup fgrdal on fgrdal.id = fgrda.final_grn_request_detail_accesories_id
								inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdal.grn_detail_id
								inner join dbo.good_receipt_note						  grn on (grn.code										  = fgrdal.grn_code)
								inner join dbo.purchase_order							  po on (po.code										  = grn.purchase_order_code)
								left join dbo.purchase_order_detail						  pod on (
																									 pod.po_code								  = po.code
																									 and pod.id									  = grnd.purchase_order_detail_id
																								 )
								left join dbo.supplier_selection_detail					  ssd on (ssd.id										  = pod.supplier_selection_detail_id)
								left join dbo.quotation_review_detail					  qrd on (qrd.id										  = ssd.quotation_detail_id)
								inner join dbo.procurement								  prc on (prc.code collate latin1_general_ci_as			  = isnull(qrd.reff_no, ssd.reff_no))
								inner join dbo.procurement_request						  pr on (pr.code										  = prc.procurement_request_code)
						where	fgrnd.id = @p_id
						and		pr.procurement_type = 'EXPENSE'

						open curr_final_detail ;

						fetch next from curr_final_detail
						into @accesories_grn_detail_id
							 ,@accesories_item_code
							 ,@accesories_item_name
							 ,@accesories_type_asset_code
							 ,@accesories_item_category_code
							 ,@accesories_item_category_name
							 ,@accesories_item_merk_code
							 ,@accesories_item_merk_name
							 ,@accesories_item_model_code
							 ,@accesories_item_model_name
							 ,@accesories_item_type_code
							 ,@accesories_item_type_name
							 ,@accesories_uom_code
							 ,@accesories_uom_name
							 ,@accesories_price_amount
							 ,@accesories_spesification
							 ,@accesories_po_quantity
							 ,@accesories_receive_quantity 
							 ,@po_object_id_acc

						while @@fetch_status = 0
						begin
					
							exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																			   ,@p_final_good_receipt_note_code		= @code_final
																			   ,@p_good_receipt_note_detail_id		= @accesories_grn_detail_id
																			   ,@p_reff_no							= @reff_no
																			   ,@p_reff_name						= 'FINAL GRN REQUEST'
																			   ,@p_item_code						= @accesories_item_code
																			   ,@p_item_name						= @accesories_item_name
																			   ,@p_type_asset_code					= @accesories_type_asset_code
																			   ,@p_item_category_code				= @accesories_item_category_code
																			   ,@p_item_category_name				= @accesories_item_category_name
																			   ,@p_item_merk_code					= @accesories_item_merk_code
																			   ,@p_item_merk_name					= @accesories_item_merk_name
																			   ,@p_item_model_code					= @accesories_item_model_code
																			   ,@p_item_model_name					= @accesories_item_model_name
																			   ,@p_item_type_code					= @accesories_item_type_code
																			   ,@p_item_type_name					= @accesories_item_type_name
																			   ,@p_uom_code							= @accesories_uom_code
																			   ,@p_uom_name							= @accesories_uom_name
																			   ,@p_price_amount						= @accesories_price_amount
																			   ,@p_specification					= @accesories_spesification
																			   ,@p_po_quantity						= @accesories_po_quantity
																			   ,@p_receive_quantity					= @accesories_receive_quantity
																			   ,@p_location_code					= ''
																			   ,@p_location_name					= ''
																			   ,@p_warehouse_code					= ''
																			   ,@p_warehouse_name					= ''
																			   ,@p_shipper_code						= ''
																			   ,@p_no_resi							= ''
																			   ,@p_cre_date							= @p_mod_date
																			   ,@p_cre_by							= @p_mod_by
																			   ,@p_cre_ip_address					= @p_mod_ip_address
																			   ,@p_mod_date							= @p_mod_date
																			   ,@p_mod_by							= @p_mod_by
																			   ,@p_mod_ip_address					= @p_mod_ip_address 
																				,@p_po_object_id					= @po_object_id_acc


						fetch next from curr_final_detail
						into @accesories_grn_detail_id
							,@accesories_item_code
							,@accesories_item_name
							,@accesories_type_asset_code
							,@accesories_item_category_code
							,@accesories_item_category_name
							,@accesories_item_merk_code
							,@accesories_item_merk_name
							,@accesories_item_model_code
							,@accesories_item_model_name
							,@accesories_item_type_code
							,@accesories_item_type_name
							,@accesories_uom_code
							,@accesories_uom_name
							,@accesories_price_amount
							,@accesories_spesification
							,@accesories_po_quantity
							,@accesories_receive_quantity 
							,@po_object_id_acc
						end ;

						close curr_final_detail ;
						deallocate curr_final_detail ;
					end

					begin -- grn post
						exec dbo.xsp_good_receipt_note_post_for_multiple_asset @p_code				= @grn_code
																			   ,@p_final_grn_code	= @code_final
																			   ,@p_company_code		= 'DSF'
																			   ,@p_application_no	= @application_no
																			   ,@p_mod_date			= @p_mod_date
																			   ,@p_mod_by			= @p_mod_by
																			   ,@p_mod_ip_address	= @p_mod_ip_address
																				,@p_po_object_id		= @po_object_id_unit

					end
				end

				fetch next from curr_final_header
				into @asset_no
					 ,@procurement_type
					 ,@grn_code
					 ,@application_no
					 ,@final_grn_detail_id

			end

			close curr_final_header ;
			deallocate curr_final_header ;

		end
		else
		begin
			begin --validasi item yang sama acessories
				declare curr_jml_item cursor fast_forward read_only for

				select	distinct
						c.item_code
				from	dbo.final_good_receipt_note_detail				   a
						inner join dbo.final_grn_request_detail_accesories b on a.id = b.final_grn_request_detail_id
						inner join dbo.final_grn_request_detail_accesories_lookup c on c.id = b.final_grn_request_detail_accesories_id
				where	a.id = @p_id ;

				open curr_jml_item

				fetch next from curr_jml_item 
				into @accesories_item_code

				while @@fetch_status = 0
				begin

					select	@data_accesories = count(b.id)
					from	dbo.final_grn_request_detail_accesories					  a
							inner join dbo.final_grn_request_detail_accesories_lookup b on a.final_grn_request_detail_accesories_id = b.id
					where	a.final_grn_request_detail_id = @p_id
					and b.item_code = @accesories_item_code

					if(@data_accesories > 1)
					begin
						set @msg = N'Cannot add the same accesories item in 1 asset.' ;
						raiserror(@msg, 16, 1) ;
					end

				    fetch next from curr_jml_item 
					into @accesories_item_code
				end

				begin -- close cursor
					if cursor_status('global', 'curr_jml_item') >= -1
					begin
						if cursor_status('global', 'curr_jml_item') > -1
						begin
							close curr_jml_item ;
						end ;

						deallocate curr_jml_item ;
					end ;
				end ;
			end

			begin --validasi item yang sama karoseri
				declare curr_jml_item cursor fast_forward read_only for
				select	distinct
						c.item_code
				from	dbo.final_good_receipt_note_detail				   a
						inner join dbo.final_grn_request_detail_karoseri b on a.id = b.final_grn_request_detail_id
						inner join dbo.final_grn_request_detail_karoseri_lookup c on c.id = b.final_grn_request_detail_karoseri_id
				where	a.id = @p_id ;

				open curr_jml_item

				fetch next from curr_jml_item 
				into @accesories_item_code

				while @@fetch_status = 0
				begin

					select	@data_accesories = count(b.id)
					from	dbo.final_grn_request_detail_karoseri					  a
							inner join dbo.final_grn_request_detail_karoseri_lookup b on a.final_grn_request_detail_karoseri_id = b.id
					where	a.final_grn_request_detail_id = @p_id
					and b.item_code = @accesories_item_code

					if(@data_accesories > 1)
					begin
						set @msg = N'Cannot add the same karoseri item in 1 asset.' ;
						raiserror(@msg, 16, 1) ;
					end

				    fetch next from curr_jml_item 
					into @accesories_item_code
				end

				begin -- close cursor
					if cursor_status('global', 'curr_jml_item') >= -1
					begin
						if cursor_status('global', 'curr_jml_item') > -1
						begin
							close curr_jml_item ;
						end ;

						deallocate curr_jml_item ;
					end ;
				end ;
			end

		--sepria CR Priority 20082025: jika asset di bukan dari stock
		begin
			if exists (	select	1
						from	dbo.final_grn_request	fgr
								inner join dbo.final_grn_request_detail	fgrnd on fgr.final_grn_request_no  = fgrnd.final_grn_request_no
								inner join dbo.purchase_order	po on po.code = fgrnd.po_code_asset
						where	fgrnd.id = @p_id
						)
			begin
				declare curr_final_header cursor fast_forward read_only FOR
				--(-) sepria ubah select looping
				select	distinct
						fgrnd.final_grn_request_no
						,isnull(po.procurement_type,'')
						,fgrnd.grn_code_asset
						,fgr.application_no
						,fgrnd.id
				from	dbo.final_grn_request	fgr
						inner join dbo.final_grn_request_detail	fgrnd on fgr.final_grn_request_no  = fgrnd.final_grn_request_no
						inner join dbo.purchase_order	po on po.code = fgrnd.po_code_asset
				where	fgrnd.id = @p_id ;


				open curr_final_header ;

				fetch next from curr_final_header
				into @asset_no
					 ,@procurement_type
					 ,@grn_code
					 ,@application_no
					 ,@final_grn_detail_id

				while @@fetch_status = 0
				begin

					if (@procurement_type <> 'EXPENSE')
					begin
						begin -- create final header
							exec dbo.xsp_final_good_receipt_note_insert @p_code				= @code_final output
																		,@p_date			= @date
																		,@p_complate_date	= @date
																		,@p_status			= 'POST'
																		,@p_reff_no			= @asset_no
																		,@p_total_amount	= 0
																		,@p_total_item		= 0
																		,@p_receive_item	= 0
																		,@p_remark			= ''
																		,@p_cre_date		= @p_mod_date
																		,@p_cre_by			= @p_mod_by
																		,@p_cre_ip_address	= @p_mod_ip_address
																		,@p_mod_date		= @p_mod_date
																		,@p_mod_by			= @p_mod_by
																		,@p_mod_ip_address	= @p_mod_ip_address ;
						end

						begin -- final detail untuk asset
							select	@grn_detail_id		 = grnd.id
									,@item_code			 = grnd.item_code
									,@item_name			 = grnd.item_name
									,@type_asset_code	 = grnd.type_asset_code
									,@item_category_code = grnd.item_category_code
									,@item_category_name = grnd.item_category_name
									,@item_merk_code	 = grnd.item_merk_code
									,@item_merk_name	 = grnd.item_merk_name
									,@item_model_code	 = grnd.item_model_code
									,@item_model_name	 = grnd.item_model_name
									,@item_type_code	 = grnd.item_type_code
									,@item_type_name	 = grnd.item_type_name
									,@uom_code			 = grnd.uom_code
									,@uom_name			 = grnd.uom_name
									,@price_amount		 = grnd.price_amount
									,@spesification		 = grnd.spesification
									,@po_quantity		 = grnd.po_quantity
									,@receive_quantity	 = grnd.receive_quantity
									,@po_object_id_unit	= fgrnd.grn_po_detail_id
							from	dbo.final_grn_request_detail			fgrnd
									inner join dbo.good_receipt_note_detail grnd on fgrnd.grn_detail_id_asset = grnd.id
							where	fgrnd.id = @p_id ;

							exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																			   ,@p_final_good_receipt_note_code		= @code_final
																			   ,@p_good_receipt_note_detail_id		= @grn_detail_id
																			   ,@p_reff_no							= @final_grn_detail_id
																			   ,@p_reff_name						= 'FINAL GRN REQUEST'
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
																			   ,@p_shipper_code						= ''
																			   ,@p_no_resi							= ''
																			   ,@p_cre_date							= @p_mod_date
																			   ,@p_cre_by							= @p_mod_by
																			   ,@p_cre_ip_address					= @p_mod_ip_address
																			   ,@p_mod_date							= @p_mod_date
																			   ,@p_mod_by							= @p_mod_by
																			   ,@p_mod_ip_address					= @p_mod_ip_address 
																				,@p_po_object_id					= @po_object_id_unit
						end

						begin -- final detail untuk karoseri
							declare curr_final_detail cursor fast_forward read_only for
							select	grnd.id
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
									,fgrdk.grn_po_detail_id
							from	dbo.final_grn_request_detail			fgrnd
									inner join dbo.final_grn_request_detail_karoseri fgrdk on fgrnd.id = fgrdk.final_grn_request_detail_id
									inner join dbo.final_grn_request_detail_karoseri_lookup fgrdkn on fgrdkn.id = fgrdk.final_grn_request_detail_karoseri_id
									inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdkn.grn_detail_id
							where	fgrnd.id = @p_id ;

							open curr_final_detail ;

							fetch next from curr_final_detail
							into @karoseri_grn_detail_id
								 ,@karoseri_item_code
								 ,@karoseri_item_name
								 ,@karoseri_type_asset_code
								 ,@karoseri_item_category_code
								 ,@karoseri_item_category_name
								 ,@karoseri_item_merk_code
								 ,@karoseri_item_merk_name
								 ,@karoseri_item_model_code
								 ,@karoseri_item_model_name
								 ,@karoseri_item_type_code
								 ,@karoseri_item_type_name
								 ,@karoseri_uom_code
								 ,@karoseri_uom_name
								 ,@karoseri_price_amount
								 ,@karoseri_spesification
								 ,@karoseri_po_quantity
								 ,@karoseri_receive_quantity 
								 ,@po_object_id_kar

							while @@fetch_status = 0
							begin

								exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																				   ,@p_final_good_receipt_note_code		= @code_final
																				   ,@p_good_receipt_note_detail_id		= @karoseri_grn_detail_id
																				   ,@p_reff_no							= @final_grn_detail_id
																				   ,@p_reff_name						= 'FINAL GRN REQUEST'
																				   ,@p_item_code						= @karoseri_item_code
																				   ,@p_item_name						= @karoseri_item_name
																				   ,@p_type_asset_code					= @karoseri_type_asset_code
																				   ,@p_item_category_code				= @karoseri_item_category_code
																				   ,@p_item_category_name				= @karoseri_item_category_name
																				   ,@p_item_merk_code					= @karoseri_item_merk_code
																				   ,@p_item_merk_name					= @karoseri_item_merk_name
																				   ,@p_item_model_code					= @karoseri_item_model_code
																				   ,@p_item_model_name					= @karoseri_item_model_name
																				   ,@p_item_type_code					= @karoseri_item_type_code
																				   ,@p_item_type_name					= @karoseri_item_type_name
																				   ,@p_uom_code							= @karoseri_uom_code
																				   ,@p_uom_name							= @karoseri_uom_name
																				   ,@p_price_amount						= @karoseri_price_amount
																				   ,@p_specification					= @karoseri_spesification
																				   ,@p_po_quantity						= @karoseri_po_quantity
																				   ,@p_receive_quantity					= @karoseri_receive_quantity
																				   ,@p_location_code					= ''
																				   ,@p_location_name					= ''
																				   ,@p_warehouse_code					= ''
																				   ,@p_warehouse_name					= ''
																				   ,@p_shipper_code						= ''
																				   ,@p_no_resi							= ''
																				   ,@p_cre_date							= @p_mod_date
																				   ,@p_cre_by							= @p_mod_by
																				   ,@p_cre_ip_address					= @p_mod_ip_address
																				   ,@p_mod_date							= @p_mod_date
																				   ,@p_mod_by							= @p_mod_by
																				   ,@p_mod_ip_address					= @p_mod_ip_address 
																					,@p_po_object_id					= @po_object_id_kar


							fetch next from curr_final_detail
							into @karoseri_grn_detail_id
								,@karoseri_item_code
								,@karoseri_item_name
								,@karoseri_type_asset_code
								,@karoseri_item_category_code
								,@karoseri_item_category_name
								,@karoseri_item_merk_code
								,@karoseri_item_merk_name
								,@karoseri_item_model_code
								,@karoseri_item_model_name
								,@karoseri_item_type_code
								,@karoseri_item_type_name
								,@karoseri_uom_code
								,@karoseri_uom_name
								,@karoseri_price_amount
								,@karoseri_spesification
								,@karoseri_po_quantity
								,@karoseri_receive_quantity 
								,@po_object_id_kar
							end ;

							close curr_final_detail ;
							deallocate curr_final_detail ;
						end

						begin --final detail untuk accesories
							declare curr_final_detail cursor fast_forward read_only for
							select	grnd.id
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
									,fgrda.grn_po_detail_id
							from	dbo.final_grn_request_detail			fgrnd
									inner join dbo.final_grn_request_detail_accesories fgrda on fgrnd.id = fgrda.final_grn_request_detail_id
									inner join dbo.final_grn_request_detail_accesories_lookup fgrdal on fgrdal.id = fgrda.final_grn_request_detail_accesories_id
									inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdal.grn_detail_id
									inner join dbo.good_receipt_note						  grn on (grn.code										  = fgrdal.grn_code)
									inner join dbo.purchase_order							  po on (po.code										  = grn.purchase_order_code)
									left join dbo.purchase_order_detail						  pod on (
																										 pod.po_code								  = po.code
																										 and pod.id									  = grnd.purchase_order_detail_id
																									 )
									left join dbo.supplier_selection_detail					  ssd on (ssd.id										  = pod.supplier_selection_detail_id)
									left join dbo.quotation_review_detail					  qrd on (qrd.id										  = ssd.quotation_detail_id)
									inner join dbo.procurement								  prc on (prc.code collate latin1_general_ci_as			  = isnull(qrd.reff_no, ssd.reff_no))
									inner join dbo.procurement_request						  pr on (pr.code										  = prc.procurement_request_code)
							where	fgrnd.id = @p_id
							and pr.procurement_type <> 'EXPENSE'

							open curr_final_detail ;

							fetch next from curr_final_detail
							into @accesories_grn_detail_id
								 ,@accesories_item_code
								 ,@accesories_item_name
								 ,@accesories_type_asset_code
								 ,@accesories_item_category_code
								 ,@accesories_item_category_name
								 ,@accesories_item_merk_code
								 ,@accesories_item_merk_name
								 ,@accesories_item_model_code
								 ,@accesories_item_model_name
								 ,@accesories_item_type_code
								 ,@accesories_item_type_name
								 ,@accesories_uom_code
								 ,@accesories_uom_name
								 ,@accesories_price_amount
								 ,@accesories_spesification
								 ,@accesories_po_quantity
								 ,@accesories_receive_quantity 
								 ,@po_object_id_acc

							while @@fetch_status = 0
							begin

								exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																				   ,@p_final_good_receipt_note_code		= @code_final
																				   ,@p_good_receipt_note_detail_id		= @accesories_grn_detail_id
																				   ,@p_reff_no							= @final_grn_detail_id
																				   ,@p_reff_name						= 'FINAL GRN REQUEST'
																				   ,@p_item_code						= @accesories_item_code
																				   ,@p_item_name						= @accesories_item_name
																				   ,@p_type_asset_code					= @accesories_type_asset_code
																				   ,@p_item_category_code				= @accesories_item_category_code
																				   ,@p_item_category_name				= @accesories_item_category_name
																				   ,@p_item_merk_code					= @accesories_item_merk_code
																				   ,@p_item_merk_name					= @accesories_item_merk_name
																				   ,@p_item_model_code					= @accesories_item_model_code
																				   ,@p_item_model_name					= @accesories_item_model_name
																				   ,@p_item_type_code					= @accesories_item_type_code
																				   ,@p_item_type_name					= @accesories_item_type_name
																				   ,@p_uom_code							= @accesories_uom_code
																				   ,@p_uom_name							= @accesories_uom_name
																				   ,@p_price_amount						= @accesories_price_amount
																				   ,@p_specification					= @accesories_spesification
																				   ,@p_po_quantity						= @accesories_po_quantity
																				   ,@p_receive_quantity					= @accesories_receive_quantity
																				   ,@p_location_code					= ''
																				   ,@p_location_name					= ''
																				   ,@p_warehouse_code					= ''
																				   ,@p_warehouse_name					= ''
																				   ,@p_shipper_code						= ''
																				   ,@p_no_resi							= ''
																				   ,@p_cre_date							= @p_mod_date
																				   ,@p_cre_by							= @p_mod_by
																				   ,@p_cre_ip_address					= @p_mod_ip_address
																				   ,@p_mod_date							= @p_mod_date
																				   ,@p_mod_by							= @p_mod_by
																				   ,@p_mod_ip_address					= @p_mod_ip_address 
																					,@p_po_object_id					= @po_object_id_acc


							fetch next from curr_final_detail
							into @accesories_grn_detail_id
								,@accesories_item_code
								,@accesories_item_name
								,@accesories_type_asset_code
								,@accesories_item_category_code
								,@accesories_item_category_name
								,@accesories_item_merk_code
								,@accesories_item_merk_name
								,@accesories_item_model_code
								,@accesories_item_model_name
								,@accesories_item_type_code
								,@accesories_item_type_name
								,@accesories_uom_code
								,@accesories_uom_name
								,@accesories_price_amount
								,@accesories_spesification
								,@accesories_po_quantity
								,@accesories_receive_quantity 
								,@po_object_id_acc
							end ;

							close curr_final_detail ;
							deallocate curr_final_detail ;
						end
					
						if(@application_no <> '')
						begin
							begin -- grn post
								exec dbo.xsp_good_receipt_note_post_for_multiple_asset @p_code				= @grn_code
																					   ,@p_final_grn_code	= @code_final
																					   ,@p_company_code		= 'DSF'
																					   ,@p_application_no	= @application_no
																					   ,@p_mod_date			= @p_mod_date
																					   ,@p_mod_by			= @p_mod_by
																					   ,@p_mod_ip_address	= @p_mod_ip_address
																						,@p_po_object_id	= @po_object_id_unit

							end
						end
						else
						begin
							exec dbo.xsp_good_receipt_note_post_for_multiple_asset_for_manual @p_code				= @grn_code
																							  ,@p_final_grn_code	= @code_final
																							  ,@p_company_code		= 'DSF'
																							  ,@p_application_no	= @application_no
																							  ,@p_mod_date			= @p_mod_date
																							  ,@p_mod_by			= @p_mod_by
																							  ,@p_mod_ip_address	= @p_mod_ip_address
																							  ,@p_po_object_id		= @po_object_id_unit

						end

					end 
					else
					begin

						exec dbo.xsp_final_good_receipt_note_insert @p_code				= @code_final output
																	,@p_date			= @date
																	,@p_complate_date	= @date
																	,@p_status			= 'POST'
																	,@p_reff_no			= @asset_no
																	,@p_total_amount	= 0
																	,@p_total_item		= 0
																	,@p_receive_item	= 0
																	,@p_remark			= ''
																	,@p_cre_date		= @p_mod_date
																	,@p_cre_by			= @p_mod_by
																	,@p_cre_ip_address	= @p_mod_ip_address
																	,@p_mod_date		= @p_mod_date
																	,@p_mod_by			= @p_mod_by
																	,@p_mod_ip_address	= @p_mod_ip_address ;

						begin--final detail untuk accesories
							declare curr_final_detail cursor fast_forward read_only for
							select	grnd.id
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
									,fgrda.GRN_PO_DETAIL_ID
							from	dbo.final_grn_request_detail			fgrnd
									inner join dbo.final_grn_request_detail_accesories fgrda on fgrnd.id = fgrda.final_grn_request_detail_id
									inner join dbo.final_grn_request_detail_accesories_lookup fgrdal on fgrdal.id = fgrda.final_grn_request_detail_accesories_id
									inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdal.grn_detail_id
									inner join dbo.good_receipt_note						  grn on (grn.code										  = fgrdal.grn_code)
									inner join dbo.purchase_order							  po on (po.code										  = grn.purchase_order_code)
									left join dbo.purchase_order_detail						  pod on (
																										 pod.po_code								  = po.code
																										 and pod.id									  = grnd.purchase_order_detail_id
																									 )
									left join dbo.supplier_selection_detail					  ssd on (ssd.id										  = pod.supplier_selection_detail_id)
									left join dbo.quotation_review_detail					  qrd on (qrd.id										  = ssd.quotation_detail_id)
									inner join dbo.procurement								  prc on (prc.code collate latin1_general_ci_as			  = isnull(qrd.reff_no, ssd.reff_no))
									inner join dbo.procurement_request						  pr on (pr.code										  = prc.procurement_request_code)
							where	fgrnd.id = @p_id
							and pr.procurement_type = 'EXPENSE'

							open curr_final_detail ;

							fetch next from curr_final_detail
							into @accesories_grn_detail_id
								 ,@accesories_item_code
								 ,@accesories_item_name
								 ,@accesories_type_asset_code
								 ,@accesories_item_category_code
								 ,@accesories_item_category_name
								 ,@accesories_item_merk_code
								 ,@accesories_item_merk_name
								 ,@accesories_item_model_code
								 ,@accesories_item_model_name
								 ,@accesories_item_type_code
								 ,@accesories_item_type_name
								 ,@accesories_uom_code
								 ,@accesories_uom_name
								 ,@accesories_price_amount
								 ,@accesories_spesification
								 ,@accesories_po_quantity
								 ,@accesories_receive_quantity 
								 ,@po_object_id_acc

							while @@fetch_status = 0
							begin

								exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																				   ,@p_final_good_receipt_note_code		= @code_final
																				   ,@p_good_receipt_note_detail_id		= @accesories_grn_detail_id
																				   ,@p_reff_no							= @asset_no
																				   ,@p_reff_name						= 'FINAL GRN REQUEST'
																				   ,@p_item_code						= @accesories_item_code
																				   ,@p_item_name						= @accesories_item_name
																				   ,@p_type_asset_code					= @accesories_type_asset_code
																				   ,@p_item_category_code				= @accesories_item_category_code
																				   ,@p_item_category_name				= @accesories_item_category_name
																				   ,@p_item_merk_code					= @accesories_item_merk_code
																				   ,@p_item_merk_name					= @accesories_item_merk_name
																				   ,@p_item_model_code					= @accesories_item_model_code
																				   ,@p_item_model_name					= @accesories_item_model_name
																				   ,@p_item_type_code					= @accesories_item_type_code
																				   ,@p_item_type_name					= @accesories_item_type_name
																				   ,@p_uom_code							= @accesories_uom_code
																				   ,@p_uom_name							= @accesories_uom_name
																				   ,@p_price_amount						= @accesories_price_amount
																				   ,@p_specification					= @accesories_spesification
																				   ,@p_po_quantity						= @accesories_po_quantity
																				   ,@p_receive_quantity					= @accesories_receive_quantity
																				   ,@p_location_code					= ''
																				   ,@p_location_name					= ''
																				   ,@p_warehouse_code					= ''
																				   ,@p_warehouse_name					= ''
																				   ,@p_shipper_code						= ''
																				   ,@p_no_resi							= ''
																				   ,@p_cre_date							= @p_mod_date
																				   ,@p_cre_by							= @p_mod_by
																				   ,@p_cre_ip_address					= @p_mod_ip_address
																				   ,@p_mod_date							= @p_mod_date
																				   ,@p_mod_by							= @p_mod_by
																				   ,@p_mod_ip_address					= @p_mod_ip_address 
																					,@p_po_object_id					= @po_object_id_acc


							fetch next from curr_final_detail
							into @accesories_grn_detail_id
								,@accesories_item_code
								,@accesories_item_name
								,@accesories_type_asset_code
								,@accesories_item_category_code
								,@accesories_item_category_name
								,@accesories_item_merk_code
								,@accesories_item_merk_name
								,@accesories_item_model_code
								,@accesories_item_model_name
								,@accesories_item_type_code
								,@accesories_item_type_name
								,@accesories_uom_code
								,@accesories_uom_name
								,@accesories_price_amount
								,@accesories_spesification
								,@accesories_po_quantity
								,@accesories_receive_quantity 
								,@po_object_id_acc
							end ;

							close curr_final_detail ;
							deallocate curr_final_detail ;
						end

						begin -- grn post
							exec dbo.xsp_good_receipt_note_post_for_multiple_asset @p_code				= @grn_code
																				   ,@p_final_grn_code	= @code_final
																				   ,@p_company_code		= 'DSF'
																				   ,@p_application_no	= @application_no
																				   ,@p_mod_date			= @p_mod_date
																				   ,@p_mod_by			= @p_mod_by
																				   ,@p_mod_ip_address	= @p_mod_ip_address
																					,@p_po_object_id		= @po_object_id_unit

						end
					end

					fetch next from curr_final_header
					into @asset_no
						 ,@procurement_type
						 ,@grn_code
						 ,@application_no
						 ,@final_grn_detail_id
				end

				close curr_final_header ;
				deallocate curr_final_header ;

			end
			else 	-- jika beli manual untuk aksesoris/karoseri saja dan asset di pilih dari stock
            begin

					declare curr_final_header cursor fast_forward read_only FOR
					--(-) sepria ubah select looping
					select	distinct
							fgrnd.final_grn_request_no
							,fgrnd.grn_code_asset
							,fgr.application_no
							,fgrnd.id
					from	dbo.final_grn_request	fgr
							inner join dbo.final_grn_request_detail	fgrnd on fgr.final_grn_request_no  = fgrnd.final_grn_request_no
					where	fgrnd.id = @p_id ;
					open curr_final_header ;

					fetch next from curr_final_header
					into @asset_no
						 ,@grn_code
						 ,@application_no
						 ,@final_grn_detail_id

					while @@fetch_status = 0
					begin

							begin -- create final header
								exec dbo.xsp_final_good_receipt_note_insert @p_code				= @code_final output
																			,@p_date			= @date
																			,@p_complate_date	= @date
																			,@p_status			= 'POST'
																			,@p_reff_no			= @asset_no
																			,@p_total_amount	= 0
																			,@p_total_item		= 0
																			,@p_receive_item	= 0
																			,@p_remark			= ''
																			,@p_cre_date		= @p_mod_date
																			,@p_cre_by			= @p_mod_by
																			,@p_cre_ip_address	= @p_mod_ip_address
																			,@p_mod_date		= @p_mod_date
																			,@p_mod_by			= @p_mod_by
																			,@p_mod_ip_address	= @p_mod_ip_address ;
							end

							begin -- final detail untuk karoseri
								declare curr_final_detail cursor fast_forward read_only for
								select	grnd.id
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
										,fgrdk.grn_po_detail_id
										,grnd.good_receipt_note_code
								from	dbo.final_grn_request_detail			fgrnd
										inner join dbo.final_grn_request_detail_karoseri fgrdk on fgrnd.id = fgrdk.final_grn_request_detail_id
										inner join dbo.final_grn_request_detail_karoseri_lookup fgrdkn on fgrdkn.id = fgrdk.final_grn_request_detail_karoseri_id
										inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdkn.grn_detail_id
								where	fgrnd.id = @p_id ;

								open curr_final_detail ;

								fetch next from curr_final_detail
								into @karoseri_grn_detail_id
									 ,@karoseri_item_code
									 ,@karoseri_item_name
									 ,@karoseri_type_asset_code
									 ,@karoseri_item_category_code
									 ,@karoseri_item_category_name
									 ,@karoseri_item_merk_code
									 ,@karoseri_item_merk_name
									 ,@karoseri_item_model_code
									 ,@karoseri_item_model_name
									 ,@karoseri_item_type_code
									 ,@karoseri_item_type_name
									 ,@karoseri_uom_code
									 ,@karoseri_uom_name
									 ,@karoseri_price_amount
									 ,@karoseri_spesification
									 ,@karoseri_po_quantity
									 ,@karoseri_receive_quantity 
									 ,@po_object_id_kar
									 ,@grn_code

								while @@fetch_status = 0
								begin

									exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																					   ,@p_final_good_receipt_note_code		= @code_final
																					   ,@p_good_receipt_note_detail_id		= @karoseri_grn_detail_id
																					   ,@p_reff_no							= @final_grn_detail_id
																					   ,@p_reff_name						= 'FINAL GRN REQUEST'
																					   ,@p_item_code						= @karoseri_item_code
																					   ,@p_item_name						= @karoseri_item_name
																					   ,@p_type_asset_code					= @karoseri_type_asset_code
																					   ,@p_item_category_code				= @karoseri_item_category_code
																					   ,@p_item_category_name				= @karoseri_item_category_name
																					   ,@p_item_merk_code					= @karoseri_item_merk_code
																					   ,@p_item_merk_name					= @karoseri_item_merk_name
																					   ,@p_item_model_code					= @karoseri_item_model_code
																					   ,@p_item_model_name					= @karoseri_item_model_name
																					   ,@p_item_type_code					= @karoseri_item_type_code
																					   ,@p_item_type_name					= @karoseri_item_type_name
																					   ,@p_uom_code							= @karoseri_uom_code
																					   ,@p_uom_name							= @karoseri_uom_name
																					   ,@p_price_amount						= @karoseri_price_amount
																					   ,@p_specification					= @karoseri_spesification
																					   ,@p_po_quantity						= @karoseri_po_quantity
																					   ,@p_receive_quantity					= @karoseri_receive_quantity
																					   ,@p_location_code					= ''
																					   ,@p_location_name					= ''
																					   ,@p_warehouse_code					= ''
																					   ,@p_warehouse_name					= ''
																					   ,@p_shipper_code						= ''
																					   ,@p_no_resi							= ''
																					   ,@p_cre_date							= @p_mod_date
																					   ,@p_cre_by							= @p_mod_by
																					   ,@p_cre_ip_address					= @p_mod_ip_address
																					   ,@p_mod_date							= @p_mod_date
																					   ,@p_mod_by							= @p_mod_by
																					   ,@p_mod_ip_address					= @p_mod_ip_address 
																						,@p_po_object_id					= @po_object_id_kar

								begin
									exec dbo.xsp_xsp_ap_invoice_registration_post_to_asset @p_code				= @grn_code
																							,@p_final_grn_code	= @code_final
																							,@p_company_code	= 'dsf'
																							,@p_mod_date		= @p_mod_date
																							,@p_mod_by			= @p_mod_by
																							,@p_mod_ip_address	= @p_mod_ip_address
																							,@p_po_object_id	= @po_object_id_kar
								end

								fetch next from curr_final_detail
								into @karoseri_grn_detail_id
									,@karoseri_item_code
									,@karoseri_item_name
									,@karoseri_type_asset_code
									,@karoseri_item_category_code
									,@karoseri_item_category_name
									,@karoseri_item_merk_code
									,@karoseri_item_merk_name
									,@karoseri_item_model_code
									,@karoseri_item_model_name
									,@karoseri_item_type_code
									,@karoseri_item_type_name
									,@karoseri_uom_code
									,@karoseri_uom_name
									,@karoseri_price_amount
									,@karoseri_spesification
									,@karoseri_po_quantity
									,@karoseri_receive_quantity 
									,@po_object_id_kar
									,@grn_code
								end ;

								close curr_final_detail ;
								deallocate curr_final_detail ;
							end

							begin --final detail untuk accesories
								declare curr_final_detail cursor fast_forward read_only for
								select	grnd.id
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
										,fgrda.grn_po_detail_id
										,grnd.good_receipt_note_code
								from	dbo.final_grn_request_detail			fgrnd
										inner join dbo.final_grn_request_detail_accesories fgrda on fgrnd.id = fgrda.final_grn_request_detail_id
										inner join dbo.final_grn_request_detail_accesories_lookup fgrdal on fgrdal.id = fgrda.final_grn_request_detail_accesories_id
										inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrdal.grn_detail_id
										inner join dbo.good_receipt_note						  grn on (grn.code										  = fgrdal.grn_code)
										inner join dbo.purchase_order							  po on (po.code										  = grn.purchase_order_code)
										left join dbo.purchase_order_detail						  pod on (
																											 pod.po_code								  = po.code
																											 and pod.id									  = grnd.purchase_order_detail_id
																										 )
										left join dbo.supplier_selection_detail					  ssd on (ssd.id										  = pod.supplier_selection_detail_id)
										left join dbo.quotation_review_detail					  qrd on (qrd.id										  = ssd.quotation_detail_id)
										inner join dbo.procurement								  prc on (prc.code collate latin1_general_ci_as			  = isnull(qrd.reff_no, ssd.reff_no))
										inner join dbo.procurement_request						  pr on (pr.code										  = prc.procurement_request_code)
								where	fgrnd.id = @p_id
								and		pr.procurement_type <> 'EXPENSE'

								open curr_final_detail ;

								fetch next from curr_final_detail
								into @accesories_grn_detail_id
									 ,@accesories_item_code
									 ,@accesories_item_name
									 ,@accesories_type_asset_code
									 ,@accesories_item_category_code
									 ,@accesories_item_category_name
									 ,@accesories_item_merk_code
									 ,@accesories_item_merk_name
									 ,@accesories_item_model_code
									 ,@accesories_item_model_name
									 ,@accesories_item_type_code
									 ,@accesories_item_type_name
									 ,@accesories_uom_code
									 ,@accesories_uom_name
									 ,@accesories_price_amount
									 ,@accesories_spesification
									 ,@accesories_po_quantity
									 ,@accesories_receive_quantity 
									 ,@po_object_id_acc
									 ,@grn_code

								while @@fetch_status = 0
								begin

									exec dbo.xsp_final_good_receipt_note_detail_insert @p_id								= 0
																					   ,@p_final_good_receipt_note_code		= @code_final
																					   ,@p_good_receipt_note_detail_id		= @accesories_grn_detail_id
																					   ,@p_reff_no							= @final_grn_detail_id
																					   ,@p_reff_name						= 'FINAL GRN REQUEST'
																					   ,@p_item_code						= @accesories_item_code
																					   ,@p_item_name						= @accesories_item_name
																					   ,@p_type_asset_code					= @accesories_type_asset_code
																					   ,@p_item_category_code				= @accesories_item_category_code
																					   ,@p_item_category_name				= @accesories_item_category_name
																					   ,@p_item_merk_code					= @accesories_item_merk_code
																					   ,@p_item_merk_name					= @accesories_item_merk_name
																					   ,@p_item_model_code					= @accesories_item_model_code
																					   ,@p_item_model_name					= @accesories_item_model_name
																					   ,@p_item_type_code					= @accesories_item_type_code
																					   ,@p_item_type_name					= @accesories_item_type_name
																					   ,@p_uom_code							= @accesories_uom_code
																					   ,@p_uom_name							= @accesories_uom_name
																					   ,@p_price_amount						= @accesories_price_amount
																					   ,@p_specification					= @accesories_spesification
																					   ,@p_po_quantity						= @accesories_po_quantity
																					   ,@p_receive_quantity					= @accesories_receive_quantity
																					   ,@p_location_code					= ''
																					   ,@p_location_name					= ''
																					   ,@p_warehouse_code					= ''
																					   ,@p_warehouse_name					= ''
																					   ,@p_shipper_code						= ''
																					   ,@p_no_resi							= ''
																					   ,@p_cre_date							= @p_mod_date
																					   ,@p_cre_by							= @p_mod_by
																					   ,@p_cre_ip_address					= @p_mod_ip_address
																					   ,@p_mod_date							= @p_mod_date
																					   ,@p_mod_by							= @p_mod_by
																					   ,@p_mod_ip_address					= @p_mod_ip_address 
																						,@p_po_object_id					= @po_object_id_acc


								begin

									exec dbo.xsp_xsp_ap_invoice_registration_post_to_asset @p_code					= @grn_code
																							,@p_final_grn_code		= @code_final
																							,@p_company_code		= 'DSF'
																							,@p_mod_date			= @p_mod_date
																							,@p_mod_by				= @p_mod_by
																							,@p_mod_ip_address		= @p_mod_ip_address
																							,@p_po_object_id		= @po_object_id_acc
								end

								fetch next from curr_final_detail
								into @accesories_grn_detail_id
									,@accesories_item_code
									,@accesories_item_name
									,@accesories_type_asset_code
									,@accesories_item_category_code
									,@accesories_item_category_name
									,@accesories_item_merk_code
									,@accesories_item_merk_name
									,@accesories_item_model_code
									,@accesories_item_model_name
									,@accesories_item_type_code
									,@accesories_item_type_name
									,@accesories_uom_code
									,@accesories_uom_name
									,@accesories_price_amount
									,@accesories_spesification
									,@accesories_po_quantity
									,@accesories_receive_quantity 
									,@po_object_id_acc
									,@grn_code
								end ;

								close curr_final_detail ;
								deallocate curr_final_detail ;
							end

							begin
								exec dbo.xsp_good_receipt_note_post_for_multiple_asset_for_manual @p_code				= @grn_code
																								  ,@p_final_grn_code	= @code_final
																								  ,@p_company_code		= 'DSF'
																								  ,@p_application_no	= @application_no
																								  ,@p_mod_date			= @p_mod_date
																								  ,@p_mod_by			= @p_mod_by
																								  ,@p_mod_ip_address	= @p_mod_ip_address
																								  ,@p_po_object_id		= 0	-- kirim po id 0 biar tidak tergenerate lagi final grn nya

							end

						fetch next from curr_final_header
						into @asset_no
							 ,@grn_code
							 ,@application_no
							 ,@final_grn_detail_id
					end

					close curr_final_header ;
					deallocate curr_final_header ;

            end
		end
		end

			update	dbo.final_grn_request_detail
			set		status			= 'POST'
					,mod_by			= @p_mod_by
					,mod_date		= @p_mod_date
					,mod_ip_address = @p_mod_ip_address
			where	id = @p_id ;

			--(+) sepria 22/07/2025: update ke grn detail untuk id fgrn request
			update dbo.good_receipt_note_detail
			set		fgrn_detail_id = @p_id
			where	id in (select good_receipt_note_detail_id from dbo.final_good_receipt_note_detail where final_good_receipt_note_code = @code_final)

			select	@code_final_grn_request = final_grn_request_no
			from	dbo.final_grn_request_detail
			where	id = @p_id ;

			if not exists
			(
				select	1
				from	dbo.final_grn_request_detail
				where	final_grn_request_no = @code_final_grn_request
						and status			 <> 'POST'
			)
			begin
				update	dbo.final_grn_request
				set		status					= 'COMPLETE'
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	final_grn_request_no	= @code_final_grn_request ;
			end ;

			declare curr_update_final_request cursor fast_forward read_only for
			select	c.id
					,e.id
					,a.final_grn_request_no
			from	dbo.final_grn_request_detail							 a
					left join dbo.final_grn_request_detail_accesories		 b on a.id							= b.final_grn_request_detail_id
					left join dbo.final_grn_request_detail_accesories_lookup c on c.id							= b.final_grn_request_detail_accesories_id
					left join dbo.final_grn_request_detail_karoseri			 d on d.final_grn_request_detail_id = a.id
					left join dbo.final_grn_request_detail_karoseri_lookup	 e on e.id							= d.final_grn_request_detail_karoseri_id
			where	a.id = @p_id ;

			open curr_update_final_request

			fetch next from curr_update_final_request 
			into @accesories_id
				,@karoseri_id
				,@code_final_grn_request

			while @@fetch_status = 0
			begin
				select	@final_grn_request_no_others_accesories = c.final_grn_request_no
				from	dbo.final_grn_request_detail_accesories					  a
						inner join dbo.final_grn_request_detail_accesories_lookup b on a.final_grn_request_detail_accesories_id = b.id
						inner join dbo.final_grn_request_detail c on c.id = a.final_grn_request_detail_id
				where	a.final_grn_request_detail_accesories_id = @accesories_id
				and c.final_grn_request_no <> @code_final_grn_request

				select	@final_grn_request_no_others_karoseri = c.final_grn_request_no
				from	dbo.final_grn_request_detail_karoseri					  a
						inner join dbo.final_grn_request_detail_karoseri_lookup b on a.final_grn_request_detail_karoseri_id = b.id
						inner join dbo.final_grn_request_detail c on c.id = a.final_grn_request_detail_id
				where	a.final_grn_request_detail_karoseri_id = @karoseri_id
				and c.final_grn_request_no <> @code_final_grn_request

				if not exists
				(
					select	1
					from	dbo.final_grn_request_detail
					where	final_grn_request_no = @final_grn_request_no_others_accesories
							and status			 <> 'POST'
				)
				begin
					update	dbo.final_grn_request
					set		status					= 'COMPLETE'
							,mod_date				= @p_mod_date
							,mod_by					= @p_mod_by
							,mod_ip_address			= @p_mod_ip_address
					where	final_grn_request_no	= @final_grn_request_no_others_accesories ;
				end ;

				if not exists
				(
					select	1
					from	dbo.final_grn_request_detail
					where	final_grn_request_no = @final_grn_request_no_others_karoseri
							and status			 <> 'POST'
				)
				begin
					update	dbo.final_grn_request
					set		status					= 'COMPLETE'
							,mod_date				= @p_mod_date
							,mod_by					= @p_mod_by
							,mod_ip_address			= @p_mod_ip_address
					where	final_grn_request_no	= @final_grn_request_no_others_karoseri ;
				end ;

			    fetch next from curr_update_final_request 
				into @accesories_id
					,@karoseri_id
					,@code_final_grn_request
			end

			close curr_update_final_request
			deallocate curr_update_final_request


			if exists
				(
					select	1 
					from	dbo.final_grn_request_detail a
					inner join dbo.final_grn_request b on b.final_grn_request_no = a.final_grn_request_no
					where	a.id = @p_id
							and isnull(b.procurement_request_code,'')<>''
				)
			begin
				exec dbo.xsp_final_grn_request_detail_check_complete @p_id				= @p_id,                         
				                                                     @p_mod_date		= @p_mod_date,				
				                                                     @p_mod_by			= @p_mod_by,                 
				                                                     @p_mod_ip_address	= @p_mod_ip_address  




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

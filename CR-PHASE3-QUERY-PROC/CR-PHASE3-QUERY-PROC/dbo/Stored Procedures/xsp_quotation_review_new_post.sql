
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_quotation_review_new_post]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@code							nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@division_code					nvarchar(50)
			,@division_name					nvarchar(250)
			,@department_code				nvarchar(50)
			,@department_name				nvarchar(250)
			,@item_code						nvarchar(50)
			,@item_name						nvarchar(250)
			,@supplier_code					nvarchar(50)
			,@supplier_name					nvarchar(250)
			,@requestor_code				nvarchar(50)
			,@remark_detail					nvarchar(4000)
			,@quotation_amount				decimal(18, 2)
			,@quotation_quantity			int
			,@quotation_review_date			datetime
			,@amount						decimal(18,2)
			,@tax_code						nvarchar(50)
			,@remarks_header				nvarchar(4000)
			,@quotation_review_detail_id	int
			,@requestor_name				nvarchar(250)
			,@tax_name						nvarchar(250)
			,@reff_no						nvarchar(50)
			,@discount_amount				decimal(18,2)
			,@unit_from						nvarchar(25)
			,@ppn_pct						decimal(9,6)
			,@pph_pct						decimal(9,6)
			,@type_asset_code				nvarchar(50)
			,@item_category_code			nvarchar(50)
			,@item_category_name			nvarchar(250)
			,@item_merk_code				nvarchar(50)
			,@item_merk_name				nvarchar(250)
			,@item_model_code				nvarchar(50)
			,@item_model_name				nvarchar(250)
			,@item_type_code				nvarchar(50)
			,@item_type_name				nvarchar(250)
			,@uom_code						nvarchar(50)
			,@uom_name						nvarchar(250)
			,@spesification					nvarchar(4000)
			,@unit_available_status			nvarchar(25)
			,@offering						nvarchar(4000)
			,@indent_days					int
			,@supplier_selection_code		nvarchar(50)
			,@approved_qty					int
			,@id_detail						int
			,@date							datetime = dbo.xfn_get_system_date()
			,@quotation_review_code			nvarchar(50)
			,@supplier_address				nvarchar(4000)
			,@supplier_npwp					nvarchar(50)
			,@tax_ppn_pct					decimal(9,6)
			,@tax_pph_pct					decimal(9,6)
			,@warranty_month				int
			,@warranty_part_month			int
			,@price_amount					decimal(18,2)
			,@nett_price					decimal(18,2)
			,@total_amount					decimal(18,2)
			,@currency_code					nvarchar(50)
			,@currency_name					nvarchar(250)
			,@payment_methode_code			nvarchar(50)
			,@asset_amount					decimal(18,2)
			,@asset_discount_amount			decimal(18,2)
			,@karoseri_amount				decimal(18,2)
			,@karoseri_discount_amount		decimal(18,2)
			,@accesories_amount				decimal(18,2)
			,@accesories_discount_amount	decimal(18,2)
			,@mobilization_amount			decimal(18,2)
			,@application_no				nvarchar(50)
			,@unit_avail_status				nvarchar(50)
			,@doc_file_path					nvarchar(250)
			,@doc_file_name					nvarchar(250)
			,@doc_remark					nvarchar(4000)
			,@otr_amount					decimal(18,2)
			,@gps_amount					decimal(18,2)
			,@budget_amount					decimal(18,2)
			,@bbn_name						nvarchar(250)
			,@bbn_location					nvarchar(250)
			,@bbn_address					nvarchar(4000)
			,@deliver_to_address			nvarchar(4000)
			,@supplier_nitku				NVARCHAR(50)
			,@supplier_npwp_pusat			NVARCHAR(50)

	begin try
		if exists(select 1 from dbo.quotation_review where status <> 'HOLD' and code = @p_code)
		begin
			set @msg = 'Data Already Post.' ;
			raiserror(@msg, 16, -1) ;
		end

		--if exists(select 1 from dbo.quotation_review_detail where isnull(supplier_code, '') = '' and quotation_review_code = @p_code)
		--begin
		--	set @msg = 'Please Input Supplier in Quotation Review First.' ;
		--	raiserror(@msg, 16, -1) ;
		--end ;

		if exists(select 1 from dbo.quotation_review where isnull(remark, '') = '' and code = @p_code)
		begin
			set @msg = 'Please Input Remark First.' ;
			raiserror(@msg, 16, -1) ;
		end ;

		--if exists(select 1 from dbo.quotation_review_detail where isnull(quotation_review_date, '') = '' or isnull(expired_date, '') = '' and quotation_review_code = @p_code)
		--begin
		--	set @msg = 'Please Input Date in Quotation Review First.' ;
		--	raiserror(@msg, 16, -1) ;
		--end

		--if exists(select 1 from dbo.quotation_review_detail where isnull(tax_code, '') = '' and quotation_review_code = @p_code)
		--begin
		--	set @msg = 'Please Input Tax in Quotation Review First.' ;
		--	raiserror(@msg, 16, -1) ;
		--end ;

		--if exists (select 1 from dbo.quotation_review_detail where price_amount = 0 and quotation_review_code = @p_code)
		--begin
		--	set @msg = 'Price Amount Must be Greater Than 0.' ;
		--	raiserror(@msg, 16, -1) ;
		--end

		--if not exists (select 1 from dbo.quotation_review_vendor where quotation_review_code = @p_code)
		--begin
		--	set @msg = 'Please input vendor first.' ;
		--	raiserror(@msg, 16, -1) ;
		--end

		delete dbo.quotation_review_detail
		where type = 'EXISTING'
		and quotation_review_code = @p_code

		--update ke quotation review 	
		DECLARE curr_quo_proceed CURSOR FAST_FORWARD READ_ONLY for
        select qrv.quotation_review_code
			  ,qrv.supplier_code
			  ,qrv.supplier_name
			  ,qrv.supplier_address
			  ,qrv.supplier_npwp
			  ,qrv.tax_code
			  ,qrv.tax_name
			  ,qrv.tax_ppn_pct
			  ,qrv.tax_pph_pct
			  ,qrv.warranty_month
			  ,qrv.warranty_part_month
			  ,qrv.price_amount
			  ,qrv.discount_amount
			  ,qrv.nett_price
			  ,qrv.total_amount
			  ,qrv.offering
			  ,qrd.remark
			  ,qrd.reff_no
			  ,qrd.branch_code
			  ,qrd.branch_name
			  ,qrd.currency_code
			  ,qrd.currency_name
			  ,qrd.payment_methode_code
			  ,qrd.item_code
			  ,qrd.item_name
			  ,qrd.type_asset_code
			  ,qrd.item_category_code
			  ,qrd.item_category_name
			  ,qrd.item_merk_code
			  ,qrd.item_merk_name
			  ,qrd.item_type_code
			  ,qrd.item_type_name
			  ,qrd.uom_code
			  ,qrd.uom_name
			  ,qrd.requestor_code
			  ,qrd.requestor_name
			  ,qrd.unit_from
			  ,qrd.spesification
			  ,qrd.quantity
			  ,qrd.approved_quantity
			  ,qrd.item_model_code
			  ,qrd.item_model_name
			  ,qrd.asset_amount
			  ,qrd.asset_discount_amount
			  ,qrd.karoseri_amount
			  ,qrd.karoseri_discount_amount
			  ,qrd.accesories_amount
			  ,qrd.accesories_discount_amount
			  ,qrd.mobilization_amount
			  ,qrd.application_no
			  ,qrv.unit_available_status
			  ,qrv.indent_days
			  ,qrd.otr_amount
			  ,qrd.gps_amount
			  ,qrd.budget_amount
			  ,qrd.bbn_name
			  ,qrd.bbn_location
			  ,qrd.bbn_address
			  ,qrd.deliver_to_address
			  --(+) Raffy 2025/02/01 CR NITKU
			  ,qrv.supplier_nitku
			  ,qrv.supplier_npwp_pusat
		from dbo.quotation_review_vendor qrv
		inner join dbo.quotation_review_detail qrd on qrv.quotation_review_code collate Latin1_General_CI_AS = qrd.quotation_review_code
		where qrv.quotation_review_code = @p_code
		and qrd.TYPE = 'NEW'

		OPEN curr_quo_proceed

		FETCH NEXT FROM curr_quo_proceed 
		into @quotation_review_code
			,@supplier_code
			,@supplier_name
			,@supplier_address
			,@supplier_npwp
			,@tax_code
			,@tax_name
			,@tax_ppn_pct
			,@tax_pph_pct
			,@warranty_month
			,@warranty_part_month
			,@price_amount
			,@discount_amount
			,@nett_price
			,@total_amount
			,@offering
			,@remark_detail
			,@reff_no				
			,@branch_code			
			,@branch_name			
			,@currency_code			
			,@currency_name			
			,@payment_methode_code	
			,@item_code				
			,@item_name				
			,@type_asset_code		
			,@item_category_code	
			,@item_category_name	
			,@item_merk_code		
			,@item_merk_name		
			,@item_type_code		
			,@item_type_name		
			,@uom_code				
			,@uom_name				
			,@requestor_code		
			,@requestor_name		
			,@unit_from				
			,@spesification
			,@quotation_quantity
			,@approved_qty
			,@item_model_code
			,@item_model_name
			,@asset_amount
			,@asset_discount_amount
			,@karoseri_amount
			,@karoseri_discount_amount
			,@accesories_amount
			,@accesories_discount_amount
			,@mobilization_amount
			,@application_no
			,@unit_available_status
			,@indent_days
			,@otr_amount
			,@gps_amount
			,@budget_amount
			,@bbn_name
			,@bbn_location
			,@bbn_address
			,@deliver_to_address
			,@supplier_nitku
			,@supplier_npwp_pusat

		WHILE @@FETCH_STATUS = 0
		begin
					--delete dbo.quotation_review_detail 
					--where quotation_review_code = @p_code
					exec dbo.xsp_quotation_review_detail_insert @p_id								= 0
																,@p_quotation_review_code			= @p_code
																,@p_quotation_review_date			= null
																,@p_reff_no							= @reff_no
																,@p_branch_code						= @branch_code
																,@p_branch_name						= @branch_name
																,@p_currency_code					= @currency_code
																,@p_currency_name					= @currency_name
																,@p_payment_methode_code			= @payment_methode_code
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
																,@p_supplier_code					= @supplier_code
																,@p_supplier_name					= @supplier_name
																,@p_tax_code						= @tax_code
																,@p_tax_name						= @tax_name
																,@p_ppn_pct							= @tax_ppn_pct
																,@p_pph_pct							= @tax_pph_pct
																,@p_warranty_month					= @warranty_month
																,@p_warranty_part_month				= @warranty_part_month
																,@p_quantity						= @quotation_quantity
																,@p_approved_quantity				= @approved_qty
																,@p_uom_code						= @uom_code
																,@p_uom_name						= @uom_name
																,@p_price_amount					= @price_amount
																,@p_discount_amount					= @discount_amount
																,@p_requestor_code					= @requestor_code
																,@p_requestor_name					= @requestor_name
																,@p_unit_from						= @unit_from
																,@p_spesification					= @spesification
																,@p_remark							= @remark_detail
																,@p_expired_date					= null
																,@p_total_amount					= @total_amount
																,@p_nett_price						= @nett_price
																,@p_supplier_npwp					= @supplier_npwp
																,@p_supplier_address				= @supplier_address
																,@p_offering						= @offering
																,@p_type							= 'EXISTING'
																,@p_asset_amount					= @asset_amount
																,@p_asset_discount_amount			= @asset_discount_amount
																,@p_karoseri_amount					= @karoseri_amount
																,@p_karoseri_discount_amount		= @karoseri_discount_amount
																,@p_accesories_amount				= @accesories_amount
																,@p_accesories_discount_amount		= @accesories_discount_amount
																,@p_mobilization_amount				= @mobilization_amount
																,@p_application_no					= @application_no
																,@p_unit_available_status			= @unit_available_status
																,@p_indent_days						= @indent_days
																,@p_otr_amount						= @otr_amount
																,@p_gps_amount						= @gps_amount
																,@p_budget_amount					= @budget_amount
																,@p_bbn_name						= @bbn_name
																,@p_bbn_location					= @bbn_location
																,@p_bbn_address						= @bbn_address
																,@p_deliver_to_address				= @deliver_to_address
																--(+) Raffy 2025/02/01 CR NITKU
																,@p_supplier_nitku					= @supplier_nitku
																,@p_supplier_npwp_pusat				= @supplier_npwp_pusat
																--
																,@p_cre_date						= @p_mod_date
																,@p_cre_by							= @p_mod_by
																,@p_cre_ip_address					= @p_mod_ip_address
																,@p_mod_date						= @p_mod_date
																,@p_mod_by							= @p_mod_by
																,@p_mod_ip_address					= @p_mod_ip_address

						--update dbo.quotation_review_detail
						--set quotation_review_code = @p_code
						--where ID = @id_detail

		    FETCH NEXT FROM curr_quo_proceed 
			into @quotation_review_code
				 ,@supplier_code
				 ,@supplier_name
				 ,@supplier_address
				 ,@supplier_npwp
				 ,@tax_code
				 ,@tax_name
				 ,@tax_ppn_pct
				 ,@tax_pph_pct
				 ,@warranty_month
				 ,@warranty_part_month
				 ,@price_amount
				 ,@discount_amount
				 ,@nett_price
				 ,@total_amount
				 ,@offering
				 ,@remark_detail
				 ,@reff_no				
				 ,@branch_code			
				 ,@branch_name			
				 ,@currency_code			
				 ,@currency_name			
				 ,@payment_methode_code	
				 ,@item_code				
				 ,@item_name				
				 ,@type_asset_code		
				 ,@item_category_code	
				 ,@item_category_name	
				 ,@item_merk_code		
				 ,@item_merk_name		
				 ,@item_type_code		
				 ,@item_type_name		
				 ,@uom_code				
				 ,@uom_name				
				 ,@requestor_code		
				 ,@requestor_name		
				 ,@unit_from				
				 ,@spesification
				 ,@quotation_quantity
				 ,@approved_qty
				 ,@item_model_code
				 ,@item_model_name
				 ,@asset_amount
				 ,@asset_discount_amount
				 ,@karoseri_amount
				 ,@karoseri_discount_amount
				 ,@accesories_amount
				 ,@accesories_discount_amount
				 ,@mobilization_amount
				 ,@application_no
				 ,@unit_available_status
				 ,@indent_days
				 ,@otr_amount
				 ,@gps_amount
				 ,@budget_amount
				 ,@bbn_name
				 ,@bbn_location
				 ,@bbn_address
				 ,@deliver_to_address
				 ,@supplier_nitku
				 ,@supplier_npwp_pusat
		END

		CLOSE curr_quo_proceed
		DEALLOCATE curr_quo_proceed

		--delete dbo.quotation_review_detail
		--where isnull(supplier_code,'') = ''
		--and quotation_review_code = @p_code

		select @quotation_review_date	= qr.quotation_review_date
			  ,@branch_code				= qr.branch_code
			  ,@branch_name				= qr.branch_name
			  ,@division_code			= qr.division_code
			  ,@division_name			= qr.division_name
			  ,@department_code			= qr.department_code
			  ,@department_name			= qr.department_name
			  ,@requestor_code			= qr.requestor_code
			  ,@requestor_name			= qr.requestor_name
			  ,@remarks_header			= qr.remark
			  ,@item_code				= qrd.item_code
			  ,@item_name				= qrd.item_name
			  ,@uom_code				= qrd.uom_code
			  ,@uom_name				= qrd.uom_name
			  ,@type_asset_code			= qrd.type_asset_code
			  ,@item_category_code		= qrd.item_category_code
			  ,@item_category_name		= qrd.item_category_name
			  ,@item_merk_code			= qrd.item_merk_code
			  ,@item_merk_name			= qrd.item_merk_name
			  ,@item_model_code			= qrd.item_model_code
			  ,@item_model_name			= qrd.item_model_name
			  ,@item_type_code			= qrd.item_type_code
			  ,@item_type_name			= qrd.item_type_name
			  ,@approved_qty			= qrd.approved_quantity
			  ,@spesification			= qrd.spesification
			  ,@reff_no					= qrd.quotation_review_code
			  ,@id_detail				= qrd.id
			  ,@unit_from				= qr.unit_from
		from dbo.quotation_review qr
		inner join dbo.quotation_review_detail qrd on (qrd.quotation_review_code collate Latin1_General_CI_AS = qr.code)
		where qr.code = @p_code

		begin			
			exec dbo.xsp_supplier_selection_insert @p_code					= @code output
												   ,@p_company_code			= 'DSF'
												   ,@p_quotation_code		= @p_code
												   ,@p_selection_date		= @date
												   ,@p_branch_code			= @branch_code
												   ,@p_branch_name			= @branch_name
												   ,@p_division_code		= @division_code
												   ,@p_division_name		= @division_name
												   ,@p_department_code		= @department_code
												   ,@p_department_name		= @department_name
												   ,@p_status				= 'HOLD'
												   ,@p_remark				= @remarks_header
												   ,@p_requestor_code		= @requestor_code
												   ,@p_requestor_name		= @requestor_name
												   ,@p_unit_from			= @unit_from
												   ,@p_cre_date				= @p_mod_date
												   ,@p_cre_by				= @p_mod_by
												   ,@p_cre_ip_address		= @p_mod_ip_address
												   ,@p_mod_date				= @p_mod_date
												   ,@p_mod_by				= @p_mod_by
												   ,@p_mod_ip_address		= @p_mod_ip_address ;
		end ;

		--Cursor untuk cek berapa jumlah item yang ada di quotation review detail
		declare curr_quo_rev_detail cursor fast_forward read_only for

		select distinct reff_no 
		from dbo.quotation_review_detail 
		where quotation_review_code = @p_code

		open curr_quo_rev_detail

		fetch next from curr_quo_rev_detail 
		into @reff_no

		while @@fetch_status = 0
		begin
			--Cursor untuk insert ke supplier
			declare c_supplier_selection_detail cursor for
			select top 1 
				item_code
				  ,item_name
				  ,supplier_code
				  ,supplier_name
				  ,price_amount
				  ,approved_quantity
				  ,requestor_code
				  ,requestor_name
				  ,remark
				  ,tax_code
				  ,tax_name
				  ,id
				  ,discount_amount
				  ,unit_from
				  ,ppn_pct
				  ,pph_pct
				  ,type_asset_code
				  ,item_category_code
				  ,item_category_name
				  ,item_merk_code
				  ,item_merk_name
				  ,item_model_code
				  ,item_model_name
				  ,item_type_code
				  ,item_type_name
				  ,uom_code
				  ,uom_name
				  ,spesification
				  ,unit_available_status
				  ,offering
				  ,indent_days
				  ,asset_amount
				  ,asset_discount_amount
				  ,karoseri_amount
				  ,karoseri_discount_amount
				  ,accesories_amount
				  ,accesories_discount_amount
				  ,mobilization_amount
				  ,application_no
				  ,otr_amount
				  ,gps_amount
				  ,budget_amount
				  ,bbn_name
				  ,bbn_location
				  ,bbn_address
				  ,deliver_to_address
				  --(+) Raffy 2025/02/01 CR NITKU
				  ,supplier_nitku
				  ,supplier_npwp_pusat
			from dbo.quotation_review_detail
			where quotation_review_code = @p_code
			and reff_no = @reff_no
			AND type = 'EXISTING'
			--order by price_amount - discount_amount asc

			open c_supplier_selection_detail ;

			fetch c_supplier_selection_detail
			into @item_code
				 ,@item_name
				 ,@supplier_code
				 ,@supplier_name
				 ,@quotation_amount
				 ,@quotation_quantity
				 ,@requestor_code
				 ,@requestor_name
				 ,@remark_detail
				 ,@tax_code
				 ,@tax_name
				 ,@quotation_review_detail_id
				 ,@discount_amount
				 ,@unit_from
				 ,@ppn_pct
				 ,@pph_pct
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
				 ,@spesification
				 ,@unit_available_status
				 ,@offering
				 ,@indent_days
				 ,@asset_amount
				 ,@asset_discount_amount
				 ,@karoseri_amount
				 ,@karoseri_discount_amount
				 ,@accesories_amount
				 ,@accesories_discount_amount
				 ,@mobilization_amount
				 ,@application_no
				 ,@otr_amount
				 ,@gps_amount
				 ,@budget_amount
				 ,@bbn_name
				 ,@bbn_location
				 ,@bbn_address
				 ,@deliver_to_address
				 ,@supplier_nitku
				 ,@supplier_npwp_pusat

			while @@fetch_status = 0
			begin
				set @amount = (@quotation_amount * @quotation_quantity) - (@discount_amount * @quotation_quantity)

				if not exists --(+) raffy 2025/07/24 ditambahkan penjagaan agar jika double click terjadi, tidak kebentuk data double
				(
					select	1 
					from	dbo.supplier_selection_detail a
					inner join dbo.supplier_selection b on b.code = a.selection_code
					where	reff_no					= @p_code 
							--and item_code			= @item_code
							--and remark				= @remark_detail
							--and application_no		= @application_no
							and quotation_detail_id = @quotation_review_detail_id
							and	b.status			<> 'cancel'
				)
				begin


				exec dbo.xsp_supplier_selection_detail_insert @p_id									= 0
															  ,@p_selection_code					= @code
															  ,@p_item_code							= @item_code
															  ,@p_item_name							= @item_name
															  ,@p_uom_code							= @uom_code
															  ,@p_uom_name							= @uom_name
															  ,@p_type_asset_code					= @type_asset_code
															  ,@p_item_category_code				= @item_category_code
															  ,@p_item_category_name				= @item_category_name
															  ,@p_item_merk_code					= @item_merk_code
															  ,@p_item_merk_name					= @item_merk_name
															  ,@p_item_model_code					= @item_model_code
															  ,@p_item_model_name					= @item_model_name
															  ,@p_item_type_code					= @item_type_code
															  ,@p_item_type_name					= @item_type_name
															  ,@p_supplier_code						= ''
															  ,@p_supplier_name						= ''										 
															  ,@p_amount							= 0
															  ,@p_quotation_amount					= 0
															  ,@p_quantity							= @approved_qty
															  ,@p_quotation_quantity				= 0
															  ,@p_total_amount						= 0
															  ,@p_remark							= @remark_detail
															  ,@p_spesification						= @spesification
															  ,@p_procurement_code					= @p_code
															  ,@p_requestor_code					= @requestor_code
															  ,@p_requestor_name					= @requestor_name
															  ,@p_supplier_selection_detail_status	= ''
															  ,@p_quotation_detail_id				= @quotation_review_detail_id
															  ,@p_discount_amount					= 0
															  ,@p_unit_from							= @unit_from
															  ,@p_unit_available_status				= null
															  ,@p_indent_days						= null
															  ,@p_offering							= null
															  ,@p_asset_amount						= @asset_amount
															  ,@p_asset_discount_amount				= @asset_discount_amount	
															  ,@p_karoseri_amount					= @karoseri_amount
															  ,@p_karoseri_discount_amount			= @karoseri_discount_amount
															  ,@p_accesories_amount					= @accesories_amount
															  ,@p_accesories_discount_amount		= @accesories_discount_amount
															  ,@p_mobilization_amount				= @mobilization_amount
															  ,@p_application_no					= @application_no
															  ,@p_otr_amount						= @otr_amount
															  ,@p_gps_amount						= @gps_amount
															  ,@p_budget_amount						= @budget_amount
															  ,@p_bbn_name							= @bbn_name
															  ,@p_bbn_location						= @bbn_location
															  ,@p_bbn_address						= @bbn_address
															  ,@p_deliver_to_address				= @deliver_to_address
															  ,@p_supplier_nitku					= @supplier_nitku
															  ,@p_supplier_npwp_pusat				= @supplier_npwp_pusat
															  --
															  ,@p_cre_date							= @p_mod_date
															  ,@p_cre_by							= @p_mod_by
															  ,@p_cre_ip_address					= @p_mod_ip_address
															  ,@p_mod_date							= @p_mod_date
															  ,@p_mod_by							= @p_mod_by
															  ,@p_mod_ip_address					= @p_mod_ip_address ;

					end



				fetch c_supplier_selection_detail
				into @item_code
					,@item_name
					,@supplier_code
					,@supplier_name
					,@quotation_amount
					,@quotation_quantity
					,@requestor_code
					,@requestor_name
					,@remark_detail
					,@tax_code
					,@tax_name
					,@quotation_review_detail_id
					,@discount_amount
					,@unit_from
					,@ppn_pct
					,@pph_pct
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
					,@spesification
					,@unit_available_status
					,@offering
					,@indent_days
					,@asset_amount
					,@asset_discount_amount
					,@karoseri_amount
					,@karoseri_discount_amount
					,@accesories_amount
					,@accesories_discount_amount
					,@mobilization_amount
					,@application_no
					,@otr_amount
					,@gps_amount
					,@budget_amount
					,@bbn_name
					,@bbn_location
					,@bbn_address
					,@deliver_to_address
					,@supplier_nitku
					,@supplier_npwp_pusat
			end ;

			close c_supplier_selection_detail ;
			deallocate c_supplier_selection_detail ;


		    fetch next from curr_quo_rev_detail 
			into @reff_no
		end

		close curr_quo_rev_detail
		deallocate curr_quo_rev_detail


		declare curr_document_quo cursor fast_forward read_only for
		select	file_path
			   ,file_name
			   ,remark
		from	dbo.quotation_review_document
		where	quotation_review_code = @p_code ;

		open curr_document_quo

		fetch next from curr_document_quo 
		into @doc_file_path
			,@doc_file_name
			,@doc_remark

		while @@fetch_status = 0
		begin
		    declare @p_id bigint ;

		    exec dbo.xsp_supplier_selection_document_insert @p_id									= 0
		    												,@p_supplier_selection_code				= @code
		    												,@p_document_code						= '' 
		    												,@p_file_path							= @doc_file_path
		    												,@p_file_name							= @doc_file_name
		    												,@p_remark_detail						= @doc_remark
															,@p_reff_no								= @p_code
		    												,@p_cre_date							= @p_mod_date
		    												,@p_cre_by								= @p_mod_by
		    												,@p_cre_ip_address						= @p_mod_ip_address
		    												,@p_mod_date							= @p_mod_date
		    												,@p_mod_by								= @p_mod_by
		    												,@p_mod_ip_address						= @p_mod_ip_address


		    fetch next from curr_document_quo 
			into @doc_file_path
				,@doc_file_name
				,@doc_remark
		end

		close curr_document_quo
		deallocate curr_document_quo

		update	dbo.quotation_review
		set		status			= 'POST'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

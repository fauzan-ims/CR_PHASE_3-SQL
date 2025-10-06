CREATE PROCEDURE dbo.xsp_ap_invoice_registration_detail_insert_item_list
(
	@p_invoice_register_code	nvarchar(50)	 = ''
	,@p_grn_code				nvarchar(50)	 = ''
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
	--
	,@p_podoi_id				bigint = 0 -- sepria 16092025: tambah ini agar bisa bayar per id object info po
)
as
begin
	if (isnull(@p_podoi_id,0) = 0) -- valdiasi jika dari ui tidak mengirim id po object id
	begin
	    raiserror ('Please Check The Completeness Of The Data',16,1)
		return
	end

	declare @msg					nvarchar(max)
			,@currency_code			nvarchar(50)
			,@item_code				nvarchar(50)
			,@purchase_amount		decimal(18, 2)
			,@total_amount			decimal(18, 2)
			,@tax_code				nvarchar(50)
			,@ppn					decimal(18, 2)
			,@pph					decimal(18, 2)
			,@shipping_fee			decimal(18, 2)	= 0
			,@discount				decimal(18, 2)	= 0
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@division_code			nvarchar(50)
			,@division_name			nvarchar(250)
			,@department_code		nvarchar(50)
			,@department_name		nvarchar(250)
			,@purchase_order_id		bigint
			,@order_qty				int
			,@sum_price_amount		decimal(18,2)
			,@sum_ppn_amount		decimal(18,2)
			,@sum_pph_amount		decimal(18,2)
			,@sum_shipping_amount	decimal(18,2)
			,@tax_name				nvarchar(250)
			,@item_name				nvarchar(250)
			,@receive_qty			decimal(18,2)
			,@uom_code				nvarchar(50)
			,@uom_name				nvarchar(250)
			,@qty					int
			,@unit_price			nvarchar(250) = 0
			,@grn_code				nvarchar(50)
			,@new_spesification		nvarchar(4000)
			,@spesification			nvarchar(4000)
			,@id					bigint
			,@id_object_info		bigint
			,@info_detail			nvarchar(4000)
			,@ppn_pct				decimal(9, 6)
			,@pph_pct				decimal(9, 6)
			,@info					nvarchar(max)
			,@count					int
            ,@grn_detail_id			bigint
			,@invd_id				bigint
            ,@qty_post				int

	begin TRY
	if not exists (
			select	invdf.purchase_order_detail_object_info_id 
			from	dbo.ap_invoice_registration_detail_faktur invdf
					inner join dbo.ap_invoice_registration_detail invd on invd.id = invdf.invoice_registration_detail_id
			where	invd.invoice_register_code = @p_invoice_register_code
			and		invdf.purchase_order_detail_object_info_id = @p_podoi_id)
	begin
	    
		select	 @currency_code		= po.currency_code
				,@item_code			= grnd.item_code
				,@item_name			= grnd.item_name
				,@purchase_amount	= isnull(grnd.price_amount,0)
				,@total_amount		= ((isnull(grnd.price_amount, pod.price_amount) - isnull(grnd.discount_amount, pod.discount_amount)) * grnd.receive_quantity) + isnull(grnd.ppn_amount, pod.ppn_amount) - isnull(grnd.pph_amount, pod.pph_amount)
				,@tax_code			= isnull(grnd.master_tax_code, pod.tax_code)
				,@tax_name			= isnull(grnd.master_tax_description, pod.tax_name)
				,@ppn				= isnull(grnd.ppn_amount, pod.ppn_amount)
				,@pph				= isnull(grnd.pph_amount, pod.pph_amount)
				,@branch_code		= grn.branch_code
				,@branch_name		= grn.branch_name
				,@division_code		= grn.division_code
				,@division_name		= grn.division_name
				,@department_code	= grn.department_code
				,@department_name	= grn.department_name
				,@purchase_order_id	= isnull(pod.id,0)
				,@order_qty			= pod.order_quantity
				,@receive_qty		= grnd.receive_quantity
				,@uom_code			= grnd.uom_code
				,@uom_name			= grnd.uom_name
				,@discount			= pod.discount_amount
				,@spesification		= grnd.spesification
				,@ppn_pct			= grnd.master_tax_ppn_pct
				,@pph_pct			= grnd.master_tax_pph_pct
				,@grn_detail_id		= grnd.id
		from	dbo.good_receipt_note_detail		grnd
				inner join dbo.good_receipt_note	grn on grn.code		   = grnd.good_receipt_note_code
				inner join dbo.purchase_order		po on po.code		   = grn.purchase_order_code
				inner join dbo.purchase_order_detail pod on (grnd.purchase_order_detail_id = pod.id)
				inner join dbo.purchase_order_detail_object_info podoi on (podoi.purchase_order_detail_id = pod.id)
		where	grn.code = @p_grn_code
				and grnd.receive_quantity <> 0
				and	podoi.id = @p_podoi_id
			

			if not exists (select 1 from dbo.ap_invoice_registration_detail where grn_code = @p_grn_code and invoice_register_code = @p_invoice_register_code and grn_detail_id = @grn_detail_id)
			begin
		
				exec dbo.xsp_ap_invoice_registration_detail_insert @p_id							= @invd_id output
																   ,@p_invoice_register_code		= @p_invoice_register_code
																   ,@p_grn_code						= @p_grn_code
																   ,@p_currency_code				= @currency_code
																   ,@p_uom_code						= @uom_code
																   ,@p_uom_name						= @uom_name
																   ,@p_quantity						= @receive_qty
																   ,@p_item_code					= @item_code
																   ,@p_item_name					= @item_name
																   ,@p_purchase_amount				= @purchase_amount
																   ,@p_total_amount					= @total_amount
																   ,@p_tax_code						= @tax_code
																   ,@p_tax_name						= @tax_name
																   ,@p_ppn_pct						= @ppn_pct
																   ,@p_pph_pct						= @pph_pct
																   ,@p_ppn							= @ppn
																   ,@p_pph							= @pph
																   ,@p_shipping_fee					= 0
																   ,@p_discount						= @discount
																   ,@p_branch_code					= @branch_code
																   ,@p_branch_name					= @branch_name
																   ,@p_division_code				= @division_code
																   ,@p_division_name				= @division_name
																   ,@p_department_code				= @department_code
																   ,@p_department_name				= @department_name
																   ,@p_purchase_order_id			= @purchase_order_id
																   ,@p_spesification				= @spesification
																   ,@p_cre_date						= @p_cre_date
																   ,@p_cre_by						= @p_cre_by
																   ,@p_cre_ip_address				= @p_cre_ip_address
																   ,@p_mod_date						= @p_mod_date
																   ,@p_mod_by						= @p_mod_by
																   ,@p_mod_ip_address				= @p_mod_ip_address
																   ,@p_grn_detail_id				= @grn_detail_id
			end
			else
            begin
                select	@invd_id = id
				from	dbo.ap_invoice_registration_detail
				where	invoice_register_code	= @p_invoice_register_code
				and		grn_code				= @p_grn_code
				and		grn_detail_id			= @grn_detail_id
            end
			
			exec	dbo.xsp_ap_invoice_registration_detail_faktur_insert 
					@p_id										= 0
		    		,@p_invoice_registration_detail_id			= @invd_id
		    		,@p_faktur_no								= ''
		    		,@p_purchase_order_detail_object_info_id	= @p_podoi_id
					--
		    		,@p_cre_date								= @p_cre_date
		    		,@p_cre_by									= @p_cre_by
		    		,@p_cre_ip_address							= @p_cre_ip_address
		    		,@p_mod_date								= @p_mod_date
		    		,@p_mod_by									= @p_mod_by
		    		,@p_mod_ip_address							= @p_mod_ip_address
		
			select	@info_detail = stuff((
								 select distinct
										case case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'') end
											when '' then ', ' + a.faktur_no
											else ',' + case when isnull(podoi.plat_no,'') = '' then isnull(asv.plat_no,'') else isnull(podoi.plat_no,'') end
											+ ' - ' + case when isnull(podoi.engine_no,'') = '' then isnull(asv.engine_no,'') else isnull(podoi.engine_no,'') end 
											+ ' - ' + case when isnull(podoi.chassis_no,'') = '' then isnull(asv.chassis_no,'') else isnull(podoi.chassis_no,'') end
											+ case when isnull(a.faktur_no,'') <> '' then  ' - ' + isnull(a.faktur_no,'') else '' end
										end
								 from	dbo.ap_invoice_registration_detail_faktur		a
										left join dbo.purchase_order_detail_object_info podoi on a.purchase_order_detail_object_info_id = podoi.id
										left join dbo.purchase_order_detail pod on pod.id = podoi.purchase_order_detail_id
										outer apply ( 
											select asv.engine_no, asv.chassis_no, asv.plat_no from 
											dbo.supplier_selection_detail		ssd 
											left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
											left join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
											left join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
											left join dbo.procurement_request_item			pri on (pri.procurement_request_code = pr.code)
											left join ifinams.dbo.asset_vehicle				asv on asv.asset_code = isnull(podoi.asset_code,pri.fa_code)
											where ssd.id								  = pod.supplier_selection_detail_id
										)asv
								 where	invoice_registration_detail_id = @invd_id
								 for xml path('')
							 ), 1, 1, ''
							) ;


			select	@qty = count(1)
			from	dbo.ap_invoice_registration_detail_faktur
			where	invoice_registration_detail_id = @invd_id

			select	@qty_post = count(1)
			from	dbo.ap_invoice_registration_detail_faktur invdf 
					inner join dbo.ap_invoice_registration_detail invd on invdf.invoice_registration_detail_id = invd.id
					inner join dbo.ap_invoice_registration inv on invd.invoice_register_code = inv.code
			where	inv.status in ('POST','PAID')
			and		invd.grn_code = @p_grn_code
			and		invd.invoice_register_code <> @p_invoice_register_code
			and		invd.grn_detail_id = @grn_detail_id

		    update dbo.ap_invoice_registration_detail
			set tpye_faktur		= 'EXIST'
				,info_detail	= @info_detail
				,qty_invoice	= @qty
				,qty_grn		= quantity
				,qty_post		= @qty_post	
				--
				,mod_by			= @p_mod_by
				,mod_date		= @p_mod_date
				,mod_ip_address	= @p_mod_ip_address
			where id			= @invd_id
		

		--Update Data Invoice Header
		select	@sum_price_amount		= sum(((ird.purchase_amount - ird.discount) * ird.quantity)  + ird.ppn - ird.pph)
				,@sum_pph_amount		= sum(pph)
				,@sum_ppn_amount		= sum(ppn)
				,@unit_price			= sum(purchase_amount)
				,@discount				= sum (discount * ird.quantity)
		from	dbo.ap_invoice_registration_detail ird with (nolock)
		where	invoice_register_code = @p_invoice_register_code

		select	@info = stuff((
						  select	',' + info_detail + ' ' + spesification
						  from		dbo.ap_invoice_registration_detail
						  where		invoice_register_code = @p_invoice_register_code
						  for xml path('')
					  ), 1, 1, ''
					 ) ;

		update	dbo.ap_invoice_registration
		set		invoice_amount	= @sum_price_amount
				,ppn			= @sum_ppn_amount
				,pph			= @sum_pph_amount
				,unit_price		= @unit_price
				,discount		= @discount
				,unit_info		= @info
		where	code			= @p_invoice_register_code ;

	end

	end try
	begin catch
		declare @error int ;

		set @error = @@error

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

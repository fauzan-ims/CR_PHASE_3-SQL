CREATE PROCEDURE dbo.xsp_good_receipt_note_detail_update_09052025
(
	@p_id						bigint
	,@p_good_receipt_note_code	nvarchar(50)
	,@p_item_code				nvarchar(50)
	,@p_item_name				nvarchar(250)
	,@p_type_asset_code			nvarchar(50) = ''
	,@p_uom_code				nvarchar(50)
	,@p_uom_name				nvarchar(250)
	,@p_price_amount			decimal(18, 2)	= 0
	,@p_po_quantity				decimal(18, 2)
	,@p_receive_quantity		decimal(18, 2)
	,@p_location_code			nvarchar(50)	= ''
	,@p_location_name			nvarchar(250)	= ''
	,@p_warehouse_code			nvarchar(50)	= ''
	,@p_warehouse_name			nvarchar(250)	= ''
	,@p_shipper_code			nvarchar(50)	= ''
	,@p_no_resi					nvarchar(50)	= ''
	,@p_ppn_amount				decimal(18,2)
	,@p_pph_amount				decimal(18,2)
	-- (+) Ari 2024-01-10 ket : add tax    
	,@p_tax_code				nvarchar(50)
	,@p_tax_name				nvarchar(250)
	,@p_pph_pct					decimal(18, 2) = 0
	,@p_ppn_pct					decimal(18, 2) = 0
	-- (+) Ari 2024-01-10
	-- (+) Ari 2024-03-22 ket : add total_amount
	,@p_total_amount			decimal(18,2)
	-- (+) Ari 2024-03-22
	,@p_discount_amount			decimal(18,2)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@counter					int
			,@id_detail					bigint
			,@id_object_info			bigint
			,@type_asset_code			nvarchar(50)
			,@count_detail				int
			,@total_count				int
			,@ppn_pct					decimal(9,6)
			,@pph_pct					decimal(9,6)
			,@ppn						bigint
			,@pph						bigint
			,@unit_price				bigint
			,@total_amount				decimal(18, 2) -- (+) Ari 2024-01-02 ket : add total amount fo validation    
			,@val_ppn					decimal(18, 2) -- (+) Ari 2024-01-05 ket : validasi ppn    
			,@ppn_before				decimal(18, 2)
			,@tax_code					nvarchar(10) 
			,@new_unit_price			decimal(18,2) -- (+) Ari 2024-03-22 ket : add new calculate unit price
			,@discount					decimal(18,2) -- (+) Ari 2024-03-22 ket : add discount
			,@unit_from					nvarchar(50)
			,@total_amount_2			decimal(18,2)

	begin try

		if (@p_receive_quantity > @p_po_quantity)
		begin
			set @msg = 'Receive Quantity Must be Less or Equal Than Remaining Quantity.'
			raiserror(@msg, 16, -1) ;
		end

		if(@p_total_amount <> 0)
		begin
			if(@p_receive_quantity = 0)
			begin
				set @msg = 'Receive Quantity Must be Greater Than 0.'
				raiserror(@msg, 16, -1) ;
			end
		end

		--if (@p_receive_quantity = 0)
		--begin
		--	set @msg = 'Receive Quantity Must be Greater Than 0.'
		--	raiserror(@msg, 16, -1) ;
		--end

		select	@ppn_pct			= isnull(qrd.ppn_pct, ssd.ppn_pct)
				,@pph_pct			= isnull(qrd.pph_pct, ssd.pph_pct)
				,@total_amount		= isnull(((grnd.price_amount - grnd.discount_amount) * grnd.receive_quantity + grnd.ppn_amount - grnd.pph_amount), 0) -- (+) Ari 2024-01-02 ket : pengambilan total diambil dari sp getrow nya    
				,@ppn_before		= isnull(grnd.master_tax_ppn_pct, 0)
				,@tax_code			= grnd.master_tax_code
				,@unit_price		= grnd.price_amount
				,@discount			= isnull(grnd.discount_amount,0) -- (+) Ari 2024-03-22
				,@unit_from			= po.unit_from
		from	dbo.good_receipt_note_detail					 grnd
		inner join dbo.good_receipt_note				 grn on (grn.code									= grnd.good_receipt_note_code)
		inner join dbo.purchase_order					 po on (po.code										= grn.purchase_order_code)
		inner join dbo.purchase_order_detail			 pod on (
																	pod.po_code								= po.code
																	and pod.id								= grnd.purchase_order_detail_id
																)
		inner join dbo.supplier_selection_detail		 ssd on (ssd.id										= pod.supplier_selection_detail_id)
		left join dbo.quotation_review_detail			 qrd on (qrd.id										= ssd.quotation_detail_id)
		where grnd.id = @p_id

		--set @val_ppn = round(isnull(@p_price_amount, 0) * isnull(@p_receive_quantity, 0) * (isnull(@p_ppn_pct, 0) / 100), 0) ;
		set @val_ppn = round((isnull(@total_amount, 0) + isnull(@discount,0)) * isnull(@p_receive_quantity, 0) * (isnull(@p_ppn_pct, 0) / 100), 0) ;

		-- (+) Ari 2024-03-22 ket : add new calculate unit price (total amount + diskon - ppn + pph)
		set @new_unit_price = ((isnull(@p_total_amount,0)  - isnull(@p_ppn_amount,0) + isnull(@p_pph_amount,0)) / @p_receive_quantity) + isnull(@discount,0)
		
		if (
			   @p_ppn_amount <= 0
			   and	@p_ppn_pct > 0
		   )
		begin
			set @msg = 'PPN Must be Greater Than 0.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (
					@p_pph_amount <= 0
					and @p_pph_pct > 0
				)
		begin
			set @msg = 'PPH Must be Greater Than 0.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (
					@new_unit_price <= 0
				)
		begin
			set @msg = 'Total Amount must be Greater Than 0.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if ((
					 isnull(@p_ppn_pct, 0) = 0
					 and isnull(@p_ppn_amount, 0) <> 0
				 )
				)
		begin
			set @msg = 'Cannot set PPN amount because PPN PCT = 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if ((
					 isnull(@p_pph_pct, 0) = 0
					 and isnull(@p_pph_amount, 0) <> 0
				 )
				)
		begin
			set @msg = 'Cannot set PPH amount because PPH PCT = 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (right(@p_ppn_amount, 2) <> '00')
		begin
			set @msg = 'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (right(@p_pph_amount, 2) <> '00')
		begin
			set @msg = 'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (right(@new_unit_price, 2) <> '00')
		begin
			set @msg = 'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if ((@p_ppn_amount/@p_receive_quantity) > @new_unit_price)
		begin
			set @msg = 'PPN cannot bigger than Total Amount ' +  convert(nvarchar(50), @unit_price) ;  

			raiserror(@msg, 16, -1) ;
		end ;
		else if ((@p_pph_amount/@p_receive_quantity) > @new_unit_price)
		begin
			set @msg = 'PPH cannot bigger than Total Amount ' +  convert(nvarchar(50), @unit_price) ;  

			raiserror(@msg, 16, -1) ;
		end ;

		-- (+) Ari 2024-01-02      

		if(@unit_from = 'BUY')
		begin
			update	good_receipt_note_detail
			set		good_receipt_note_code	= @p_good_receipt_note_code
					,item_code				= @p_item_code
					,item_name				= @p_item_name
					,uom_code				= @p_uom_code
					,uom_name				= @p_uom_name
					--,price_amount			= @p_price_amount
					,po_quantity			= @p_po_quantity
					,receive_quantity		= @p_receive_quantity
					,shipper_code			= @p_shipper_code
					,no_resi				= @p_no_resi
					,ppn_amount				= @p_ppn_amount
					,pph_amount				= @p_pph_amount
					--,ppn_amount				= @ppn
					--,pph_amount				= @pph
					-- (+) Ari 2024-01-10 ket : add tax    
					,master_tax_code		= @p_tax_code
					,master_tax_description = @p_tax_name
					,master_tax_ppn_pct		= @p_ppn_pct
					,master_tax_pph_pct		= @p_pph_pct
					-- (+) Ari 2024-01-10
					-- (+) Ari 2024-03-22 ket : add total amount & new calculate new unit price
					,total_amount			= @p_total_amount
					,price_amount			= @new_unit_price
					-- (+) Ari 2024-03-22
					,orig_price_amount		= @new_unit_price
					,orig_ppn_amount		= @p_ppn_amount
					,orig_pph_amount		= @p_pph_amount
					,orig_total_amount		= @p_total_amount
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	id						= @p_id ;
		end
		else
		begin
			set @total_amount_2 = ((@p_price_amount - @p_discount_amount) * isnull(@p_receive_quantity,0)) + @p_ppn_amount -  @p_pph_amount
			update	good_receipt_note_detail
			set		good_receipt_note_code	= @p_good_receipt_note_code
					,item_code				= @p_item_code
					,item_name				= @p_item_name
					,uom_code				= @p_uom_code
					,uom_name				= @p_uom_name
					,price_amount			= @p_price_amount
					,po_quantity			= @p_po_quantity
					,receive_quantity		= @p_receive_quantity
					,shipper_code			= @p_shipper_code
					,no_resi				= @p_no_resi
					,ppn_amount				= @p_ppn_amount
					,pph_amount				= @p_pph_amount
					--,ppn_amount				= @ppn
					--,pph_amount				= @pph
					-- (+) Ari 2024-01-10 ket : add tax    
					,master_tax_code		= @p_tax_code
					,master_tax_description = @p_tax_name
					,master_tax_ppn_pct		= @p_ppn_pct
					,master_tax_pph_pct		= @p_pph_pct
					-- (+) Ari 2024-01-10
					-- (+) Ari 2024-03-22 ket : add total amount & new calculate new unit price
					,total_amount			= @total_amount_2
					--,price_amount			= @new_unit_price
					-- (+) Ari 2024-03-22
					,discount_amount		= @p_discount_amount
					,orig_discount_amount	= @p_discount_amount
					,orig_price_amount		= @p_price_amount
					,orig_ppn_amount		= @p_ppn_amount
					,orig_pph_amount		= @p_pph_amount
					,orig_total_amount		= @total_amount_2
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	id						= @p_id ;
		end

		---- Auto insert ke tab object info dengan isi kosong
		--set @counter = 1

		--select @count_detail = count(id) 
		--from dbo.good_receipt_note_detail_object_info
		--where good_receipt_note_detail_id = @p_id

		--set @total_count = @p_receive_quantity - @count_detail

		----Cek terlebih dahulu, jika jumlah data detail kurang dari data yang mau direceive maka akan insert sesuai dengan hasil pengurangan.
		----Namun jika data yang ada didetail lebih banyak maka tidak ada action
		--if(@total_count > 0)
		--begin
		--	while ( @counter <= @total_count)
		--	begin
		--	    exec dbo.xsp_good_receipt_note_detail_object_info_insert @p_id								= @id_object_info output
		--																,@p_good_receipt_note_detail_id		= @p_id
		--																,@p_plat_no							= ''
		--																,@p_chassis_no						= ''
		--																,@p_engine_no						= ''
		--																,@p_cre_date						= @p_mod_date
		--																,@p_cre_by							= @p_mod_by
		--																,@p_cre_ip_address					= @p_mod_ip_address
		--																,@p_mod_date						= @p_mod_date
		--																,@p_mod_by							= @p_mod_by
		--																,@p_mod_ip_address					= @p_mod_ip_address

		--		-- Auto insert ke tab Checklist Berdasarkan settingan di Asset Management
		--		insert into dbo.good_receipt_note_detail_checklist
		--		(
		--			good_receipt_note_detail_id
		--			,good_receipt_note_detail_object_info_id
		--			,checklist_code
		--			,checklist_name
		--			,checklist_status
		--			,checklist_remark
		--			,cre_date
		--			,cre_by
		--			,cre_ip_address
		--			,mod_date
		--			,mod_by
		--			,mod_ip_address
		--		)
		--		select @p_id
		--			  ,@id_object_info
		--			  ,code
		--			  ,checklist_name
		--			  ,''
		--			  ,''
		--			  ,@p_mod_date
		--			  ,@p_mod_by
		--			  ,@p_mod_ip_address
		--			  ,@p_mod_date
		--			  ,@p_mod_by
		--			  ,@p_mod_ip_address
		--		from ifinams.dbo.master_bast_checklist_asset
		--		where asset_type_code = @p_type_asset_code
		--		and is_active = '1'

		--	    set @counter  = @counter  + 1
		--	end				
		--end
		--else if ( @p_receive_quantity = 0)
		--begin
		--	delete dbo.good_receipt_note_detail_object_info where good_receipt_note_detail_id = @p_id
		--end
				
		update dbo.good_receipt_note
		set is_validate = '0'
		where code = @p_good_receipt_note_code

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

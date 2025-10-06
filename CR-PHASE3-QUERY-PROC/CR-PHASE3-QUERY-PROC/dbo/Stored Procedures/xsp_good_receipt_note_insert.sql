CREATE PROCEDURE dbo.xsp_good_receipt_note_insert
(
	@p_code					nvarchar(50)  output
	,@p_company_code		nvarchar(50)	= 'DSF'
	,@p_purchase_order_code nvarchar(50)
	,@p_receive_date		datetime
	,@p_supplier_code		nvarchar(50)
	,@p_supplier_name		nvarchar(250)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_division_code		nvarchar(50)  = ''
	,@p_division_name		nvarchar(25)  = ''
	,@p_department_code		nvarchar(50)  = ''
	,@p_department_name		nvarchar(250) = ''
	,@p_remark				nvarchar(4000)
	,@p_is_validate			nvarchar(1) = 1
	,@p_status				nvarchar(25)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@year						nvarchar(2)
			,@month						nvarchar(2)
			,@code						nvarchar(50)
			,@total_quantity			int = 0
			,@counter					int
			,@item_code					nvarchar(50)
			,@item_name					nvarchar(250)
			,@uom_code					nvarchar(50)
			,@price_amount				decimal(18, 2)
			,@order_quantity			int
			,@receive_quantity			int 
			,@purchase_order_detail_id	int
			,@uom_name					nvarchar(250)
			,@id_detail					bigint
			,@id_object_info			bigint
			,@type_asset_code			nvarchar(50)
			,@item_category_code		nvarchar(50)
			,@item_category_name		nvarchar(250)
			,@item_merk_code			nvarchar(50)
			,@item_merk_name			nvarchar(250)
			,@item_model_code			nvarchar(50)
			,@item_model_name			nvarchar(250)
			,@item_type_code			nvarchar(50)
			,@item_type_name			nvarchar(250)
			,@spesification				nvarchar(4000)
			,@order_remaining			int
			,@discount_amount			decimal(18,2)
			,@ppn_amount				decimal(18,2)
			,@pph_amount				decimal(18,2)
			-- (+) Ari 2024-03-26 ket : get plat no, chassis, engine no
			,@plat_no					nvarchar(50)
			,@chassis_no				nvarchar(50)
			,@engine					nvarchar(50)
			,@month_val					nvarchar(25)
			,@year_val					nvarchar(4)
			,@unit_from					nvarchar(50)
			,@new_spec					nvarchar(4000)
			,@value						int
			

	begin try
		if @p_receive_date > dbo.xfn_get_system_date()
		begin
			set @msg = 'Receive date must be less or equal than system date.';
			raiserror(@msg, 16, -1) ;
		end

		select	@value = value
		from	dbo.sys_global_param
		where	CODE = 'GRNRD' ;

		--validasi tanggal receive date kurang dari bulan ini
		select @month_val	= case 
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
						end
		select @year_val	= year(dbo.xfn_get_system_date())

		if(@p_receive_date < dateadd(month, -@value, dbo.xfn_get_system_date()))
		begin
			if(@value <> 0)
			begin
				set @msg = N'Receive date cannot be back dated for more than ' + convert(varchar(1), @value) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value = 0)
			begin
				set @msg = N'Receive date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		--if (cast(@p_receive_date as date) < DATEFROMPARTS(YEAR(dbo.xfn_get_system_date()), MONTH(dbo.xfn_get_system_date()), 1))
		--BEGIN
		--	SET @msg = 'Receive Date Must be Greater or Equal Than, 1 ' + @month_val + ' ' + @year_val
		--	RAISERROR(@msg, 16, -1) ;
		--end

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= @p_company_code
													,@p_sys_document_code	= ''
													,@p_custom_prefix		= 'GRN'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'GOOD_RECEIPT_NOTE'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= '0' ;

		insert into good_receipt_note
		(
			code
			,company_code
			,purchase_order_code
			,receive_date
			,supplier_code
			,supplier_name
			,branch_code
			,branch_name
			,division_code
			,division_name
			,department_code
			,department_name
			,remark
			,status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_company_code
			,@p_purchase_order_code
			,@p_receive_date
			,@p_supplier_code
			,@p_supplier_name
			,@p_branch_code
			,@p_branch_name
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_remark
			,@p_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		set @p_code = @code ;

		declare c_po_detail cursor fast_forward for
		select	pod.item_code
				,pod.item_name
				,pod.uom_code
				,pod.uom_name
				,pod.price_amount
				,pod.order_quantity
				,pod.id
				,pod.type_asset_code
				,pod.item_category_code
				,pod.item_category_name
				,pod.item_merk_code
				,pod.item_merk_name
				,pod.item_model_code
				,pod.item_model_name
				,pod.item_type_code
				,pod.item_type_name
				,pod.spesification
				,pod.order_remaining
				,pod.discount_amount
				,pod.ppn_amount
				,pod.pph_amount
		from	dbo.purchase_order_detail pod
		where	pod.po_code = @p_purchase_order_code
		and pod.order_remaining <> 0

		open c_po_detail ;

		fetch c_po_detail
		into @item_code
			 ,@item_name
			 ,@uom_code
			 ,@uom_name
			 ,@price_amount
			 ,@order_quantity
			 ,@purchase_order_detail_id
			 ,@type_asset_code
			 ,@item_category_code
			 ,@item_category_name
			 ,@item_merk_code
			 ,@item_merk_name
			 ,@item_model_code
			 ,@item_model_name
			 ,@item_type_code
			 ,@item_type_name
			 ,@spesification
			 ,@order_remaining
			 ,@discount_amount
			 ,@ppn_amount
			 ,@pph_amount

		while @@fetch_status = 0
		begin
				--select	@receive_quantity = grnd.receive_quantity
				--from	dbo.good_receipt_note_detail	 grnd
				--		inner join dbo.good_receipt_note grn on grn.code = grnd.good_receipt_note_code
				--where	grn.purchase_order_code = @p_purchase_order_code
				--		and grn.status			= 'POST' ;

				exec dbo.xsp_good_receipt_note_detail_insert @p_id							= @id_detail output
															 ,@p_good_receipt_note_code		= @p_code
															 ,@p_item_code					= @item_code
															 ,@p_item_name					= @item_name
															 ,@p_type_asset_code			= @type_asset_code
															 ,@p_item_category_code			= @item_category_code
															 ,@p_item_category_name			= @item_category_name
															 ,@p_item_merk_code				= @item_merk_code
															 ,@p_item_merk_name				= @item_merk_name
															 ,@p_item_model_code			= @item_model_code
															 ,@p_item_model_name			= @item_model_name
															 ,@p_item_type_code				= @item_type_code
															 ,@p_item_type_name				= @item_type_name
															 ,@p_uom_code					= @uom_code
															 ,@p_uom_name					= @uom_name
															 ,@p_price_amount				= @price_amount
															 ,@p_po_quantity				= @order_remaining
															 ,@p_receive_quantity			= 0
															 ,@p_shipper_code				= ''
															 ,@p_no_resi					= ''
															 ,@p_purchase_order_detail_id	= @purchase_order_detail_id
															 ,@p_spesification				= @spesification
															 ,@p_discount_amount			= @discount_amount
															 ,@p_ppn_amount					= @ppn_amount
															 ,@p_pph_amount					= @pph_amount
															 ,@p_orig_price_amount			= @price_amount	
															 ,@p_orig_discount_amount		= @discount_amount
															 ,@p_orig_ppn_amount			= @ppn_amount			
															 ,@p_orig_pph_amount			= @pph_amount
															 ,@p_orig_total_amount			= 0
															 --
															 ,@p_cre_date					= @p_cre_date
															 ,@p_cre_by						= @p_cre_by
															 ,@p_cre_ip_address				= @p_cre_ip_address
															 ,@p_mod_date					= @p_mod_date
															 ,@p_mod_by						= @p_mod_by
															 ,@p_mod_ip_address				= @p_mod_ip_address	
				

				--exec dbo.xsp_good_receipt_note_detail_insert @p_id							= @id_detail output
				--											,@p_good_receipt_note_code		= @p_code
				--											,@p_item_code					= @item_code
				--											,@p_item_name					= @item_name
				--											,@p_type_asset_code				= @type_asset_code
				--											,@p_item_category_code			= @item_category_code
				--											,@p_item_category_name			= @item_category_name
				--											,@p_item_merk_code				= @item_merk_code
				--											,@p_item_merk_name				= @item_merk_name
				--											,@p_item_model_code				= @item_model_code
				--											,@p_item_model_name				= @item_model_name
				--											,@p_item_type_code				= @item_type_code
				--											,@p_item_type_name				= @item_type_name
				--											,@p_uom_code					= @uom_code
				--											,@p_uom_name					= @uom_name
				--											,@p_price_amount				= @price_amount
				--											,@p_po_quantity					= @order_remaining
				--											,@p_receive_quantity			= 0
				--											,@p_shipper_code				= ''
				--											,@p_no_resi						= ''
				--											,@p_purchase_order_detail_id	= @purchase_order_detail_id
				--											,@p_spesification				= @spesification
				--											,@p_cre_date					= @p_cre_date
				--											,@p_cre_by						= @p_cre_by
				--											,@p_cre_ip_address				= @p_cre_ip_address
				--											,@p_mod_date					= @p_mod_date
				--											,@p_mod_by						= @p_mod_by
				--											,@p_mod_ip_address				= @p_mod_ip_address	

				--if exists
				--(
				--	select	1
				--	from	dbo.good_receipt_note_detail	 grnd
				--			inner join dbo.good_receipt_note grn on grn.code = grnd.good_receipt_note_code
				--	where	grn.purchase_order_code = @p_purchase_order_code
				--			and grn.status			= 'POST'
				--			and grnd.item_code		= @item_code
				--)
				--begin

					
				--	if @order_remaining > 0
				--	begin
				--		exec dbo.xsp_good_receipt_note_detail_insert @p_id							= @id_detail output
				--													 ,@p_good_receipt_note_code		= @p_code
				--													 ,@p_item_code					= @item_code
				--													 ,@p_item_name					= @item_name
				--													 ,@p_type_asset_code			= @type_asset_code
				--													 ,@p_item_category_code			= @item_category_code
				--													 ,@p_item_category_name			= @item_category_name
				--													 ,@p_item_merk_code				= @item_merk_code
				--													 ,@p_item_merk_name				= @item_merk_name
				--													 ,@p_item_model_code			= @item_model_code
				--													 ,@p_item_model_name			= @item_model_name
				--													 ,@p_item_type_code				= @item_type_code
				--													 ,@p_item_type_name				= @item_type_name
				--													 ,@p_uom_code					= @uom_code
				--													 ,@p_uom_name					= @uom_name
				--													 ,@p_price_amount				= @price_amount
				--													 ,@p_po_quantity				= @total_quantity
				--													 ,@p_receive_quantity			= 0
				--													 ,@p_shipper_code				= ''
				--													 ,@p_no_resi					= ''
				--													 ,@p_purchase_order_detail_id	= @purchase_order_detail_id
				--													 ,@p_spesification				= @spesification
				--													 ,@p_cre_date					= @p_cre_date
				--													 ,@p_cre_by						= @p_cre_by
				--													 ,@p_cre_ip_address				= @p_cre_ip_address
				--													 ,@p_mod_date					= @p_mod_date
				--													 ,@p_mod_by						= @p_mod_by
				--													 ,@p_mod_ip_address				= @p_mod_ip_address		
				--	end
				--end
				--else
				--begin
				--	set @total_quantity = @order_quantity

				--	exec dbo.xsp_good_receipt_note_detail_insert @p_id								= @id_detail output
				--													 ,@p_good_receipt_note_code		= @p_code
				--													 ,@p_item_code					= @item_code
				--													 ,@p_item_name					= @item_name
				--													 ,@p_type_asset_code			= @type_asset_code
				--													 ,@p_item_category_code			= @item_category_code
				--													 ,@p_item_category_name			= @item_category_name
				--													 ,@p_item_merk_code				= @item_merk_code
				--													 ,@p_item_merk_name				= @item_merk_name
				--													 ,@p_item_model_code			= @item_model_code
				--													 ,@p_item_model_name			= @item_model_name
				--													 ,@p_item_type_code				= @item_type_code
				--													 ,@p_item_type_name				= @item_type_name
				--													 ,@p_uom_code					= @uom_code
				--													 ,@p_uom_name					= @uom_name
				--													 ,@p_price_amount				= @price_amount
				--													 ,@p_po_quantity				= @total_quantity
				--													 ,@p_receive_quantity			= 0
				--													 ,@p_shipper_code				= ''
				--													 ,@p_no_resi					= ''
				--													 ,@p_purchase_order_detail_id	= @purchase_order_detail_id
				--													 ,@p_spesification				= @spesification
				--													 ,@p_cre_date					= @p_cre_date
				--													 ,@p_cre_by						= @p_cre_by
				--													 ,@p_cre_ip_address				= @p_cre_ip_address
				--													 ,@p_mod_date					= @p_mod_date
				--													 ,@p_mod_by						= @p_mod_by
				--													 ,@p_mod_ip_address				= @p_mod_ip_address	
				
				--end



				--(+) Ari 2024-03-26 ket : get plat no, chasis, engine for searching filter
				--select	@plat_no = plat_no
				--		,@chassis_no = chassis_no
				--		,@engine = engine_no 
				--from	dbo.purchase_order_detail_object_info 
				--where	purchase_order_detail_id = @purchase_order_detail_id

				--update	dbo.good_receipt_note
				--set		new_spesification = isnull(new_spesification,'') + '/' + @plat_no + '/' + @chassis_no + '/' + @engine
				--where	code = @p_code
				--(+) Ari 2024-03-26

			fetch c_po_detail
			into @item_code
				,@item_name
				,@uom_code
				,@uom_name
				,@price_amount
				,@order_quantity
				,@purchase_order_detail_id
				,@type_asset_code
				,@item_category_code
				,@item_category_name
				,@item_merk_code
				,@item_merk_name
				,@item_model_code
				,@item_model_name
				,@item_type_code
				,@item_type_name
				,@spesification
				,@order_remaining
				,@discount_amount
				,@ppn_amount
				,@pph_amount
		end ;

		close c_po_detail ;
		deallocate c_po_detail ;

		select @unit_from = po.unit_from 
		from dbo.good_receipt_note grn
		inner join dbo.purchase_order po on grn.purchase_order_code = po.code
		where grn.code = @p_code

		if(@unit_from = 'RENT')
		begin
			declare cursor_name cursor fast_forward read_only for
			select id 
			from dbo.good_receipt_note_detail
			where good_receipt_note_code = @p_code
			
			open cursor_name
			
			fetch next from cursor_name 
			into @id_detail
			
			while @@fetch_status = 0
			begin
					select	@price_amount		= price_amount
							,@discount_amount	= discount_amount
							,@ppn_amount		= ppn_amount
							,@pph_amount		= pph_amount
					from	dbo.good_receipt_note_detail
					where	id = @id_detail ;

					update dbo.good_receipt_note_detail
					set total_amount	= @price_amount - @discount_amount + @ppn_amount - @pph_amount
						--
						,mod_by			= @p_mod_by
						,mod_date		= @p_mod_date
						,mod_ip_address	= @p_mod_ip_address
					where id = @id_detail
			    fetch next from cursor_name 
				into @id_detail
			end
			
			close cursor_name
			deallocate cursor_name

			--select @new_spec =	stuff((
			--	  select	distinct ',' + spesification
			--	  from		dbo.good_receipt_note_detail
			--	  where		good_receipt_note_code = @p_code
			--	  for xml path('')
			--  ), 1, 1, ''
			-- ) ;

			--update	dbo.good_receipt_note
			--set		new_spesification = @new_spec
			--where	code = @p_code ;
		end

		select	@new_spec = stuff((
							  select	distinct
										',' + spesification + ' ' + isnull(podoi.plat_no,'') + ' ' + isnull(podoi.engine_no,'') + ' ' + isnull(podoi.chassis_no,'')
							  from		dbo.good_receipt_note_detail					grnd
										left join dbo.purchase_order_detail_object_info podoi on (
																									 grnd.id							= podoi.good_receipt_note_detail_id
																									 and podoi.purchase_order_detail_id = grnd.purchase_order_detail_id
																								 )
							  where		good_receipt_note_code = @p_code
							  for xml path('')
						  ), 1, 1, ''
						 ) ;

		update	dbo.good_receipt_note
		set		new_spesification = @new_spec
		where	code = @p_code ;

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

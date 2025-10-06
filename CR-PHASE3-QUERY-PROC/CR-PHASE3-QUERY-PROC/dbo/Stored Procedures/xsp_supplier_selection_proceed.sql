CREATE PROCEDURE [dbo].[xsp_supplier_selection_proceed]
(
	@p_id			   bigint
	-- 
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@remark						nvarchar(4000)
			,@code							nvarchar(50)
			,@year							nvarchar(2)
			,@month							nvarchar(2)
			,@p_company_code				nvarchar(50)
			,@purchase_type_name			nvarchar(50)
			,@quotation_date				datetime
			,@expired_date					datetime
			,@item_group_code				nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@division_code					nvarchar(50)
			,@division_name					nvarchar(250)
			,@department_code				nvarchar(50)
			,@department_name				nvarchar(250)
			,@item_code						nvarchar(50)
			,@item_name						nvarchar(250)
			,@supplier_code					nvarchar(50)
			,@reff_type						nvarchar(20)
			,@requestor_code				nvarchar(50)
			,@remark_detail					nvarchar(4000)
			,@selection_date				datetime
			,@quotation_amount				decimal(18, 2)
			,@supplier_amount				decimal(18, 2)
			,@supplier_quantity				int
			,@quotation_code				nvarchar(50)
			,@selection_code				nvarchar(50)
			,@count_validate				int
			,@uom_code						nvarchar(50)
			,@tax_code						nvarchar(50)
			,@quantity						int
			,@description					nvarchar(4000)
			,@total_amount					decimal(18,2)
			,@temp_total_amount				decimal(18,2)
			,@pph_amount					bigint
			,@ppn_amount					bigint
			,@supplier_selection_detail_id	int
			,@supplier_name					nvarchar(250)
			,@requestor_name				nvarchar(250)
			,@uom_name						nvarchar(250)
			,@tax_name						nvarchar(250)
			,@amount						decimal(18,2)
			,@discount_amount				decimal(18,2)
			,@unit_from						nvarchar(25)
			,@is_rent						nvarchar(25)
			,@supplier_address				nvarchar(4000)
			,@type_asset_code				nvarchar(50)
			,@item_category_code			nvarchar(50)
			,@item_category_name			nvarchar(250)
			,@item_merk_code				nvarchar(50)
			,@item_merk_name				nvarchar(250)
			,@item_model_code				nvarchar(50)
			,@item_model_name				nvarchar(250)
			,@item_type_code				nvarchar(50)
			,@item_type_name				nvarchar(250)
			,@ppn_pct						decimal(9,6)
			,@pph_pct						decimal(9,6)
			,@spesification					nvarchar(4000)
			,@id_po_detail					bigint
			,@counter						int
			,@offering						nvarchar(4000)
			,@indent_days					int
			,@availability_status			nvarchar(50)
			,@procurement_type				nvarchar(50)
			,@date							datetime = dbo.xfn_get_system_date()
			,@bbn_name						nvarchar(250)
			,@bbn_location					nvarchar(250)
			,@bbn_address					nvarchar(4000)
			,@deliver_to_address			nvarchar(4000)
			,@application_no				nvarchar(50)
			,@asset_no						nvarchar(50)
			,@description_log				nvarchar(4000)
			,@reff_no						nvarchar(50)


	begin TRY
    		if exists --(+) raffy 2025/07/24 ditambahkan penjagaan agar jika double click terjadi, tidak kebentuk data double
		(		
			select	1
			from	dbo.supplier_selection_detail 
			where	id = @p_id 
					and supplier_selection_detail_status <> 'HOLD'
		)
		begin
			set @msg = 'Data already proceed'
			raiserror(@msg, 16, -1)
		end

		select	@quotation_code			= quotation_code
				,@p_company_code		= company_code
				,@branch_code			= branch_code
				,@branch_name			= branch_name
				,@division_code			= division_code
				,@division_name			= division_name
				,@department_code		= department_code
				,@department_name		= department_name
				,@selection_date		= selection_date
				,@supplier_code			= ssd.supplier_code
				,@supplier_name			= ssd.supplier_name
				,@requestor_code		= ssd.requestor_code
				,@requestor_name		= ssd.requestor_name
				,@discount_amount		= ssd.discount_amount
				,@selection_code		= ss.code
				,@remark				= ss.remark
				,@unit_from				= ssd.unit_from
				,@supplier_address		= ssd.supplier_address
				,@ppn_amount			= cast(ssd.ppn_amount as bigint)
				,@pph_amount			= cast(ssd.pph_amount as bigint)
				,@ppn_pct				= ssd.ppn_pct
				,@pph_pct				= ssd.pph_pct
				,@reff_no				= ssd.reff_no
		from	dbo.supplier_selection ss
				inner join dbo.supplier_selection_detail ssd on ss.code = ssd.selection_code
		where	ssd.id = @p_id

		select @procurement_type = isnull(pr.procurement_type, pr2.procurement_type)
				,@asset_no		 = isnull(pr.asset_no, pr2.asset_no)
		from dbo.supplier_selection_detail ssd
		inner join dbo.supplier_selection ss on (ssd.selection_code = ss.code)
		left join dbo.quotation_review_detail qrd on (qrd.id											 = ssd.quotation_detail_id)
		left join dbo.procurement prc on (prc.code collate latin1_general_ci_as							 = qrd.reff_no)
		left join dbo.procurement prc2 on (prc2.code													 = ssd.reff_no)
		left join dbo.procurement_request pr on (pr.code												 = prc.procurement_request_code)
		left join dbo.procurement_request pr2 on (pr2.code												 = prc2.procurement_request_code)
		where ssd.id = @p_id


		begin 
		if(@unit_from = 'RENT')
		begin
			if not exists(select 1 from dbo.purchase_order where supplier_code = @supplier_code and status = 'HOLD' and unit_from = @unit_from and procurement_type = @procurement_type)
			begin
				exec dbo.xsp_purchase_order_insert @p_code						= @code output
												   ,@p_company_code				= @p_company_code
												   ,@p_order_date				= @date
												   ,@p_supplier_code			= @supplier_code
												   ,@p_supplier_name			= @supplier_name
												   ,@p_supplier_address			= @supplier_address
												   ,@p_branch_code				= @branch_code
												   ,@p_branch_name				= @branch_name
												   ,@p_division_code			= @division_code
												   ,@p_division_name			= @division_name
												   ,@p_department_code			= @department_code
												   ,@p_department_name			= @department_name
												   ,@p_payment_methode_code		= 'SGS230100003'
												   ,@p_payment_methode_name		= 'PAYMENT TRANSFER'
												   ,@p_currency_code			= 'IDR'
												   ,@p_currency_name			= 'RUPIAH'
												   ,@p_order_type_code			= 'PO'
												   ,@p_total_amount				= 0
												   ,@p_ppn_amount				= 0
												   ,@p_pph_amount				= 0
												   ,@p_payment_by				= 'HO'
												   ,@p_receipt_by				= 'HO'
												   ,@p_is_termin				= '0'
												   ,@p_unit_from				= @unit_from
												   ,@p_procurement_type			= @procurement_type
												   ,@p_flag_process				= 'GNR'
												   ,@p_status					= 'HOLD'
												   ,@p_remark					= @remark
												   ,@p_reff_no					= @selection_code
												   ,@p_requestor_code			= @requestor_code
												   ,@p_requestor_name			= @requestor_name
												   ,@p_is_spesific_address		= '0'
												   ,@p_cre_date					= @p_mod_date
												   ,@p_eta_date					= @p_mod_date
												   ,@p_cre_by					= @p_mod_by
												   ,@p_cre_ip_address			= @p_mod_ip_address
												   ,@p_mod_date					= @p_mod_date
												   ,@p_mod_by					= @p_mod_by
												   ,@p_mod_ip_address			= @p_mod_ip_address ;
			end
			else
			begin
				select	@code = code
				from	dbo.purchase_order
				where	supplier_code		= @supplier_code
				and		status				= 'HOLD'
				and		unit_from			= 'RENT'
				and		procurement_type	= @procurement_type
			end
		end
		else 
		begin
			if not exists(select 1 from dbo.purchase_order where supplier_code = @supplier_code and status = 'HOLD' and unit_from = @unit_from and procurement_type = @procurement_type)
			begin
				exec dbo.xsp_purchase_order_insert @p_code						= @code output
												   ,@p_company_code				= @p_company_code
												   ,@p_order_date				= @date
												   ,@p_supplier_code			= @supplier_code
												   ,@p_supplier_name			= @supplier_name
												   ,@p_supplier_address			= @supplier_address
												   ,@p_branch_code				= @branch_code
												   ,@p_branch_name				= @branch_name
												   ,@p_division_code			= @division_code
												   ,@p_division_name			= @division_name
												   ,@p_department_code			= @department_code
												   ,@p_department_name			= @department_name
												   ,@p_payment_methode_code		= 'SGS230100003'
												   ,@p_payment_methode_name		= 'PAYMENT TRANSFER'
												   ,@p_currency_code			= 'IDR'
												   ,@p_currency_name			= 'RUPIAH'
												   ,@p_order_type_code			= 'PO'
												   ,@p_total_amount				= 0
												   ,@p_ppn_amount				= 0
												   ,@p_pph_amount				= 0
												   ,@p_payment_by				= 'HO'
												   ,@p_receipt_by				= 'HO'
												   ,@p_is_termin				= '0'
												   ,@p_unit_from				= @unit_from
												   ,@p_procurement_type			= @procurement_type
												   ,@p_flag_process				= 'GNR'
												   ,@p_status					= 'HOLD'
												   ,@p_remark					= @remark
												   ,@p_reff_no					= @selection_code
												   ,@p_requestor_code			= @requestor_code
												   ,@p_requestor_name			= @requestor_name
												   ,@p_is_spesific_address		= '0'
												   ,@p_cre_date					= @p_mod_date
												   ,@p_eta_date					= @p_mod_date
												   ,@p_cre_by					= @p_mod_by
												   ,@p_cre_ip_address			= @p_mod_ip_address
												   ,@p_mod_date					= @p_mod_date
												   ,@p_mod_by					= @p_mod_by
												   ,@p_mod_ip_address			= @p_mod_ip_address ;
			end
			else
			begin
				select	@code = code
				from	dbo.purchase_order
				where	supplier_code		= @supplier_code
				and		status				= 'HOLD'
				and		unit_from			= 'BUY'
				and		procurement_type	= @procurement_type
			end
		end

		select	@item_code						= ssd.item_code
				,@item_name						= ssd.item_name
				,@supplier_code					= ssd.supplier_code
				,@supplier_quantity				= ssd.quantity
				,@supplier_amount				= ssd.amount
				,@requestor_code				= ssd.requestor_code
				,@requestor_name				= ssd.requestor_name
				,@tax_code						= ssd.tax_code
				,@tax_name						= ssd.tax_name
				,@description					= ssd.remark
				,@supplier_selection_detail_id	= ssd.id
				,@discount_amount				= ssd.discount_amount
				,@uom_code						= ssd.uom_code
				,@uom_name						= ssd.uom_name
				,@type_asset_code				= ssd.type_asset_code
				,@item_category_code			= ssd.item_category_code
				,@item_category_name			= ssd.item_category_name
				,@item_merk_code				= ssd.item_merk_code
				,@item_merk_name				= ssd.item_merk_name
				,@item_model_code				= ssd.item_model_code
				,@item_model_name				= ssd.item_model_name
				,@item_type_code				= ssd.item_type_code
				,@item_type_name				= ssd.item_type_name
				,@ppn_amount					= cast(round(ssd.ppn_amount,0) as bigint)
				,@pph_amount					= cast(round(ssd.pph_amount,0) as bigint)
				,@spesification					= ssd.spesification
				,@availability_status			= isnull(qrd.unit_available_status,ssd.unit_available_status)
				,@indent_days					= isnull(qrd.indent_days, qrd.indent_days)
				,@offering						= case
												  	when isnull(qrd.offering,'')='' then isnull(ssd.offering,'')
												  	else qrd.offering
												  end
				,@bbn_name						= ssd.bbn_name
				,@bbn_location					= ssd.bbn_location
				,@bbn_address					= ssd.bbn_address
				,@deliver_to_address			= ssd.deliver_to_address
		from	dbo.supplier_selection_detail ssd
		left join dbo.quotation_review_detail qrd on (qrd.id = ssd.quotation_detail_id)
		where	ssd.id = @p_id ;

		if not exists (select 1 from dbo.purchase_order_detail where po_code = @code and supplier_selection_detail_id = @p_id) --(+) Raffy 2024/11/06 Penambahan validasi agar tidak bisa masuk double
		begin
			exec dbo.xsp_purchase_order_detail_insert	@p_id								= @id_po_detail output
														,@p_po_code							= @code
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
														,@p_uom_code						= @uom_code
														,@p_uom_name						= @uom_name
														,@p_price_amount					= @supplier_amount
														,@p_discount_amount					= @discount_amount
														,@p_order_quantity					= @supplier_quantity
														,@p_order_remaining					= @supplier_quantity
														,@p_description						= @description
														,@p_tax_code						= @tax_code
														,@p_tax_name						= @tax_name
														,@p_ppn_pct							= @ppn_pct
														,@p_pph_pct							= @pph_pct
														,@p_ppn_amount						= @ppn_amount
														,@p_pph_amount						= @pph_amount
														,@p_requestor_code					= @requestor_code
														,@p_requestor_name					= @requestor_name
														,@p_supplier_selection_detail_id	= @supplier_selection_detail_id
														,@p_eta_date_detail					= @p_mod_date
														,@p_initiation_eta_date				= @p_mod_date
														,@p_spesification					= @spesification
														,@p_unit_available_status			= @availability_status
														,@p_indent_days						= @indent_days
														,@p_offering						= @offering
														,@p_bbn_name						= @bbn_name
													    ,@p_bbn_location					= @bbn_location
													    ,@p_bbn_address						= @bbn_address
														,@p_deliver_to_address				= @deliver_to_address
														--
														,@p_cre_date						= @p_mod_date
														,@p_cre_by							= @p_mod_by
														,@p_cre_ip_address					= @p_mod_ip_address
														,@p_mod_date						= @p_mod_date
														,@p_mod_by							= @p_mod_by
														,@p_mod_ip_address					= @p_mod_ip_address ;
			end
			-- insert ke table purchase order object info sesuai dengan order qty
			--set @counter = 0
			--while(@counter < @supplier_quantity)
			--begin
			--	exec dbo.xsp_purchase_order_detail_object_info_insert @p_id								= 0
			--													  ,@p_purchase_order_detail_id		= @id_po_detail
			--													  ,@p_good_receipt_note_detail_id	= 0
			--													  ,@p_plat_no						= ''
			--													  ,@p_chassis_no					= ''
			--													  ,@p_engine_no						= ''
			--													  ,@p_serial_no						= ''
			--													  ,@p_invoice_no					= ''
			--													  ,@p_domain						= ''
			--													  ,@p_imei							= ''
			--													  ,@p_cre_date						= @p_mod_date
			--													  ,@p_cre_by						= @p_mod_by
			--													  ,@p_cre_ip_address				= @p_mod_ip_address
			--													  ,@p_mod_date						= @p_mod_date
			--													  ,@p_mod_by						= @p_mod_by
			--													  ,@p_mod_ip_address				= @p_mod_ip_address
			--	set @counter  = @counter  + 1
			--end

			--Update Supplier Selection Detail
			update	dbo.supplier_selection_detail
			set		supplier_selection_detail_status = 'POST'
					,purchase_order_no				 = @code
					--
					,mod_date						 = @p_mod_date
					,mod_by							 = @p_mod_by
					,mod_ip_address					 = @p_mod_ip_address
			where	id = @supplier_selection_detail_id

			--Upadate amount, pph, ppn di header
			select	@total_amount			= sum ((isnull(price_amount, 0) - isnull(discount_amount, 0)) * isnull(order_quantity, 0) + cast(round(isnull(ppn_amount, 0),0) as bigint)  - cast(round(isnull(pph_amount,0),0) as bigint))
					,@pph_amount			= cast(sum(isnull(pph_amount, 0)) as bigint)
					,@ppn_amount			= cast(sum(isnull(ppn_amount, 0)) as bigint)
			from dbo.purchase_order_detail
			where po_code = @code

			update	dbo.purchase_order
			set		total_amount		= @total_amount
					,pph_amount			= @pph_amount
					,ppn_amount			= @ppn_amount
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where code = @code
		end ;

		select	distinct
				@asset_no	= d.asset_no
				,@item_name	= a.item_name
		from	dbo.supplier_selection_detail		  a
				left join dbo.quotation_review_detail b on a.reff_no = b.quotation_review_code collate Latin1_General_CI_AS
				left join dbo.procurement			  c on c.code	 = isnull(b.reff_no, a.reff_no)collate Latin1_General_CI_AS
				inner join dbo.procurement_request	  d on d.code	 = c.procurement_request_code
		where	a.reff_no = @reff_no ;

		select @application_no = isnull(application_no,'') 
		from ifinopl.dbo.application_asset 
		where asset_no = @asset_no

		if (@application_no <> '')
		begin
			set @description_log = 'Order request proceed, Asset no : ' + @asset_no + ' - ' + @item_name
		
			exec ifinopl.dbo.xsp_application_log_insert @p_id					= 0
														,@p_application_no		= @application_no
														,@p_log_date			= @date
														,@p_log_description		= @description_log
														,@p_cre_date			= @p_mod_date
														,@p_cre_by				= @p_mod_by
														,@p_cre_ip_address		= @p_mod_ip_address
														,@p_mod_date			= @p_mod_date
														,@p_mod_by				= @p_mod_by
														,@p_mod_ip_address		= @p_mod_ip_address
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

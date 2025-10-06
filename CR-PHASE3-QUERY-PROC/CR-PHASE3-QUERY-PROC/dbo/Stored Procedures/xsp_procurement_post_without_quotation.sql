CREATE PROCEDURE [dbo].[xsp_procurement_post_without_quotation]
(
	@p_code						 nvarchar(50)
	,@p_procurement_request_code nvarchar(50)
	,@p_company_code			 nvarchar(50)
	,@p_date_flag				 datetime	 = null
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@count_procurement				int
			,@count_request					int
			,@remark						nvarchar(4000)
			,@purchase_type_code			nvarchar(50)
			,@code							nvarchar(50)
			,@quotation_date				datetime
			,@expired_date					datetime
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@division_code					nvarchar(50)
			,@division_name					nvarchar(250)
			,@department_code				nvarchar(50)
			,@department_name				nvarchar(250)
			,@item_code						nvarchar(50)
			,@item_name						nvarchar(250)
			,@quantity_request				int
			,@approved_quantity				int
			,@specification					nvarchar(4000)
			,@requestor_code				nvarchar(50)
			,@uom_code						nvarchar(50)
			,@supplier_selection_code		nvarchar(50)
			,@min_supplier					int
			,@counter						int
			,@requestor_name				nvarchar(250)
			,@uom_name						nvarchar(250) 
			,@unit_from						nvarchar(25)
			,@type_asset_code				nvarchar(50)
			,@item_model_code				nvarchar(50)
			,@item_model_name				nvarchar(250)
			,@item_category_code			nvarchar(50)
			,@item_category_name			nvarchar(250)
			,@item_merk_code				nvarchar(50)
			,@item_merk_name				nvarchar(250)
			,@item_type_code				nvarchar(50)
			,@item_type_name				nvarchar(250)
			,@remark_item					nvarchar(4000)
			,@remark_proc_requeset			nvarchar(4000)
			,@remark_quo					nvarchar(4000)
			,@date							datetime = dbo.xfn_get_system_date()
			,@asset_amount					decimal(18,2)
			,@asset_discount_amount			decimal(18,2)
			,@karoseri_amount				decimal(18,2)
			,@karoseri_discount_amount		decimal(18,2)
			,@accesoris_amount				decimal(18,2)
			,@accesoris_discount_amount		decimal(18,2)
			,@mobilization_amount			decimal(18,2)
			,@application_no				nvarchar(50)
			,@otr_amount					decimal(18,2)
			,@gps_amount					decimal(18,2)
			,@budget_amount					decimal(18,2)
			,@new_spec						nvarchar(4000)
			,@new_spec_2					nvarchar(4000)
			,@fa_code						nvarchar(50)
			,@plat_no						nvarchar(50)
			,@engine_no						nvarchar(50)
			,@chasis_no						nvarchar(50)
			,@bbn_name						nvarchar(250)
			,@bbn_location					nvarchar(250)
			,@bbn_address					nvarchar(4000)
			,@deliver_to_address			nvarchar(4000)
			,@asset_no						nvarchar(50)
			,@description_log				nvarchar(4000)

	begin try

		select @branch_code		= value
				,@branch_name	= description
		from dbo.sys_global_param
		where code = 'HO'

		--if exists
		--(
		--	select	1
		--	from	dbo.procurement
		--	where	new_purchase = 'YES'
		--			and purchase_type_code is null
		--			and code	 = @p_code
		--)
		--begin
		--	set @msg = 'Please Input Purchase Type.' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		update	procurement
		set		status			= 'POST'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;

		select	@remark						= prc.remark
				,@purchase_type_code		= prc.purchase_type_code
				,@specification				= prc.specification
				,@item_code					= prc.item_code
				,@item_name					= prc.item_name
				,@quantity_request			= prc.quantity_request
				,@approved_quantity			= prc.approved_quantity
				,@remark_item				= prc.remark
				,@unit_from					= prc.unit_from
				,@uom_code					= pri.uom_code
				,@uom_name					= pri.uom_name
				,@type_asset_code			= prc.type_asset_code
				,@item_category_code		= prc.item_category_code
				,@item_category_name		= prc.item_category_name
				,@item_model_code			= prc.item_model_code
				,@item_model_name			= prc.item_model_name
				,@item_type_code			= prc.item_type_code
				,@item_type_name			= prc.item_type_name
				,@item_merk_code			= prc.item_merk_code
				,@item_merk_name			= prc.item_merk_name
				,@requestor_code			= prc.requestor_code
				,@requestor_name			= prc.requestor_name
				,@asset_amount				= prc.asset_amount
				,@asset_discount_amount		= prc.asset_discount_amount
				,@karoseri_amount			= prc.karoseri_amount
				,@karoseri_discount_amount	= prc.karoseri_discount_amount
				,@accesoris_amount			= prc.accesories_amount
				,@accesoris_discount_amount	= prc.accesories_discount_amount
				,@mobilization_amount		= prc.mobilization_amount
				,@application_no			= prc.application_no
				,@otr_amount				= prc.otr_amount
				,@gps_amount				= prc.gps_amount
				,@budget_amount				= prc.budget_amount
				,@fa_code					= pri.fa_code
				,@bbn_name					= prc.bbn_name
				,@bbn_location				= prc.bbn_location
				,@bbn_address				= prc.bbn_address
				,@deliver_to_address		= prc.deliver_to_address
				,@asset_no					= pr.asset_no
		from	dbo.procurement prc
		left join dbo.procurement_request_item pri on (pri.id = prc.procurement_request_item_id)
		inner join dbo.procurement_request pr on pr.code = prc.procurement_request_code
		where	prc.code = @p_code ;

		select	@quotation_date			= request_date
				,@expired_date			= request_date
				,@branch_code			= branch_code
				,@branch_name			= branch_name
				,@division_code			= division_code
				,@division_name			= division_name
				,@department_code		= department_code
				,@department_name		= department_name
				,@remark_proc_requeset	= remark
		from	dbo.procurement_request
		where	code = @p_procurement_request_code ;


		update dbo.PROCUREMENT 
		set PURCHASE_TYPE_CODE		= 'NONQTN'
			,PURCHASE_TYPE_NAME		= 'WITHOUT QUOTATION'
			,MOD_DATE				= @p_mod_date
			,MOD_BY					= @p_mod_by
			,MOD_IP_ADDRESS			= @p_mod_ip_address
		where CODE = @p_code

		
		--if (@purchase_type_code = 'WTQTN')
		--begin

		--	if not exists
		--	(
		--		select	1
		--		from	dbo.quotation_review
		--		where	date_flag = @p_date_flag
		--		and unit_from = @unit_from
		--	)
		--	begin
		--		exec dbo.xsp_quotation_review_insert @p_code					=  @code output
		--											 ,@p_company_code			= @p_company_code
		--											 ,@p_quotation_review_date	= @date
		--											 ,@p_expired_date			= @expired_date
		--											 ,@p_branch_code			= @branch_code
		--											 ,@p_branch_name			= @branch_name
		--											 ,@p_division_code			= @division_code
		--											 ,@p_division_name			= @division_name
		--											 ,@p_department_code		= @department_code
		--											 ,@p_department_name		= @department_name
		--											 ,@p_requestor_code			= @requestor_code
		--											 ,@p_requestor_name			= @requestor_name
		--											 ,@p_status					= 'HOLD'
		--											 ,@p_date_flag				= @p_date_flag
		--											 ,@p_unit_from				= @unit_from
		--											 ,@p_remark					= @remark_quo
		--											 ,@p_cre_date				= @p_mod_date
		--											 ,@p_cre_by					= @p_mod_by
		--											 ,@p_cre_ip_address			= @p_mod_ip_address
		--											 ,@p_mod_date				= @p_mod_date
		--											 ,@p_mod_by					= @p_mod_by
		--											 ,@p_mod_ip_address			= @p_mod_ip_address ;
		--	end ;
		--	else
		--	begin
		--		select	@code = code
		--		from	dbo.quotation_review
		--		where	date_flag = @p_date_flag 
		--		and		unit_from = @unit_from;
		--	end ;

		--	select	@min_supplier = value
		--	from	dbo.sys_global_param
		--	where	code = 'MINSUPP' ;

		--	set @counter = 1 ;
		--	while (@counter <= @min_supplier)
		--	begin		
		--		exec dbo.xsp_quotation_review_detail_insert @p_id								= 0
		--													,@p_quotation_review_code			= @code
		--													,@p_quotation_review_date			= null
		--													,@p_reff_no							= @p_code
		--													,@p_branch_code						= @branch_code
		--													,@p_branch_name						= @branch_name
		--													,@p_currency_code					= 'IDR'
		--													,@p_currency_name					= 'RUPIAH'
		--													,@p_payment_methode_code			= @purchase_type_code
		--													,@p_item_code						= @item_code
		--													,@p_item_name						= @item_name
		--													,@p_type_asset_code					= @type_asset_code
		--													,@p_item_category_code				= @item_category_code
		--													,@p_item_category_name				= @item_category_name
		--													,@p_item_merk_code					= @item_merk_code
		--													,@p_item_merk_name					= @item_merk_name
		--													,@p_item_model_code					= @item_model_code
		--													,@p_item_model_name					= @item_model_name
		--													,@p_item_type_code					= @item_type_code
		--													,@p_item_type_name					= @item_type_name
		--													,@p_supplier_code					= ''
		--													,@p_supplier_name					= ''
		--													,@p_tax_code						= ''
		--													,@p_tax_name						= ''
		--													,@p_warranty_month					= 0
		--													,@p_warranty_part_month				= 0
		--													,@p_quantity						= @quantity_request
		--													,@p_approved_quantity				= @approved_quantity
		--													,@p_uom_code						= @uom_code
		--													,@p_uom_name						= @uom_name
		--													,@p_price_amount					= 0
		--													,@p_discount_amount					= 0
		--													,@p_requestor_code					= @requestor_code
		--													,@p_requestor_name					= @requestor_name
		--													,@p_unit_from						= @unit_from
		--													,@p_spesification					= @specification
		--													,@p_remark							= @remark
		--													,@p_expired_date					= null
		--													,@p_total_amount					= 0
		--													,@p_nett_price						= 0
		--													,@p_cre_date						= @p_mod_date
		--													,@p_cre_by							= @p_mod_by
		--													,@p_cre_ip_address					= @p_mod_ip_address
		--													,@p_mod_date						= @p_mod_date
		--													,@p_mod_by							= @p_mod_by
		--													,@p_mod_ip_address					= @p_mod_ip_address

		--		set @Counter = @Counter + 1 ;
		--	end ;

		--	select @remark_quo =	stuff((
		--		  select	distinct ',' + item_name
		--		  from		dbo.quotation_review_detail
		--		  where		quotation_review_code = @code
		--		  for xml path('')
		--	  ), 1, 1, ''
		--	 ) ;

		--	 update dbo.quotation_review
		--	 set remark = @unit_from + ' for ' +@remark_quo
		--	 where code = @code
		--end ;
		--else if (@purchase_type_code = 'NONQTN')
		if not exists
		(
			select 1 from dbo.supplier_selection 
			where unit_from = @unit_from
			and date_flag	= @p_date_flag
		)
		begin
			exec dbo.xsp_supplier_selection_insert @p_code					= @supplier_selection_code output
												   ,@p_company_code			= @p_company_code
												   ,@p_quotation_code		= ''
												   ,@p_selection_date		= @date
												   ,@p_branch_code			= @branch_code
												   ,@p_branch_name			= @branch_name
												   ,@p_division_code		= @division_code
												   ,@p_division_name		= @division_name
												   ,@p_department_code		= @department_code
												   ,@p_department_name		= @department_name
												   ,@p_status				= 'HOLD'
												   ,@p_remark				= @remark
												   ,@p_requestor_code		= @requestor_code
												   ,@p_requestor_name		= @requestor_name
												   ,@p_unit_from			= @unit_from
												   ,@p_date_flag			= @p_date_flag
												   --
												   ,@p_cre_date				= @p_mod_date
												   ,@p_cre_by				= @p_mod_by
												   ,@p_cre_ip_address		= @p_mod_ip_address
												   ,@p_mod_date				= @p_mod_date
												   ,@p_mod_by				= @p_mod_by
												   ,@p_mod_ip_address		= @p_mod_ip_address ;
		end
		else
		begin
			select	@supplier_selection_code = code
			from	dbo.supplier_selection
			where	date_flag		= @p_date_flag
			and unit_from			= @unit_from ;
		end
		begin
			--exec dbo.xsp_supplier_selection_insert @p_code					= @supplier_selection_code output
			--									   ,@p_company_code			= @p_company_code
			--									   ,@p_quotation_code		= ''
			--									   ,@p_selection_date		= @date
			--									   ,@p_branch_code			= @branch_code
			--									   ,@p_branch_name			= @branch_name
			--									   ,@p_division_code		= @division_code
			--									   ,@p_division_name		= @division_name
			--									   ,@p_department_code		= @department_code
			--									   ,@p_department_name		= @department_name
			--									   ,@p_status				= 'HOLD'
			--									   ,@p_remark				= @remark
			--									   ,@p_requestor_code		= @requestor_code
			--									   ,@p_requestor_name		= @requestor_name
			--									   --
			--									   ,@p_cre_date				= @p_mod_date
			--									   ,@p_cre_by				= @p_mod_by
			--									   ,@p_cre_ip_address		= @p_mod_ip_address
			--									   ,@p_mod_date				= @p_mod_date
			--									   ,@p_mod_by				= @p_mod_by
			--									   ,@p_mod_ip_address		= @p_mod_ip_address ;
			if(@unit_from = 'RENT')
			begin
				set @new_spec_2 = 'Rental Harian ' + @specification
			end

			select	@plat_no	= plat_no
					,@engine_no = engine_no
					,@chasis_no = chassis_no
			from	ifinams.dbo.asset_vehicle
			where	asset_code = @fa_code ;

			set @new_spec = isnull(@new_spec_2, @specification) + case
														  when isnull(@fa_code, '') <> '' then +' - ' + isnull(@plat_no, '') + ' - ' + isnull(@engine_no, '') + ' - ' + isnull(@chasis_no, '')
														  else ''
													  end ;
			
			exec dbo.xsp_supplier_selection_detail_insert @p_id									= 0
														  ,@p_selection_code					= @supplier_selection_code
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
														  ,@p_quantity							= @approved_quantity
														  ,@p_quotation_quantity				= 0
														  ,@p_total_amount						= 0
														  ,@p_remark							= @remark
														  ,@p_spesification						= @new_spec --@specification
														  ,@p_procurement_code					= @p_code
														  ,@p_requestor_code					= @requestor_code
														  ,@p_requestor_name					= @requestor_name
														  ,@p_supplier_selection_detail_status	= ''
														  ,@p_quotation_detail_id				= null
														  ,@p_discount_amount					= 0
														  ,@p_unit_from							= @unit_from
														  ,@p_unit_available_status				= null
														  ,@p_indent_days						= null
														  ,@p_offering							= null
														  ,@p_asset_amount						= @asset_amount
														  ,@p_asset_discount_amount				= @asset_discount_amount
														  ,@p_karoseri_amount					= @karoseri_amount
														  ,@p_karoseri_discount_amount			= @karoseri_discount_amount
														  ,@p_accesories_amount					= @accesoris_amount
														  ,@p_accesories_discount_amount		= @accesoris_discount_amount
														  ,@p_mobilization_amount				= @mobilization_amount
														  ,@p_application_no					= @application_no
														  ,@p_otr_amount						= @otr_amount
														  ,@p_gps_amount						= @gps_amount
														  ,@p_budget_amount						= @budget_amount
														  ,@p_bbn_name							= @bbn_name
														  ,@p_bbn_location						= @bbn_location
														  ,@p_bbn_address						= @bbn_address
														  ,@p_deliver_to_address				= @deliver_to_address
														  --
														  ,@p_cre_date							= @p_mod_date
														  ,@p_cre_by							= @p_mod_by
														  ,@p_cre_ip_address					= @p_mod_ip_address
														  ,@p_mod_date							= @p_mod_date
														  ,@p_mod_by							= @p_mod_by
														  ,@p_mod_ip_address					= @p_mod_ip_address ;
		end ;

		if (@count_procurement = @count_request)
		begin
			update	procurement_request
			set		status			= 'POST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_procurement_request_code ;
		end ;

		select @application_no = isnull(application_no,'') 
		from ifinopl.dbo.application_asset 
		where asset_no = @asset_no

		if(@application_no <> '')
		begin
			set @description_log = 'Procurement proceed without quotation, Asset no : ' + @asset_no + ' - ' + @item_name
		
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;


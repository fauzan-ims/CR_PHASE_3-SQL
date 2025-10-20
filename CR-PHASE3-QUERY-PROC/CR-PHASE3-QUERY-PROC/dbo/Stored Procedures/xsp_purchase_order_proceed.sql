-- Stored Procedure

CREATE PROCEDURE dbo.xsp_purchase_order_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@item_code							nvarchar(50)
			,@item_name							nvarchar(250)
			,@interface_remarks					nvarchar(4000)
			,@req_date							datetime
			,@reff_approval_category_code		nvarchar(50)
			,@request_code						nvarchar(50)
			,@req_amount						decimal(18,2)
			,@table_name						nvarchar(50)
			,@primary_column					nvarchar(50)
			,@dimension_code					nvarchar(50)
			,@dim_value							nvarchar(50)
			,@reff_dimension_code				nvarchar(50)
			,@reff_dimension_name				nvarchar(250)
			,@approval_code						nvarchar(50)
			,@approval_path						nvarchar(4000)
			,@path								nvarchar(250)
			,@reff_no							nvarchar(50)
			,@id								bigint
			,@id_purchase						bigint
			,@eta_date							datetime
			,@supplier_code						nvarchar(50)
			,@supplier_name						nvarchar(250)
			,@unit_from							nvarchar(25)
			,@system_date						datetime
			,@plat_no							nvarchar(50)
			,@engine_no							nvarchar(50)
			,@chasis_no							nvarchar(50)
			,@total_amount						decimal(18,2)
			,@remark_po							nvarchar(4000)
			,@url_path							nvarchar(250)
			,@requestor_code					nvarchar(50)
			,@requestor_name					nvarchar(250)

	begin try
		select @total_amount = po.total_amount 
		from dbo.purchase_order po
		where po.code = @p_code

		if @total_amount = 0
		begin
			set @msg = 'Total amount must be greater than 0.'
			raiserror (@msg, 16, 1)
		end

		if not exists(select 1 from dbo.purchase_order_detail where po_code = @p_code)
		begin
			set @msg = N'Please insert item first.'
			raiserror(@msg, 16, -1) ;
		end

		if exists(select 1 from dbo.purchase_order where payment_methode_code is null or payment_methode_code = '' and code = @p_code)
		begin
			set @msg = N'Payment Methode cannot be empty'

			raiserror(@msg, 16, -1) ;
		end

		if exists(select 1 from dbo.purchase_order where currency_code is null or currency_code = '' and code = @p_code)
		begin
			set @msg = N'Currency cannot be empty'

			raiserror(@msg, 16, -1) ;
		end

		if exists(select 1 from dbo.purchase_order_detail where uom_code is null or uom_code = '' and po_code = @p_code)
		begin
			set @msg = N'UOM cannot be empty'

			raiserror(@msg, 16, -1) ;
		end

		if exists(select 1 from dbo.purchase_order_detail where tax_code is null or tax_code = '' and po_code = @p_code)
		begin
			set @msg = N'TAX cannot be empty'

			raiserror(@msg, 16, -1) ;
		end

		if exists(select 1 from dbo.purchase_order_detail where price_amount = 0 and order_quantity = 0 and po_code = @p_code)
		begin
			set @msg = N'price amount and order quantitiy cannot be empty'

			raiserror(@msg, 16, -1) ;
		end

		select @plat_no		= podo.plat_no
				,@engine_no = podo.engine_no
				,@chasis_no = podo.chassis_no
		from  dbo.purchase_order po 
		left join dbo.purchase_order_detail pod on (pod.po_code = po.code) 
		left join dbo.purchase_order_detail_object_info podo on (podo.purchase_order_detail_id = pod.id)
		where po.code = @p_code

		--if(@plat_no = '')
		--begin
		--	set @msg = N'Plat No cannot be empty.'
		--	raiserror(@msg, 16, -1) ;
		--end
		--if (isnull(@engine_no,'') = '')
		--		begin
		--			set @msg = N'Engine No cannot be empty.'
		--			raiserror(@msg, 16, -1) ;
		--		end
		--		else if (isnull(@chasis_no,'') = '')
		--		begin
		--			set @msg = N'Chasis No cannot be empty.'
		--			raiserror(@msg, 16, -1) ;
		--		end

		--validasi engine dan chasis wajib diisi
		--if exists(
		--	select	1
		--	from	dbo.purchase_order po
		--			left join dbo.purchase_order_detail pod on (pod.po_code = po.code)
		--			left join dbo.purchase_order_detail_object_info podoi on (pod.id = podoi.purchase_order_detail_id)
		--			left join dbo.supplier_selection_detail ssd on (ssd.id								  = pod.supplier_selection_detail_id)
		--			left join dbo.quotation_review_detail	qrd on (qrd.id								  = ssd.quotation_detail_id)
		--			left join dbo.procurement				prc on (prc.code collate latin1_general_ci_as = qrd.reff_no)
		--			left join dbo.procurement				prc2 on (prc2.code							  = ssd.reff_no)
		--			left join dbo.procurement_request		pr on (pr.code								  = prc.procurement_request_code)
		--			left join dbo.procurement_request		pr2 on (pr2.code							  = prc2.procurement_request_code)
		--			left join dbo.procurement_request_item	pri on (
		--															   pr.code							  = pri.procurement_request_code
		--															   and	pri.item_code				  = pod.item_code
		--														   )
		--			left join dbo.procurement_request_item	pri2 on (
		--																pr2.code						  = pri2.procurement_request_code
		--																and pri2.item_code				  = pod.item_code
		--															)
		--	where	po.code = @p_code
		--			and isnull(pri.category_type, pri2.category_type) = 'ASSET'
		--			and (isnull(podoi.engine_no, '') = '' 
		--			or isnull(podoi.chassis_no, '') = '')
		--	)
		--	begin
		--		set @msg = N'Chasis & Engine No cannot be empty.'
		--		raiserror(@msg, 16, -1) ;
		--	end


		if exists
		(
			select	1
			from	dbo.purchase_order
			where	code	   = @p_code
					and status = 'HOLD'
		)
		begin
			update	dbo.purchase_order
			set		status			= 'ON PROCESS'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
		end 
		else
		begin
			set @msg = N'Data already process' ;
			raiserror(@msg, 16, 1) ;
		end ;

		--SEPRIA CR PRIORITY, 05062026: UNTUK ORDER TIDAK MASUK KE APPROVAL, LANGSUNG POST

		--Auto Post
		exec dbo.xsp_purchase_order_post @p_code			= @p_code
										 ,@p_mod_date		= @p_mod_date
										 ,@p_mod_by			= @p_mod_by
										 ,@p_mod_ip_address = @p_mod_ip_address

		--SEPRIA CR PRIORITY, 05062026: UNTUK ORDER TIDAK MASUK KE APPROVAL, LANGSUNG POST
		--/* declare variables */
		--declare curr_apv cursor local fast_forward read_only for
		--select	po.branch_code
		--		,po.branch_name
		--		,po.total_amount
		--		,po.unit_from
		--		,po.supplier_name
		--		,po.remark
		--		,po.order_date
		--		,po.mod_by
		--		,sem.name
		--from dbo.purchase_order po
		--left join ifinsys.dbo.sys_employee_main sem on sem.code = po.mod_by
		--where po.code = @p_code

		--open curr_apv

		--fetch next from curr_apv 
		--into @branch_code
		--	,@branch_name
		--	,@req_amount
		--	,@unit_from
		--	,@supplier_name
		--	,@remark_po
		--	,@req_date
		--	,@requestor_code
		--	,@requestor_name

		--while @@fetch_status = 0
		--begin

		--    set @interface_remarks = N'Approval Purchase Order ' +  isnull(@unit_from,'') + ' ' +  'PO No ' + @p_code + ', vendor ' + @supplier_name + ', Amount : ' + format (@req_amount, '#,###.00', 'DE-de') + ', ' + @remark_po ;
		--	--set @req_date = dbo.xfn_get_system_date() ;

		--	select	@reff_approval_category_code = reff_approval_category_code
		--	from	dbo.master_approval
		--	where	code						 = 'PO' ;

		--	--select path di global param
		--	select	@url_path = value
		--	from	dbo.sys_global_param
		--	where	code = 'URL_PATH' ;

		--	select	@path = @url_path + value
		--	from	dbo.sys_global_param
		--	where	code = 'PATHOA'

		--	set	@approval_path = @path + @p_code

		--	exec dbo.xsp_proc_interface_approval_request_insert @p_code						= @request_code output
		--														,@p_branch_code				= @branch_code
		--														,@p_branch_name				= @branch_name
		--														,@p_request_status			= 'HOLD'
		--														,@p_request_date			= @req_date
		--														,@p_request_amount			= @req_amount
		--														,@p_request_remarks			= @interface_remarks
		--														,@p_reff_module_code		= 'IFINPROC'
		--														,@p_reff_no					= @p_code
		--														,@p_reff_name				= 'PURCHASE ORDER APPROVAL'
		--														,@p_paths					= @approval_path
		--														,@p_approval_category_code	= @reff_approval_category_code
		--														,@p_approval_status			= 'HOLD'
		--														,@p_requestor_code			= @request_code
		--														,@p_requesttor_name			= @requestor_name
		--														,@p_cre_date				= @p_mod_date	  
		--														,@p_cre_by					= @p_mod_by		  
		--														,@p_cre_ip_address			= @p_mod_ip_address
		--														,@p_mod_date				= @p_mod_date	  
		--														,@p_mod_by					= @p_mod_by		  
		--														,@p_mod_ip_address			= @p_mod_ip_address

		--	declare curr_appv cursor fast_forward read_only for
		--	select 	approval_code
		--			,reff_dimension_code
		--			,reff_dimension_name
		--			,dimension_code
		--	from	dbo.master_approval_dimension
		--	where	approval_code = 'PO'

		--	open curr_appv

		--	fetch next from curr_appv 
		--	into @approval_code
		--		,@reff_dimension_code
		--		,@reff_dimension_name
		--		,@dimension_code

		--	while @@fetch_status = 0
		--	begin
		--		select	@table_name					 = table_name
		--				,@primary_column			 = primary_column
		--		from	dbo.sys_dimension
		--		where	code						 = @dimension_code

		--		exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
		--													,@p_reff_code	= @p_code
		--													,@p_reff_table	= 'PURCHASE_ORDER'
		--													,@p_output		= @dim_value output ;

		--		exec dbo.xsp_proc_interface_approval_request_dimension_insert @p_id						= 0
		--																	  ,@p_request_code			= @request_code
		--																	  ,@p_dimension_code		= @reff_dimension_code
		--																	  ,@p_dimension_value		= @dim_value
		--																	  ,@p_cre_date				= @p_mod_date
		--																	  ,@p_cre_by				= @p_mod_by
		--																	  ,@p_cre_ip_address		= @p_mod_ip_address
		--																	  ,@p_mod_date				= @p_mod_date
		--																	  ,@p_mod_by				= @p_mod_by
		--																	  ,@p_mod_ip_address		= @p_mod_ip_address


		--	    fetch next from curr_appv 
		--		into @approval_code
		--			,@reff_dimension_code
		--			,@reff_dimension_name
		--			,@dimension_code
		--	end

		--	close curr_appv
		--	deallocate curr_appv


		--    fetch next from curr_apv 
		--	into @branch_code
		--		,@branch_name
		--		,@req_amount
		--		,@unit_from
		--		,@supplier_name

		--		,@remark_po

		--		,@req_date
		--		,@requestor_code
		--		,@requestor_name
		--end

		--close curr_apv
		--deallocate curr_apv		

		----cursor purchase order
		--declare c_purchase cursor for
		--select	pod.id
		--from	dbo.purchase_order po

		--		left join dbo.purchase_order_detail pod on (pod.po_code = po.code)
		--where	po.code = @p_code 

		--open	c_purchase

		--fetch	c_purchase

		--into	@id_purchase

		--while	@@fetch_status = 0
		--begin

		--	select	@reff_no			= isnull(pr.reff_no, pr2.reff_no)
		--			,@eta_date			= pod.eta_date
		--			,@supplier_code		= isnull(qrd.supplier_code, ssd.supplier_code)
		--			,@supplier_name		= isnull(qrd.supplier_name, ssd.supplier_name)

		--			,@unit_from			= isnull(prc.unit_from, prc2.unit_from)
		--	from	dbo.purchase_order_detail pod 
		--			left join dbo.supplier_selection_detail ssd on (ssd.id											 = pod.supplier_selection_detail_id)

		--			left join dbo.quotation_review_detail qrd on (qrd.id											 = ssd.quotation_detail_id)

		--			left join dbo.procurement prc on (prc.code collate Latin1_General_CI_AS							 = qrd.reff_no)
		--			left join dbo.procurement prc2 on (prc2.code													 = ssd.reff_no)
		--			left join dbo.procurement_request pr on (pr.code												 = prc.procurement_request_code)
		--			left join dbo.procurement_request pr2 on (pr2.code												 = prc2.procurement_request_code)
		--	where	pod.id = @id_purchase

		--	if (isnull(@reff_no, '') <> '')
		--	begin
		--		set	@system_date = dbo.xfn_get_system_date()

		--		exec dbo.xsp_proc_interface_purchase_order_update_insert @p_id				= @id output
		--																,@p_purchase_code	= @reff_no
		--																,@p_po_code			= @p_code
		--																,@p_eta_po_date		= @eta_date
		--																,@p_supplier_code	= @supplier_code
		--																,@p_supplier_name	= @supplier_name
		--																,@p_unit_from		= @unit_from
		--																,@p_settle_date		= @system_date
		--																,@p_job_status		= 'HOLD'
		--																,@p_failed_remarks	= N''
		--																,@p_cre_date		= @p_mod_date
		--																,@p_cre_by			= @p_mod_by
		--																,@p_cre_ip_address	= @p_mod_ip_address

		--																,@p_mod_date		= @p_mod_date
		--																,@p_mod_by			= @p_mod_by
		--																,@p_mod_ip_address	= @p_mod_ip_address

		--	end

		--	fetch	c_purchase
		--	into	@id_purchase
		--end

		--close		c_purchase

		--deallocate	c_purchase





















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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;
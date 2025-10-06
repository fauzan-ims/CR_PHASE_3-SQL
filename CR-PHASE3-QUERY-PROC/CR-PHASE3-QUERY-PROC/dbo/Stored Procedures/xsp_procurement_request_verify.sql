CREATE PROCEDURE [dbo].[xsp_procurement_request_verify]
(
	@p_code			   nvarchar(50)
	,@p_company_code   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@year							nvarchar(2)
			,@month							nvarchar(2)
			,@code							nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(50)
			,@procurement_request_item_id	bigint
			,@item_code						nvarchar(50)
			,@item_name						nvarchar(50)
			,@quantity_request				int
			,@approved_quantity				int
			,@specification					nvarchar(4000)
			,@remark						nvarchar(4000)
			,@request_date					datetime
			,@requestor_code				nvarchar(50)
			,@requestor_name				nvarchar(250)
			,@type_asset_code				nvarchar(50)
			,@item_category_code			nvarchar(50)
			,@item_category_name			nvarchar(250)
			,@item_merk_code				nvarchar(50)
			,@item_merk_name				nvarchar(250)
			,@item_model_code				nvarchar(50)
			,@item_model_name				nvarchar(250)
			,@item_type_code				nvarchar(50)
			,@item_type_name				nvarchar(250)
			,@reff_dimension_code			nvarchar(50)
			,@reff_dimension_name			nvarchar(50)
			,@table_name					nvarchar(50)
			,@primary_column				nvarchar(50)
			,@dimension_code				nvarchar(50)
			,@dim_value						nvarchar(50)
			,@value_approval				nvarchar(250)
			,@approval_code					nvarchar(50)
			,@interface_remarks				nvarchar(4000)
			,@req_date						DATETIME
            ,@reff_approval_category_code	nvarchar(50)
			,@path							nvarchar(250)
			,@request_code					nvarchar(50)
			,@approve_qty					decimal(18,2)
			,@url_path						nvarchar(50)
			,@approval_path					nvarchar(250);

	begin try
		set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

		--Validasi jika jumlah quantity yang disetujui 0
		if exists(select 1 from dbo.procurement_request_item where approved_quantity = 0 and procurement_request_code = @p_code)
		begin
			set @msg = 'Quantity Approve Must be Greater Than 0.';
			raiserror(@msg, 16, -1) ;
		end

		-- Validasi jika jumlah quantity yang disetujui lebih dari yang di minta
		if exists(select 1 from dbo.procurement_request_item where approved_quantity > quantity_request and procurement_request_code = @p_code)
		begin
			set @msg = 'Quantity Approve Must be Less Than Quantity Request.';
			raiserror(@msg, 16, -1) ;
		end

		--Update Procurement Request
		update	procurement_request
		set		status					= 'ON PROCESS'
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code
				and company_code		= @p_company_code ;

		--select	@branch_code			= branch_code
		--		,@branch_name			= branch_name
		--from	dbo.procurement_request
		--where	code					= @p_code ;

		----Cursor untuk insert ke Procurement
		--declare curr_proc_request cursor for
		--select		id
		--			,item_code
		--			,item_name
		--			,quantity_request
		--			,approved_quantity
		--			,specification
		--			,pri.remark
		--			,pr.request_date
		--			,pr.requestor_code
		--			,pr.requestor_name
		--			,pri.type_asset_code
		--			,pri.item_category_code
		--			,pri.item_category_name
		--			,pri.item_merk_code
		--			,pri.item_merk_name
		--			,pri.item_model_code
		--			,pri.item_model_name
		--			,pri.item_type_code
		--			,pri.item_type_name
		--from		dbo.procurement_request_item	   pri
		--			inner join dbo.procurement_request pr on (pr.code = pri.procurement_request_code)
		--where		procurement_request_code = @p_code
		--order by	id asc ;

		--open curr_proc_request ;

		--fetch next from curr_proc_request
		--into @procurement_request_item_id
		--	 ,@item_code
		--	 ,@item_name
		--	 ,@quantity_request
		--	 ,@approved_quantity
		--	 ,@specification
		--	 ,@remark
		--	 ,@request_date
		--	 ,@requestor_code
		--	 ,@requestor_name
		--	 ,@type_asset_code
		--	 ,@item_category_code
		--	 ,@item_category_name
		--	 ,@item_merk_code
		--	 ,@item_merk_name
		--	 ,@item_model_code
		--	 ,@item_model_name
		--	 ,@item_type_code
		--	 ,@item_type_name

		--while @@fetch_status = 0
		--begin
		--	if not exists
		--	(
		--		select	1
		--		from	dbo.procurement
		--		where	procurement_request_item_id	 = @procurement_request_item_id
		--				and procurement_request_code = @p_code
		--	)
		--	begin
		--			--Generate Code untuk procurement
		--			exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
		--														,@p_branch_code			= @p_company_code
		--														,@p_sys_document_code	= N''
		--														,@p_custom_prefix		= 'PRC'
		--														,@p_year				= @year
		--														,@p_month				= @month
		--														,@p_table_name			= 'PROCUREMENT'
		--														,@p_run_number_length	= 6
		--														,@p_delimiter			= '.'
		--														,@p_run_number_only		= N'0' ;

		--			exec dbo.xsp_procurement_insert @p_code								= @code
		--											,@p_company_code					= 'DSF'
		--											,@p_procurement_request_item_id		= @procurement_request_item_id
		--											,@p_procurement_request_code		= @p_code
		--											,@p_procurement_request_date		= @request_date
		--											,@p_branch_code						= @branch_code
		--											,@p_branch_name						= @branch_name
		--											,@p_item_code						= @item_code
		--											,@p_item_name						= @item_name
		--											,@p_type_asset_code					= @type_asset_code
		--											,@p_item_category_code				= @item_category_code
		--											,@p_item_category_name				= @item_category_name
		--											,@p_item_merk_code					= @item_merk_code
		--											,@p_item_merk_name					= @item_merk_name
		--											,@p_item_model_code					= @item_model_code
		--											,@p_item_model_name					= @item_model_name
		--											,@p_item_type_code					= @item_type_code
		--											,@p_item_type_name					= @item_type_name
		--											,@p_type_code						= 'FXDAST'
		--											,@p_type_name						= 'FIXED ASSET'
		--											,@p_quantity_request				= @quantity_request
		--											,@p_approved_quantity				= @approved_quantity
		--											,@p_specification					= @specification
		--											,@p_remark							= @remark
		--											,@p_purchase_type_code				= ''
		--											,@p_purchase_type_name				= ''
		--											,@p_quantity_purchase				= @approved_quantity
		--											,@p_status							= 'HOLD'
		--											,@p_requestor_code					= @requestor_code
		--											,@p_requestor_name					= @requestor_name
		--											,@p_cre_date						= @p_mod_date
		--											,@p_cre_by							= @p_mod_by
		--											,@p_cre_ip_address					= @p_mod_ip_address
		--											,@p_mod_date						= @p_mod_date
		--											,@p_mod_by							= @p_mod_by
		--											,@p_mod_ip_address					= @p_mod_ip_address 
					
		--	end ;

		--	fetch next from curr_proc_request
		--	into @procurement_request_item_id
		--		,@item_code
		--		,@item_name
		--		,@quantity_request
		--		,@approved_quantity
		--		,@specification
		--		,@remark
		--		,@request_date
		--		,@requestor_code
		--		,@requestor_name
		--		,@type_asset_code
		--		,@item_category_code
		--		,@item_category_name
		--		,@item_merk_code
		--		,@item_merk_name
		--		,@item_model_code
		--		,@item_model_name
		--		,@item_type_code
		--		,@item_type_name
		--end ;

		--close curr_proc_request ;
		--deallocate curr_proc_request ;

		/* declare variables */
		declare curr_apv cursor fast_forward read_only for
		select	pr.branch_code
				,pr.branch_name
				,pri.item_code		
				,pri.item_name
				,pri.approved_quantity
				,pr.request_date
		from dbo.procurement_request pr
		inner join dbo.procurement_request_item pri on (pr.code = pri.procurement_request_code)
		where pr.code = @p_code

		open curr_apv

		fetch next from curr_apv 
		into @branch_code
			,@branch_name
			,@item_code
			,@item_name
			,@approve_qty
			,@req_date

		while @@fetch_status = 0
		BEGIN
			set @interface_remarks = 'Approval Verification For ' + @item_code + ' - ' + @item_name ;
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'VRAPV' ;

			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'PATHVFA'

			--set approval path
			set	@approval_path = @path + @p_code

			exec dbo.xsp_proc_interface_approval_request_insert @p_code						= @request_code output
																,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_request_status			= 'HOLD'
																,@p_request_date			= @req_date
																,@p_request_amount			= @approve_qty
																,@p_request_remarks			= @interface_remarks
																,@p_reff_module_code		= 'IFINPROC'
																,@p_reff_no					= @p_code
																,@p_reff_name				= 'VERIFICATION APPROVAL'
																,@p_paths					= @approval_path
																,@p_approval_category_code	= @reff_approval_category_code
																,@p_approval_status			= 'HOLD'
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
			where	approval_code = 'VRAPV'

			open curr_appv

			fetch next from curr_appv 
			into @approval_code
				,@reff_dimension_code
				,@reff_dimension_name
				,@dimension_code

			while @@fetch_status = 0
			BEGIN
				select	@table_name					 = table_name
						,@primary_column			 = primary_column
				from	dbo.sys_dimension
				where	code						 = @dimension_code

				exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
															,@p_reff_code	= @p_code
															,@p_reff_table	= 'PROCUREMENT_REQUEST'
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
				fetch next from curr_appv 
				into @approval_code
					,@reff_dimension_code
					,@reff_dimension_name
					,@dimension_code
			end

			close curr_appv
			deallocate curr_appv

		fetch next from curr_apv 
		into @branch_code
			,@branch_name
			,@item_code
			,@item_name
			,@approve_qty
			,@req_date
		end
        
		close curr_apv
		deallocate curr_apv

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


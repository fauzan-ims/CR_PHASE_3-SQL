-- Stored Procedure

-- Stored Procedure

/*
exec xsp_job_interface_in_ifinproc_purchase_request
*/
CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinproc_purchase_request]
as
declare @msg							nvarchar(max)
		,@row_to_process				int
		,@last_id_from_job				bigint
		,@id_interface					bigint
		,@procurement_request_code		nvarchar(50)
		,@code_sys_job					nvarchar(50)
		,@last_id						bigint		 = 0
		,@number_rows					int			 = 0
		,@is_active						nvarchar(1)
		,@purchase_request_code			nvarchar(50)
		,@remark						nvarchar(4000)
		,@req_date						datetime	
		,@mod_date						datetime		 = getdate()
		,@mod_by						nvarchar(15)	 = 'job'
		,@mod_ip_address				nvarchar(15)	 = '127.0.0.1'
		,@from_id						bigint		 = 0
		,@unit_code						nvarchar(50)
		,@unit_name						nvarchar(250)
		,@branch_code					nvarchar(50)
		,@branch_name					nvarchar(250)
		,@marketing_code				nvarchar(50)
		,@marketing_name				nvarchar(250)
		,@warehouse_code				nvarchar(50)
		,@procurement_code				nvarchar(50)
		,@current_mod_date				datetime
		,@purchase_request_remark		nvarchar(4000) 
		,@item_category_code			nvarchar(50)
		,@item_category_name			nvarchar(250)
		,@item_merk_code				nvarchar(50)
		,@item_merk_name				nvarchar(250)
		,@item_model_code				nvarchar(50)
		,@item_model_name				nvarchar(250)
		,@item_type_code				nvarchar(50)
		,@item_type_name				nvarchar(250)
		,@specification					nvarchar(4000)
		,@unit_from						nvarchar(25)
		,@categori_type					nvarchar(20)
		,@asset_no						nvarchar(50)
		,@spaf_amount					decimal(18,2)
		,@subvention_amount				decimal(18,2)
		,@to_province_code				nvarchar(50)	
		,@to_province_name				nvarchar(250)	
		,@to_city_code					nvarchar(50)	
		,@to_city_name					nvarchar(250)	
		,@to_area_phone_no				nvarchar(4)		
		,@to_phone_no					nvarchar(15)	
		,@to_address					nvarchar(4000)	
		,@procurement_type				nvarchar(50)
		,@mobilization_fa_code			nvarchar(50)
		,@mobilization_fa_name			nvarchar(250)
		,@asset_amount					decimal(18,2)
		,@asset_discount_amount			decimal(18,2)
		,@karoseri_amount				decimal(18,2)
		,@karoseri_discount_amount		decimal(18,2)
		,@accesories_amount				decimal(18,2)
		,@accesories_discount_amount	decimal(18,2)
		,@application_no				nvarchar(50)
		,@mobilization_amount			decimal(18,2)
		,@otr_amount					decimal(18,2)
		,@gps_amount					decimal(18,2)
		,@budget_amount					decimal(18,2)
		,@bbn_name						nvarchar(250)
		,@bbn_location					nvarchar(250)
		,@bbn_address					nvarchar(4000)
		,@deliver_to_address			nvarchar(4000)
		,@built_year					nvarchar(4)
		,@asset_colour					nvarchar(50)
		,@asset_condition				nvarchar(15)

select	@code_sys_job		= code
		,@row_to_process	= row_to_process
		,@last_id_from_job	= last_id
		,@is_active			= is_active
from	dbo.sys_job_tasklist
where	sp_name				= 'xsp_job_interface_in_ifinproc_purchase_request' ; -- sesuai dengan nama sp ini

if (@is_active <> '0')
begin
	--get cashier received request
	declare curr_purchase_request cursor for
	select		id
				,code
				,branch_code
				,branch_name
				,marketing_code
				,isnull(marketing_name, '')
				,fa_category_code
				,fa_category_name
				,fa_merk_code
				,fa_merk_name
				,fa_model_code
				,fa_model_name
				,fa_type_code
				,fa_type_name
				,fa_unit_code
				,fa_unit_name
				,description
				,case
						when unit_from = 'RENT' then 'GTS - '
						else ''
					end + 'Asset No : ' + isnull(asset_no, '') + ' - Year : ' + fa_reff_no_04 + ' - Condition : ' + fa_reff_no_05 + ' - Colour : ' + fa_reff_no_06 + case
																																							when fa_type_code = 'VHCL' then ' - Transmition : ' + fa_reff_no_07
																																							else '.'
																																						end
				,request_date
				,unit_from
				,category_type
				,asset_no
				,spaf_amount
				,subvention_amount
				,mobilization_city_code
				,mobilization_city_description
				,mobilization_province_code
				,mobilization_province_description
				,mobilization_fa_code
				,mobilization_fa_name
				,deliver_to_area_no
				,deliver_to_phone_no
				,deliver_to_address
				,asset_amount
				,asset_discount_amount
				,karoseri_amount
				,karoseri_discount_amount
				,accesories_amount
				,accesories_discount_amount
				,application_no
				,mobilization_amount
				,otr_amount
				,gps_amount
				,budget_amount
				,bbn_name
				,bbn_location
				,bbn_address
				,deliver_to_address
				,built_year
				,asset_colour
				,fa_reff_no_05
	from		dbo.proc_interface_purchase_request
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_purchase_request ;

	fetch next from curr_purchase_request
	into @id_interface
		 ,@purchase_request_code 
		 ,@branch_code
		 ,@branch_name
		 ,@marketing_code
		 ,@marketing_name
		 ,@item_category_code	
		 ,@item_category_name	
		 ,@item_merk_code		
		 ,@item_merk_name		
		 ,@item_model_code		
		 ,@item_model_name		
		 ,@item_type_code		
		 ,@item_type_name		
		 ,@unit_code
		 ,@unit_name
		 ,@purchase_request_remark
		 ,@specification
		 ,@req_date
		 ,@unit_from
		 ,@categori_type
		 ,@asset_no
		 ,@spaf_amount
		 ,@subvention_amount
		 ,@to_city_code		
		 ,@to_city_name		
		 ,@to_province_code	
		 ,@to_province_name	
		 ,@mobilization_fa_code
		 ,@mobilization_fa_name
		 ,@to_area_phone_no	
		 ,@to_phone_no		
		 ,@to_address
		 ,@asset_amount
		 ,@asset_discount_amount
		 ,@karoseri_amount
		 ,@karoseri_discount_amount
		 ,@accesories_amount
		 ,@accesories_discount_amount
		 ,@application_no
		 ,@mobilization_amount
		 ,@otr_amount
		 ,@gps_amount
		 ,@budget_amount
		 ,@bbn_name
		 ,@bbn_location
		 ,@bbn_address
		 ,@deliver_to_address
		 ,@built_year
		 ,@asset_colour
		 ,@asset_condition

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			if (@categori_type = 'MOBILISASI')
			begin
				set @procurement_type = 'MOBILISASI'
			end
			else if (@categori_type = 'GPS' or @categori_type = 'BUDGET')
			begin
				set @procurement_type = 'EXPENSE'
			end
			else
			begin
				set @procurement_type = 'PURCHASE'
			end

			set @req_date = dbo.xfn_get_system_date() -- raffy buat testing qa dulu

			exec dbo.xsp_procurement_request_insert @p_code					= @procurement_request_code output		   
													,@p_company_code		= N'DSF'								   
													,@p_request_date		= @req_date								   
													,@p_requestor_code		= @marketing_code
													,@p_requestor_name		= @marketing_name				   
													,@p_requirement_type	= N'URGENT'								   
													,@p_branch_code			= @branch_code							   
													,@p_branch_name			= @branch_name			 		 								   
													,@p_status				= N'ON PROCESS'
													,@p_remark				= @purchase_request_remark
													,@p_reff_no				= @purchase_request_code
													,@p_procurement_type	= @procurement_type
													,@p_is_reimburse		= '0'
													,@p_asset_no			= @asset_no
													,@p_to_province_code	= @to_province_code
													,@p_to_province_name	= @to_province_name
													,@p_to_city_code		= @to_city_code	
													,@p_to_city_name		= @to_city_name	
													,@p_to_area_phone_no	= @to_area_phone_no	
													,@p_to_phone_no			= @to_phone_no		
													,@p_to_address			= @to_address
													,@p_application_no		= @application_no
													,@p_built_year			= @built_year
													,@p_asset_colour		= @asset_colour
													--
													,@p_cre_date			= @mod_date		
													,@p_cre_by				= @mod_by		
													,@p_cre_ip_address		= @mod_ip_address
													,@p_mod_date			= @mod_date		
													,@p_mod_by				= @mod_by		
													,@p_mod_ip_address		= @mod_ip_address

				exec dbo.xsp_procurement_request_item_insert @p_id							= 0
															 ,@p_procurement_request_code	= @procurement_request_code				
															 ,@p_item_code					= @unit_code							
															 ,@p_item_name					= @unit_name							
															 ,@p_quantity_request			= 1 									
															 ,@p_approved_quantity			= 1										
															 ,@p_specification				= @specification					
															 ,@p_remark						= @purchase_request_remark				
															 ,@p_uom_code					= 'UNT'									
															 ,@p_uom_name					= 'UNIT' 								
															 ,@p_type_asset_code			= @item_type_code
															 ,@p_item_category_code			= @item_category_code	
															 ,@p_item_category_name			= @item_category_name	
															 ,@p_item_merk_code				= @item_merk_code		
															 ,@p_item_merk_name				= @item_merk_name		
															 ,@p_item_model_code			= @item_model_code		
															 ,@p_item_model_name			= @item_model_name		
															 ,@p_item_type_code				= @item_type_code			
															 ,@p_item_type_name				= @item_type_name	
															 ,@p_fa_code					= @mobilization_fa_code
															 ,@p_fa_name					= @mobilization_fa_name
															 ,@p_category_type				= @categori_type
															 ,@p_spaf_amount				= @spaf_amount
															 ,@p_subvention_amount			= @subvention_amount
															 ,@p_asset_amount				= @asset_amount
															 ,@p_asset_discount_amount		= @asset_discount_amount
															 ,@p_karoseri_amount			= @karoseri_amount
															 ,@p_karoseri_discount_amount	= @karoseri_discount_amount
															 ,@p_accesories_amount			= @accesories_amount
															 ,@p_accesories_discount_amount	= @accesories_discount_amount
															 ,@p_mobilization_amount		= @mobilization_amount
															 ,@p_otr_amount					= @otr_amount
															 ,@p_gps_amount					= @gps_amount
															 ,@p_budget_amount				= @budget_amount
															 ,@p_bbn_name					= @bbn_name
															 ,@p_bbn_address				= @bbn_address
															 ,@p_bbn_location				= @bbn_location
															 ,@p_deliver_to_address			= @deliver_to_address
															 --																		 		
															 ,@p_cre_date					= @mod_date								 		
															 ,@p_cre_by						= @mod_by								 		
															 ,@p_cre_ip_address				= @mod_ip_address						 		
															 ,@p_mod_date					= @mod_date								 		
															 ,@p_mod_by						= @mod_by								 		
															 ,@p_mod_ip_address				= @mod_ip_address	
															 ,@p_condition					= @asset_condition
															 					 		
				-- proceed procurement_request																						 		
				--begin																												 		
				--	exec dbo.xsp_procurement_request_proceed @p_code			= @procurement_request_code
				--											 ,@p_company_code	= N'DSF'
				--											 ,@p_mod_date		= @mod_date		
				--											 ,@p_mod_by			= @mod_by		
				--											 ,@p_mod_ip_address = @mod_ip_address
				--end

				--approve procurement_request
				begin
					--update status terlebih dahulu
					--update dbo.procurement_request
					--set		status				= 'ON PROCESS'
					--		--
					--		,mod_date			= @mod_date
					--		,mod_by				= @mod_by
					--		,mod_ip_address		= @mod_ip_address
					--where	code				= @procurement_request_code

					--exec sp approve
					exec dbo.xsp_procurement_request_approve @p_code			= @procurement_request_code
															 ,@p_unit_from		= @unit_from
															 --
															 ,@p_mod_date		= @mod_date
															 ,@p_mod_by			= @mod_by
															 ,@p_mod_ip_address = @mod_ip_address
				end

				-- verify procurement_request
				--begin
				--	exec dbo.xsp_procurement_request_verify @p_code				= @procurement_request_code
				--											,@p_company_code	= N'DSF'
				--											,@p_mod_date		= @mod_date		
				--											,@p_mod_by			= @mod_by		
				--											,@p_mod_ip_address	= @mod_ip_address
				--end

				-- update procurement
				--begin
				--	select top 1
				--			@warehouse_code = code
				--	from	dbo.master_warehouse
				--	where	branch_code = @branch_code ;

				--	update	dbo.procurement
				--	set		new_purchase			 = 'YES'
				--			,purchase_type_code		 = 'NONQTN'
				--			,purchase_type_name		 = 'WITHOUT QUOTATION'
				--			,warehouse_code			 = @warehouse_code
				--			--						 
				--			,mod_date				 = @mod_date		
				--			,mod_by					 = @mod_by		
				--			,mod_ip_address			 = @mod_ip_address
				--	where	procurement_request_code = @procurement_request_code ;
				--end

				-- proceed & post procurement
				--begin
				--	select top 1
				--			@procurement_code = code
				--	from	dbo.procurement
				--	where	procurement_request_code = @procurement_request_code ;

				--	exec dbo.xsp_procurement_proceed @p_code						= @procurement_code
				--									 ,@p_procurement_request_code	= @procurement_request_code
				--									 ,@p_company_code				= N'DSF'
				--									 ,@p_date_flag					= @mod_date	
				--									 --
				--									 ,@p_mod_date					= @mod_date		
				--									 ,@p_mod_by						= @mod_by		
				--									 ,@p_mod_ip_address				= @mod_ip_address
				--end

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.proc_interface_purchase_request --cek poin
			set		job_status = 'POST'
			where	id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;

			update	dbo.proc_interface_purchase_request --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface ;

			print @msg ;

			--cek poin	

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;

			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= N'Error'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date --cek poin
													 ,@p_log_description	= @msg
													 ,@p_run_by				= @mod_by
													 ,@p_from_id			= @from_id --cek poin
													 ,@p_to_id				= @id_interface --cek poin
													 ,@p_number_of_rows		= @number_rows --cek poin
													 ,@p_cre_date			= @current_mod_date --cek poin
													 ,@p_cre_by				= @mod_by
													 ,@p_cre_ip_address		= @mod_ip_address
													 ,@p_mod_date			= @current_mod_date --cek poin
													 ,@p_mod_by				= @mod_by
													 ,@p_mod_ip_address		= @mod_ip_address ;

			-- clear cursor when error
			--close curr_purchase_request ;
			--deallocate curr_purchase_request ;

			-- stop looping
			--break ;
		end catch ;

		fetch next from curr_purchase_request
		into @id_interface
			 ,@purchase_request_code 
			 ,@branch_code
			 ,@branch_name
			 ,@marketing_code
			 ,@marketing_name
			 ,@item_category_code	
			 ,@item_category_name	
			 ,@item_merk_code		
			 ,@item_merk_name		
			 ,@item_model_code		
			 ,@item_model_name		
			 ,@item_type_code		
			 ,@item_type_name		
			 ,@unit_code
			 ,@unit_name
			 ,@purchase_request_remark
			 ,@specification
			 ,@req_date
			 ,@unit_from
			 ,@categori_type
			 ,@asset_no
			 ,@spaf_amount
			 ,@subvention_amount
			 ,@to_city_code		
			 ,@to_city_name		
			 ,@to_province_code	
			 ,@to_province_name	
			 ,@mobilization_fa_code
			 ,@mobilization_fa_name
			 ,@to_area_phone_no	
			 ,@to_phone_no		
			 ,@to_address
			 ,@asset_amount
			 ,@asset_discount_amount
			 ,@karoseri_amount
			 ,@karoseri_discount_amount
			 ,@accesories_amount
			 ,@accesories_discount_amount
			 ,@application_no
			 ,@mobilization_amount
			 ,@otr_amount
			 ,@gps_amount
			 ,@budget_amount
			 ,@bbn_name
			 ,@bbn_location
			 ,@bbn_address
			 ,@deliver_to_address
			 ,@built_year
			 ,@asset_colour
			 ,@asset_condition
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_purchase_request') >= -1
		begin
			if cursor_status('global', 'curr_purchase_request') > -1
			begin
				close curr_purchase_request ;
			end ;

			deallocate curr_purchase_request ;
		end ;
	end ;

	if (@last_id > 0) --cek poin
	begin
		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate() ;

		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
												 ,@p_status				= N'Success'
												 ,@p_start_date			= @mod_date
												 ,@p_end_date			= @current_mod_date --cek poin
												 ,@p_log_description	= ''
												 ,@p_run_by				= @mod_by
												 ,@p_from_id			= @from_id --cek poin
												 ,@p_to_id				= @id_interface --cek poin
												 ,@p_number_of_rows		= @number_rows --cek poin
												 ,@p_cre_date			= @current_mod_date --cek poin
												 ,@p_cre_by				= @mod_by
												 ,@p_cre_ip_address		= @mod_ip_address
												 ,@p_mod_date			= @current_mod_date --cek poin
												 ,@p_mod_by				= @mod_by
												 ,@p_mod_ip_address		= @mod_ip_address ; 
	end ;
end ;

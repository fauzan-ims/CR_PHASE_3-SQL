/*
exec xsp_job_interface_in_ifinopl_master_item
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinopl_master_item
as
	declare @msg								nvarchar(max)
			,@row_to_process					int
			,@last_id_from_job					bigint
			,@type_asset_code					nvarchar(50)
			,@id_interface						bigint
			,@code_sys_job						nvarchar(50)
			,@is_active							nvarchar(1)
			,@last_id							bigint		  = 0
			,@number_rows						int			  = 0
			,@mod_date							datetime	  = getdate()
			,@mod_by							nvarchar(15)  = 'job'
			,@mod_ip_address					nvarchar(15)  = '127.0.0.1'
			,@from_id							bigint		  = 0
			,@current_mod_date					datetime
			,@is_success						nvarchar(1)	  = 0
			,@err_msg							nvarchar(4000)
			,@merk_code							nvarchar(50)
			,@model_code						nvarchar(50)
			,@type_code							nvarchar(50)
			,@item_code							nvarchar(50)
			,@temp_merk_code					nvarchar(50)
			,@temp_model_code					nvarchar(50)
			,@temp_type_code					nvarchar(50)
			--(+) fauzan
			,@temp_name							nvarchar(250)
			,@temp_description					nvarchar(4000)
			,@temp_category_type				nvarchar(20)
			,@temp_class_type_code				nvarchar(50)
			,@temp_class_type_name				nvarchar(250)
			,@temp_insurance_asset_type_code	nvarchar(50)
			,@temp_insurance_asset_type_name	nvarchar(250)
			,@temp_registration_class_type_code nvarchar(50)
			,@temp_registration_class_type_name nvarchar(250)
			,@is_spaf							nvarchar(1)
			,@spaf_pct							decimal(9, 6) ;

	begin try

		select	@code_sys_job = code
				,@row_to_process = row_to_process
				,@last_id_from_job = last_id
				,@is_active = is_active
		from	dbo.sys_job_tasklist
		where	sp_name = 'xsp_job_interface_in_ifinopl_master_item' ; -- sesuai dengan nama sp ini
			
		if (@is_active = '1')
		BEGIN
			
			--get approval request
			declare curr_master_item cursor for
			select	 id
						,type_asset_code
						,merk_code
						,model_code
						,type_code
						,item_code
			FROM		dbo.opl_interface_master_item
			WHERE		job_status IN
			(
				'HOLD', 'FAILED'
			)
			ORDER BY	id ASC OFFSET 0 ROWS FETCH NEXT @row_to_process ROWS ONLY ;

			open curr_master_item ;

			fetch next from curr_master_item
			into @id_interface
				 ,@type_asset_code 
				 ,@merk_code	
				 ,@model_code	
				 ,@type_code
				 ,@item_code

			while @@fetch_status = 0
			begin
				begin try
					set @is_success = '0' ;

					begin transaction ;

					if (@number_rows = 0)
					begin
						set @from_id = @id_interface ;
					end ;

					select	@temp_merk_code						= merk_code
							,@temp_model_code					= model_code
							,@temp_type_code					= type_code
							,@temp_name							= item_name
							,@temp_description					= item_name
							,@temp_category_type				= category_type
							,@temp_class_type_code				= class_type_code
							,@temp_class_type_name				= class_type_name
							,@temp_insurance_asset_type_code	= insurance_asset_type_code	
							,@temp_insurance_asset_type_name	= insurance_asset_type_name	
							,@temp_registration_class_type_code	= registration_class_type_code
							,@temp_registration_class_type_name = registration_class_type_name
							,@is_spaf							= is_spaf
							,@spaf_pct							= spaf_pct
					from	opl_interface_master_item
					where	id									= @id_interface ;
			
					if (@type_asset_code = 'VHCL')
					begin  
			
						if not exists (select 1 from master_vehicle_merk where code = @merk_code)
						begin
							insert into dbo.master_vehicle_merk
							(
								code
								,description
								,vehicle_made_in_code
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	merk_code
									,merk_name
									,'OTHR'
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;

						end
				
						if not exists (select 1 from master_vehicle_model where code = @model_code)
						begin
						
							insert into dbo.master_vehicle_model
							(
								code
								,vehicle_merk_code
								,vehicle_subcategory_code
								,description
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	model_code
									,merk_code
									,'OTHR'
									,model_name
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;

						end

						if not exists (select 1 from master_vehicle_type where code = @type_code)
						begin 
							insert into dbo.master_vehicle_type
							(
								code
								,vehicle_model_code
								,description
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	type_code
									,model_code
									,type_name
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end

						if exists (select 1 from dbo.master_vehicle_unit where code = @item_code)
						begin 
							update dbo.master_vehicle_unit
							set		vehicle_merk_code				= @temp_merk_code
									,vehicle_model_code				= @temp_model_code
									,vehicle_type_code				= @temp_type_code
									,vehicle_name					= @temp_name
									,description 					= @temp_description 
									,category_type					= @temp_category_type 
									,class_type_code				= @temp_class_type_code
									,class_type_name				= @temp_class_type_name
									,insurance_asset_type_code		= @temp_insurance_asset_type_code	
									,insurance_asset_type_name		= @temp_insurance_asset_type_name	
									,registration_class_type_code	= @temp_registration_class_type_code
									,registration_class_type_name	= @temp_registration_class_type_name
									,is_spaf						= @is_spaf
									,spaf_pct						= @spaf_pct
									--
									,mod_date						= @mod_date
									,mod_by							= @mod_by
									,mod_ip_address					= @mod_ip_address
							where	code							= @item_code;
						end
						else if not exists (select 1 from dbo.master_vehicle_unit where code = @item_code)
						begin
							insert into dbo.master_vehicle_unit
							(
								code
								,vehicle_category_code
								,vehicle_subcategory_code
								,vehicle_merk_code
								,vehicle_model_code
								,vehicle_type_code
								,vehicle_name
								,description
								,is_cbu
								,is_karoseri
								,usefull_life
								,category_type
								,class_type_code
								,class_type_name
								,insurance_asset_type_code	
								,insurance_asset_type_name	
								,registration_class_type_code
								,registration_class_type_name
								,is_spaf
								,spaf_pct
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	item_code
									,'OTHR'
									,'OTHR'
									,merk_code
									,model_code
									,type_code
									,item_name
									,item_name
									,'0'
									,'0'
									,5
									,category_type
									,class_type_code
									,class_type_name
									,insurance_asset_type_code	
									,insurance_asset_type_name	
									,registration_class_type_code
									,registration_class_type_name
									,is_spaf
									,spaf_pct
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.OPL_INTERFACE_MASTER_ITEM
							where	id = @id_interface ;
						end
					end
					else if (@type_asset_code = 'MCHN')
					begin  
						if not exists (select 1 from master_machinery_merk where code = @merk_code)
						begin
							insert into dbo.master_machinery_merk
							(
								code
								,description 
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	merk_code
									,merk_name 
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
				
						if not exists (select 1 from master_machinery_model where code = @model_code)
						begin
							insert into dbo.master_machinery_model
							(
								code
								,machinery_merk_code
								,machinery_subcategory_code
								,description
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	model_code
									,merk_code
									,'OTHR'
									,model_name
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
				
						if not exists (select 1 from master_machinery_type where code = @type_code)
						begin 
							insert into dbo.master_machinery_type
							(
								code
								,machinery_model_code
								,description
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	type_code
									,model_code
									,type_name
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
							
						if exists (select 1 from dbo.master_machinery_unit where code = @item_code)
						begin 
							update dbo.master_machinery_unit
							set		machinery_merk_code				= @temp_merk_code
									,machinery_model_code			= @temp_model_code
									,machinery_type_code			= @temp_type_code
									,machinery_name					= @temp_name
									,description 					= @temp_description 
									,category_type					= @temp_category_type
									,class_type_code				= @temp_class_type_code
									,class_type_name				= @temp_class_type_name
									,insurance_asset_type_code		= @temp_insurance_asset_type_code	
									,insurance_asset_type_name		= @temp_insurance_asset_type_name	
									,registration_class_type_code	= @temp_registration_class_type_code
									,registration_class_type_name	= @temp_registration_class_type_name
									,is_spaf						= @is_spaf
									,spaf_pct						= @spaf_pct
									--
									,mod_date						= @mod_date
									,mod_by							= @mod_by
									,mod_ip_address					= @mod_ip_address
							where	code							= @item_code;
						end 
						else
						begin
							insert into dbo.master_machinery_unit
							(
								code
								,machinery_category_code
								,machinery_subcategory_code
								,machinery_merk_code
								,machinery_model_code
								,machinery_type_code
								,machinery_name
								,description
								,usefull_life
								,category_type
								,class_type_code
								,class_type_name
								,insurance_asset_type_code	
								,insurance_asset_type_name	
								,registration_class_type_code
								,registration_class_type_name
								,is_spaf						
								,spaf_pct
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							) 
							select	item_code
									,'OTHR'
									,'OTHR'
									,merk_code
									,model_code
									,type_code
									,item_name
									,item_name
									,5
									,category_type
									,class_type_code
									,class_type_name
									,insurance_asset_type_code	
									,insurance_asset_type_name	
									,registration_class_type_code
									,registration_class_type_name
									,is_spaf
									,spaf_pct
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
					end
					else if (@type_asset_code = 'HE')
					begin  
						if not exists (select 1 from master_he_merk where code = @merk_code)
						begin
							insert into dbo.master_he_merk
							(
								code
								,description 
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	merk_code
									,merk_name 
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
				
						if not exists (select 1 from master_he_model where code = @model_code)
						begin
							insert into dbo.master_he_model
							(
								code
								,he_merk_code
								,he_subcategory_code
								,description
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	model_code
									,merk_code
									,'OTHR'
									,model_name
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
				
						if not exists (select 1 from master_he_type where code = @type_code)
						begin 
							insert into dbo.master_he_type
							(
								code
								,he_model_code
								,description
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	type_code
									,model_code
									,type_name
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
						
						if exists (select 1 from dbo.master_he_unit where code = @item_code)
						begin 
							update dbo.master_he_unit
							set		he_merk_code					= @temp_merk_code
									,he_model_code					= @temp_model_code
									,he_type_code					= @temp_type_code
									,he_name						= @temp_name
									,description 					= @temp_description 
									,category_type					= @temp_category_type
									,class_type_code				= @temp_class_type_code
									,class_type_name				= @temp_class_type_name
									,insurance_asset_type_code		= @temp_insurance_asset_type_code	
									,insurance_asset_type_name		= @temp_insurance_asset_type_name	
									,registration_class_type_code	= @temp_registration_class_type_code
									,registration_class_type_name	= @temp_registration_class_type_name
									,is_spaf						= @is_spaf
									,spaf_pct						= @spaf_pct
									--				 
									,mod_date						= @mod_date
									,mod_by							= @mod_by
									,mod_ip_address					= @mod_ip_address
							where	code							= @item_code;
						end
						else
						begin
							insert into dbo.master_he_unit
							(
								code
								,he_category_code
								,he_subcategory_code
								,he_merk_code
								,he_model_code
								,he_type_code
								,he_name
								,description
								,usefull_life
								,category_type
								,class_type_code
								,class_type_name
								,insurance_asset_type_code	
								,insurance_asset_type_name	
								,registration_class_type_code
								,registration_class_type_name
								,is_spaf
								,spaf_pct
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							) 
							select	item_code
									,'OTHR'
									,'OTHR'
									,merk_code
									,model_code
									,type_code
									,item_name
									,item_name
									,5
									,category_type
									,class_type_code
									,class_type_name
									,insurance_asset_type_code	
									,insurance_asset_type_name	
									,registration_class_type_code
									,registration_class_type_name
									,is_spaf
									,spaf_pct
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
					end
					else if (@type_asset_code = 'ELCT')
					begin 
						if not exists (select 1 from master_electronic_merk where code = @merk_code)
						begin
							insert into dbo.master_electronic_merk
							(
								code
								,description 
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	merk_code
									,merk_name 
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
				
						if not exists (select 1 from master_electronic_model where code = @model_code)
						begin
							insert into dbo.master_electronic_model
							(
								code
								,electronic_merk_code
								,electronic_subcategory_code
								,description
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							)
							select	model_code
									,merk_code
									,'OTHR'
									,model_name
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
				
						if exists (select 1 from dbo.master_electronic_unit where code = @item_code)
						begin
							update dbo.master_electronic_unit
							set		electronic_merk_code			= @temp_merk_code
									,electronic_model_code			= @temp_model_code 
									,electronic_name				= @temp_name
									,description 					= @temp_description 
									,category_type					= @temp_category_type
									,class_type_code				= @temp_class_type_code
									,class_type_name				= @temp_class_type_name
									,insurance_asset_type_code		= @temp_insurance_asset_type_code	
									,insurance_asset_type_name		= @temp_insurance_asset_type_name	
									,registration_class_type_code	= @temp_registration_class_type_code
									,registration_class_type_name	= @temp_registration_class_type_name
									,is_spaf						= @is_spaf
									,spaf_pct						= @spaf_pct
									--						 
									,mod_date						= @mod_date
									,mod_by							= @mod_by
									,mod_ip_address					= @mod_ip_address
							where	code							= @item_code;
						end
						else
						begin
							insert into dbo.master_electronic_unit
							(
								code
								,electronic_category_code
								,electronic_subcategory_code
								,electronic_merk_code
								,electronic_model_code 
								,electronic_name
								,description
								,usefull_life
								,category_type
								,class_type_code
								,class_type_name
								,insurance_asset_type_code	
								,insurance_asset_type_name	
								,registration_class_type_code
								,registration_class_type_name
								,is_spaf
								,spaf_pct
								,is_active
								--
								,cre_date
								,cre_by
								,cre_ip_address
								,mod_date
								,mod_by
								,mod_ip_address
							) 
							select	item_code
									,'OTHR'
									,'OTHR'
									,merk_code
									,model_code 
									,item_name
									,item_name
									,5
									,category_type
									,class_type_code
									,class_type_name
									,insurance_asset_type_code	
									,insurance_asset_type_name	
									,registration_class_type_code
									,registration_class_type_name
									,is_spaf
									,spaf_pct
									,'1'
									--
									,@mod_date
									,@mod_by
									,@mod_ip_address
									,@mod_date
									,@mod_by
									,@mod_ip_address
							from	dbo.opl_interface_master_item
							where	id = @id_interface ;
						end
					end

					set @number_rows = +1 ;
					set @last_id = @id_interface ;

					update	dbo.opl_interface_master_item --cek poin
					set		job_status		= 'POST'
					where	id				= @id_interface ;
					
					set @is_success = '1' ;
					commit transaction ;

				end try
				begin catch
				
					rollback transaction ;
					set @is_success = '0' ;
					set @msg = error_message() ;
					set @current_mod_date = getdate() ;

					update	dbo.opl_interface_master_item --cek poin
					set		job_status			= 'FAILED'
							,failed_remarks		= @msg
					where	id					= @id_interface ; --cek poin	

					/*insert into dbo.sys_job_tasklist_log*/
					exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
															 ,@p_status				= N'Error'
															 ,@p_start_date			= @mod_date
															 ,@p_end_date			= @current_mod_date --cek poin
															 ,@p_log_description	= @msg
															 ,@p_run_by				= 'job'
															 ,@p_from_id			= @from_id --cek poin
															 ,@p_to_id				= @id_interface --cek poin
															 ,@p_number_of_rows		= @number_rows --cek poin
															 ,@p_cre_date			= @current_mod_date --cek poin
															 ,@p_cre_by				= N'job'
															 ,@p_cre_ip_address		= N'127.0.0.1'
															 ,@p_mod_date			= @current_mod_date --cek poin
															 ,@p_mod_by				= N'job'
															 ,@p_mod_ip_address		= N'127.0.0.1' ;
															 
				
				end catch ;
			
				fetch next from curr_master_item
				into @id_interface
					 ,@type_asset_code
					 ,@merk_code	
					 ,@model_code	
					 ,@type_code
					 ,@item_code
			end ;

			begin -- close cursor
				if cursor_status('global', 'curr_master_item') >= -1
				begin
					if cursor_status('global', 'curr_master_item') > -1
					begin
						close curr_master_item ;
					end ;

					deallocate curr_master_item ;
				end ;
			end ;

			if (@last_id > 0) --cek poin
			begin
				set @current_mod_date = getdate() ;

				update	dbo.sys_job_tasklist
				set		last_id = @last_id
				where	code = @code_sys_job ;

				/*insert into dbo.sys_job_tasklist_log*/
				exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
														 ,@p_status				= 'Success'
														 ,@p_start_date			= @mod_date
														 ,@p_end_date			= @current_mod_date --cek poin
														 ,@p_log_description	= ''
														 ,@p_run_by				= 'job'
														 ,@p_from_id			= @from_id --cek poin
														 ,@p_to_id				= @last_id --cek poin
														 ,@p_number_of_rows		= @number_rows --cek poin
														 ,@p_cre_date			= @current_mod_date --cek poin
														 ,@p_cre_by				= 'job'
														 ,@p_cre_ip_address		= '127.0.0.1'
														 ,@p_mod_date			= @current_mod_date --cek poin
														 ,@p_mod_by				= 'job'
														 ,@p_mod_ip_address		= '127.0.0.1' ;
			end ;
		end ;
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

/*
exec xsp_job_interface_in_ifinams_asset 
*/ 
CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinams_asset]
as
declare @msg								nvarchar(max)
		,@row_to_process					int
		,@last_id_from_job					bigint
		,@type_asset_code					nvarchar(50)
		,@id_interface						BIGINT
		,@code_sys_job						NVARCHAR(50)
		,@is_active							NVARCHAR(1)
		,@last_id							BIGINT		= 0
		,@number_rows						INT			= 0
		,@mod_date							DATETIME		= GETDATE()
		,@mod_by							NVARCHAR(15) = 'job'
		,@mod_ip_address					NVARCHAR(15) = '127.0.0.1'
		,@from_id							BIGINT		= 0
		,@current_mod_date					DATETIME
		,@is_success						NVARCHAR(1)	= 0
		,@err_msg							NVARCHAR(4000) 
		,@merk_code							NVARCHAR(50)
		,@model_code						NVARCHAR(50)
		,@request_code						NVARCHAR(50)
		,@type_code							NVARCHAR(50)
		,@item_code							NVARCHAR(50)
		,@purchase_price					DECIMAL(18,2)
		,@category_name						NVARCHAR(250)
		,@category_code						NVARCHAR(50)
		,@depre_cat_comm_code				NVARCHAR(50)
		,@depre_cat_fiscal_code				NVARCHAR(50)
		,@use_life							INT
		,@amt_threshold						DECIMAL(18,2)
		,@value_type						NVARCHAR(50)
		,@is_valid							INT
		,@is_depre							NVARCHAR(1)
		,@code								NVARCHAR(50)
		,@item_group_code					NVARCHAR(50)
		,@category_code_header				NVARCHAR(50)
		,@unit_from							NVARCHAR(50)
		,@cover_note						NVARCHAR(50)
		,@cover_note_date					DATETIME
		,@cover_exp_date					DATETIME
		,@cover_file_name					NVARCHAR(250)
		,@cover_file_path					NVARCHAR(250)
		,@is_maintenance					NVARCHAR(1)
		,@model_code_main					NVARCHAR(50)
		,@stnk_no							NVARCHAR(50)
		,@stnk_date							DATETIME
		,@stnk_exp_date						DATETIME
		,@stck_no							NVARCHAR(50)
		,@stck_date							DATETIME
		,@stck_exp_date						DATETIME
		,@keur_no							NVARCHAR(50)
		,@keur_date							DATETIME
		,@keur_exp_date						DATETIME
		,@usefull							INT
		,@rate								DECIMAL(9,6)
		,@posting_date						DATETIME --(+) Ari 2024-03-26 ket : add posting date

SELECT	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
FROM	dbo.sys_job_tasklist
WHERE	sp_name = 'xsp_job_interface_in_ifinams_asset' ; -- sesuai dengan nama sp ini

if (@is_active = '1')
begin
	--get approval request
	declare curr_asset cursor for
	select		id 
				,type_code
				,code
	from		dbo.efam_interface_asset
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_asset ;

	fetch next from curr_asset
	into @id_interface 
		 ,@type_code
		 ,@request_code

	while @@fetch_status = 0
	begin
		begin try
			set @is_success = '0' ;

			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			--Cek Apakah Depre atau tidak
			select	@item_code				= item_code
					,@purchase_price		= purchase_price
					,@code					= code
					,@item_group_code		= item_group_code
					,@category_code_header	= category_code
					,@unit_from				= asset_from
					,@cover_note			= cover_note
					,@cover_note_date		= cover_note_date
					,@cover_exp_date		= cover_exp_date
					,@cover_file_name		= file_name
					,@cover_file_path		= file_path
					,@stnk_no				= stnk_no
					,@stnk_date				= stnk_date
					,@stnk_exp_date			= stnk_exp_date
					,@keur_no				= keur_no
					,@keur_date				= keur_date
					,@keur_exp_date			= keur_exp_date
					--(+) Ari 2024-03-26 ket : add posting date, stck no, date & exp date
					,@posting_date			= posting_date 
					,@stck_no				= stck_no
					,@stck_date				= stck_date
					,@stck_exp_date			= stck_exp_date
			from dbo.efam_interface_asset
			where id = @id_interface

			select	@category_name					= mc.description -- temporary 
					,@amt_threshold					= depre_amount_threshold
					,@type_asset_code				= isnull(mc.asset_type_code,'')
					,@category_code					= mc.code
					,@depre_cat_comm_code			= mc.depre_cat_commercial_code
					,@depre_cat_fiscal_code			= mc.depre_cat_fiscal_code
					,@use_life						= mdcc.usefull
					,@amt_threshold					= mc.depre_amount_threshold
					,@value_type					= mc.value_type
			from	dbo.master_category mc
					inner join dbo.master_depre_category_commercial mdcc on mc.depre_cat_commercial_code = mdcc.code
			where	mc.code = @category_code_header

			-- jika unit from nya RENT maka tidak ter depre
			if(@unit_from =  'BUY')
			begin
				select @is_valid = dbo.xfn_depre_threshold_validation('DSF', @category_code, @purchase_price)
				if @is_valid = 1
				    set @is_depre = '1';
				else
				    set @is_depre = '0';

				set @is_maintenance = '1';
			end
            else
				set @is_maintenance = '0';
						
			--insert rv commercial
			select @rate = 100 - (usefull * rate)
			from dbo.master_depre_category_commercial
			where code = @depre_cat_comm_code

			insert into dbo.asset
			(
				code
				,company_code
				,item_code
				,item_name
				,item_group_code
				,condition
				,barcode
				,status
				,po_no
				,requestor_code
				,requestor_name
				,vendor_code
				,vendor_name
				,type_code
				,category_code
				,category_name
				,purchase_date
				,purchase_price
				,invoice_no
				,invoice_date
				,original_price
				,sale_amount
				,sale_date
				,disposal_date
				,branch_code
				,branch_name
				,division_code
				,division_name
				,department_code
				,department_name
				,pic_code
				,residual_value
				,is_depre
				,depre_category_comm_code
				,total_depre_comm
				,depre_period_comm
				,net_book_value_comm
				,depre_category_fiscal_code
				,total_depre_fiscal
				,depre_period_fiscal
				,net_book_value_fiscal
				,contractor_name
				,contractor_address
				,contractor_email
				,contractor_pic
				,contractor_pic_phone
				,contractor_start_date
				,contractor_end_date
				,warranty
				,warranty_start_date
				,warranty_end_date
				,remarks_warranty
				,is_maintenance
				,maintenance_time
				,maintenance_type
				,maintenance_cycle_time
				,maintenance_start_date
				,use_life
				,remarks
				,pph
				,ppn
				,is_po
				,is_rental
				,asset_from
				,asset_purpose
				,fisical_status
				,spaf_amount
				,subvention_amount
				,spaf_pct
				,rental_reff_no
				,is_spaf_use
				,ppn_amount
				,pph_amount
				,discount_amount
				,posting_date --(+) Ari 2024-03-26 ket : add posting date
				,re_rent_status
				,old_purchase_price
				,old_original_price
				,old_net_book_value_fiscal
				,old_net_book_value_commercial
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				,is_gps
				,gps_vendor_code		
				,gps_vendor_name	
				,gps_received_date	
			)
			select	code
					,company_code
					,item_code
					,item_name
					,item_group_code
					,condition
					,isnull(barcode, null)
					,status
					,isnull(po_no, null)
					,isnull(requestor_code, null)
					,isnull(requestor_name, null)
					,isnull(vendor_code, '')
					,isnull(vendor_name, '')
					,isnull(type_code,'')
					,isnull(category_code, null)
					,isnull(category_name, null)
					,purchase_date
					,purchase_price
					,isnull(invoice_no, null)
					,isnull(invoice_date, null)
					,original_price
					,isnull(sale_amount, 0)
					,isnull(sale_date, null)
					,isnull(disposal_date, null)
					,branch_code
					,branch_name
					,isnull(division_code, null)
					,isnull(division_name, null)
					,isnull(department_code, null)
					,isnull(department_name, null)
					,isnull(pic_code, null)
					,cast(@rate / 100 * purchase_price AS bigint)--isnull(residual_value, 0)
					,@is_depre
					,isnull(@depre_cat_comm_code,'')
					,isnull(total_depre_comm, 0)
					,isnull(depre_period_comm, null)
					,case when @purchase_price >= @amt_threshold then @purchase_price else 0 end
					,isnull(@depre_cat_fiscal_code,'')
					,isnull(total_depre_fiscal, 0)
					,isnull(depre_period_fiscal, null)
					,case when @purchase_price >= @amt_threshold then @purchase_price else 0 end
					,isnull(contractor_name, null)
					,isnull(contractor_address, null)
					,isnull(contractor_email, null)
					,isnull(contractor_pic, null)
					,isnull(contractor_pic_phone, null)
					,isnull(contractor_start_date, null)
					,isnull(contractor_end_date, null)
					,isnull(warranty, 0)
					,isnull(warranty_start_date, null)
					,isnull(warranty_end_date, null)
					,isnull(remarks_warranty, null)
					,isnull(@is_maintenance, null)
					,isnull(maintenance_time, 0)
					,isnull(maintenance_type, null)
					,isnull(maintenance_cycle_time, 0)
					,isnull(maintenance_start_date, null)
					,@use_life
					,isnull(remarks, null)
					,isnull(pph, 0)
					,isnull(ppn, 0)
					,isnull(is_po, '')
					,isnull(is_rent, '')
					,isnull(asset_from,'')
					,isnull(asset_purpose,'')
					,'ON HAND'
					,spaf_amount
					,subvention_amount
					,2
					,reff_no
					,case when  isnull(reff_no,'')  <> '' then '1' else '0' end -- Hari - 06.Jul.2023 08:04 PM --	JIKA ADA REFF NO OTOMATIS DIANGAP SUDAH TER CLAIM
					,ppn_amount
					,pph_amount
					,discount_amount
					,posting_date --(+) Ari 2024-03-26 ket : add posting date
					,'NOT'
					,purchase_price
					,original_price
					,case when @purchase_price >= @amt_threshold then @purchase_price else 0 end
					,case when @purchase_price >= @amt_threshold then @purchase_price else 0 end
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,isnull(is_gps,'0')
					,gps_vendor_code		
					,gps_vendor_name	
					,gps_received_date	
			from	dbo.efam_interface_asset
			where	id = @id_interface ;


			insert into dbo.asset_document
			(
				asset_code
				,description
				,file_name
				,file_path
				--(+) Ari 2024-04-04 ket : add doc sys
				,document_code
				,doc_file
				,doc_no
				,doc_date
				,doc_exp_date
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	asset_code
					,description
					,file_name
					,path
					,case	when description like '%STNK%'
							then (select code from ifinams.dbo.sys_general_document where document_name = 'STNK')
							when description like '%STCK%'
							then (select code from ifinams.dbo.sys_general_document where document_name = 'STCK')
							when description like '%KEUR%'
							then (select code from ifinams.dbo.sys_general_document where document_name = 'KEUR')
							else '-'
					end
					,doc_file
					,doc_no
					,doc_date
					,doc_exp_date
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
			from	dbo.efam_interface_asset_document
			where	asset_code = @request_code ;
			
			if (@type_code = 'ELCT')
			begin
				insert into dbo.asset_electronic
				(
					asset_code
					,merk_code
					,merk_name
					,type_item_code
					,type_item_name
					,model_code
					,model_name
					,serial_no
					,dimension
					,hdd
					,processor
					,ram_size
					,domain
					,imei
					,remark
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	asset_code
						,merk_code
						,merk_name
						,type_item_code
						,type_item_name
						,model_code
						,model_name
						,serial_no
						,dimension
						,hdd
						,processor
						,ram_size
						,domain
						,imei
						,remark
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.efam_interface_asset_electronic
				where	asset_code = @request_code ;
			end ;
			else if (@type_code = 'FNTR')
			begin
				insert into dbo.asset_furniture
				(
					asset_code
					,merk_code
					,merk_name
					,type_code
					,type_name
					,model_code
					,model_name
					,remark
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	asset_code
						,merk_code
						,merk_name
						,type_code
						,type_name
						,model_code
						,model_name
						,remark
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.efam_interface_asset_furniture
				where	asset_code = @request_code ;
			end ;
			else if (@type_code = 'MCHN')
			begin
				insert into dbo.asset_machine
				(
					asset_code
					,merk_code
					,merk_name
					,type_item_code
					,type_item_name
					,model_code
					,model_name
					,built_year
					,chassis_no
					,engine_no
					,colour
					,serial_no
					,remark
					,invoice_no
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	asset_code
						,merk_code
						,merk_name
						,type_item_code
						,type_item_name
						,model_code
						,model_name
						,built_year
						,chassis_no
						,engine_no
						,colour
						,serial_no
						,remark
						,invoice_no
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.efam_interface_asset_machine
				where	asset_code = @request_code ;
			end ;
			else if (@type_code = 'OTHR')
			begin
				insert into dbo.asset_other
				(
					asset_code
					,remark
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	asset_code
						,remark
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.efam_interface_asset_other
				where	asset_code = @request_code ;
			end ;
			else if (@type_code = 'PRTY')
			begin
				insert into dbo.asset_property
				(
					asset_code
					,imb_no
					,certificate_no
					,land_size
					,building_size
					,status_of_ruko
					,number_of_ruko_and_floor
					,total_square
					--,pph
					,vat
					,no_lease_agreement
					,date_of_lease_agreement
					,land_and_building_tax
					,security_deposit
					,owner
					,remark
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	asset_code
						,imb_no
						,certificate_no
						,land_size
						,building_size
						,status_of_ruko
						,number_of_ruko_and_floor
						,total_square
						--,pph
						,vat
						,no_lease_agreement
						,date_of_lease_agreement
						,land_and_building_tax
						,security_deposit
						,owner
						,remark
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.asset_property
				where	asset_code = @request_code ;
			end ;
			else if (@type_code = 'VHCL')
			begin
				insert into dbo.asset_vehicle
				(
					asset_code
					,merk_code
					,merk_name
					,type_item_code
					,type_item_name
					,model_code
					,model_name
					,plat_no
					,chassis_no
					,engine_no
					,bpkb_no
					,colour
					,cylinder
					,stnk_no
					,stnk_expired_date
					,stnk_tax_date
					,stnk_renewal
					,keur_no
					,keur_date
					,keur_expired_date
					,built_year
					,remark
					--(+) Ari 2024-03-26 ket : add stck no, date & exp date
					,stck_no
					,stck_date
					,stck_exp_date
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	asset_code
						,merk_code
						,merk_name
						,type_item_code
						,type_item_name
						,model_code
						,model_name
						,plat_no
						,chassis_no
						,engine_no
						,isnull(bpkb_no, '')
						,colour
						,cylinder
						,@stnk_no
						,@stnk_exp_date
						,@stnk_date
						,stnk_renewal
						,@keur_no
						,@keur_date
						,@keur_exp_date
						,built_year
						,remark
						--(+) Ari 2024-03-26 ket : add stck no, date & exp date
						,@stck_no
						,@stck_date
						,@stck_exp_date
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.efam_interface_asset_vehicle
				where	asset_code = @request_code ;
			end
			else if (@type_code = 'HE')
			begin
				insert into dbo.asset_he
				(
					asset_code
					,merk_code
					,merk_name
					,type_item_code
					,type_item_name
					,model_code
					,model_name
					,built_year
					,invoice_no
					,chassis_no
					,engine_no
					,colour
					,serial_no
					,remark
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select asset_code
					  ,merk_code
					  ,merk_name
					  ,type_item_code
					  ,type_item_name
					  ,model_code
					  ,model_name
					  ,built_year
					  ,invoice_no
					  ,chassis_no
					  ,engine_no
					  ,colour
					  ,serial_no
					  ,remark
					  --
					  ,@mod_date
					  ,@mod_by
					  ,@mod_ip_address
					  ,@mod_date
					  ,@mod_by
					  ,@mod_ip_address
				from dbo.efam_interface_asset_he
				where	asset_code = @request_code ;
			end
			
			-- jika unit from nya Buy maka generate maintenance schedule
			if(@unit_from =  'BUY')
			begin
				select	@model_code_main	= model_code
				from	dbo.efam_interface_asset_vehicle
				where	asset_code			= @request_code ;

				exec dbo.xsp_schedule_maintenance_asset_generate_master @p_code				= @code                  
				                                                        ,@p_model_code		= @model_code_main       
				                                                        ,@p_cre_by			= @mod_by 
				                                                        ,@p_cre_date		= @mod_date
				                                                        ,@p_cre_ip_address	= @mod_ip_address
				                                                        ,@p_mod_by			= @mod_by
				                                                        ,@p_mod_date		= @mod_date
				                                                        ,@p_mod_ip_address	= @mod_ip_address ;				
			end
			
			--insert into dbo.asset_maintenance_schedule
			--(
			--	asset_code
			--	,maintenance_no
			--	,maintenance_date
			--	,maintenance_status
			--	,last_status_date
			--	,reff_trx_no --
			--	,cre_by
			--	,cre_date
			--	,cre_ip_address
			--	,mod_by
			--	,mod_date
			--	,mod_ip_address
			--)
			--select	asset_code
			--		,maintenance_no
			--		,maintenance_date
			--		,maintenance_status
			--		,last_status_date
			--		,reff_trx_no
			--		--
			--		,@mod_by
			--		,@mod_date
			--		,@mod_ip_address
			--		,@mod_by
			--		,@mod_date
			--		,@mod_ip_address
			--from	dbo.efam_interface_asset_maintenance_schedule
			--where	asset_code = @request_code ;


			-- Data dari PROC langsung di proceed dan post
			exec dbo.xsp_asset_proceed @p_code				= @code
									   ,@p_mod_date			= @mod_date
									   ,@p_mod_by			= @mod_by
									   ,@p_mod_ip_address	= @mod_ip_address
			
			exec dbo.xsp_asset_post @p_code					= @code
									,@p_cover_note			= @cover_note
									,@p_cover_note_date		= @cover_note_date
									,@p_cover_exp_date		= @cover_exp_date
									,@p_cover_file_name		= @cover_file_name
									,@p_cover_file_path		= @cover_file_path
									,@p_mod_date			= @mod_date
									,@p_mod_by				= @mod_by
									,@p_mod_ip_address		= @mod_ip_address
			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.efam_interface_asset --cek poin
			set		job_status		= 'POST'
			where	id				= @id_interface ;

			commit transaction ;

			set @is_success = '1' ;	
		end try
		begin catch
			rollback transaction ;

			set @is_success = '0' ;
			set @msg = error_message() ;
			set @current_mod_date = getdate() ;

			update	dbo.efam_interface_asset --cek poin
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

		fetch next from curr_asset
		into @id_interface 
			 ,@type_code
			 ,@request_code
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_asset') >= -1
		begin
			if cursor_status('global', 'curr_asset') > -1
			begin
				close curr_asset ;
			end ;

			deallocate curr_asset ;
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

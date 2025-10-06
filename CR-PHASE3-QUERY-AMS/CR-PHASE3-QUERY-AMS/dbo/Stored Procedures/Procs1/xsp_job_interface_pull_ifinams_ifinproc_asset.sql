/*
	exec dbo.xsp_job_interface_pull_ifinams_ifinproc_asset
*/
-- Louis Kamis, 05 Januari 2023 10.53.04 --
CREATE PROCEDURE [dbo].[xsp_job_interface_pull_ifinams_ifinproc_asset]
AS
declare @msg				nvarchar(max)
		,@row_to_process	int
		,@last_id_from_job	bigint
		,@last_id			bigint			= 0
		,@code_sys_job		nvarchar(50)
		,@number_rows		int				= 0
		,@is_active			nvarchar(1)
		,@id_interface		bigint
		,@mod_date			datetime		= getdate()
		,@mod_by			nvarchar(15)	= 'job'
		,@mod_ip_address	nvarchar(15)	= '127.0.0.1'
		,@current_mod_date	datetime
		,@from_id			bigint			= 0
		,@request_code		nvarchar(50)
		,@type_code			nvarchar(50)
		,@merk_code			nvarchar(50)	= null
		,@model_code		nvarchar(50)	= null
		,@type_item_code	nvarchar(50)	= null
		,@merk_name			nvarchar(250)	= null
		,@model_name		nvarchar(250)	= null 
		,@type_item_name	nvarchar(250)	= null
		,@engine_no			nvarchar(50)
		,@plat_no			nvarchar(50)
		,@chasis_no			nvarchar(50)
		,@chasis_no_mchn	nvarchar(50)
		,@engine_no_mchn	nvarchar(50)
		,@invoice_no_he		nvarchar(50)
		,@engine_no_he		nvarchar(50)
		,@chasis_no_he		nvarchar(50)
		,@invoice_no_mchn	nvarchar(50)
		,@serial_no_elct	nvarchar(50)
		,@domain_elct		nvarchar(50)
		,@imei_elct			nvarchar(50)
		,@bpkb_no			nvarchar(50)
		,@posting_date		datetime -- (+) Ari 2024-03-26 ket : add posting date

-- sesuai dengan nama sp ini
select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_pull_ifinams_ifinproc_asset' ;

if (@is_active <> '0')
begin	
	--get cashier received request
	declare curr_asset cursor for
	select		eia.id
				,eia.type_code
				,eia.code
				,isnull(piah.merk_code,isnull(piav.merk_code, isnull(piae.merk_code, piam.merk_code)))
				,isnull(piah.model_code,isnull(piav.model_code, isnull(piae.model_code, piam.model_code)))
				,isnull(piah.type_item_code,isnull(piav.type_item_code, isnull(piae.type_item_code, piam.type_item_code)))
				,isnull(piah.merk_name,isnull(piav.merk_name, isnull(piae.merk_name, piam.merk_name)))
				,isnull(piah.model_name,isnull(piav.model_name, isnull(piae.model_name, piam.model_name)))
				,isnull(piah.type_item_name,isnull(piav.type_item_name, isnull(piae.type_item_name, piam.type_item_name)))
				,piav.engine_no
				,piav.chassis_no
				,piav.plat_no
				,piam.chassis_no
				,piam.engine_no
				,piam.invoice_no
				,piah.invoice_no
				,piah.engine_no
				,piah.chassis_no
				,piae.serial_no
				,piae.domain
				,piae.imei
				,piav.bpkb_no
				,eia.posting_date -- (+) Ari 2024-03-26 ket : add posting date
	from		ifinproc.dbo.eproc_interface_asset eia
				left join ifinproc.dbo.proc_interface_asset_vehicle piav on (piav.asset_code = eia.code)
				left join ifinproc.dbo.proc_interface_asset_electronic piae on (piae.asset_code = eia.code)
				left join ifinproc.dbo.proc_interface_asset_machine piam on (piam.asset_code = eia.code)
				left join ifinproc.dbo.proc_interface_asset_he piah on (piah.asset_code = eia.code)
	where		eia.id			   > @last_id_from_job
				and job_status = 'HOLD'
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_asset ;

	fetch next from curr_asset
	into @id_interface
		 ,@type_code
		 ,@request_code 
		 ,@merk_code		 
		 ,@model_code	 
		 ,@type_item_code 
		 ,@merk_name		 
		 ,@model_name	 
		 ,@type_item_name
		 ,@engine_no
		 ,@chasis_no
		 ,@plat_no
		 ,@chasis_no_mchn
		 ,@engine_no_mchn
		 ,@invoice_no_mchn
		 ,@invoice_no_he
		 ,@engine_no_he
		 ,@chasis_no_he
		 ,@serial_no_elct
		 ,@domain_elct
		 ,@imei_elct
		 ,@bpkb_no
		 ,@posting_date -- (+) Ari 2024-03-26 ket : add posting date

	WHILE @@fetch_status = 0
	BEGIN
		BEGIN TRY
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;
			
			insert into dbo.efam_interface_asset
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
				,remarks
				,pph
				,ppn
				,is_po
				,is_rent
				,asset_from
				,asset_purpose
				,spaf_amount
				,subvention_amount
				,bpkb_no
				,cover_note
				,cover_note_date
				,cover_exp_date
				,file_name
				,file_path
				,reff_no
				,document_type
				,stnk_no
				,stnk_date
				,stnk_exp_date
				,stck_no
				,stck_date
				,stck_exp_date
				,keur_no
				,keur_date
				,keur_exp_date
				,ppn_amount
				,pph_amount
				,discount_amount
				,posting_date -- (+) Ari 2024-03-26 ket : add posting date
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				--
				,is_gps
				,gps_vendor_code		
				,gps_vendor_name	
				,gps_received_date	
			)
			select	code
					,company_code
					,isnull(item_code, null)
					,isnull(item_name, null)
					,isnull(item_group_code, null)
					,isnull(condition, null)
					,isnull(barcode, null)
					,isnull(status, 'HOLD')
					,isnull(po_no, null)
					,isnull(requestor_code, null)
					,isnull(requestor_name, null)
					,isnull(vendor_code, null)
					,isnull(vendor_name, null)
					,isnull(type_code, null)
					,isnull(category_code, null)
					,isnull(category_name, null)
					,isnull(purchase_date, null)
					,isnull(purchase_price, 0)
					,isnull(invoice_no, null)
					,isnull(invoice_date, null)
					,isnull(original_price, 0)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(branch_code, null)
					,isnull(branch_name, null)
					,isnull(division_code, null)
					,isnull(division_name, null)
					,isnull(department_code, null)
					,isnull(department_name, null)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, '')
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, '')
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(remarks, null)
					,isnull(pph, 0)
					,isnull(ppn, 0)
					,isnull(is_po, '')
					,isnull(is_rental, '')
					,isnull(asset_from,'')
					,isnull(asset_purpose,'')
					,isnull(spaf_amount, 0)
					,isnull(subvention_amount, 0)
					,bpkb_no
					,cover_note
					,cover_note_date
					,cover_note_exp_date
					,file_name
					,file_path
					,reff_no
					,document_type
					,stnk_no
					,stnk_date
					,stnk_exp_date
					,stck_no
					,stck_date
					,stck_exp_date
					,keur_no
					,keur_date
					,keur_exp_date
					,ppn_amount
					,pph_amount
					,discount_amount
					,posting_date -- (+) Ari 2024-03-26 ket : add posting date
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
					--
					,isnull(is_gps,'0')
					,gps_vendor_code		
					,gps_vendor_name	
					,gps_received_date	
			from	ifinproc.dbo.eproc_interface_asset
			where	id = @id_interface ;
			
			IF (@type_code = 'VHCL')
			begin 
				exec dbo.xsp_efam_interface_asset_vehicle_insert @p_asset_code				 = @request_code			  
																 ,@p_merk_code				 = @merk_code					  
																 ,@p_merk_name				 = @merk_name			  
																 ,@p_type_item_code			 = @type_item_code			  
																 ,@p_type_item_name			 = @type_item_name			  
																 ,@p_model_code				 = @model_code				  
																 ,@p_model_name				 = @model_name				  
																 ,@p_plat_no				 = @plat_no						  
																 ,@p_chassis_no				 = @chasis_no						  
																 ,@p_engine_no				 = @engine_no						  
																 ,@p_bpkb_no				 = @bpkb_no						  
																 ,@p_colour					 = null						  
																 ,@p_cylinder				 = null						  
																 ,@p_stnk_no				 = null						  
																 ,@p_stnk_expired_date		 = null						  
																 ,@p_stnk_tax_date			 = null						  
																 ,@p_stnk_renewal			 = null						  
																 ,@p_built_year				 = null		 					  
																 ,@p_remark					 = null
																 --
																 ,@p_cre_date				= @mod_date
																 ,@p_cre_by					= @mod_by
																 ,@p_cre_ip_address			= @mod_ip_address
																 ,@p_mod_date				= @mod_date
																 ,@p_mod_by					= @mod_by
																 ,@p_mod_ip_address			= @mod_ip_address
			
			end
			else if(@type_code = 'MCHN')
			begin
				exec dbo.xsp_efam_interface_asset_machine_insert @p_asset_code				 = @request_code		
																 ,@p_merk_code				 = @merk_code			
																 ,@p_merk_name				 = @merk_name			
																 ,@p_type_item_code			 = @type_item_code		
																 ,@p_type_item_name			 = @type_item_name		
																 ,@p_model_code				 = @model_code			
																 ,@p_model_name				 = @model_name			
																 ,@p_built_year				 = null					
																 ,@p_chassis_no				 = @chasis_no_mchn					
																 ,@p_engine_no				 = @engine_no_mchn					
																 ,@p_colour					 = null					
																 ,@p_serial_no				 = null
																 ,@p_invoice_no				 = @invoice_no_mchn	 	
																 ,@p_remark					 = null
																 --
																 ,@p_cre_date				 = @mod_date
																 ,@p_cre_by					 = @mod_by
																 ,@p_cre_ip_address			 = @mod_ip_address
																 ,@p_mod_date				 = @mod_date
																 ,@p_mod_by					 = @mod_by
																 ,@p_mod_ip_address			 = @mod_ip_address
			
			end
			else if(@type_code = 'ELCT')
			begin
				exec dbo.xsp_efam_interface_asset_electronic_insert @p_asset_code				= @request_code	 
																	,@p_merk_code				= @merk_code			 
																	,@p_merk_name				= @merk_name			 
																	,@p_type_item_code			= @type_item_code		 
																	,@p_type_item_name			= @type_item_name		 
																	,@p_model_code				= @model_code			 
																	,@p_model_name				= @model_name			 
																	,@p_serial_no				= @serial_no_elct			 
																	,@p_dimension				= null		
																	,@p_hdd						= null			 
																	,@p_processor				= null			 
																	,@p_ram_size				= null			 
																	,@p_domain					= @domain_elct			 
																	,@p_imei					= @imei_elct		 	 
																	,@p_remark					= null
																	--
																	,@p_cre_date				 = @mod_date
																	,@p_cre_by					 = @mod_by
																	,@p_cre_ip_address			 = @mod_ip_address
																	,@p_mod_date				 = @mod_date
																	,@p_mod_by					 = @mod_by
																	,@p_mod_ip_address			 = @mod_ip_address
			
			end
			else if(@type_code = 'HE')
			begin
				exec dbo.xsp_efam_interface_asset_he_insert @p_asset_code		= @request_code
															,@p_merk_code		= @merk_code
															,@p_merk_name		= @merk_name
															,@p_type_item_code	= @type_item_code
															,@p_type_item_name	= @type_item_name
															,@p_model_code		= @model_code
															,@p_model_name		= @model_name
															,@p_built_year		= null
															,@p_invoice_no		= @invoice_no_he
															,@p_chassis_no		= @chasis_no_he
															,@p_engine_no		= @engine_no_he
															,@p_colour			= null
															,@p_serial_no		= null
															,@p_remark			= null
															--
															,@p_cre_date		= @mod_date
															,@p_cre_by			= @mod_by
															,@p_cre_ip_address	= @mod_ip_address
															,@p_mod_date		= @mod_date
															,@p_mod_by			= @mod_by
															,@p_mod_ip_address	= @mod_ip_address
				
				
			end
			update	ifinproc.dbo.eproc_interface_asset
			set		job_status = 'POST'
			where	id = @id_interface ;

		
			-- (+) Ari 2024-04-03 ket : add insert document
			begin
				declare @code			nvarchar(50)
						,@reff_code		nvarchar(50)
                
				select	@code = code
						,@reff_code = grnd.good_receipt_note_code
				from	ifinproc.dbo.eproc_interface_asset iast
				inner	join ifinproc.dbo.good_receipt_note_detail grnd on (grnd.id = iast.grn_detail_id)
				where	iast.id = @id_interface ;
				
				insert into dbo.efam_interface_asset_document
				(
				    asset_code,
				    description,
				    file_name,
				    path,
					doc_file,
				    cre_date,
				    cre_by,
				    cre_ip_address,
				    mod_date,
				    mod_by,
				    mod_ip_address
				)				
				select	@code
						,case 
							when doc.file_name = pt.stnk_file_no
							then 'STNK ' + @reff_code
							when doc.file_name = pt.stck_file_no
							then 'STCK ' + @reff_code
							when doc.file_name = pt.keur_file_no
							then 'KEUR ' + @reff_code
							else '-'
						end
						,doc.file_name
						,case 
							when doc.file_name = pt.stnk_file_no
							then pt.stnk_file_path
							when doc.file_name = pt.stck_file_no
							then pt.stck_file_path
							when doc.file_name = pt.keur_file_no
							then pt.keur_file_path
							else '-'
						end
						,doc.doc_file
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	ifinproc.dbo.proc_interface_sys_document_upload doc
				inner	join ifinproc.dbo.good_receipt_note_detail grnd on (grnd.good_receipt_note_code = doc.reff_no)
				outer	apply 
						(
							select	pob.stnk_file_no
									,pob.stnk_file_path
									,pob.stck_file_no
									,pob.stck_file_path
									,pob.keur_file_no
									,pob.keur_file_path
									,pob.asset_code
							from	ifinproc.dbo.purchase_order_detail_object_info pob
							where	pob.good_receipt_note_detail_id = grnd.id
						) pt
				where	pt.asset_code = @code --doc.reff_no = @reff_code
				and case
						when doc.file_name = pt.stnk_file_no then pt.stnk_file_path
						when doc.file_name = pt.stck_file_no then pt.stck_file_path
						when doc.file_name = pt.keur_file_no then pt.keur_file_path
						else '-'
					end <> '-'



			end

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;
			select @msg
			update dbo.efam_interface_asset
			set		job_status		= 'FAILED'
					,failed_remarks	= @msg
			where	id				= @id_interface
	
			set @current_mod_date = getdate() ;
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

			--clear cursor when error
			close curr_asset
			deallocate curr_asset

			--stop looping
			break ;
		end catch ;

		fetch next from curr_asset
		into @id_interface
			,@type_code
			,@request_code 
			,@merk_code		 
			,@model_code	 
			,@type_item_code 
			,@merk_name		 
			,@model_name	 
			,@type_item_name
			,@engine_no
			,@chasis_no
			,@plat_no
			,@chasis_no_mchn
			,@engine_no_mchn
			,@invoice_no_mchn
			,@invoice_no_he
			,@engine_no_he
			,@chasis_no_he
			,@serial_no_elct
			,@domain_elct
			,@imei_elct
			,@bpkb_no
			,@posting_date -- (+) Ari 2024-03-26 ket : add posting date
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

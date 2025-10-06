
-- Stored Procedure

-- Stored Procedure

CREATE procedure [dbo].[xsp_eproc_interface_asset_insert]
(
	@p_code					nvarchar(50) output
	,@p_company_code		nvarchar(50)
	,@p_item_code			nvarchar(50)
	,@p_item_name			nvarchar(250)
	,@p_item_group_code		nvarchar(50)	= null
	,@p_condition			nvarchar(50)	= null
	,@p_barcode				nvarchar(50)	= null
	,@p_status				nvarchar(20)	= null
	,@p_po_no				nvarchar(50)	= null
	,@p_requestor_code		nvarchar(50)	= null
	,@p_requestor_name		nvarchar(250)	= null
	,@p_vendor_code			nvarchar(50)	= null
	,@p_vendor_name			nvarchar(250)	= null
	,@p_type_code			nvarchar(50)	= null
	,@p_type_name			nvarchar(250)	= null
	,@p_category_code		nvarchar(50)	= null
	,@p_category_name		nvarchar(250)	= null
	,@p_purchase_date		datetime		= null
	,@p_purchase_price		decimal(18, 2)	= null
	,@p_invoice_no			nvarchar(50)	= null
	,@p_invoice_date		datetime		= null
	,@p_original_price		decimal(18, 2)	= null
	,@p_branch_code			nvarchar(50)	= null
	,@p_branch_name			nvarchar(250)	= null
	,@p_division_code		nvarchar(50)	= null
	,@p_division_name		nvarchar(250)	= null
	,@p_department_code		nvarchar(50)	= null
	,@p_department_name		nvarchar(250)	= null
	,@p_merk_code			nvarchar(50)	= null
	,@p_merk_name			nvarchar(250)	= null
	,@p_type_item_code		nvarchar(50)	= null
	,@p_type_item_name		nvarchar(250)	= null
	,@p_model_code			nvarchar(50)	= null
	,@p_model_name			nvarchar(250)	= null
	,@p_pph					decimal(9, 6)	= 0
	,@p_ppn					decimal(9, 6)	= 0
	,@p_is_po				nvarchar(1)
	,@p_plat_no				nvarchar(50)
	,@p_chassis_no			nvarchar(50)
	,@p_engine_no			nvarchar(50)
	,@p_serial				nvarchar(50)
	,@p_invoice				nvarchar(50)
	,@p_domain				nvarchar(50)
	,@p_imei				nvarchar(50)
	,@p_is_rental			nvarchar(1)
	,@p_asset_from			nvarchar(50)
	,@p_asset_purpose		nvarchar(50)
	,@p_remarks				nvarchar(4000)
	,@p_spaf_amount			decimal(18,2)
	,@p_subvention_amount	decimal(18,2)
	,@p_bpkb_no				nvarchar(50)
	,@p_cover_note			nvarchar(50)
	,@p_cover_note_date		datetime
	,@p_cover_note_exp_date	datetime
	,@p_file_name			nvarchar(250)
	,@p_file_path			nvarchar(250)
	,@p_reff_no				nvarchar(50)
	,@p_document_type		nvarchar(15)
	,@p_stnk_no				nvarchar(50)
	,@p_stnk_date			datetime
	,@p_stnk_exp_date		datetime
	,@p_stck_no				nvarchar(50)
	,@p_stck_date			datetime
	,@p_stck_exp_date		datetime
	,@p_keur_no				nvarchar(50)
	,@p_keur_date			datetime
	,@p_keur_exp_date		datetime
    ,@p_ppn_amount			decimal(18,2)
	,@p_pph_amount			decimal(18,2)
	,@p_discount_amount		decimal(18,2)
	,@p_posting_date		datetime -- (+) ari 2024-03-26 ket : add posting date
	,@p_grn_detail			bigint = 0 -- (+) ari 2024-04-04 ket : add for checking grn
	,@p_built_year			nvarchar(4) = null
	,@p_colour				nvarchar(50) = null
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
	--
	,@is_from_grn_process	nvarchar(1) = null -- (+) sepria 23012025: untuk flaging asset dr grn
	,@p_fgrn_detail_id		bigint = 0
	,@p_is_final_all		nvarchar(1) = null -- cr priority sepria 09092025: jika sudah final + semua invoice item sudah bayar, sebagai flag generate depre asset
)
as
begin
	declare @msg			nvarchar(max)
			,@year			nvarchar(4)
			,@month			nvarchar(2)
			,@code			nvarchar(50)

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @p_code output
												,@p_branch_code			= @p_branch_code
												,@p_sys_document_code	= ''
												,@p_custom_prefix		= 'AST'
												,@p_year				= @year
												,@p_month				= @month
												,@p_table_name			= 'EPROC_INTERFACE_ASSET'
												,@p_run_number_length	= 5
												,@p_delimiter			= '.'
												,@p_run_number_only		= '0' ;

	begin try
		insert into eproc_interface_asset
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
			,type_name
			,category_code
			,category_name
			,purchase_date
			,purchase_price
			,invoice_no
			,invoice_date
			,original_price
			,branch_code
			,branch_name
			,division_code
			,division_name
			,department_code
			,department_name
			,pph
			,ppn
			,is_po
			,is_rental
			,asset_from
			,asset_purpose
			,remarks
			,spaf_amount
			,subvention_amount
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
			,grn_detail_id
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			,is_from_grn_process
			,final_grn_request_detail_id
			,is_final_all

		)
		values
		(	@p_code
			,@p_company_code
			,@p_item_code
			,@p_item_name
			,@p_item_group_code
			,@p_condition
			,@p_barcode
			,@p_status
			,@p_po_no
			,@p_requestor_code
			,@p_requestor_name
			,@p_vendor_code
			,@p_vendor_name
			,@p_type_code
			,@p_type_name
			,@p_category_code
			,@p_category_name
			,@p_purchase_date
			,@p_purchase_price
			,@p_invoice_no
			,@p_invoice_date
			,@p_original_price
			,@p_branch_code
			,@p_branch_name
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_pph
			,@p_ppn
			,@p_is_po
			,@p_is_rental
			,@p_asset_from
			,@p_asset_purpose
			,@p_remarks
			,@p_spaf_amount
			,@p_subvention_amount
			,@p_bpkb_no
			,@p_cover_note
			,@p_cover_note_date
			,@p_cover_note_exp_date
			,@p_file_name
			,@p_file_path
			,@p_reff_no
			,@p_document_type
			,@p_stnk_no			
			,@p_stnk_date		
			,@p_stnk_exp_date	
			,@p_stck_no			
			,@p_stck_date		
			,@p_stck_exp_date	
			,@p_keur_no			
			,@p_keur_date		
			,@p_keur_exp_date
			,@p_ppn_amount
			,@p_pph_amount
			,@p_discount_amount
			,@p_posting_date -- (+) Ari 2024-03-26 ket : add posting date
			,@p_grn_detail -- (+) Ari 2024-04-04 ket : add for checking grn
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,@is_from_grn_process
			,@p_fgrn_detail_id
			,@p_is_final_all
		) ;

		if (@p_type_code = 'VHCL')
		begin
			exec dbo.xsp_proc_interface_asset_vehicle_insert @p_asset_code				 = @p_code
															 ,@p_merk_code				 = @p_merk_code		
															 ,@p_merk_name				 = @p_merk_name		
															 ,@p_type_item_code			 = @p_type_item_code	
															 ,@p_type_item_name			 = @p_type_item_name	
															 ,@p_model_code				 = @p_model_code		
															 ,@p_model_name				 = @p_model_name		
															 ,@p_plat_no				 = @p_plat_no
															 ,@p_chassis_no				 = @p_chassis_no
															 ,@p_engine_no				 = @p_engine_no
															 ,@p_bpkb_no				 = @p_bpkb_no
															 ,@p_colour					 = @p_colour
															 ,@p_cylinder				 = null
															 ,@p_stnk_no				 = null
															 ,@p_stnk_expired_date		 = null
															 ,@p_stnk_tax_date			 = null
															 ,@p_stnk_renewal			 = null
															 ,@p_built_year				 = @p_built_year
															 ,@p_last_miles				 = null
															 ,@p_last_maintenance_date	 = null
															 ,@p_purchase				 = null
															 ,@p_no_lease_agreement		 = null
															 ,@p_date_of_lease_agreement = null
															 ,@p_security_deposit		 = 0 
															 ,@p_total_rental_period	 = null
															 ,@p_rental_period			 = null
															 ,@p_rental_price			 = 0 
															 ,@p_total_rental_price		 = 0
															 ,@p_start_rental_date		 = null
															 ,@p_end_rental_date		 = null
															 ,@p_remark					 = null
															 --
															 ,@p_cre_date				 = @p_cre_date
															 ,@p_cre_by					 = @p_cre_by
															 ,@p_cre_ip_address			 = @p_cre_ip_address
															 ,@p_mod_date				 = @p_mod_date
															 ,@p_mod_by					 = @p_mod_by
															 ,@p_mod_ip_address			 = @p_mod_ip_address

		end
		else if(@p_type_code = 'MCHN')
		begin
			exec dbo.xsp_proc_interface_asset_machine_insert @p_asset_code				 = @p_code
															 ,@p_merk_code				 = @p_merk_code		
															 ,@p_merk_name				 = @p_merk_name		
															 ,@p_type_item_code			 = @p_type_item_code	
															 ,@p_type_item_name			 = @p_type_item_name	
															 ,@p_model_code				 = @p_model_code		
															 ,@p_model_name				 = @p_model_name		
															 ,@p_built_year				 = null
															 ,@p_chassis_no				 = @p_chassis_no
															 ,@p_engine_no				 = @p_engine_no
															 ,@p_invoice_no				 = @p_invoice
															 ,@p_colour					 = null
															 ,@p_serial_no				 = @p_serial
															 ,@p_purchase				 = null
															 ,@p_no_lease_agreement		 = null
															 ,@p_date_of_lease_agreement = null
															 ,@p_security_deposit		 = 0
															 ,@p_total_rental_period	 = null
															 ,@p_rental_period			 = null
															 ,@p_rental_price			 = 0 
															 ,@p_total_rental_price		 = 0
															 ,@p_start_rental_date		 = null
															 ,@p_end_rental_date		 = null
															 ,@p_remark					 = null
															 --
															 ,@p_cre_date				 = @p_cre_date
															 ,@p_cre_by					 = @p_cre_by
															 ,@p_cre_ip_address			 = @p_cre_ip_address
															 ,@p_mod_date				 = @p_mod_date
															 ,@p_mod_by					 = @p_mod_by
															 ,@p_mod_ip_address			 = @p_mod_ip_address

		end
		else if(@p_type_code = 'ELCT')
		begin
			exec dbo.xsp_proc_interface_asset_electronic_insert @p_asset_code				= @p_code
																,@p_merk_code				= @p_merk_code		
																,@p_merk_name				= @p_merk_name		
																,@p_type_item_code			= @p_type_item_code	
																,@p_type_item_name			= @p_type_item_name	
																,@p_model_code				= @p_model_code		
																,@p_model_name				= @p_model_name		
																,@p_serial_no				= @p_serial
																,@p_dimension				= null
																,@p_hdd						= null
																,@p_processor				= null
																,@p_ram_size				= null
																,@p_domain					= @p_domain
																,@p_imei					= @p_imei
																,@p_purchase				= null
																,@p_no_lease_agreement		= null
																,@p_date_of_lease_agreement = null
																,@p_security_deposit		= 0
																,@p_total_rental_period		= null
																,@p_rental_period			= null
																,@p_rental_price			= 0
																,@p_total_rental_price		= 0
																,@p_start_rental_date		= null
																,@p_end_rental_date			= null
																,@p_remark					= null
															    --
															    ,@p_cre_date				 = @p_cre_date
															    ,@p_cre_by					 = @p_cre_by
															    ,@p_cre_ip_address			 = @p_cre_ip_address
															    ,@p_mod_date				 = @p_mod_date
															    ,@p_mod_by					 = @p_mod_by
															    ,@p_mod_ip_address			 = @p_mod_ip_address

		end
		else if(@p_type_code = 'HE')
		begin
			exec dbo.xsp_proc_interface_asset_he_insert @p_asset_code				= @p_code
														,@p_merk_code				= @p_merk_code		
														,@p_merk_name				= @p_merk_name		
														,@p_type_item_code			= @p_type_item_code	
														,@p_type_item_name			= @p_type_item_name	
														,@p_model_code				= @p_model_code		
														,@p_model_name				= @p_model_name		
														,@p_plat_no					= @p_plat_no
														,@p_chassis_no				= @p_chassis_no
														,@p_engine_no				= @p_engine_no
														,@p_invoice_no				= @p_invoice
														,@p_bpkb_no					= null
														,@p_colour					= null
														,@p_cylinder				= null
														,@p_stnk_no					= null
														,@p_stnk_expired_date		= null
														,@p_stnk_tax_date			= null
														,@p_stnk_renewal			= null
														,@p_built_year				= null
														,@p_last_miles				= null
														,@p_last_maintenance_date	= null
														,@p_purchase				= null
														,@p_no_lease_agreement		= null
														,@p_date_of_lease_agreement = null
														,@p_security_deposit		= 0 
														,@p_total_rental_period		= null
														,@p_rental_period			= null
														,@p_rental_price			= 0 
														,@p_total_rental_price		= 0
														,@p_start_rental_date		= null
														,@p_end_rental_date			= null
														,@p_remark					= null
														--
														,@p_cre_date				= @p_cre_date
														,@p_cre_by					= @p_cre_by
														,@p_cre_ip_address			= @p_cre_ip_address
														,@p_mod_date				= @p_mod_date
														,@p_mod_by					= @p_mod_by
														,@p_mod_ip_address			= @p_mod_ip_address

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


CREATE PROCEDURE dbo.xsp_job_interface_in_asset
(
	@p_company_code	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg   nvarchar(max)
			,@code nvarchar(50) ;

	begin try
		exec dbo.xsp_job_pull_interface_asset @p_company_code		= @p_company_code
											  ,@p_cre_date			= @p_cre_date	  
											  ,@p_cre_by			= @p_cre_by		  
											  ,@p_cre_ip_address	= @p_cre_ip_address
											  ,@p_mod_date			= @p_mod_date	  
											  ,@p_mod_by			= @p_mod_by		  
											  ,@p_mod_ip_address	= @p_mod_ip_address
		

		declare c_asset cursor fast_forward read_only for
		select	code
		from	dbo.efam_interface_asset with (nolock)
		where	company_code = @p_company_code
				and CODE not in
					(
						select	ast.CODE
						from	dbo.ASSET ast
					) ;

		open c_asset ;

		fetch next from c_asset
		into @code ;

		while @@fetch_status = 0
		begin
			insert into dbo.asset
			(
				code
				,company_code
				,item_code
				,item_name
				,barcode
				,status
				,po_no
				,requestor_code
				,requestor_name
				,vendor_code
				,vendor_name
				,type_code
				,category_code
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
				,location_code
				,division_code
				,division_name
				,department_code
				,department_name
				,sub_department_code
				,sub_department_name
				,units_code
				,units_name
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
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	code
					,company_code
					,item_code
					,item_name
					,isnull(barcode, null)
					,status
					,isnull(po_no, null)
					,isnull(requestor_code, null)
					,isnull(requestor_name, null)
					,vendor_code
					,vendor_name
					,type_code
					,isnull(category_code, null)
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
					,location_code
					,isnull(division_code, null)
					,isnull(division_name, null)
					,isnull(department_code, null)
					,isnull(department_name, null)
					,isnull(sub_department_code, null)
					,isnull(sub_department_name, null)
					,isnull(units_code, null)
					,isnull(units_name, null)
					,isnull(pic_code, null)
					,isnull(residual_value, 0)
					,depre_category_comm_code
					,total_depre_comm
					,isnull(depre_period_comm, null)
					,net_book_value_comm
					,depre_category_fiscal_code
					,total_depre_fiscal
					,isnull(depre_period_fiscal, null)
					,net_book_value_fiscal
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
					,isnull(is_maintenance, null)
					,isnull(maintenance_time, 0)
					,isnull(maintenance_type, null)
					,isnull(maintenance_cycle_time, 0)
					,isnull(maintenance_start_date, null)
					,isnull(remarks, null)
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
			from	dbo.efam_interface_asset
			where	code = @code ;

			insert into dbo.asset_barcode_history
			(
				asset_code
				,previous_barcode
				,new_barcode
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	asset_code
					,previous_barcode
					,new_barcode
					,remark
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
			from	dbo.efam_interface_asset_barcode_history
			where	asset_code = @code ;

			insert into dbo.asset_barcode_image
			(
				asset_code
				,barcode
				,barcode_image
			)
			select	asset_code
					,barcode
					,barcode_image
			from	dbo.efam_interface_asset_barcode_image
			where	asset_code = @code ;

			insert into dbo.asset_document
			(
				asset_code
				,description
				,file_name
				,path
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
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
			from	dbo.efam_interface_asset_document
			where	asset_code = @code ;

			if exists
			(
				select	1
				from	dbo.asset
				where	code		  = @code
						and type_code = 'ELCT'
			)
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
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
				from	dbo.efam_interface_asset_electronic
				where	asset_code = @code ;
			end ;
			else if exists
			(
				select	1
				from	dbo.asset
				where	code		  = @code
						and type_code = 'FNTR'
			)
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
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
				from	dbo.efam_interface_asset_furniture
				where	asset_code = @code ;
			end ;
			else if exists
			(
				select	1
				from	dbo.asset
				where	code		  = @code
						and type_code = 'MCHN'
			)
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
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
				from	dbo.efam_interface_asset_machine
				where	asset_code = @code ;

			end ;
			else if exists
			(
				select	1
				from	dbo.asset
				where	code		  = @code
						and type_code = 'OTHR'
			)
			begin
				insert into dbo.asset_other
				(
					asset_code
					,remark
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	asset_code
						,remark
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
				from	dbo.efam_interface_asset_other
				where	asset_code = @code ;
			end ;
			else if exists
			(
				select	1
				from	dbo.asset
				where	code		  = @code
						and type_code = 'PRTY'
			)
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
					,penalty
					,owner
					,address
					,total_rental_period
					,rental_period
					,rental_price_per_year
					,rental_price_per_month
					,total_rental_price
					,start_rental_date
					,end_rental_date
					,remark
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
						,penalty
						,owner
						,address
						,total_rental_period
						,rental_period
						,rental_price_per_year
						,rental_price_per_month
						,total_rental_price
						,start_rental_date
						,end_rental_date
						,remark
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
				from	dbo.asset_property
				where	asset_code = @code ;
			end ;
			else if exists
			(
				select	1
				from	dbo.asset
				where	code		  = @code
						and type_code = 'VHCL'
			)
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
					,built_year
					,remark
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
						,bpkb_no
						,colour
						,cylinder
						,stnk_no
						,stnk_expired_date
						,stnk_tax_date
						,stnk_renewal
						,built_year
						,remark
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
				from	dbo.efam_interface_asset_vehicle
				where	asset_code = @code ;
			end ;

			insert into dbo.asset_maintenance_schedule
			(
				asset_code
				,maintenance_no
				,maintenance_date
				,maintenance_status
				,last_status_date
				,reff_trx_no
				,cre_by
				,cre_date
				,cre_ip_address
				,mod_by
				,mod_date
				,mod_ip_address
			)
			select	asset_code
					,maintenance_no
					,maintenance_date
					,maintenance_status
					,last_status_date
					,reff_trx_no
					,cre_by
					,cre_date
					,cre_ip_address
					,mod_by
					,mod_date
					,mod_ip_address
			from	dbo.efam_interface_asset_maintenance_schedule
			where	asset_code = @code ;

			fetch next from c_asset
			into @code ;
		end ;

		close c_asset ;
		deallocate c_asset ;
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

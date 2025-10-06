CREATE PROCEDURE dbo.xsp_asset_property_upload_update
(
	@p_fa_upload_id				 bigint
	,@p_file_name				 nvarchar(250)
	,@p_upload_no				 nvarchar(50)
	,@p_asset_code				 nvarchar(50)
	,@p_imb_no					 nvarchar(50)
	,@p_certificate_no			 nvarchar(50)
	,@p_land_size				 decimal(18, 2)
	,@p_building_size			 decimal(18, 2)
	,@p_status_of_ruko			 nvarchar(50)
	,@p_number_of_ruko_and_floor nvarchar(50)
	,@p_total_square			 nvarchar(10)
	,@p_vat						 decimal(18, 2)
	,@p_no_lease_agreement		 nvarchar(50)
	,@p_date_of_lease_agreement	 datetime
	,@p_land_and_building_tax	 nvarchar(50)
	,@p_security_deposit		 decimal(18, 2)
	,@p_penalty					 decimal(18, 2)
	,@p_owner					 nvarchar(250)
	,@p_address					 nvarchar(400)
	,@p_purchase				 nvarchar(50)
	,@p_total_rental_period		 nvarchar(9)
	,@p_rental_period			 nvarchar(15)
	,@p_rental_price_per_year	 decimal(18, 2)
	,@p_rental_price_per_month	 decimal(18, 2)
	,@p_total_rental_price		 decimal(18, 2)
	,@p_start_rental_date		 datetime
	,@p_end_rental_date			 datetime
	,@p_remark					 nvarchar(4000)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	asset_property_upload
		--set		fa_upload_id = @p_fa_upload_id
		set		file_name = @p_file_name
				,upload_no = @p_upload_no
				,asset_code = @p_asset_code
				,imb_no = @p_imb_no
				,certificate_no = @p_certificate_no
				,land_size = @p_land_size
				,building_size = @p_building_size
				,status_of_ruko = @p_status_of_ruko
				,number_of_ruko_and_floor = @p_number_of_ruko_and_floor
				,total_square = @p_total_square
				,vat = @p_vat
				,no_lease_agreement = @p_no_lease_agreement
				,date_of_lease_agreement = @p_date_of_lease_agreement
				,land_and_building_tax = @p_land_and_building_tax
				,security_deposit = @p_security_deposit
				,penalty = @p_penalty
				,owner = @p_owner
				,address = @p_address
				,purchase = @p_purchase
				,total_rental_period = @p_total_rental_period
				,rental_period = @p_rental_period
				,rental_price_per_year = @p_rental_price_per_year
				,rental_price_per_month = @p_rental_price_per_month
				,total_rental_price = @p_total_rental_price
				,start_rental_date = @p_start_rental_date
				,end_rental_date = @p_end_rental_date
				,remark = @p_remark
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	FA_UPLOAD_ID = @p_fa_upload_id ;
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

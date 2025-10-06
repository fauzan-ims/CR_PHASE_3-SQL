CREATE PROCEDURE dbo.xsp_asset_property_insert
(
	@p_asset_code				 nvarchar(50)
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
	,@p_owner					 nvarchar(250)
	,@p_remark					 nvarchar(4000)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into asset_property
		(
			asset_code
			,imb_no
			,certificate_no
			,land_size
			,building_size
			,status_of_ruko
			,number_of_ruko_and_floor
			,total_square
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
		values
		(	@p_asset_code
			,@p_imb_no
			,@p_certificate_no
			,@p_land_size
			,@p_building_size
			,@p_status_of_ruko
			,@p_number_of_ruko_and_floor
			,@p_total_square
			,@p_vat
			,@p_no_lease_agreement
			,@p_date_of_lease_agreement
			,@p_land_and_building_tax
			,@p_security_deposit
			,@p_owner
			,@p_remark
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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

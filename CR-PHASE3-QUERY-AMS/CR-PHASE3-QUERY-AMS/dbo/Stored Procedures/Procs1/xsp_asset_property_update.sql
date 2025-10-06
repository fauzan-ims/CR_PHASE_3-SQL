CREATE PROCEDURE dbo.xsp_asset_property_update
(
	@p_asset_code				 nvarchar(50)
	,@p_imb_no					 nvarchar(50)	= ''
	,@p_certificate_no			 nvarchar(50)	= ''
	,@p_land_size				 decimal(18, 2)	= 0
	,@p_building_size			 decimal(18, 2)	= 0
	,@p_status_of_ruko			 nvarchar(50)	= ''
	,@p_number_of_ruko_and_floor nvarchar(50)	= ''
	,@p_total_square			 nvarchar(10)	= ''
	,@p_vat						 decimal(9, 6)	= 0
	,@p_no_lease_agreement		 nvarchar(50)	= ''
	,@p_date_of_lease_agreement	 datetime		= null
	,@p_land_and_building_tax	 nvarchar(50)	= ''
	,@p_security_deposit		 decimal(18, 2)	= 0
	,@p_owner					 nvarchar(250)	= ''
	,@p_remark					 nvarchar(4000)	= ''
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists (select 1 from dbo.asset_property where imb_no  = @p_imb_no and imb_no <> '')
		begin
			set @msg = 'IMB No Already Exist.';
			raiserror(@msg ,16,-1);	    
		end
		if exists (select 1 from dbo.asset_property where certificate_no  = @p_certificate_no and certificate_no <> '')
		begin
			set @msg = 'Certificate No Already Exist.';
			raiserror(@msg ,16,-1);	    
		end
		if exists (select 1 from dbo.asset_property where no_lease_agreement  = @p_no_lease_agreement and no_lease_agreement <> '')
		begin
			set @msg = 'Lease Agreement No Already Exist.';
			raiserror(@msg ,16,-1);	    
		end

		update	asset_property
		set		imb_no						 = @p_imb_no
				,certificate_no				 = @p_certificate_no
				,land_size					 = @p_land_size
				,building_size				 = @p_building_size
				,status_of_ruko				 = @p_status_of_ruko
				,number_of_ruko_and_floor	 = @p_number_of_ruko_and_floor
				,total_square				 = @p_total_square
				,vat						 = @p_vat
				,no_lease_agreement			 = @p_no_lease_agreement
				,date_of_lease_agreement	 = @p_date_of_lease_agreement
				,land_and_building_tax		 = @p_land_and_building_tax
				,security_deposit			 = @p_security_deposit
				,owner						 = @p_owner
				,remark						 = @p_remark
				--
				,mod_date					 = @p_mod_date
				,mod_by						 = @p_mod_by
				,mod_ip_address				 = @p_mod_ip_address
		where	asset_code					 = @p_asset_code ;
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

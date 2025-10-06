CREATE PROCEDURE dbo.xsp_proc_interface_asset_he_insert
(
	@p_asset_code							nvarchar(50)
	,@p_merk_code							nvarchar(50)
	,@p_merk_name							nvarchar(250)
	,@p_type_item_code						nvarchar(50)
	,@p_type_item_name						nvarchar(250)
	,@p_model_code							nvarchar(50)
	,@p_model_name							nvarchar(250)
	,@p_plat_no								nvarchar(20)
	,@p_chassis_no							nvarchar(50)
	,@p_engine_no							nvarchar(50)
	,@p_invoice_no							nvarchar(50)
	,@p_bpkb_no								nvarchar(50)
	,@p_colour								nvarchar(50)
	,@p_cylinder							nvarchar(20)
	,@p_stnk_no								nvarchar(50)
	,@p_stnk_expired_date					datetime
	,@p_stnk_tax_date						datetime
	,@p_stnk_renewal						nvarchar(15)
	,@p_built_year							nvarchar(4)
	,@p_last_miles							nvarchar(15)
	,@p_last_maintenance_date				datetime
	,@p_purchase							nvarchar(50)
	,@p_no_lease_agreement					nvarchar(50)
	,@p_date_of_lease_agreement				datetime
	,@p_security_deposit					decimal(18,2)
	,@p_total_rental_period					nvarchar(9)
	,@p_rental_period						nvarchar(15)
	,@p_rental_price						decimal(18,2)
	,@p_total_rental_price					decimal(18,2)
	,@p_start_rental_date					datetime
	,@p_end_rental_date						datetime
	,@p_remark								nvarchar(4000)
	--
	,@p_cre_date							datetime
	,@p_cre_by								nvarchar(15)
	,@p_cre_ip_address						nvarchar(15)
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.proc_interface_asset_he
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
			,invoice_no
			,bpkb_no
			,colour
			,cylinder
			,stnk_no
			,stnk_expired_date
			,stnk_tax_date
			,stnk_renewal
			,built_year
			,last_miles
			,last_maintenance_date
			,purchase
			,no_lease_agreement
			,date_of_lease_agreement
			,security_deposit
			,total_rental_period
			,rental_period
			,rental_price
			,total_rental_price
			,start_rental_date
			,end_rental_date
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
			,@p_merk_code
			,@p_merk_name
			,@p_type_item_code
			,@p_type_item_name
			,@p_model_code
			,@p_model_name
			,@p_plat_no
			,@p_chassis_no
			,@p_engine_no
			,@p_invoice_no
			,@p_bpkb_no
			,@p_colour
			,@p_cylinder
			,@p_stnk_no
			,@p_stnk_expired_date
			,@p_stnk_tax_date
			,@p_stnk_renewal
			,@p_built_year
			,@p_last_miles
			,@p_last_maintenance_date
			,@p_purchase
			,@p_no_lease_agreement
			,@p_date_of_lease_agreement
			,@p_security_deposit
			,@p_total_rental_period
			,@p_rental_period
			,@p_rental_price
			,@p_total_rental_price
			,@p_start_rental_date
			,@p_end_rental_date
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

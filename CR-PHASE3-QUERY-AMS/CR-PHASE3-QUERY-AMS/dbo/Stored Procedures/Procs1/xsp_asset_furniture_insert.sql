CREATE PROCEDURE dbo.xsp_asset_furniture_insert
(
	@p_asset_code					nvarchar(50)
	,@p_merk_code					nvarchar(50)
	,@p_merk_name					nvarchar(250)
	,@p_type_code					nvarchar(50)
	,@p_type_name					nvarchar(250)
	,@p_model_code					nvarchar(50)
	,@p_model_name					nvarchar(250)
	,@p_purchase					nvarchar(50)
	,@p_no_lease_agreement			nvarchar(50)
	,@p_date_of_lease_agreement		datetime
	,@p_security_deposit			decimal(18,2)
	,@p_total_rental_period			nvarchar(9)
	,@p_rental_period				nvarchar(15)
	,@p_rental_price				decimal(18,2)
	,@p_total_rental_price			decimal(18,2)
	,@p_start_rental_date			datetime
	,@p_end_rental_date				datetime
	,@p_remark						nvarchar(4000)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into asset_furniture
		(
			asset_code
			,merk_code
			,merk_name
			,type_code
			,type_name
			,model_code
			,model_name
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
			,@p_type_code
			,@p_type_name
			,@p_model_code
			,@p_model_name
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

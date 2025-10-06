CREATE PROCEDURE dbo.xsp_asset_furniture_update
(
	@p_asset_code					nvarchar(50)
	,@p_merk_code					nvarchar(50)	= ''
	,@p_merk_name					nvarchar(250)	= ''
	,@p_type_code					nvarchar(50)	= ''
	,@p_type_name					nvarchar(250)	= ''
	,@p_model_code					nvarchar(50)	= ''
	,@p_model_name					nvarchar(250)	= ''
	,@p_purchase					nvarchar(50)	= ''
	,@p_no_lease_agreement			nvarchar(50)	= ''
	,@p_date_of_lease_agreement		datetime		= null
	,@p_security_deposit			decimal(18,2)	= 0
	,@p_total_rental_period			nvarchar(9)		= ''
	,@p_rental_period				nvarchar(15)	= ''
	,@p_rental_price				decimal(18,2)	= 0
	,@p_total_rental_price			decimal(18,2)	= 0
	,@p_start_rental_date			datetime		= null
	,@p_end_rental_date				datetime		= null
	,@p_remark						nvarchar(4000)	= ''
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists (select 1 from dbo.asset_furniture where no_lease_agreement  = @p_no_lease_agreement and no_lease_agreement <> '')
		begin
			set @msg = 'The loan agreement number already exists in another asset.';
			raiserror(@msg ,16,-1);	    
		end
		update	asset_furniture
		set		merk_code					= @p_merk_code
				,merk_name					= @p_merk_name
				,type_code					= @p_type_code
				,type_name					= @p_type_name
				,model_code					= @p_model_code
				,model_name					= @p_model_name
				,purchase					= @p_purchase
				,no_lease_agreement			= @p_no_lease_agreement		
				,date_of_lease_agreement	= @p_date_of_lease_agreement	
				,security_deposit			= @p_security_deposit		
				,total_rental_period		= @p_total_rental_period		
				,rental_period				= @p_rental_period			
				,rental_price				= @p_rental_price			
				,total_rental_price			= @p_total_rental_price		
				,start_rental_date			= @p_start_rental_date		
				,end_rental_date			= @p_end_rental_date			
				,remark						= @p_remark
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	asset_code					= @p_asset_code ;
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

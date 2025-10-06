---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_vehicle_pricelist_detail_update
(
	@p_id					   bigint
	,@p_vehicle_pricelist_code nvarchar(50)
	,@p_branch_code			   nvarchar(50)
	,@p_branch_name			   nvarchar(250)
	,@p_currency_code		   nvarchar(3)
	,@p_effective_date		   datetime
	,@p_asset_value			   decimal(18, 2)
	,@p_dp_pct				   decimal(9, 6)
	,@p_dp_amount			   decimal(18, 2)
	,@p_financing_amount	   decimal(18, 2)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_effective_date < dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be greater than System Date' ;

			raiserror(@msg, 16, 1) ;
		end ;

		update	master_vehicle_pricelist_detail
		set		vehicle_pricelist_code  = @p_vehicle_pricelist_code
				,branch_code			= @p_branch_code
				,branch_name			= @p_branch_name
				,currency_code			= @p_currency_code
				,effective_date			= @p_effective_date
				,asset_value			= @p_asset_value
				,dp_pct					= @p_dp_pct
				,dp_amount				= @p_dp_amount
				,financing_amount		= @p_financing_amount
					--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
	end try
	Begin catch
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



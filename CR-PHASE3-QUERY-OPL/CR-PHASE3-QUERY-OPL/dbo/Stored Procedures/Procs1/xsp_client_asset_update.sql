CREATE PROCEDURE dbo.xsp_client_asset_update
(
	@p_id				bigint
	,@p_client_code		nvarchar(50)
	,@p_asset_type_code nvarchar(50)
	,@p_asset_name		nvarchar(250)
	,@p_asset_value		decimal(18, 2)
	,@p_reff_no			nvarchar(50)
	,@p_location		nvarchar(4000)
	,@p_remarks			nvarchar(4000)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		update	client_asset
		set		asset_type_code	= @p_asset_type_code
				,asset_name		= upper(@p_asset_name)
				,asset_value	= @p_asset_value
				,reff_no		= upper(@p_reff_no)
				,location		= upper(@p_location)
				,remarks		= @p_remarks
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;
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


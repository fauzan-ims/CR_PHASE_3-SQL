CREATE PROCEDURE dbo.xsp_application_asset_final_check_update
(
	@p_asset_no			nvarchar(50) 
	,@p_asset_type		nvarchar(10) = null
	,@p_chassis_no		nvarchar(50) = null
	,@p_engine_no		nvarchar(50) = null 
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg				 nvarchar(max)
			,@result_status		 nvarchar(4000)
			,@application_no	 nvarchar(50)
			,@collateral_no		 nvarchar(50)
			,@is_main_collateral nvarchar(1) ;

	begin try 
		select	@application_no = application_no
		from	dbo.application_asset
		where	asset_no = @p_asset_no ; 
		
		exec @result_status = dbo.xfn_duplicate_collateral_and_asset_validation @p_reff_code					= @application_no
																				,@p_collateral_no				= null
																				,@p_asset_no					= @p_asset_no
																				,@p_asset_or_collateral_type	= @p_asset_type
																				,@p_chassis_no					= @p_chassis_no	
																				,@p_engine_no					= @p_engine_no	

		if (isnull(@result_status, '') <> '')
		begin
			set @msg = @result_status ;

			raiserror(@msg, 16, 1) ;
		end ;

		if (@p_asset_type = 'VHCL')
		begin
			update	application_asset_vehicle
			set		 mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_no			= @p_asset_no ; 
		end
		if (@p_asset_type = 'HE')
		begin
			update	application_asset_he
			set		mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_no			= @p_asset_no ; 
		end
		if (@p_asset_type = 'MCHN')
		begin
			update	application_asset_machine
			set		mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_no			= @p_asset_no ; 
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


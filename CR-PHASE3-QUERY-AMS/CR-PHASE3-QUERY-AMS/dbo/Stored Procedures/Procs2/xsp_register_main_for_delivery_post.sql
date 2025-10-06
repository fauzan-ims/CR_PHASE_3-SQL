CREATE PROCEDURE dbo.xsp_register_main_for_delivery_post
(
	@p_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	
	declare @msg					nvarchar(max)
			,@regis_status			nvarchar(20)
			,@stnk_no				nvarchar(50)
			,@stnk_tax_date			datetime
			,@stnk_expired_date		datetime
			,@keur_no				nvarchar(50)
			,@keur_date				datetime
			,@keur_expired_date		datetime
			,@asset_no				nvarchar(50)


	begin try
	
		select	@regis_status			= register_status
				,@stnk_no				= stnk_no
				,@stnk_tax_date			= stnk_tax_date
				,@stnk_expired_date		= stnk_expired_date
				,@keur_no				= keur_no
				,@keur_date				= keur_date
				,@keur_expired_date		= keur_expired_date
				,@asset_no				= fa_code
		from	dbo.register_main
		where	code = @p_code

		if @regis_status <> 'DELIVERY'
		begin
			set @msg = 'Data already proceed.'
			raiserror(@msg ,16,-1)
		end
		
		update	dbo.register_main
		set		register_status						= 'DONE'
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	code = @p_code

		if(isnull(@stnk_no,'') <> '')
		begin
			update	dbo.asset_vehicle
			set		stnk_no				= @stnk_no
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_code			= @asset_no
		end
		else if(isnull(@stnk_tax_date,'') <> '')
		begin
			update	dbo.asset_vehicle
			set		stnk_tax_date		= @stnk_tax_date
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_code			= @asset_no
		end
		else if(isnull(@stnk_expired_date,'') <> '')
		begin
			update	dbo.asset_vehicle
			set		stnk_expired_date	= @stnk_expired_date
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_code			= @asset_no
		end
		else if(isnull(@keur_no,'') <> '')
		begin
			update	dbo.asset_vehicle
			set		keur_no				= @keur_no
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_code			= @asset_no
		end
		else if(isnull(@keur_date,'') <> '')
		begin
			update	dbo.asset_vehicle
			set		keur_date			= @keur_date
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_code			= @asset_no
		end
		else if(isnull(@keur_expired_date,'') <> '')
		begin
			update	dbo.asset_vehicle
			set		keur_expired_date	= @keur_expired_date
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_code			= @asset_no
		end

		--update	dbo.asset_vehicle
		--set		stnk_no				= @stnk_no
		--		,stnk_tax_date		= @stnk_tax_date
		--		,stnk_expired_date	= @stnk_expired_date
		--		,keur_no			= @keur_no
		--		,keur_date			= @keur_date
		--		,keur_expired_date	= @keur_expired_date
		--where	asset_code			= @asset_no

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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;

end



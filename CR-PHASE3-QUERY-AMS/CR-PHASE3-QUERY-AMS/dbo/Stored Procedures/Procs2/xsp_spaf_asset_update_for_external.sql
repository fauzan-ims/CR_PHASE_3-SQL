CREATE PROCEDURE dbo.xsp_spaf_asset_update_for_external
(
	@p_asset_code			nvarchar(50)
	,@p_validation_status	nvarchar(10)
	,@p_validation_remark	nvarchar(4000)	= null
	,@p_validation_date		datetime
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max);

	begin try
		update	dbo.spaf_asset
		set		validation_status			= @p_validation_status
				,validation_remark			= @p_validation_remark
				,validation_date			= @p_validation_date
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	fa_code						= @p_asset_code ;

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

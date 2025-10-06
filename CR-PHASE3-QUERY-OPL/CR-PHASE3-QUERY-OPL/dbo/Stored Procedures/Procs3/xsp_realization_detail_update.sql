CREATE PROCEDURE [dbo].[xsp_realization_detail_update]
(
	@p_asset_no			nvarchar(250)
	,@p_deliver_to_name		nvarchar(250)  = ''
	,@p_deliver_to_area_no	nvarchar(4)	   = ''
	,@p_deliver_to_phone_no nvarchar(15)   = ''
	,@p_deliver_to_address	nvarchar(4000) = ''
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	dbo.application_asset
		set		deliver_to_name			= @p_deliver_to_name
				,deliver_to_area_no		= @p_deliver_to_area_no
				,deliver_to_phone_no	= @p_deliver_to_phone_no
				,deliver_to_address		= @p_deliver_to_address
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	asset_no				= @p_asset_no ;

	--update	realization_detail
	--set		realization_code	= @p_realization_code  
	--		,asset_no			= @p_asset_no		 
	--		--
	--		,mod_date			= @p_mod_date
	--		,mod_by				= @p_mod_by
	--		,mod_ip_address		= @p_mod_ip_address
	--where	id					= @p_id ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

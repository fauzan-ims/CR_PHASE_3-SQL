CREATE PROCEDURE [dbo].[xsp_asset_status_update]
(
	@p_code					NVARCHAR(50)
	,@p_status_condition	nvarchar(250) = NULL
	,@p_status_progress		nvarchar(250) = NULL
	,@p_status_remark		nvarchar(4000) = null
	--
	,@p_mod_date			DATETIME
	,@p_mod_by				NVARCHAR(15)
	,@p_mod_ip_address		NVARCHAR(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	dbo.ASSET
		set		status_condition			= @p_status_condition
				,status_progress			= @p_status_progress
				,status_remark				= @p_status_remark
				--
				,STATUS_LAST_UPDATE_BY		= @p_mod_by
				,STATUS_LAST_UPDATE_DATE	= @p_mod_date
		where	code			 = @p_code ;
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

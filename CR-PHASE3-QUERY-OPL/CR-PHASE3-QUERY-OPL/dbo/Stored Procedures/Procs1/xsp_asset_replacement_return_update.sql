CREATE PROCEDURE dbo.xsp_asset_replacement_return_update
(
	@p_id						bigint
	,@p_replacement_code		nvarchar(50)
	,@p_new_asset_code			nvarchar(50)
	,@p_reason_code				nvarchar(50)
	,@p_estimate_date			datetime
	,@p_remark					nvarchar(4000)
	,@p_status					nvarchar(10)
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin

	declare @msg nvarchar(max) ;

	begin try
	 
		update	asset_replacement_return
		set		replacement_code	= @p_replacement_code
				,new_asset_code		= @p_new_asset_code
				,reason_code		= @p_reason_code
				,estimate_date		= @p_estimate_date
				,remark				= @p_remark
				,status				= @p_status
					--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id	= @p_id

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
end

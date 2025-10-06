CREATE PROCEDURE dbo.xsp_asset_management_pricing_detail_update
(
	@p_id						  bigint
	,@p_pricing_code			  nvarchar(50)
	,@p_request_amount			  decimal(18, 2)
	,@p_approve_amount			  decimal(18, 2)
	--
	,@p_mod_date				  datetime
	,@p_mod_by					  nvarchar(15)
	,@p_mod_ip_address			  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	asset_management_pricing_detail
		set		pricing_code				= @p_pricing_code
				,request_amount				= @p_request_amount
				,approve_amount				= @p_approve_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id = @p_id ;
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

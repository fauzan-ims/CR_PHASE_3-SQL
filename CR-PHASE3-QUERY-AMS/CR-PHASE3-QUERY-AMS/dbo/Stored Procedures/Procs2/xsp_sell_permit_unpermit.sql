CREATE PROCEDURE dbo.xsp_sell_permit_unpermit
(
	@p_code					nvarchar(50)
	,@p_permit_sell_remark	nvarchar(4000)	= ''
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@is_permit_to_sell	nvarchar(1);

	begin try
		select	@is_permit_to_sell = is_permit_to_sell
		from	dbo.asset
		where	code = @p_code ;

		if (@is_permit_to_sell = '1')
			set @is_permit_to_sell = '0' ;
		else
			set @is_permit_to_sell = '1' ;

		
		update	dbo.asset
		set		is_permit_to_sell			= @is_permit_to_sell
				,permit_sell_remark			= @p_permit_sell_remark	
				--
				,mod_date					= @p_mod_date		
				,mod_by						= @p_mod_by			
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code
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




CREATE PROCEDURE dbo.xsp_faktur_no_replacement_update_cancel
(
	 @p_code							nvarchar (50)
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
	begin try
	if exists(
		select status from faktur_no_replacement where code = @p_code and STATUS <> 'HOLD')
		begin
		set @msg = 'Data Already Proceed'
		raiserror(@msg, 16, -1)
		end
	else
		update	dbo.faktur_no_replacement
		set		status			= 'CANCEL'		
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	 code			= @p_code --and status = 'HOLD' ;
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

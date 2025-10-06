/*
exec dbo.xsp_withholding_settlement_audit_return @p_code = N'' -- nvarchar(50)
												 ,@p_mod_date = '2023-06-02 11.14.49' -- datetime
												 ,@p_mod_by = N'' -- nvarchar(15)
												 ,@p_mod_ip_address = N'' -- nvarchar(15)
*/

-- Louis Jumat, 02 Juni 2023 18.14.33 -- 
CREATE PROCEDURE dbo.xsp_withholding_settlement_audit_return
(
	@p_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg	nvarchar(max)

	begin try
		
			update	dbo.withholding_settlement_audit
			set		status				= 'HOLD'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code
		
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



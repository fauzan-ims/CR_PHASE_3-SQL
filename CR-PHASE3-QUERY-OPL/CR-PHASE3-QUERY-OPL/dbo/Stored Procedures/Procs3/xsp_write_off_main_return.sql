/*
exec dbo.xsp_write_off_main_return @p_code = N'' -- nvarchar(50)
								   ,@p_mod_date = '2023-03-06 12.24.42' -- datetime
								   ,@p_mod_by = N'' -- nvarchar(15)
								   ,@p_mod_ip_address = N'' -- nvarchar(15)
*/

-- Louis Senin, 06 Maret 2023 19.24.33 -- 
CREATE PROCEDURE dbo.xsp_write_off_main_return
(
	@p_code						nvarchar(50)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)	
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg nvarchar(max) ;
				
	begin try
		
		if exists
		(
			select	1
			from	dbo.write_off_main
			where	code		  = @p_code
					and wo_status <> 'ON PROCESS'
		)
		begin
			set @msg = 'Error data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;
        else
		begin
			update dbo.write_off_main
			set		wo_status				= 'HOLD'
					,mod_by					= @p_mod_by
					,mod_date				= @p_mod_date
					,mod_ip_address			= @p_mod_ip_address
			where   code					= @p_code
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
	
end


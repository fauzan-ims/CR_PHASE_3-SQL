CREATE PROCEDURE dbo.xsp_sys_company_update_status
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@user_code	nvarchar(50);

	begin try
		
		select	@user_code = code 
		from	dbo.sys_company_user_main
		where	company_code = @p_code;

		if exists (	select 1 from dbo.sys_company 
						where code = @p_code 
						and is_active = '1')
		
			begin
				update	dbo.sys_company 
				set		is_active	= '0'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code;

				exec dbo.xsp_sys_company_user_main_update_status @p_code			= @user_code
																 ,@p_mod_date		= @p_mod_date		
																 ,@p_mod_by			= @p_mod_by			
																 ,@p_mod_ip_address = @p_mod_ip_address;
			end
            else
            begin
				
				update	dbo.sys_company 
				set		is_active	= '1'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code;

				exec dbo.xsp_sys_company_user_main_update_status @p_code			= @user_code
																 ,@p_mod_date		= @p_mod_date		
																 ,@p_mod_by			= @p_mod_by			
																 ,@p_mod_ip_address = @p_mod_ip_address;
			end
			
	end try
	begin catch
		if (LEN(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE();
		end;

		raiserror(@msg, 16, -1) ;
		return ;  
	end catch ;
end ;

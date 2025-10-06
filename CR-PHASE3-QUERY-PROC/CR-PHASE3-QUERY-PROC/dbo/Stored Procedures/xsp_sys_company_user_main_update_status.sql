CREATE PROCEDURE dbo.xsp_sys_company_user_main_update_status 
(
	@p_code				nvarchar(50)
	,@p_company_code	nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@max_user		int
			,@count_user	int;

	begin try
	
			if exists (	select 1 from dbo.sys_company_user_main 
						where code = @p_code 
						and	company_code = @p_company_code
						and is_active = '1')
		
			begin
				update	dbo.sys_company_user_main 
				set		is_active	= '0'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code
				and		company_code	= @p_company_code;

			end
            else
            begin
				
				update	dbo.sys_company_user_main 
				set		is_active	= '1'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code
				and		company_code	= @p_company_code;
			end
	
			--select	@max_user = max_user
			--from	eprocsys.dbo.sys_company
			--where	code = @p_company_code
			--and		is_active = '1';

			select	@count_user = count(*)
			from	dbo.sys_company_user_main
			where	company_code = @p_company_code
			and		is_active = '1';
			
			if (@count_user > @max_user)
			begin
				set @msg = 'User has exceeded the maximum limit. Maximum active user is ' + cast(@max_user as nvarchar(20));
				raiserror(@msg, 16, -1) ;
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
end ;

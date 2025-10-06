CREATE PROCEDURE dbo.xsp_master_user_main_validate
	@p_ucode		nvarchar(50)
	,@p_password	nvarchar(50)
	,@p_ip_address	nvarchar(15) 
	,@p_is_login	nvarchar(1) = ''
with execute as caller
as
begin

	declare @msg					nvarchar(max)
			,@regex_pass			nvarchar(1)
			,@system_date			datetime
			,@login_try				int 
			,@reminder_change_pass	int 
			,@pass_hint				nvarchar(250)
			,@max_char				int 
			,@uid					nvarchar(15)
			,@password				nvarchar(20)
			,@pass_next_change		int
			,@u_code				nvarchar(20)
			,@last_fail_count		int
			,@max_login_try			int
			,@company_code			nvarchar(50)
			,@idle_time				nvarchar(250) ;

	begin try


		set @system_date = getdate();
				
		-- get idle time
		select	@idle_time = value 
		from	dbo.sys_global_param 
		where	code = 'IDLT' ;
		
		-- get validate
		select	@max_login_try = value 
		from	dbo.sys_global_param 
		where	code = 'MFL' ;
		
		select	@last_fail_count = mum.last_fail_count 
		from	dbo.sys_company_user_main mum
		where	code = @p_ucode  or mum.email = @p_ucode or mum.username = @p_ucode;

		if @last_fail_count >= @max_login_try
		begin
			set @msg = 'This user is lock, please contact your IT Department for unlock';
			--set @msg = 'User telah terkunci, silahkan menghubungi tim IT untuk membuka akses';
			raiserror(@msg, 16, -1) ;
		end
		


		select	@uid			= isnull(mum.code,'')
				,@password		= isnull(mum.upass,'')
				,@company_code	= mum.company_code
		from	sys_company_user_main mum
		where	(mum.code = @p_ucode or mum.email = @p_ucode or mum.username = @p_ucode) ;
		

		-- cek user tidak terdaftar 
		if not exists 
		(	
			select	1
			from	dbo.sys_company_user_main
			where	code = @p_ucode
		)
		begin
			set @msg = 'User not registered';
			raiserror(@msg, 16, -1) ;
				--set @msg = 'Username or password tidak Terdaftar';
				--raiserror(@msg, 16, -1) ;
		end ;
		 

		if not exists 
		(	
			select	1
			from	dbo.sys_company_user_main
			where	code = @uid
			and		is_active = '1'
		)
		begin
			set @msg = 'User non active';
			--set @msg = 'User tidak aktif';
			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin
			if (dbo.fn_generate_md5(isnull(@p_password, '')) <> isnull(@password, '')) and @p_ucode = 'SUPERADMIN'
			begin
				update	dbo.sys_company_user_main 
				set		last_fail_count = last_fail_count + 1 
				where	code = @p_ucode ;
				
				if exists(select 1 from dbo.sys_company_user_main where last_fail_count >= @max_login_try and code = @p_ucode)
				begin
					set @msg = 'This user is lock, please contact your IT Department for unlock';
					raiserror(@msg, 16, -1) ;
				end
				else
				begin
					set @msg = 'Username or password does not match';
					raiserror(@msg, 16, -1) ;
				end
				
			end ;
			
			------------------------------------------------------
			select	top 1 
				    seb.code as 'uid'
					,seb.name as 'name'
					,dbo.xfn_get_system_date() as 'system_date'
					,seb.company_code as 'company_code'
					,@idle_time 'idle_time'
					,@p_is_login 'isLogin'
					,@p_is_login 'is_login'
			from	dbo.sys_company_user_main seb
			where	(seb.code = @p_ucode or seb.email = @p_ucode or seb.username = @p_ucode) ;


			--insert to log (sys_company_user_login_log)
			if (@p_is_login = '0')
			begin
				exec dbo.xsp_sys_company_user_login_log_insert @p_id				= 0
															   ,@p_user_code		= @uid
															   ,@p_login_date		= @system_date
															   ,@p_flag_code		= 'LOGIN'
															   ,@p_session_id		= @p_ip_address
															   ,@p_cre_date			= @system_date
															   ,@p_cre_by			= @uid
															   ,@p_cre_ip_address	= @p_ip_address
															   ,@p_mod_date			= @system_date
															   ,@p_mod_by			= @uid
															   ,@p_mod_ip_address	= @p_ip_address
			end
			

			-- update history login 
			update	dbo.sys_company_user_main
			set		last_login_date = @system_date
					,last_fail_count = 0
			where	code = @uid
			and		company_code = @company_code ;
			-- end

		end ;

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



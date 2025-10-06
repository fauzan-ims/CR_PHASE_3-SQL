CREATE procedure dbo.xsp_master_user_main_reset_password
(
	@p_uid_or_email			nvarchar(200)
) as
begin
	
	declare @msg				nvarchar(max)
			,@emp_email			nvarchar(200)
			,@body				nvarchar(4000)
			,@subject			nvarchar(200)
			,@u_pass			nvarchar(20)
			,@cc_email			nvarchar(200)
			--
			,@company_name		nvarchar(50)
			,@company_address	nvarchar(4000)
			,@company_phone		nvarchar(30)
			,@company_fax		nvarchar(30)
			,@emp_name			nvarchar(100)
			,@com_param_address	nvarchar(50)
			,@com_zip_code		nvarchar(50)
			,@com_area_phone_no	nvarchar(50)
			,@com_phone_no		nvarchar(50)
			,@com_area_fax_no	nvarchar(50)
			,@com_fax_no		nvarchar(50)
			,@date_now			nvarchar(25)
			,@u_code			nvarchar(20)


	begin try

		set @date_now = getdate();

		if not exists (select 1 
					from dbo.sys_user_main um
					inner join dbo.sys_employee_main sem on (sem.code = um.code)
					where (um.code = @p_uid_or_email or sem.email = @p_uid_or_email))
		begin
			set @msg = 'User or Email doesn`t exist in the database'
			raiserror(@msg,16,-1)
		end

		select @u_code = um.code  
		from dbo.sys_user_main um
		inner join dbo.sys_employee_main sem on (sem.code = um.code)
		where (um.code = @p_uid_or_email or sem.email = @p_uid_or_email)
	
		select	@emp_name			= name
		from	sys_employee_main
		where	code				= @u_code


		select	@company_name		= name
		from	sys_company

		select @com_param_address	= isnull(value,'') from dbo.sys_branch_param where CODE = 'address'
		select @com_zip_code		= isnull(value,'') from dbo.sys_branch_param where CODE = 'zip'
		select @com_area_phone_no	= isnull(value,'') from dbo.sys_branch_param where CODE = 'area_phone_no'
		select @com_phone_no		= isnull(value,'') from dbo.sys_branch_param where CODE = 'phone_no'
		select @com_area_fax_no		= isnull(value,'') from dbo.sys_branch_param where CODE = 'area_fax_no'
		select @com_fax_no			= isnull(value,'') from dbo.sys_branch_param where CODE = 'fax_no'
	
		set	@company_address		= isnull(@com_param_address, '') + isnull(' ' + @com_zip_code, '')
		set @company_phone			= isnull('(' + @com_area_phone_no + ')', '') + isnull(' ' + @com_phone_no, '')
		set @company_fax			= isnull('(' + @com_area_fax_no + ')', '') + isnull(' ' + @com_fax_no, '')
	
	

		set @u_pass = dbo.xfn_get_randomize_password(newid())
	
	 
		set @subject = '[IFINANCING] Reset Password'

		set @body = '<html>
						<head>
							<style>
								body {
									font-family:sans-serif;
								}

								table {
									width:100%; 
								}

								p {
									padding-left: 60px;
									font-size: 14px;
								}

								.title {
									font-size: 20px;
									background-color:#cceeff;
									padding-left: 20px;
									height:60px;
								}

								.footer {
									background-color:#cceeff;
									height: 30px;
								}

								.password {
									background-color: #ffe699;
									height: 80px;
									font-size: 34px;
								}

								#ifinancing {
									color:#ff8000;
								}

								#companyinfo {
									font-family: "Lucida Console";
									font-size: 12px;
								}
							</style>
						</head>
						<body>
							<table>
								<tr>
									<td class="title" colspan="3">
										<span class="title">
											I<span id="ifinancing">FINANCING</span>
										</span>
									</td>
								</tr>
								<tr>
									<td colspan="3">
										<br/>
										<p><b>Dear ' + isnull(@emp_name,'') + '</b>,</p>
										<br/><br/>
										<p>Anda telah melakukan permintaan untuk mengunakan <b>Reset Password</b>.</p>
										<p>Silahkan melakukan login dengan mengunakan password berikut :</p>
										<br/>
									</td>
								</tr>
								<tr>
									<td width="25%"></td>
									<td class="password" width="50%">
										<center>
											<b>' + isnull(ltrim(rtrim(@u_pass)),'') + '</b>
										</center>					
									</td>
									<td width="25%"></td>
								</tr>
								<tr>
									<td colspan="3">
										<br/><br/>
										<p>Terima Kasih,<br/><br/><br/>IFinancing</p>
										<hr/>
										<p id="companyinfo">' + isnull(@company_name,'') + '<br/>' + isnull(@company_address,'') + '<br/>' + isnull(@company_phone,'') + '<br/>' + isnull(@company_fax,'') + '</p>
									</td>
								</tr>
								<tr>
									<td class="footer" colspan="3"></td>
								</tr>
							</table>
						</body>
					</html>'
				
		set @u_pass = dbo.fn_generate_md5(@u_pass)
	

		select	@emp_email	= email 	
		from	sys_employee_main
		where	code		= @u_code


		select	@cc_email	= email2	
		from	sys_employee_main
		where	code		= @u_code

	
		begin try 
			exec xsp_send_email @emp_email, @cc_email, null, @body, @subject
		end try
		begin catch
			--set @msg = 'User or Email doesn`t exist in the database'
			raiserror('System cannot proceed your request! Please contact IT Department. (invalid db mail profile/user email)', 16, -1)
		end catch  

		update	sys_user_main
		set		upass 					= @u_pass
				,upassapproval			= @u_pass
				,last_fail_count		= 0
				,next_change_pass		= dbo.fn_get_system_date()
				--,change_password_flag	= 'BOTH'
				,is_active				= '1'
		where	code					= @u_code  


		declare @p_code nvarchar(50);
		exec dbo.xsp_sys_user_reset_password_insert @p_code				= @p_code output
		                                          , @p_user_code		= @u_code
		                                          , @p_request_date		= @date_now
		                                          , @p_password_type	= N'LOGIN'
		                                          , @p_new_password		= @u_pass
		                                          , @p_remarks			= N'Reset Password'
		                                          , @p_status			= N'HOLD'
		                                          , @p_cre_date			= @date_now
		                                          , @p_cre_by			= ''
		                                          , @p_cre_ip_address	= N''
		                                          , @p_mod_date			= @date_now
		                                          , @p_mod_by			= N''
		                                          , @p_mod_ip_address	= N''


		declare @p_id bigint;
		exec dbo.xsp_sys_user_login_log_insert @p_id				= @p_id output
		                                     , @p_ucode				= @u_code
		                                     , @p_login_date		= @date_now
		                                     , @p_flag_code			= N'RESET'
		                                     , @p_session_id		= N''
		                                     , @p_cre_date			= @date_now
		                                     , @p_cre_by			= N''
		                                     , @p_cre_ip_address	= N''
		                                     , @p_mod_date			= @date_now
		                                     , @p_mod_by			= N''
		                                     , @p_mod_ip_address	= N''
		
		

	end try
	begin catch
		print LEN(@msg)
	   if (LEN(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end;

		raiserror(@msg, 16, -1) ;
		return ; 
	end catch

end

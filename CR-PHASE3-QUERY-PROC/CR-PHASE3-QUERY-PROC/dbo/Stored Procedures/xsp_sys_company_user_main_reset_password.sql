CREATE PROCEDURE dbo.xsp_sys_company_user_main_reset_password
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
			,@company_code		nvarchar(50)
			,@company_name		nvarchar(100)
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
			,@username			nvarchar(250)

	begin try

		set @date_now = getdate();

		if not exists (select 1 
						from dbo.sys_company_user_main um
						where (um.code = @p_uid_or_email or um.email = @p_uid_or_email))
		begin
			set @msg = 'User or Email doesn`t exist in the database';
			raiserror(@msg,16,-1)
		end

		select @u_code		= um.code  
				,@emp_name	= um.name
				,@emp_email = um.email
				,@username	= username
				,@company_code = um.company_code
		from dbo.sys_company_user_main um
		where (um.code = @p_uid_or_email or um.email = @p_uid_or_email)

		select	@company_name = name
		from	sys_company
		where	code = @company_code

		select	@com_param_address	= address
				,@com_zip_code		= ''
				,@com_area_phone_no	= ''
				,@com_phone_no		= phone_no
				,@com_area_fax_no	= ''
				,@com_fax_no		= fax_no
		from	eprocsys.dbo.sys_company
		where	code = @company_code;

		set	@company_address		= isnull(@com_param_address, '') + isnull(' ' + @com_zip_code, '')
		set @company_phone			= isnull('(' + @com_area_phone_no + ')', '') + isnull(' ' + @com_phone_no, '')
		set @company_fax			= isnull('(' + @com_area_fax_no + ')', '') + isnull(' ' + @com_fax_no, '')	
	

		set @u_pass = @username
	
	 
		set @subject = '[eproc] Reset Password'

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

								#ICAS {
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
											e<span id="icas">CAS</span>
										</span>
									</td>
								</tr>
								<tr>
									<td colspan="3">
										<br/>
										<p><b>Dear ' + isnull(@emp_name,'') + '</b>,</p>
										<br/><br/>
										<p>Your password has been reset.</p>
										<p>This is your new username and password :</p>
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
										<p>Regards,<br/><br/><br/>Collection and Sales System</p>
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
				
		set @u_pass = dbo.fn_generate_md5(@username)
	
	
		begin try 
			exec xsp_send_email @emp_email, null, null, @body, @subject
		end try
		begin catch
			raiserror('System cannot proceed your request! Please contact IT Department. (invalid db mail profile/user email)', 16, -1)
		end catch  

		update	sys_company_user_main
		set		upass 					= @u_pass
				,upassapproval			= @u_pass
				,last_fail_count		= 0
				,next_change_pass		= dbo.fn_get_system_date()
				--,change_password_flag	= 'BOTH'
				,is_active				= '1'
		where	code					= @u_code  
		
		exec dbo.xsp_sys_company_user_reset_password_insert @p_code					= ''                             
		                                                    ,@p_request_date		= @date_now
		                                                    ,@p_user_code			= @u_code
		                                                    ,@p_password_type		= 'LOGIN'
		                                                    ,@p_new_password		= @u_pass
		                                                    ,@p_remarks				= 'Reset Password'
		                                                    ,@p_status				= 'HOLD'
		                                                    ,@p_cre_date			= @date_now
		                                                    ,@p_cre_by				= @u_code
		                                                    ,@p_cre_ip_address		= ''
		                                                    ,@p_mod_date			= @date_now
		                                                    ,@p_mod_by				= @u_code
		                                                    ,@p_mod_ip_address		= ''
		
		exec dbo.xsp_sys_company_user_login_log_update @p_id			= 0
		                                               ,@p_user_code	= @u_code
		                                               ,@p_login_date	= @date_now
		                                               ,@p_flag_code	= 'RESET'
		                                               ,@p_session_id	= ''
		                                               ,@p_mod_date		= @date_now
		                                               ,@p_mod_by		= @u_code
		                                               ,@p_mod_ip_address = ''
		
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

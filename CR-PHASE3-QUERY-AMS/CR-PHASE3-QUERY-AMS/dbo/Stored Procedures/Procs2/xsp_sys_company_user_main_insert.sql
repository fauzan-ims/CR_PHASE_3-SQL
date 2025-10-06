CREATE PROCEDURE dbo.xsp_sys_company_user_main_insert
(
	@p_code				 nvarchar(50) output
	,@p_company_code	 nvarchar(50)
	,@p_name			 nvarchar(100)
	,@p_username		 nvarchar(50)
	,@p_main_task_code	 nvarchar(50)
	,@p_email			 nvarchar(50)
	,@p_phone_no		 nvarchar(25)
	,@p_province_code	 nvarchar(50)
	,@p_province_name	 nvarchar(250)
	,@p_city_code		 nvarchar(50)
	,@p_city_name		 nvarchar(250)
	,@p_last_login_date	 datetime	 = null
	,@p_last_fail_count	 int		 = 0
	,@p_next_change_pass datetime	 = null
	,@p_module			 nvarchar(20)
	,@p_is_default		 nvarchar(1)
	,@p_is_active		 nvarchar(1)
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@upass				nvarchar(20)
			,@next_change_pass	datetime 
			,@year			    nvarchar(4)
			,@month			    nvarchar(2)
			,@code				nvarchar(50)
			,@max_user			int
			,@count_user		int
			,@body				nvarchar(4000)
			,@subject			nvarchar(200)
			,@com_param_address	nvarchar(50)
			,@company_address	nvarchar(4000)
			,@company_phone		nvarchar(30)
			,@company_fax		nvarchar(30)
			,@com_zip_code		nvarchar(50)
			,@com_area_phone_no	nvarchar(50)
			,@com_phone_no		nvarchar(50)
			,@com_area_fax_no	nvarchar(50)
			,@com_fax_no		nvarchar(50)
			,@company_name		nvarchar(100)
			,@efam_link			nvarchar(4000)
			,@prefix			nvarchar(50)
			,@eprocbase_link	nvarchar(4000);
			
	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	set @prefix = @p_company_code + 'USR';

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = ''
												,@p_custom_prefix = @prefix
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'SYS_COMPANY_USER_MAIN'
												,@p_run_number_length = 5
												,@p_run_number_only = '0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else if @p_is_active = '1'
		set @p_is_active = '1' ;
	else if @p_is_active = '0'
		set @p_is_active = '0' ;
	else
		set @p_is_active = '0' ;

	begin try

		select	@upass = dbo.fn_generate_md5(@p_username) ;

		select	@next_change_pass = dateadd(month, password_next_change, dbo.xfn_get_system_date())
		from	dbo.sys_it_param ;
	
		if exists(select 1 from dbo.sys_company_user_main where username = @p_username or email = @p_email)
		begin
			set @msg = 'Username or Email already exist';
			--set @msg = 'Username atau Email sudah ada.';
			raiserror(@msg, 16, -1) ;
		end
		
		select	@max_user = max_user
		from	mobiesys.dbo.sys_company
		where	code = @p_company_code
		and		is_active = '1';

		select	@count_user = count(*)
		from	dbo.sys_company_user_main
		where	company_code = @p_company_code
		and		is_active = '1';
		
		if (@count_user + 1 > @max_user)
		begin
			set @msg = 'User has exceeded the maximum limit. Maximum active user is ' + cast(@max_user as nvarchar(20));
			--set @msg = 'User telah mencapai batas maksimal. User aktif maksimal adalah ' + cast(@max_user as nvarchar(20));
			raiserror(@msg, 16, -1) ;
		end
		
		if @p_username = upper(@p_username) and @p_username like '%[^a-zA-Z0-9_]%'
		begin
			set @msg = 'Invalid Special Character for Username';
			--set @msg = 'Tidak bisa menggunakan karakter khusus untuk username.';
			raiserror(@msg, 16, -1) ;
		end
		else
		begin
			insert into sys_company_user_main
			(
				code
				,company_code
				,upass
				,upassapproval
				,name
				,username
				,main_task_code
				,email
				,phone_no
				,province_code
				,province_name
				,city_code
				,city_name
				,last_login_date
				,last_fail_count
				,next_change_pass
				,module
				,is_default
				,is_active
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	
				@code
				,@p_company_code
				,@upass
				,@upass
				,@p_name
				,@p_username
				,@p_main_task_code
				,@p_email
				,@p_phone_no
				,@p_province_code
				,@p_province_name
				,@p_city_code
				,@p_city_name
				,@p_last_login_date
				,@p_last_fail_count
				,@next_change_pass
				,@p_module
				,@p_is_default
				,@p_is_active
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			set @p_code = @code;

			select	@com_param_address	= address
					,@com_zip_code		= ''
					,@com_area_phone_no	= ''
					,@com_phone_no		= phone_no
					,@com_area_fax_no	= ''
					,@com_fax_no		= fax_no
					,@company_name		= name
			from	mobiesys.dbo.sys_company
			where	code = @p_company_code
						
			select	@efam_link = value 
			from	mobiesys.dbo.sys_global_param
			where	code = 'EFAM';
			
			select	@eprocbase_link = value 
			from	mobiesys.dbo.sys_global_param
			where	code = 'EPROCBASE';

			set	@company_address		= isnull(@com_param_address, '') + isnull(' ' + @com_zip_code, '')
			set @company_phone			= isnull('(' + @com_area_phone_no + ')', '') + isnull(' ' + @com_phone_no, '')
			set @company_fax			= isnull('(' + @com_area_fax_no + ')', '') + isnull(' ' + @com_fax_no, '')	

			-- Region Send Email
			if (@p_is_default = '1') -- SA (Super Admin)
			begin
				set @subject = '[efam] Default User Register'

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

										#EFAM {
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
													e<span id="efam">FAM</span>
												</span>
											</td>
										</tr>
										<tr>
											<td colspan="3">
												<br/>
												<p><b>Dear ' + isnull(@company_name,'') + '</b>,</p>
												<br/>
												<p>Thanks for signing up! You can use following links to access : </p>
												<p>(1) Fixed Asset Management : '+ @efam_link +'</p>
												<p>(2) Admin Control : '+ @eprocbase_link +'</p>
												<p>This is your username and password :</p>
												<br/>
											</td>
										</tr>
										<tr>
											<td width="25%"></td>
											<td class="password" width="50%">
												<center>
													<b>' + isnull(ltrim(rtrim(@p_username)),'') + '</b>
												</center>					
											</td>
											<td width="25%"></td>
										</tr>
										<tr>
											<td colspan="3">
												<br/><br/>
												<p>Regards,<br/><br/><br/>Fixed Asset Management System</p>
												<hr/>
												<p id="companyinfo">' + 'PT. Mobitech Media Integrasi' + '<br/>' + 'Jl. Cideng Timur Raya No.86A, Petojo Selatan, Gambir, Jakarta Pusat 10160' + '<br/>' + '+62 21 3456 852' + '<br/>' + '+62 21 3456 934' + '</p>
											</td>
										</tr>
										<tr>
											<td class="footer" colspan="3"></td>
										</tr>
									</table>
								</body>
							</html>'
				
				begin try 
					exec xsp_send_email @p_email, null, null, @body, @subject
				end try
				begin catch
					raiserror('System cannot proceed your request! Please contact IT Department. (invalid db mail profile/user email)', 16, -1)
				end catch  
	
			end
			else if (@p_is_default = '0') -- Not SA
			begin
				set @subject = '[efam] User Register'

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

										#EFAM {
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
													e<span id="efam">FAM</span>
												</span>
											</td>
										</tr>
										<tr>
											<td colspan="3">
												<br/>
												<p><b>Dear ' + isnull(@p_name,'') + '</b>,</p>
												<br/><br/>
												<p>Your registration user ' + isnull(@p_module,'') + '</b> has been successful.</p>
												<p>You can use this link to access our full app '+ @efam_link +'</p>
												<p>This is your username and password :</p>
												<br/>
											</td>
										</tr>
										<tr>
											<td width="25%"></td>
											<td class="password" width="50%">
												<center>
													<b>' + isnull(ltrim(rtrim(@p_username)),'') + '</b>
												</center>					
											</td>
											<td width="25%"></td>
										</tr>
										<tr>
											<td colspan="3">
												<br/><br/>
												<p>Terima Kasih,<br/><br/><br/>Fixed Asset Management System</p>
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
				
				begin try 
					exec xsp_send_email @p_email, null, null, @body, @subject
				end try
				begin catch
					raiserror('System cannot proceed your request! Please contact IT Department. (invalid db mail profile/user email)', 16, -1)
				end catch
			end
		
			-- End Region Send Email   
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








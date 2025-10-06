CREATE PROCEDURE dbo.xsp_sys_company_user_main_resend_email
(
	@p_user_code	nvarchar(50)
)
as
begin
	declare @msg				nvarchar(max)
			,@body				nvarchar(4000)
			,@subject			nvarchar(200)
			--
			,@company_code		nvarchar(50)
			,@email				nvarchar(50)
			,@username			nvarchar(50)
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
			,@icas_link			nvarchar(4000);

	begin try --
		
		select	@company_code	= company_code
				,@email			= email 
				,@username		= username
		from	dbo.sys_company_user_main
		where	code = @p_user_code;
		 
		select	@com_param_address	= address
				,@com_zip_code		= ''
				,@com_area_phone_no	= ''
				,@com_phone_no		= phone_no
				,@com_area_fax_no	= ''
				,@com_fax_no		= fax_no
				,@company_name		= name
		from	eprocsys.dbo.sys_company
		where	code = @company_code;
							
		select	@icas_link = value 
		from	eprocsys.dbo.sys_global_param
		where	code = 'eproc';

		set	@company_address		= isnull(@com_param_address, '') + isnull(' ' + @com_zip_code, '')
		set @company_phone			= isnull('(' + @com_area_phone_no + ')', '') + isnull(' ' + @com_phone_no, '')
		set @company_fax			= isnull('(' + @com_area_fax_no + ')', '') + isnull(' ' + @com_fax_no, '')	

		-- Region Send Email
		set @subject = '[eproc] Default User Register'

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
										<p><b>Dear ' + isnull(@company_name,'') + '</b>,</p>
										<br/><br/>
										<p>Thanks for signing up! You can use this link to access our full app '+ @icas_link +'.</p>
										<p>This is your username and password :</p>
										<br/>
									</td>
								</tr>
								<tr>
									<td width="25%"></td>
									<td class="password" width="50%">
										<center>
											<b>' + isnull(ltrim(rtrim(@username)),'') + '</b>
										</center>					
									</td>
									<td width="25%"></td>
								</tr>
								<tr>
									<td colspan="3">
										<br/><br/>
										<p>Regards,<br/><br/><br/>Collection and Sales System</p>
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
			exec xsp_send_email @email, null, null, @body, @subject
		end try
		begin catch
			raiserror('System cannot proceed your request! Please contact IT Department. (invalid db mail profile/user email)', 16, -1)
		end catch  
		
	end try
	Begin catch
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

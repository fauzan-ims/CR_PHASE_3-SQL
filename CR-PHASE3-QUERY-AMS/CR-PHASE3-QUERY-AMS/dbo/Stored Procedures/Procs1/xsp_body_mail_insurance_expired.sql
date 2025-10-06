create procedure [dbo].[xsp_body_mail_insurance_expired]
as
begin
	declare @msg				  nvarchar(max)
			,@id				  bigint
			,@email				  nvarchar(250)
			,@recipient_name	  nvarchar(250)
			,@agreement_no		  nvarchar(50)
			,@client_name		  nvarchar(250)
			,@invoice_no		  nvarchar(50)
			,@invoice_date		  datetime
			,@invoice_due_date	  datetime
			,@billing_amount	  decimal(18, 2)
			,@reference_no_1	  nvarchar(50)	= N''
			,@reference_no_2	  nvarchar(50)	= N''
			,@header_message	  nvarchar(250)
			,@body_message_1	  nvarchar(max) = N''
			,@body_message_2	  nvarchar(max) = N''
			,@body_message_3	  nvarchar(max) = N'</table></table></table></table>'
			,@reference_amount_1  decimal(18, 2)
			,@company_name		  nvarchar(250)
			,@company_address	  nvarchar(4000)
			,@media_code		  nvarchar(50)
			,@request_date		  datetime		= getdate()
			,@request_sent_date	  datetime		= getdate()
			,@manual_request_flag nvarchar(250)
			,@use_request_code	  nvarchar(50)
			,@reff_no			  nvarchar(50)
			,@header			  nvarchar(4000)
			,@footer			  nvarchar(4000)
			,@body_1			  nvarchar(max)
			,@reff_name			  nvarchar(50)
			,@index				  int
			,@p_code			  nvarchar(50)
			,@emp_code			  nvarchar(50)
			,@email_cc			  nvarchar(250) = null
			,@email_to			  nvarchar(250)
			,@from_email		  nvarchar(250)
			,@status			  nvarchar(50)
			,@remarks			  nvarchar(200)
			,@debit				  decimal(18, 2)
			,@credit			  decimal(18, 2)
			,@keterangan		  nvarchar(200)
			,@total				  nvarchar(10)
			,@status2			  nvarchar(50)
			,@remarks2			  nvarchar(200)
			,@keterangan2		  nvarchar(200)
			,@status_header		  nvarchar(50)
			,@count				  bigint
			,@policy_no			  nvarchar(50)
			,@total_asset		  nvarchar(4)
			,@eff_date			  nvarchar(30)
			,@exp_date			  nvarchar(30)
			,@insurance_name	  nvarchar(250)
			,@no				  bigint		= 1
			,@no_body			  bigint
			,@count_data_2		  bigint
			,@attacthment		  nvarchar(4000)
			--
			,@p_cre_date		  datetime		= getdate()
			,@p_cre_by			  nvarchar(15)	= N'EOD'
			,@p_cre_ip_address	  nvarchar(15)	= N'SYSTEM'
			,@p_mod_date		  datetime		= getdate()
			,@p_mod_by			  nvarchar(15)	= N'TEST'
			,@p_mod_ip_address	  nvarchar(15)	= N'SYSTEM' ;

	begin try
		select	@company_name = value
		from	dbo.sys_global_param
		where	code = 'COMP' ;

		select	@company_address = value
		from	dbo.sys_global_param
		where	code = 'COMPADD' ;

		--select @media_code = value
		--from dbo.sys_global_param
		--where code = 'NTFEMAIL';
		select	@from_email = value
		from	ifinsys.dbo.sys_global_param
		where	code = 'ESEND' ;

		--if (convert(varchar(30), dbo.xfn_get_system_date(), 103) = convert(varchar(30), eomonth(dbo.xfn_get_system_date()), 103))
		begin
			set @header_message = N'Policy Expired Monitoring ' + convert(varchar, @p_cre_date, 108) ;
			set @header = --N'	<p>Dear ' + @recipient_name + N', </p>
			--'<p>Daily Checking iFinancing</p>';
			N'<table style = "font-size: 20px; background-color:#cceeff; padding-left: 20px;	height:60px; width:100%">
									<tr>
										<td class="title" colspan="2">
											<span class="title">
												<span id="ifinancing"> Policy Expired</span>
											</span>
										</td>
									</tr>
								</table>' ;

			set @body_message_1 = 'Berikut terlampir file insurance expired.'

			--+ @status + N'</td>' + N'</tr>' ;
			set @footer = N'<p></p>
							<p>Terima Kasih,</p>
							<p>iFinancing</p>
							<p></p>
							<p>' + isnull(@company_name, '') + N'</p>
							<p>' + isnull(@company_address, '') + N'</p>' ;

			--select	@email = value
			--from	ifinsys.dbo.sys_global_param
			--where	code = 'EODEMAIL3' ;
			set @email = N'bagas@ims-tec.com' ;
			set @attacthment = N'C:\V5\ReportImage\box.png' ;

			exec IFINSYS.dbo.sys_email_notification_task_insert @p_from_email		= @from_email
																,@p_to_email		= @email
																,@p_to_email_cc		= @email_cc
																,@p_to_email_bcc	= null
																,@p_subject			= @header_message
																,@p_header			= @header
																,@p_body1			= @body_message_1
																,@p_body2			= @body_message_2
																,@p_body3			= @body_message_3
																,@p_footer			= @footer
																,@p_attachment		= @attacthment
																,@p_date			= null
																,@p_send_date		= null
																,@p_send_status		= 'HOLD'
																,@p_cre_date		= @p_cre_date
																,@p_cre_by			= @p_cre_by
																,@p_cre_ip_address	= @p_cre_ip_address
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

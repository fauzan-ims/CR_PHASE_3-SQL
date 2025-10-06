CREATE PROCEDURE dbo.xsp_job_eom_invoice_duedate_notification

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
			,@reference_no_1	  nvarchar(50)	 = ''
			,@reference_no_2	  nvarchar(50)	 = ''
			,@header_message	  nvarchar(250)
			,@body_message_1	  nvarchar(4000) = ''
			,@body_message_2	  nvarchar(4000) = ''
			,@body_message_3	  nvarchar(4000) = '</table></table></table></table>'
			,@reference_amount_1  decimal(18, 2)
			,@company_name		  nvarchar(250)
			,@company_address	  nvarchar(4000)
			,@media_code		  nvarchar(50)
			,@request_date		  datetime		 = getdate()
			,@request_sent_date	  datetime		 = getdate()
			,@manual_request_flag nvarchar(250)
			,@use_request_code	  nvarchar(50)
			,@reff_no			  nvarchar(50)
			,@header			  nvarchar(4000)
			,@footer			  nvarchar(4000)
			,@body_1			  nvarchar(max)
			,@reff_name			  nvarchar(50)
			,@p_code			  nvarchar(50)
			,@emp_code			  nvarchar(50)
			,@count_data_1		  int
			,@count_data_2		  int
			,@email_cc			  nvarchar(250) 
			,@from_email		  nvarchar(250)
			,@asset_no				NVARCHAR(50)
			,@billing_no		int
			,@due_date			datetime
			--
			,@p_cre_date		  datetime		 = getdate()
			,@p_cre_by			  nvarchar(15)	 = 'EOD'
			,@p_cre_ip_address	  nvarchar(15)	 = 'SYSTEM'
			,@p_mod_date		  datetime		 = getdate()
			,@p_mod_by			  nvarchar(15)	 = 'EOD'
			,@p_mod_ip_address	  nvarchar(15)	 = 'SYSTEM' ;
		

	begin try
		select	@company_name = value
		from	dbo.sys_global_param
		where	code = 'COMP' ;

		select	@company_address = value
		from	dbo.sys_global_param
		where	code = 'COMPADD' ;

		select	@media_code = value
		from	dbo.sys_global_param
		where	code = 'NTFEMAIL' ;

		select @from_email = value
		from ifinsys.dbo.sys_global_param
		where code = 'ESEND'

		declare c_invoice_due cursor for
		select	distinct agm.client_name
				,ams.email 
		from	dbo.agreement_main agm
				inner join dbo.agreement_asset ams on agm.agreement_no = ams.agreement_no
		where	agm.agreement_status = 'GO LIVE'
		and		ams.is_auto_email = '1'

		open c_invoice_due
		fetch c_invoice_due
		into	@email
				,@recipient_name
			

		while @@fetch_status = 0
		begin

			set @header_message = '[EOD] INFORMASI INVOICE YANG TELAH JATUH TEMPO DALAM 30 HARI SEBELUM DAN AKAN JATUH TEMPO DALAM 30 HARI KEDEPAN'
		
			SET @header = '	<p>Dear ' + @recipient_name + ', </p>
							<p>Informasi Invoice yang akan Telah Jatuh Tempo dalam 30 Hari sebelum dan akan Jatuh Tempo dalam 30 Hari kedepan </p>'

			begin
				set @body_message_1	= '	Invoice yang telah jatuh tempo 30 hari sebelum: </br>
										<table style="border-collapse: collapse; width: 100%;" border="1">
										<tbody>
										<tr>
										<td style="width: 25%; text-align:center; font-weight:bold;">Agreement No</td>
										<td style="width: 25%; text-align:center; font-weight:bold;">Asset No</td>
										<td style="width: 10%; text-align:center; font-weight:bold;">Billing No.</td>
										<td style="width: 20%; text-align:center; font-weight:bold;">Invoice No.</td>
										<td style="width: 10%; text-align:center; font-weight:bold;">Due Date</td>
										<td style="width: 10%; text-align:center; font-weight:bold;">Invoice Date</td>
										</tr>'
											
				declare c_billing cursor FOR
                select	agreement_no
						,asset_no
						,billing_no
						,invoice_no
						,due_date
						,invoice_date
				from	dbo.agreement_invoice
				where	agreement_no = @agreement_no
				and		asset_no = @asset_no
				and		cast(due_date as date) between cast(dateadd(month,-1,@p_mod_date) as date) and cast(dateadd(day,-1,@p_mod_date) as date)

					open c_billing
					fetch c_billing
					into	@agreement_no
							,@asset_no
							,@billing_no
							,@invoice_no
							,@due_date
							,@invoice_date
			

					while @@fetch_status = 0
					begin

						set @body_message_1 = @body_message_1 + '<tr>
												 <td style="width: 25%; text-align:left;">' + @agreement_no			+ '</td>' +
												'<td style="width: 25%; text-align:left;">' + @asset_no				+ '</td>' +
												'<td style="width: 10%; text-align:left;">' + @billing_no				+ '</td>' +
												'<td style="width: 20%; text-align:left;">' + @invoice_no				+ '</td>' +
												'<td style="width: 10%; text-align:center;">' + CONVERT(NVARCHAR(50),CAST(@due_date AS DATE))			+ '</td>' +
												'<td style="width: 10%; text-align:center;">' + CONVERT(NVARCHAR(50),CAST(@invoice_date AS DATE))			+ '</td>' +
												'</tr>'
		
						fetch c_billing
						into	@agreement_no
							,@asset_no
							,@billing_no
							,@invoice_no
							,@due_date
							,@invoice_date

				end
            
				close c_billing
				deallocate c_billing
									
				set @body_message_1 = @body_message_1 + '</table></br>'
						
		
			end

			-- 8 - 30
			BEGIN
			    set @body_message_2	= '	</br></br>
										Invoice yang akan jatuh tempo 30 hari kedepan: </br>
										<table style="border-collapse: collapse; width: 100%;" border="1">
										<tbody>
										<tr>
										<td style="width: 25%; text-align:center; font-weight:bold;">Agreement No</td>
										<td style="width: 25%; text-align:center; font-weight:bold;">Asset No</td>
										<td style="width: 10%; text-align:center; font-weight:bold;">Billing No.</td>
										<td style="width: 20%; text-align:center; font-weight:bold;">Invoice No.</td>
										<td style="width: 10%; text-align:center; font-weight:bold;">Due Date</td>
										<td style="width: 10%; text-align:center; font-weight:bold;">Invoice Date</td>
										</tr>'
												
				declare c_billing cursor for
				select	agreement_no
						,asset_no
						,billing_no
						,invoice_no
						,due_date
						,invoice_date
				from	dbo.agreement_invoice
				where	agreement_no = @agreement_no
				and		asset_no = @asset_no
				and		cast(due_date as date) between cast(dateadd(month,-1,@p_mod_date) as date) and cast(dateadd(day,-1,@p_mod_date) as date)

					open c_billing
					fetch c_billing
					into	@agreement_no
							,@asset_no
							,@billing_no
							,@invoice_no
							,@due_date
							,@invoice_date
			
					while @@fetch_status = 0
					begin

						set @body_message_2 = @body_message_2 + '<tr>
												 <td style="width: 25%; text-align:left;">' + @agreement_no				+ '</td>' +
												'<td style="width: 25%; text-align:left;">' + @asset_no					+ '</td>' +
												'<td style="width: 10%; text-align:left;">' + @billing_no				+ '</td>' +
												'<td style="width: 20%; text-align:left;">' + @invoice_no				+ '</td>' +
												'<td style="width: 10%; text-align:right;">' + CONVERT(NVARCHAR(50),CAST(@due_date AS DATE))			+ '</td>' +
												'<td style="width: 10%; text-align:right;">' + CONVERT(NVARCHAR(50),CAST(@invoice_date AS DATE))		+ '</td>' +
												'</tr>'
		
						fetch c_billing
						into @agreement_no
							,@asset_no
							,@billing_no
							,@invoice_no
							,@due_date
							,@invoice_date

					end
            
					close c_billing
					deallocate c_billing
						
					
				set @body_message_2 = @body_message_2 + '</table></br>'
SELECT @header_message'@header_message',@header'@header',@body_message_1'@body_message_1',@body_message_2'@body_message_2',@footer'@footer'
			end

			set @footer = '<p></p>
						<p>Terima Kasih,</p>
						<p>iFinancing</p>
						<p></p>
						<p>' + isnull(@company_name,'') + '</p>
						<p>' + isnull(@company_address,'') +'</p>'


			EXEC ifinsys.dbo.sys_email_notification_task_insert @p_from_email		= @from_email,                
																@p_to_email			= 'sepria@ims-tec.com',--@email,           
																@p_to_email_cc		= 'sepria@ims-tec.com',--@email_cc,        
																@p_to_email_bcc		= null,              
																@p_subject			= @header_message,  
																@p_header			= @header,          
																@p_body1			= @body_message_1,  
																@p_body2			= @body_message_2,  
																@p_body3			= @body_message_3,  
																@p_footer			= @footer,          
																@p_attachment		= N'',              
																@p_date				= null,
																@p_send_date		= null,
																@p_send_status		= 'HOLD',
																@p_cre_date			= @p_cre_date,
																@p_cre_by			= @p_cre_by,                    
																@p_cre_ip_address	= @p_cre_ip_address,            
																@p_mod_date			= @p_mod_date,
																@p_mod_by			= @p_mod_by,                     
																@p_mod_ip_address	= @p_mod_ip_address              
		
			FETCH c_invoice_due
			INTO @email
				,@recipient_name

		END
            
		CLOSE c_invoice_due
		DEALLOCATE c_invoice_due
		
	end try
	begin catch
		
		if cursor_status('global', 'c_billing') >= -1
		begin
			if cursor_status('global', 'c_billing') > -1
			begin
				close c_billing ;
			end ;

			deallocate c_billing ;
		end ;

		if cursor_status('global', 'c_invoice_due') >= -1
		begin
			if cursor_status('global', 'c_invoice_due') > -1
			begin
				close c_invoice_due ;
			end ;

			deallocate c_invoice_due ;
		end ;
	
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
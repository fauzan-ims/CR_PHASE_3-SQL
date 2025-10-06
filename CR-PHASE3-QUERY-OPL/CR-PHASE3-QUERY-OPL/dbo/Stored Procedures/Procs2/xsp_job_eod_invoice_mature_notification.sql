CREATE PROCEDURE [dbo].[xsp_job_eod_invoice_mature_notification]

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

		select	distinct 
				am.email
				,am.name
				,sep.emp_code
				,amh.email
		from	dbo.agreement_main agm
				inner join ifinsys.dbo.sys_employee_position sep on agm.marketing_code = sep.emp_code
				inner join ifinsys.dbo.sys_employee_main am on am.code = sep.emp_code
				left join ifinsys.dbo.sys_employee_main amh on amh.code = am.head_emp_code		
		where	agm.agreement_status = 'GO LIVE'


		open c_invoice_due
		fetch c_invoice_due
		into	@email
				,@recipient_name
				,@emp_code
				,@email_cc
			

		while @@fetch_status = 0
		begin
		    

			set @header_message = '[EOD] INFORMASI KONTRAK YANG AKAN LUNAS DALAM 30 HARI KEDEPAN'
		
			SET @header = '	<p>Dear ' + @recipient_name + ', </p>
							<p>Informasi Kontrak yang akan Lunas :</p>'

			begin
				set @body_message_1	= '	Dalam 7 hari ke depan: </br>
										<table style="border-collapse: collapse; width: 100%;" border="0">
										<tbody>
										<tr>
										<td style="width: 30%;">Agreement No</td>
										<td style="width:  50%;">Client Name</td>
										<td style="width:  20%;">Mature Date</td>
										</tr>'
											
				declare c_billing cursor for
				select	top 5 am.agreement_no
						,am.client_name
						,a.max_due_date
				from	dbo.agreement_main am
						inner join dbo.agreement_asset ast on ast.agreement_no = am.agreement_no
						outer apply (	select	max(aamt.due_date) 'max_due_date'
												,max(aamt.billing_no) 'max_billing_no'
										from	dbo.agreement_asset_amortization aamt
										where	aamt.agreement_no = ast.agreement_no
									) a
				where	am.agreement_status = 'go live'
				--and		cast(a.max_due_date as date) between dbo.xfn_get_system_date() and dateadd(day,7,dbo.xfn_get_system_date())
				--and		am.marketing_code = @emp_code

					open c_billing
					fetch c_billing
					into	@agreement_no
							,@client_name
							,@invoice_date
			

					while @@fetch_status = 0
					begin

						set @body_message_1 = @body_message_1 + '<tr>
												<td style="width: 30%;">' + @agreement_no				+ '</td>' +
												'<td style="width: 50%;">' + @client_name				+ '</td>' +
												'<td style="width: 20%;">' + CONVERT(NVARCHAR(50),CAST(@invoice_date AS DATE))			+ '</td>' +
												'</tr>'
		
						fetch c_billing
						into @agreement_no
							,@client_name
							,@invoice_date

				end
            
				close c_billing
				deallocate c_billing
									
				set @body_message_1 = @body_message_1 + '</table></br>'

				select	@count_data_1 = count(isnull(am.agreement_no,0)) - 10
				from	dbo.agreement_main am
						inner join dbo.agreement_asset ast on ast.agreement_no = am.agreement_no
						outer apply (	select	max(aamt.due_date) 'max_due_date'
												,max(aamt.billing_no) 'max_billing_no'
										from	dbo.agreement_asset_amortization aamt
										where	aamt.agreement_no = ast.agreement_no
									) a
				where	am.agreement_status = 'go live'
				and		cast(a.max_due_date as date) between dbo.xfn_get_system_date() and dateadd(day,7,dbo.xfn_get_system_date())
				and		am.marketing_code = @emp_code

				if(isnull(@count_data_1,0) > 0)
				begin
					set @body_message_1 = @body_message_1 + '</br>*Dan masih ada ' + CONVERT(NVARCHAR(5), ISNULL(@count_data_1,0)) + ' lainnya.'
				end

			end

			-- 8 - 30
			BEGIN
			    set @body_message_2	= '	</br></br>
										Dalam 8 hingga 30 hari ke depan: </br>
										<table style="border-collapse: collapse; width: 86.9318%;" border="0">
										<tbody>
										<tr>
										<td style="width: 30%;">Agreement No</td>
										<td style="width:  50%;">Client Name</td>
										<td style="width:  20%;">Mature Date</td>
										</tr>'
												
				declare c_billing cursor for
				select	top 5 am.agreement_no
						,am.client_name
						,a.max_due_date
				from	dbo.agreement_main am
						inner join dbo.agreement_asset ast on ast.agreement_no = am.agreement_no
						outer apply (	select	max(aamt.due_date) 'max_due_date'
												,max(aamt.billing_no) 'max_billing_no'
										from	dbo.agreement_asset_amortization aamt
										where	aamt.agreement_no = ast.agreement_no
									) a
				where	am.agreement_status = 'go live'
				--and		cast(a.max_due_date as date) between dateadd(day,8,dbo.xfn_get_system_date()) and dateadd(day,30,dbo.xfn_get_system_date())
				--and		am.marketing_code = @emp_code

					open c_billing
					fetch c_billing
					into	@agreement_no
							,@client_name
							,@invoice_date
			

					while @@fetch_status = 0
					begin

						set @body_message_2 = @body_message_2 + '<tr>
												<td style="width: 30%;">' + @agreement_no				+ '</td>' +
												'<td style="width: 50%;">' + @client_name				+ '</td>' +
												'<td style="width: 20%;">' + CONVERT(NVARCHAR(50),CAST(@invoice_date AS DATE))			+ '</td>' +
												'</tr>'
		
						fetch c_billing
						into @agreement_no
							,@client_name
							,@invoice_date

					end
            
					close c_billing
					deallocate c_billing
						
					
				set @body_message_2 = @body_message_2 + '</table></br>'


				select	@count_data_2 = count(am.agreement_no) - 10
				from	dbo.agreement_main am
						inner join dbo.agreement_asset ast on ast.agreement_no = am.agreement_no
						outer apply (	select	max(aamt.due_date) 'max_due_date'
												,max(aamt.billing_no) 'max_billing_no'
										from	dbo.agreement_asset_amortization aamt
										where	aamt.agreement_no = ast.agreement_no
									) a
				where	am.agreement_status = 'go live'
				and		cast(a.max_due_date as date) between dateadd(day,8,dbo.xfn_get_system_date()) and dateadd(day,30,dbo.xfn_get_system_date())
				and		am.marketing_code = @emp_code

				if (isnull(@count_data_2,0) > 0)
				begin
					set @body_message_2 = @body_message_2 + '</br>*Dan masih ada ' + convert(nvarchar(5), isnull(@count_data_2,0)) + ' lainnya.'
				end

			end

			set @footer = '<p></p>
						<p>Terima Kasih,</p>
						<p>iFinancing</p>
						<p></p>
						<p>' + isnull(@company_name,'') + '</p>
						<p>' + isnull(@company_address,'') +'</p>'


			EXEC ifinsys.dbo.sys_email_notification_task_insert @p_from_email		= @from_email,                
																@p_to_email			= @email,           
																@p_to_email_cc		= @email_cc,        
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
				,@emp_code
				,@email_cc

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
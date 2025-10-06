CREATE PROCEDURE dbo.xsp_job_eom_insurance_expired
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
		,@email_cc			  nvarchar(250)	= null
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

		if(convert(varchar(30), dbo.xfn_get_system_date(), 103) = convert(varchar(30), eomonth(dbo.xfn_get_system_date()), 103))
		begin
			declare @table_temp table
			(
				policy_no		nvarchar(50)
				,total_asset	nvarchar(4)
				,eff_date		nvarchar(50)
				,exp_date		nvarchar(50)
				,insurance_name nvarchar(250)
				,status			nvarchar(50)
				,no				bigint
			) ;

			declare curr_exp_polis cursor fast_forward read_only for
			select	top 15
					policy_no
					,asset.total_asset
					,convert(varchar(30), ipm.policy_eff_date, 103)
					,convert(varchar(30), ipm.policy_exp_date, 103)
					,ipm.insured_name
					,ipm.policy_payment_status
			from	dbo.insurance_policy_main ipm
					outer apply
			(
				select		count(ipa.code) 'total_asset'
				from		dbo.insurance_policy_asset ipa
				where		ipa.policy_code = ipm.code
				group by	ipa.policy_code
			)								  asset
			where	cast(ipm.policy_exp_date as date)
			between cast(dbo.xfn_get_system_date() as date) and dateadd(month, 3, cast(dbo.xfn_get_system_date() as date)) ;
			--where	convert(char(6), policy_exp_date, 112) = convert(char(6), dateadd(month, -3, dbo.xfn_get_system_date()), 112) ;
			
			open curr_exp_polis
			
			fetch next from curr_exp_polis 
			into @policy_no
				,@total_asset
				,@eff_date
				,@exp_date
				,@insurance_name
				,@status
			
			while @@fetch_status = 0
			begin

					insert	@table_temp
					(
						policy_no
						,total_asset
						,eff_date
						,exp_date
						,insurance_name
						,status
						,no
					)
					values
					(
						@policy_no
						,@total_asset
						,@eff_date
						,@exp_date
						,@insurance_name
						,@status
						,@no
					) ;
	
					set @no = @no + 1

			
			    fetch next from curr_exp_polis 
				into @policy_no
					,@total_asset
					,@eff_date
					,@exp_date
					,@insurance_name
					,@status
			end
			
			close curr_exp_polis
			deallocate curr_exp_polis

		
			begin
				set @index = 0 ;

				declare c_body cursor local fast_forward read_only for
				select	policy_no
						,total_asset
						,eff_date
						,exp_date
						,insurance_name
						,status
						,no
				from	@table_temp ;

				/* fetch record */
				open c_body ;

				fetch c_body
				into @policy_no
					 ,@total_asset
					 ,@eff_date
					 ,@exp_date
					 ,@insurance_name
					 ,@status
					 ,@no_body

				while @@fetch_status = 0
				begin
					set @header_message = N' Policy Expired Monitoring ' + convert(varchar, @p_cre_date, 108) ;
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

					if (@index = 0)
					begin
						set @body_message_1 = N'	</br>
									<table style="border-collapse: collapse; width: 100%;" border="1">
									<tbody>
									<tr>
									<td style="width:0%; text-align:center; font-weight:bold;">No</td>
									<td style="width:15%; text-align:center; font-weight:bold;">Policy No</td>
									<td style="width:15%; text-align:center; font-weight:bold;">Total Asset</td>
									<td style="width:15%; text-align:center; font-weight:bold;">Eff Date</td>
									<td style="width:15%; text-align:center; font-weight:bold;">Exp Date</td>
									<td style="width:25%; text-align:center; font-weight:bold;">Insurance Name</td>
									<td style="width:15%; text-align:center; font-weight:bold;">Status</td>
									</tr>' ;
					end ;

					set @body_message_1 = @body_message_1 + N'<tr>
										<td style="width: 0%; text-align:center;"> ' + convert(nvarchar(4), @no_body) + N'</td>'
										  + N'<td style="width: 15%; text-align:center;">' + @policy_no + N'</td>'
										  + N'<td style="width: 15%; text-align:center;">' + @total_asset + N'</td>'
										  + N'<td style="width: 15%; text-align:center;">' + @eff_date + N'</td>'
										  + N'<td style="width: 15%; text-align:center;">' + @exp_date + N'</td>'
										  + N'<td style="width: 25%; text-align:left;">' + @insurance_name + N'</td>'
										  + N'<td style="width: 15%; text-align:center;">' + @status + N'</td>'
										  --+ @status + N'</td>' + N'</tr>' ;
					set @index = @index + 1 ;

					--set @body_message_1
					--    = @body_message_1 + N'</br>* Dan masih ada ' + CONVERT(NVARCHAR(5), ISNULL(@count_data_1, 0))
					--      + N' lainnya.';
					fetch c_body
					into @policy_no
						 ,@total_asset
						 ,@eff_date
						 ,@exp_date
						 ,@insurance_name
						 ,@status
						 ,@no_body
				end ;

				/* tutup cursor */
				close c_body ;
				deallocate c_body ;

				select	@count_data_2 = count(ipm.CODE) -  15
				from	dbo.insurance_policy_main ipm
				where	convert(char(6), policy_exp_date, 112) = convert(char(6), dateadd(month, -3, dbo.xfn_get_system_date()), 112) ;

				set @body_message_1 = @body_message_1 + N'</table></br>*Dan masih ada ' + convert(nvarchar(5), isnull(@count_data_2,0)) + ' lainnya.';
			end ;

			set @footer = N'<p></p>
							<p>Terima Kasih,</p>
							<p>iFinancing</p>
							<p></p>
							<p>' + isnull(@company_name, '') + N'</p>
							<p>' + isnull(@company_address, '') + N'</p>' ;

		select	@email = value
		FROM	ifinsys.dbo.sys_global_param
		WHERE	code = 'EODEMAIL3'
		
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
																,@p_attachment		= N''
																,@p_date			= null
																,@p_send_date		= null
																,@p_send_status		= 'HOLD'
																,@p_cre_date		= @p_cre_date
																,@p_cre_by			= @p_cre_by
																,@p_cre_ip_address	= @p_cre_ip_address
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address ;
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

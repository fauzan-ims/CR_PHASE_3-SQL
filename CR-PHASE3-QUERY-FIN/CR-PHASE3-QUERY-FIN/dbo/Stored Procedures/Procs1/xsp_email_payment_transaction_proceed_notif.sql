--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE procedure [dbo].[xsp_email_payment_transaction_proceed_notif]
    @p_payment_code			nvarchar(50)
	,@p_msg					nvarchar(4000)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(10)		
	,@p_mod_ip_address		nvarchar(15)

-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
as
begin
		begin try
    	declare  @header_message		nvarchar(200)
				,@header				nvarchar(4000)
				,@body_message_1		nvarchar(max)	= ''
				,@footer				nvarchar(4000)
				,@company_name			nvarchar(250)
				,@company_address		nvarchar(4000)
				,@from_email			nvarchar(250)
				,@email					nvarchar(250)

				if @p_msg = '{}'
				BEGIN
				    					set @header_message = 'NOTIFICATION SUCCESS TRANSAKSI PAYMENT CONFIRM FINANCE ' + @p_payment_code;

					set @header			=	'<table style = "font-size: 20px; background-color:#cceeff; padding-left: 20px;	height:60px; width:100%">
												<tr>
													<td class="title" colspan="2">
														<span class="title">
															<span id="ifinancing"> iFinancing</span>
														</span>
													</td>
												</tr>
											</table>'

					set @body_message_1	=	'<table>
												<tr>
													<td class="title" colspan="2">
														<span class="title">
															<span id="ifinancing"> Dear Sirs/Madam,</span>
														</span>
														</br>
														<span id="ifinancing"> Dengan ini kami informasikan telah sukses dilakukan transaksi '+isnull(@p_payment_code, '') + ' tanggal ' + isnull(convert(varchar, @p_mod_date, 106) + ' ' + convert(varchar, @p_mod_date, 108), '')+' dengan detail sebagai berikut: </span>
													</td>
												</tr>
											</table>
											<p>
												Jumlah Transaksi Sukses: 1
											</p>
											<table >
												<thead style="width: 100%; border-collapse: collapse;">
													<tr>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Tanggal</th>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Monitoring</th>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Keterangan</th>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Pesan</th>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Action</th>
													</tr>
												</thead>
												<tbody>
													<tr>
														<td style="padding: 8px; border: 1px solid #ddd;">'+isnull (convert(varchar, @p_mod_date, 106) + ' ' + convert(varchar, @p_mod_date, 108),'')+'</td>
														<td style="padding: 8px; border: 1px solid #ddd;">Success!</td>
														<td style="padding: 8px; border: 1px solid #ddd;">Kode Payment Confirm '+isnull(@p_payment_code,'')+'</td>
														<td style="padding: 8px; border: 1px solid #ddd;">Success!</td>
														<td style="padding: 8px; border: 1px solid #ddd;">Success!</td>
													</tr>
												</tbody>
											</table>
											</br>
											</br>
											</br>
											';

					set @footer = N'<p></p>
							<p>Terima Kasih,</p>
							<p>iFinancing</p>
							<p></p>
							<p>' + isnull(@company_name, '') + '</p>
							<p>' + isnull(@company_address, '') + '</p>';
				END
				else
				BEGIN
					set @header_message = 'NOTIFICATION RAISERROR TRANSAKSI PAYMENT CONFIRM FINANCE ' + @p_payment_code;

					set @header			=	'<table style = "font-size: 20px; background-color:#cceeff; padding-left: 20px;	height:60px; width:100%">
												<tr>
													<td class="title" colspan="2">
														<span class="title">
															<span id="ifinancing"> iFinancing</span>
														</span>
													</td>
												</tr>
											</table>'

					set @body_message_1	=	'<table>
												<tr>
													<td class="title" colspan="2">
														<span class="title">
															<span id="ifinancing"> Dear Sirs/Madam,</span>
														</span>
														</br>
														<span id="ifinancing"> Dengan ini kami informasikan terdapat error pada transaksi '+isnull(@p_payment_code, '') + ' tanggal ' + isnull(convert(varchar, @p_mod_date, 106) + ' ' + convert(varchar, @p_mod_date, 108), '')+' dengan detail sebagai berikut: </span>
													</td>
												</tr>
											</table>
											<p>
												Jumlah Transaksi Error: 1
											</p>
											<table >
												<thead style="width: 100%; border-collapse: collapse;">
													<tr>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Tanggal</th>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Monitoring</th>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Keterangan</th>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Pesan Error</th>
													  <th style="padding: 8px;  border: 1px solid #ddd;">Action</th>
													</tr>
												</thead>
												<tbody>
													<tr>
														<td style="padding: 8px; border: 1px solid #ddd;">'+isnull (convert(varchar, @p_mod_date, 106) + ' ' + convert(varchar, @p_mod_date, 108),'')+'</td>
														<td style="padding: 8px; border: 1px solid #ddd;">Failed proceed payment to MUFG</td>
														<td style="padding: 8px; border: 1px solid #ddd;">Kode Payment Confirm '+isnull(@p_payment_code,'')+'</td>
														<td style="padding: 8px; border: 1px solid #ddd;">'+isnull(@p_msg,'')+'</td>
														<td style="padding: 8px; border: 1px solid #ddd;">Konfirmasi dan hubungi tim ITD dengan memberikan kode payment</td>
													</tr>
												</tbody>
											</table>
											</br>
											</br>
											</br>
											';

					set @footer = N'<p></p>
							<p>Terima Kasih,</p>
							<p>iFinancing</p>
							<p></p>
							<p>' + isnull(@company_name, '') + '</p>
							<p>' + isnull(@company_address, '') + '</p>';
				END
-------------------------------------------------------------------------



		select	@email = value
		from	ifinsys.dbo.sys_global_param
		where	code = 'EFINPC'
		--set @email = 'fauzan@ims-tec.com'

		select	@from_email = value
        from	ifinsys.dbo.sys_global_param
        where	code = 'ESEND';
-------------------------------------------------------------------------
exec ifinsys.dbo.sys_email_notification_task_insert @p_from_email		= @from_email
															,@p_to_email		= @email
															,@p_to_email_cc		= null --@email_cc
															,@p_to_email_bcc	= null
															,@p_subject			= @header_message
															,@p_header			= @header
															,@p_body1			= @body_message_1
															,@p_body2			= '' --@body_message_2
															,@p_body3			= '' --@body_message_3
															,@p_footer			= @footer
															,@p_attachment		= ''
															,@p_date			= null
															,@p_send_date		= null
															,@p_send_status		= 'HOLD'
															,@p_cre_date		= @p_mod_date
															,@p_cre_by			= @p_mod_by
															,@p_cre_ip_address	= @p_mod_ip_address
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address

	end try
	begin catch
		        declare @error int;

        set @error = @@error;

        if (@error = 2627)
        begin
            set @p_msg = dbo.xfn_get_msg_err_code_already_exist();
        end;

        if (len(@p_msg) <> 0)
        begin
            set @p_msg = 'v' + ';' + @p_msg;
        end;
        else
        begin
            if (error_message() like '%v;%' or error_message() like '%e;%')
            begin
                set @p_msg = error_message();
            end;
            else
            begin
                set @p_msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
            end;
        end;

        raiserror(@p_msg, 16, -1);

        return;
	end catch
END

CREATE PROCEDURE dbo.xsp_email_notif_transaction_update
(
	@p_id					 int
	,@p_mail_sender			 nvarchar(200)
	,@p_mail_to				 nvarchar(200)
	,@p_mail_cc				 nvarchar(100)
	,@p_mail_bcc			 nvarchar(100)
	,@p_mail_subject		 nvarchar(200)
	,@p_mail_body			 nvarchar(4000)
	,@p_mail_file_name		 nvarchar(100)
	,@p_mail_file_path		 nvarchar(250)
	,@p_generate_file_status nvarchar(50)
	,@p_mail_status			 nvarchar(50)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	email_notif_transaction
		set		mail_sender				= @p_mail_sender
				,mail_to				= @p_mail_to
				,mail_cc				= @p_mail_cc
				,mail_bcc				= @p_mail_bcc
				,mail_subject			= @p_mail_subject
				,mail_body				= @p_mail_body
				,mail_file_name			= @p_mail_file_name
				,mail_file_path			= @p_mail_file_path
				,generate_file_status	= @p_generate_file_status
				,mail_status			= @p_mail_status
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

/*
	Created : Yunus Muslim, 21 Desember 2018
*/
CREATE procedure dbo.xsp_sys_email_notification_insert
(
	@p_code			   nvarchar(50)
	,@p_email_subject  nvarchar(100)
	,@p_email_body	   nvarchar(4000)
	,@p_reply_to	   nvarchar(100)
	,@p_flag_1		   nvarchar(1)
	,@p_email_1		   nvarchar(100)
	,@p_flag_2		   nvarchar(1)
	,@p_email_2		   nvarchar(100)
	,@p_flag_3		   nvarchar(1)
	,@p_email_3		   nvarchar(100)
	,@p_flag_4		   nvarchar(1)
	,@p_email_4		   nvarchar(100)
	,@p_flag_5		   nvarchar(1)
	,@p_email_5		   nvarchar(100)
	,@p_email_header   nvarchar(4000)
	,@p_email_footer   nvarchar(4000)
	,@p_description	   nvarchar(4000)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into sys_email_notification
		(
			code
			,email_subject
			,email_body
			,reply_to
			,flag_1
			,email_1
			,flag_2
			,email_2
			,flag_3
			,email_3
			,flag_4
			,email_4
			,flag_5
			,email_5
			,email_header
			,email_footer
			,description
			--				
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,upper(@p_email_subject)
			,upper(@p_email_body)
			,upper(@p_reply_to)
			,@p_flag_1
			,upper(@p_email_1)
			,@p_flag_2
			,upper(@p_email_2)
			,@p_flag_3
			,upper(@p_email_3)
			,@p_flag_4
			,upper(@p_email_4)
			,@p_flag_5
			,upper(@p_email_5)
			,upper(@p_email_header)
			,upper(@p_email_footer)
			,upper(@p_description)
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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

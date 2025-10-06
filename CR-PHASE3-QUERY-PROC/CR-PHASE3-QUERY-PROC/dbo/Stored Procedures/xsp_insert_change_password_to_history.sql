--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE procedure dbo.xsp_insert_change_password_to_history
(
	@p_uid				 nvarchar(10)
	,@p_date_change_pass datetime
	,@old_password		 nvarchar(20)
	,@u_pass			 nvarchar(20)
	,@p_cre_ip_address	 nvarchar(20)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.HISTORY_PASSWORD
		(
			ID
			,DATE_CHANGE_PASS
			,OLDPASS
			,NEWPASS
			,CRE_IP_ADDRESS
		)
		values
		(@p_uid, getdate(), @old_password, @u_pass, @p_cre_ip_address) ;
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

--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE dbo.xsp_master_user_main_login
     @p_uid				as nvarchar(50)
	,@p_password		as nvarchar(50)
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
begin
	declare	@msg	nvarchar(max)

	begin try
		if not exists (select id from dbo.SYS_USER_MAIN where id = @p_uid)
		begin
		
			raiserror('user %s tidak terdaftar!',16,0,@p_uid)
			return

		end
		else
		begin

			declare	@password	[nvarchar](20)

			select	@password	= ou.upass
			from	dbo.SYS_USER_MAIN ou
			where	id	= @p_uid  

			if @password <> @p_password
			begin
		
				raiserror('password salah!',16,0,@p_uid)
				return

			end
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

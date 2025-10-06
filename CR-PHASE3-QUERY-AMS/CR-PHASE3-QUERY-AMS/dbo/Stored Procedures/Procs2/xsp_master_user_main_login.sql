--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE dbo.xsp_master_user_main_login
     @p_uid				as nvarchar(50)
	,@p_password		as nvarchar(50)
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
begin

	if not exists (select id from dbo.SYS_USER_MAIN where id = @p_uid)
	begin
		
		raiserror('user %s not registered!',16,0,@p_uid)
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
		
			raiserror('invalid password!',16,0,@p_uid)
			return

		end
        end
	
end    

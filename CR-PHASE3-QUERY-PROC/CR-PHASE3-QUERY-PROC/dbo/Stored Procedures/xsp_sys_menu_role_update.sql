CREATE PROCEDURE dbo.xsp_sys_menu_role_update
(
	@p_menu_code	   nvarchar(50)
	,@p_role_code	   nvarchar(50)
	,@p_role_name	   nvarchar(250)
	,@p_role_access    nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	sys_menu_role
			where	role_code <> @p_role_code and role_name = @p_role_name
		)
		begin
			set @msg = 'Name already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	sys_menu_role
		set		role_name		= UPPER(@p_role_name)
				,role_access	= @p_role_access
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	role_code				= @p_role_code ;
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
end ;

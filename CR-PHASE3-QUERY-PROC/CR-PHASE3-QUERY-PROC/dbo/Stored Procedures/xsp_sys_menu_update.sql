CREATE PROCEDURE dbo.xsp_sys_menu_update
(
	@p_code				 nvarchar(50)
	,@p_name			 nvarchar(250)
	,@p_abbreviation	 nvarchar(50)  = ''
	,@p_module_code		 nvarchar(50)  = ''
	,@p_parent_menu_code nvarchar(50)  = ''
	,@p_url_menu		 nvarchar(200) = ''
	,@p_order_key		 nvarchar(200)
	,@p_css_icon		 nvarchar(250) = ''
	,@p_is_active		 nvarchar(1)
	,@p_type			 nvarchar(5)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		update	sys_menu
		set		name				= UPPER(@p_name)
				,abbreviation		= @p_abbreviation
				,module_code        = @p_module_code
				,parent_menu_code	= @p_parent_menu_code
				,url_menu			= @p_url_menu
				,order_key			= @p_order_key
				,css_icon			= @p_css_icon
				,is_active			= @p_is_active
				,type				= @p_type
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
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

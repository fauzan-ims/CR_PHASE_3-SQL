CREATE PROCEDURE dbo.xsp_sys_todo_update
(
	@p_code			   nvarchar(50)
	,@p_todo_name	   nvarchar(250)
	,@p_link_address   nvarchar(250)
	,@p_query		   nvarchar(250)
	,@p_is_active	   nvarchar(1)
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

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		update	dbo.sys_todo
		set		todo_name        = upper(@p_todo_name)
				,link_address    = @p_link_address
				,query           = @p_query
				,is_active       = @p_is_active
				--
				,mod_date        = @p_mod_date
				,mod_by          = @p_mod_by
				,mod_ip_address  = @p_mod_ip_address
		where	code			 = @p_code ;
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

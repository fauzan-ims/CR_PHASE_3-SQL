CREATE PROCEDURE dbo.xsp_sys_role_group_detail_delete
(
	@p_role_group_code nvarchar(50)
	,@p_role_code  nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete sys_role_group_detail
		where	role_group_code	  = @p_role_group_code
				and role_code = @p_role_code ;
	end try
	begin catch
		declare  @error int
		set  @error = @@error
	 
		if ( @error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end ;
		else if ( @error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used();
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;

		raiserror(@msg, 16, -1) ;

		return ;  
	end catch ;
end ;

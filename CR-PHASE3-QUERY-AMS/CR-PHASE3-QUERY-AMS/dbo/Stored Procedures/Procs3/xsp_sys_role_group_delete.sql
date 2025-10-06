CREATE PROCEDURE dbo.xsp_sys_role_group_delete
(
	@p_code				nvarchar(50)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;
	
	begin try
		if exists (select	1
					from	dbo.sys_role_group
					where	application_code = 'SA'
					and		code = @p_code
					and		company_code = @p_company_code)
		begin
			set @msg = 'Super Admin can`t be deleted';
			raiserror(@msg, 16, -1);
		end
		else 
		begin
			delete sys_role_group
			where	code = @p_code
			and		company_code = @p_company_code ;
		end
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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

CREATE PROCEDURE dbo.xsp_master_task_user_detail_delete
(
	@p_code				nvarchar(50)
	,@p_role_group_code	nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		if exists (select 1 from dbo.sys_company_user_main_group_sec where role_group_code = @p_role_group_code)
		begin
		    set @msg = 'Data already used. Please check your setting on Company User List';
			raiserror(@msg, 16, -1) ;
		end
        
		delete master_task_user_detail
		where	code = @p_code ;

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

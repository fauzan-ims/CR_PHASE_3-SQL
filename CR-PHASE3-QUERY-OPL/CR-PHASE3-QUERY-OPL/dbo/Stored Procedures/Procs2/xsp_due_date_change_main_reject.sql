CREATE PROCEDURE dbo.xsp_due_date_change_main_reject
(
	@p_code						nvarchar(50)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)	
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg				nvarchar(max)
			,@change_amount		decimal(18,2)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
			,@currency			nvarchar(10)
			,@remark			nvarchar(4000)
			,@agreement_no		nvarchar(50)
				
	
	begin try
		
		if exists(select 1 from dbo.due_date_change_main where code = @p_code and change_status <> 'ON PROCESS')
		begin
			set @msg ='Data already proceed';
		    raiserror(@msg,16,1) ;
		end
        else
		begin
			select	@agreement_no = agreement_no
			from	dbo.due_date_change_main
			where	code = @p_code ;

			update dbo.due_date_change_main
			set		change_status   = 'REJECT'
					,mod_by			= @p_mod_by
					,mod_date		= @p_mod_date
					,mod_ip_address	= @p_mod_ip_address
			where   code			= @p_code

			-- update lms status
			exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no	= @agreement_no
														  ,@p_status		= N'' 
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

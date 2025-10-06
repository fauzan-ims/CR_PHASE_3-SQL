/*
	Created : Yunus Muslim, 16 April 2020
*/
CREATE PROCEDURE dbo.xsp_employee_main_notification_broadcast 
(
	@p_notification_code	nvarchar(50)
	,@p_notif_remark		nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@emp_code		nvarchar(50);

	begin try

		declare emp_cur	cursor local fast_forward for

		select	emp_code
		from	dbo.sys_employee_notification_subscription
		where	notif_code	= @p_notification_code
						
		open emp_cur
		fetch next from emp_cur  
		into	@emp_code
						
		while @@fetch_status = 0
		begin
			
			exec dbo.xsp_sys_employee_notification_insert @p_id					= 0
														  ,@p_emp_code			= @emp_code
														  ,@p_notif_message		= @p_notif_remark 
														  ,@p_is_read			= N'0' 
														  ,@p_log_date			= @p_cre_date
														  ,@p_cre_date			= @p_cre_date		
														  ,@p_cre_by			= @p_cre_by		
														  ,@p_cre_ip_address	= @p_cre_ip_address
														  ,@p_mod_date			= @p_mod_date		
														  ,@p_mod_by			= @p_mod_by		
														  ,@p_mod_ip_address	= @p_mod_ip_address
			
				
			fetch next from emp_cur  
			into @emp_code
			
		end
				
		close emp_cur
		deallocate emp_cur

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

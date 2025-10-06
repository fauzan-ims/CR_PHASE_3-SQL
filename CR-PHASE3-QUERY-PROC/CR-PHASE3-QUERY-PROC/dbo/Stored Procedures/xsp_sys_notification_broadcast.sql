CREATE PROCEDURE dbo.xsp_sys_notification_broadcast 
(
	@p_code			nvarchar(50)
	,@p_doc_code	nvarchar(100)
	,@p_branch_code	nvarchar(10)= null
	,@p_user_id		nvarchar(15)= null
) as
begin

	
	declare	@emp_code		nvarchar(10)
			,@emp_message	nvarchar(1000)
			,@is_active		nvarchar(1)
			,@msg			nvarchar(max)

	begin try

		select	@emp_message	= description
				,@is_active		= is_active
		from	dbo.sys_notification
		where	code			= @p_code

		if (@is_active = '1')
		begin
		
			set		@emp_message = ltrim(rtrim(@emp_message)) + '. Document No : ' + @p_doc_code

			declare	c_emp cursor for
			select	en.emp_code
			from	sys_employee_notification_subscription en
					inner join dbo.sys_branch_employee be on (be.emp_code = en.emp_code)
			where	notifi_code		= @p_code
			and		action_flag		= '1'
			and		(be.branch_code = isnull(@p_branch_code,be.branch_code))
			and		(en.emp_code = isnull(@p_user_id,en.emp_code) )


			open	c_emp
			fetch	c_emp
			into	@emp_code

			while @@fetch_status = 0
			begin
			
				insert into sys_employee_notification
				(
					emp_code
					,notifi_message
					,is_read
					,log_date
				)
				values
				(
					@emp_code
					,@emp_message
					,'0'
					,getdate()
				)
			
				fetch	c_emp
				into	@emp_code

			end

			close		c_emp
			deallocate	c_emp
	
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

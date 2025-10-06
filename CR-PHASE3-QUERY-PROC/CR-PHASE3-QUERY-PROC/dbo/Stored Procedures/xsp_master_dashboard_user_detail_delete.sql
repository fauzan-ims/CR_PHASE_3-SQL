CREATE PROCEDURE dbo.xsp_master_dashboard_user_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg			 nvarchar(max)
			,@dashboard_code nvarchar(50)
			,@employee_code	 nvarchar(50)
			,@sum			 int
			,@order_key		 int ;

	begin try
		select	@employee_code = employee_code
				,@order_key = order_key
		from	dbo.master_dashboard_user
		where	id = @p_id ;

		select	@sum = count(id)
		from	dbo.master_dashboard_user
		where	employee_code = @employee_code ;

		if @sum = 1
		begin
			update	dbo.master_dashboard_user
			set		dashboard_code = null
					,order_key = null
			where	id = @p_id ;
		end ;
		else
		begin
			update	dbo.master_dashboard_user
			set		order_key = order_key - 1
			where	order_key		  > @order_key
					and employee_code = @employee_code ;

			delete dbo.master_dashboard_user
			where	id = @p_id ;
		end ;
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

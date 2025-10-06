CREATE PROCEDURE dbo.xsp_master_dashboard_user_update_order_key
(
	@p_id			   bigint
	,@p_employee_code  nvarchar(50)
	,@p_dashboard_code nvarchar(50)
	,@p_order_key	   int
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max)
			,@old_order_no int
			,@count		   int ;

	begin try
		select	@count = count(id)
		from	dbo.master_dashboard_user
		where	employee_code = @p_employee_code ;

		if (@p_order_key <= 0)
		begin
			set @msg = 'Order No must be greater than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@count < @p_order_key)
		begin
			set @msg = 'Maximum Order No is ' + cast(@count as nvarchar(3)) ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@old_order_no = order_key
		from	dbo.master_dashboard_user
		where	id = @p_id ;

		if @old_order_no > @p_order_key
		begin
			update	dbo.master_dashboard_user
			set		order_key = order_key + 1
			where	order_key between @p_order_key and @old_order_no ;
		end ;
		else if @old_order_no < @p_order_key
		begin
			update	dbo.master_dashboard_user
			set		order_key = order_key - 1
			where	order_key between @old_order_no and @p_order_key ;
		end ;

		update	dbo.master_dashboard_user
		set		order_key		= @p_order_key
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;
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

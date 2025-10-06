CREATE PROCEDURE dbo.xsp_cashier_main_update
(
	@p_code						nvarchar(50)
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_cashier_status			nvarchar(10)
	,@p_cashier_open_date		datetime
	,@p_cashier_close_date		datetime = null
	,@p_cashier_innitial_amount	decimal(18, 2) 
	,@p_cashier_open_amount		decimal(18, 2)
	,@p_cashier_db_amount		decimal(18, 2)
	,@p_cashier_cr_amount		decimal(18, 2)
	,@p_cashier_close_amount	decimal(18, 2)
	,@p_employee_code			nvarchar(50)
	,@p_employee_name			nvarchar(250)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@cashier_open_date		datetime;

	select		top 1 
				@cashier_open_date		= cashier_open_date
	from		dbo.cashier_main
	where		employee_code = @p_employee_code
				and	cashier_status = 'CLOSE'
	order by	cashier_close_date desc	
				,mod_date desc

	begin try
		if (@p_cashier_open_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
					raiserror(@msg ,16,-1)
				end
		
		if (@p_cashier_open_date < @cashier_open_date) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date','Previous Open Date');
			raiserror(@msg ,16,-1)
		end

		if	(@p_cashier_innitial_amount < 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Innitial Amount','0');
			raiserror(@msg ,16,-1)
		end

		set @p_cashier_close_amount = isnull(@p_cashier_innitial_amount,0) + isnull(@p_cashier_open_amount,0) + isnull(@p_cashier_db_amount,0) - isnull(@p_cashier_cr_amount,0)

		update	cashier_main
		set		branch_code					= @p_branch_code
				,branch_name				= @p_branch_name
				,cashier_status				= @p_cashier_status
				,cashier_open_date			= @p_cashier_open_date
				,cashier_close_date			= @p_cashier_close_date
				,cashier_innitial_amount	= @p_cashier_innitial_amount
				,cashier_open_amount		= @p_cashier_open_amount
				,cashier_db_amount			= @p_cashier_db_amount
				,cashier_cr_amount			= @p_cashier_cr_amount
				,cashier_close_amount		= @p_cashier_close_amount
				,employee_code				= @p_employee_code
				,employee_name				= @p_employee_name
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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

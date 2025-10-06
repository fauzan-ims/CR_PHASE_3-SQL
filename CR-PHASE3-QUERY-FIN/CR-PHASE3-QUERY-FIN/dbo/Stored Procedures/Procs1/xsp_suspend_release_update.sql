CREATE PROCEDURE dbo.xsp_suspend_release_update
(
	@p_code						  nvarchar(50)
	,@p_branch_code				  nvarchar(50)
	,@p_branch_name				  nvarchar(250)
	,@p_release_status			  nvarchar(20)
	,@p_release_date			  datetime
	,@p_release_amount			  decimal(18, 2)
	,@p_release_remarks			  nvarchar(4000)
	,@p_release_bank_name		  nvarchar(250)
	,@p_release_bank_account_no	  nvarchar(50)
	,@p_release_bank_account_name nvarchar(250)
	,@p_suspend_code			  nvarchar(50)
	,@p_suspend_currency_code	  nvarchar(3)
	,@p_suspend_amount			  decimal(18, 2)
	--
	,@p_mod_date				  datetime
	,@p_mod_by					  nvarchar(15)
	,@p_mod_ip_address			  nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max) 
			,@previous_suspend_code		nvarchar(50);

	begin try
		if (@p_release_date > dbo.xfn_get_system_date()) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
			raiserror(@msg ,16,-1)
		end

		if (@p_release_amount > @p_suspend_amount)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Release Amount ','Suspend Amount');
			raiserror(@msg ,16,-1)
		end

		if (@p_release_amount <= 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Release Amount ','0');
			raiserror(@msg ,16,-1)
		end

		select	@previous_suspend_code	= suspend_code 
		from	dbo.suspend_release	
		where	code	= @p_code

		update	suspend_release
		set		branch_code					= @p_branch_code
				,branch_name				= @p_branch_name
				,release_status				= @p_release_status
				,release_date				= @p_release_date
				,release_amount				= @p_release_amount
				,release_remarks			= @p_release_remarks
				,release_bank_name			= @p_release_bank_name
				,release_bank_account_no	= @p_release_bank_account_no
				,release_bank_account_name	= @p_release_bank_account_name
				,suspend_code				= @p_suspend_code
				,suspend_currency_code		= @p_suspend_currency_code
				,suspend_amount				= @p_suspend_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;

		update	dbo.suspend_main
		set		transaction_code	= @p_code
				,transaction_name	= 'RELEASE'
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_suspend_code

		if (@previous_suspend_code <> @p_suspend_code)
		begin
			update	dbo.suspend_main
			set		transaction_code	= null
					,transaction_name	= null
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @previous_suspend_code
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
end ;

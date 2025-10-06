CREATE PROCEDURE dbo.xsp_due_date_change_main_update
(
	@p_code					  nvarchar(50)
	,@p_change_date			  datetime
	,@p_change_remarks		  nvarchar(4000)
	,@p_billing_type		  nvarchar(15)
	,@p_billing_mode		  nvarchar(15)
	,@p_is_prorate			  nvarchar(15)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
	,@p_billing_mode_date	  INT = 0

)
as
begin
	declare @msg					nvarchar(max)
			,@min_installment_no	int
			,@max_installment_no    int
			,@max_due_date			datetime
			,@old_due_date			datetime
			,@change_exp_date		datetime 
			,@total_amount			decimal(18, 2);

	begin try

		if (@p_billing_mode IN ('BEFORE DUE','BY DATE'))
		begin
			if(@p_billing_mode_date <= 0)
			begin
				set @msg = 'Date Cannot Be 0'
				raiserror (@msg, 16, -1)
			end
		
			if(@p_billing_mode_date > 31)
			begin
				set @msg = 'Date Cannot Be More Than 31'
				raiserror (@msg, 16, -1)
			end
		end
		
	
		select	@change_exp_date = dateadd(day, cast(value as int), @p_change_date)
		from	dbo.sys_global_param
		where	code = 'EXPOPL' ;

		update	due_date_change_main
		set		change_date				= @p_change_date
				,change_exp_date		= @change_exp_date
				,change_remarks			= @p_change_remarks
				,billing_type			= @p_billing_type
				,billing_mode			= @p_billing_mode
				,is_prorate				= @p_is_prorate	
				,billing_mode_date		= @p_billing_mode_date
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;

		update	dbo.due_date_change_detail
		set		billing_mode		= @p_billing_mode				
				,prorate			= @p_is_prorate					
				,billing_mode_date	= @p_billing_mode_date
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	due_date_change_code = @p_code
		and		is_change = '1' or is_change_billing_date = '1'
		
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

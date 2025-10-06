CREATE PROCEDURE dbo.xsp_suspend_revenue_detail_update
(
	@p_id					 bigint
	,@p_suspend_revenue_code nvarchar(50)
	--,@p_suspend_code		 nvarchar(50)
	,@p_suspend_amount		 decimal(18, 2)
	,@p_revenue_amount		 decimal(18, 2)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max) 
			,@sum_amount	decimal(18, 2) ;

	begin try
		if (@p_revenue_amount > @p_suspend_amount)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Revenue Amount ','Suspend Amount');
			raiserror(@msg ,16,-1)
		end

		if (@p_revenue_amount <= 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Revenue Amount ','0');
			raiserror(@msg ,16,-1)
		end

		update	suspend_revenue_detail
		set		suspend_revenue_code	= @p_suspend_revenue_code
				--,suspend_code			= @p_suspend_code
				--,suspend_amount		= @p_suspend_amount
				,revenue_amount			= @p_revenue_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

		select	@sum_amount		= sum(revenue_amount)
		from	dbo.suspend_revenue_detail
		where	suspend_revenue_code = @p_suspend_revenue_code

		update	dbo.suspend_revenue
		set		revenue_amount	= isnull(@sum_amount,0)
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code			= @p_suspend_revenue_code

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

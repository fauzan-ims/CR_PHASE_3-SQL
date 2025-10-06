CREATE PROCEDURE dbo.xsp_insurance_register_loading_update
(
	@p_id					bigint
	,@p_register_code		nvarchar(50)
	,@p_loading_code		nvarchar(50)
	,@p_year_period			int
	,@p_initial_buy_rate	decimal
	,@p_initial_sell_rate	decimal
	,@p_initial_buy_amount	decimal
	,@p_initial_sell_amount decimal
	,@p_total_buy_amount	decimal
	,@p_total_sell_amount	decimal
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	insurance_register_loading
		set		register_code			= @p_register_code
				,loading_code			= @p_loading_code
				,year_period			= @p_year_period
				,initial_buy_rate		= @p_initial_buy_rate
				,initial_sell_rate		= @p_initial_sell_rate
				,initial_buy_amount		= @p_initial_buy_amount
				,initial_sell_amount	= @p_initial_sell_amount
				,total_buy_amount		= @p_total_buy_amount
				,total_sell_amount		= @p_total_sell_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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


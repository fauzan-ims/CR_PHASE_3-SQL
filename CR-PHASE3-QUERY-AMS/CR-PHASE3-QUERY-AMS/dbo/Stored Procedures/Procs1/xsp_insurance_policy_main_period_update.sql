CREATE PROCEDURE dbo.xsp_insurance_policy_main_period_update
(
	@p_code						 nvarchar(50)
	,@p_policy_code				 nvarchar(50)
	,@p_sum_insured				 decimal
	,@p_rate_depreciation		 decimal
	,@p_coverage_code			 nvarchar(50)
	,@p_year_periode			 int
	,@p_initial_buy_rate		 decimal
	,@p_initial_sell_rate		 decimal
	,@p_initial_buy_amount		 decimal
	,@p_initial_sell_amount		 decimal
	,@p_initial_discount_pct	 decimal
	,@p_initial_discount_amount	 decimal
	,@p_initial_admin_fee_amount decimal
	,@p_initial_stamp_fee_amount decimal
	,@p_adjustment_amount		 decimal
	,@p_buy_amount				 decimal
	,@p_sell_amount				 decimal
	,@p_total_buy_amount		 decimal
	,@p_total_sell_amount		 decimal
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	insurance_policy_main_period
		set		policy_code					= @p_policy_code
				,sum_insured				= @p_sum_insured
				,rate_depreciation			= @p_rate_depreciation
				,coverage_code				= @p_coverage_code
				,year_periode				= @p_year_periode
				,initial_buy_rate			= @p_initial_buy_rate
				,initial_sell_rate			= @p_initial_sell_rate
				,initial_buy_amount			= @p_initial_buy_amount
				,initial_sell_amount		= @p_initial_sell_amount
				,initial_discount_pct		= @p_initial_discount_pct
				,initial_discount_amount	= @p_initial_discount_amount
				,initial_admin_fee_amount	= @p_initial_admin_fee_amount
				,initial_stamp_fee_amount	= @p_initial_stamp_fee_amount
				,adjustment_amount			= @p_adjustment_amount
				,buy_amount					= @p_buy_amount
				,sell_amount				= @p_sell_amount
				,total_buy_amount			= @p_total_buy_amount
				,total_sell_amount			= @p_total_sell_amount
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


CREATE PROCEDURE dbo.xsp_insurance_payment_schedule_renewal_update
(
	@p_code						   nvarchar(50)
	,@p_payment_renual_status	   nvarchar(10)
	,@p_policy_code				   nvarchar(50)
	,@p_year_period				   int
	,@p_policy_eff_date			   datetime
	,@p_policy_exp_date			   datetime
	,@p_sell_amount				   decimal(18, 2)
	,@p_discount_amount			   decimal(18, 2)
	,@p_buy_amount				   decimal(18, 2)
	,@p_adjustment_sell_amount	   decimal(18, 2)
	,@p_adjustment_discount_amount decimal(18, 2)
	,@p_adjustment_buy_amount	   decimal(18, 2)
	,@p_total_amount			   decimal(18, 2)
	,@p_ppn_amount				   decimal(18, 2)
	,@p_pph_amount				   decimal(18, 2)
	,@p_total_payment_amount	   decimal(18, 2)
	,@p_payment_request_code	   nvarchar(50)
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	insurance_payment_schedule_renewal
		set		payment_renual_status = @p_payment_renual_status
				,policy_code = @p_policy_code
				,year_period = @p_year_period
				,policy_eff_date = @p_policy_eff_date
				,policy_exp_date = @p_policy_exp_date
				,sell_amount = @p_sell_amount
				,discount_amount = @p_discount_amount
				,buy_amount = @p_buy_amount
				,adjustment_sell_amount = @p_adjustment_sell_amount
				,adjustment_discount_amount = @p_adjustment_discount_amount
				,adjustment_buy_amount = @p_adjustment_buy_amount
				,total_amount = @p_total_amount
				,ppn_amount = @p_ppn_amount
				,pph_amount = @p_pph_amount
				,total_payment_amount = @p_total_payment_amount
				,payment_request_code = @p_payment_request_code
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;
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

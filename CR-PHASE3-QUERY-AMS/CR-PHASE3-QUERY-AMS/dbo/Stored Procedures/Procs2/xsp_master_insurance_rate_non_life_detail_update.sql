CREATE PROCEDURE dbo.xsp_master_insurance_rate_non_life_detail_update
(
	@p_id				   bigint
	,@p_rate_non_life_code nvarchar(50)
	,@p_sum_insured_from   decimal(18, 2)
	,@p_sum_insured_to	   decimal(18, 2)
	,@p_is_commercial	   nvarchar(1)
	,@p_is_authorized	   nvarchar(1)
	,@p_calculate_by	   nvarchar(10)
	,@p_buy_rate		   decimal(9, 6)
	,@p_buy_amount		   decimal(18, 2)
	,@p_discount_pct	   decimal(9, 6)
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_commercial = 'T'
		set @p_is_commercial = '1' ;
	else
		set @p_is_commercial = '0' ;

	if @p_is_authorized = 'T'
		set @p_is_authorized = '1' ;
	else
		set @p_is_authorized = '0' ;

	begin TRY
		if (@p_sum_insured_from > @p_sum_insured_to)
		begin
			set @msg = 'Sum Insured From cannot be greater than Sum Insured To' ;

			raiserror(@msg, 16, -1) ;
		end
        
  --      if (@p_buy_rate > @p_sell_rate)
		--begin
		--	set @msg = 'Buy Rate cannot be greater than Sell Rate' ;

		--	raiserror(@msg, 16, -1) ;
		--end
  --      if (@p_buy_amount > @p_sell_amount)
		--begin
		--	set @msg = 'Buy Amount cannot be greater than Sell Amount' ;

		--	raiserror(@msg, 16, -1) ;
		--end
        
		if exists
		(
			select	1
			from	master_insurance_rate_non_life_detail
			where	id							<> @p_id
					and rate_non_life_code	    = @p_rate_non_life_code
					and is_authorized			= @p_is_authorized
					and is_commercial			= @p_is_commercial
					and (
							sum_insured_from		   <= @p_sum_insured_from
							and @p_sum_insured_from <= sum_insured_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_insurance_rate_non_life_detail
			where	id							<> @p_id
					and rate_non_life_code	    = @p_rate_non_life_code
					and is_authorized			= @p_is_authorized
					and is_commercial			= @p_is_commercial
					and (
							sum_insured_from	 <= @p_sum_insured_to
							and @p_sum_insured_to <= sum_insured_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_insurance_rate_non_life_detail
			where	id							<> @p_id
					and rate_non_life_code	    = @p_rate_non_life_code
					and is_authorized			= @p_is_authorized
					and is_commercial			= @p_is_commercial
					and (
							@p_sum_insured_from	<= sum_insured_from
							and sum_insured_from <= @p_sum_insured_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_insurance_rate_non_life_detail
			where	id							<> @p_id
					and rate_non_life_code	    = @p_rate_non_life_code
					and is_authorized			= @p_is_authorized
					and is_commercial			= @p_is_commercial
					and (
							@p_sum_insured_to  <= sum_insured_to
							and sum_insured_to <= @p_sum_insured_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;
		update	master_insurance_rate_non_life_detail
		set		rate_non_life_code	= @p_rate_non_life_code
				,sum_insured_from	= @p_sum_insured_from
				,sum_insured_to		= @p_sum_insured_to
				,is_commercial		= @p_is_commercial
				,is_authorized		= @p_is_authorized
				,calculate_by		= @p_calculate_by
				,buy_rate			= @p_buy_rate
				,sell_rate			= @p_buy_rate
				,buy_amount			= @p_buy_amount
				,sell_amount		= @p_buy_amount
				,discount_pct		= @p_discount_pct
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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





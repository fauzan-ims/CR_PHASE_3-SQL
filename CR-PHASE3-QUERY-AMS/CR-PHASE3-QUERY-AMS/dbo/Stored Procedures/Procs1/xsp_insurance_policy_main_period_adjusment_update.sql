/*
	alterd : Nia, 27 Mei 2020
*/
/*
	alterd : Nia, 28 Mei 2020
*/
CREATE PROCEDURE dbo.xsp_insurance_policy_main_period_adjusment_update
(
	@p_id						   bigint
	,@p_adjustment_buy_amount	   decimal(18, 2)
	,@p_adjustment_admin_amount	   decimal(18, 2)
	,@p_adjustment_discount_amount decimal(18, 2)
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
		    ,@policy_code						nvarchar(50)
			,@year_periode						int
			,@total_buy_amount_period			decimal(18,2)
			,@total_sell_amount_period          decimal(18,2)
			,@total_admin_period				decimal(18,2)
			,@total_stamp_period				decimal(18,2)
			,@initial_discount_amount_period	decimal(18,2)
			,@total_buy_amount_loading			decimal(18,2)
			,@total_sell_amount_loading			decimal(18,2)
			,@ppn_amount						decimal(18,2)
			,@pph_amount						decimal(18,2)
			,@adjustment_buy_amount				decimal(18,2)
			,@adjustment_admin_amount			decimal(18,2)
			,@adjustment_discount_amount		decimal(18,2)

	begin try
		update	insurance_policy_main_period_adjusment
		set		
				adjustment_buy_amount		= @p_adjustment_buy_amount
				,adjustment_admin_amount	= @p_adjustment_admin_amount
				,adjustment_discount_amount = @p_adjustment_discount_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id ;
		
		--adjustment
		select  @policy_code				   = policy_code
				,@year_periode				   = year_periode
	   from		dbo.insurance_policy_main_period_adjusment
	   where	id	= @p_id
	   
		if exists (select 1 from dbo.insurance_policy_main  where code = @policy_code and policy_payment_type = 'FTAP')
		begin
			--period
			select	@total_buy_amount_period			= sum(total_buy_amount)
					--,@total_sell_amount_period			= sum(total_sell_amount)
					--,@total_admin_period				= sum(initial_admin_fee_amount)
					--,@total_admin_period				= sum(initial_admin_fee_amount)
					--,@total_stamp_period				= sum(initial_stamp_fee_amount)
					--,@initial_discount_amount_period	= sum(initial_discount_amount)
			from	dbo.insurance_policy_main_period
			where	policy_code							= @policy_code 
			and		year_periode						= '1'
	   
			--loading
			select	@total_buy_amount_loading			= isnull(sum(total_buy_amount),0)
					,@total_sell_amount_loading			= isnull(sum(total_sell_amount),0)
			from	dbo.insurance_policy_main_loading
			where	policy_code							= @policy_code 
			and		year_period							= '1'

			--adjustment
			select	@adjustment_buy_amount				= sum(adjustment_buy_amount		)
					,@adjustment_admin_amount			= sum(adjustment_admin_amount	)
					,@adjustment_discount_amount		= sum(adjustment_discount_amount)
			from	dbo.insurance_policy_main_period_adjusment
			where	policy_code							= @policy_code 
			and		year_periode						= '1'
		
		end
        else
        begin
			  --period
			select	@total_buy_amount_period			= sum(total_buy_amount)
					--,@total_sell_amount_period			= sum(total_sell_amount)
					--,@total_admin_period				= sum(initial_admin_fee_amount)
					--,@total_stamp_period				= sum(initial_stamp_fee_amount)
					--,@initial_discount_amount_period	= sum(initial_discount_amount)
			from	dbo.insurance_policy_main_period
			where	policy_code							= @policy_code 
	   
			--loading
			select	@total_buy_amount_loading			= isnull(sum(total_buy_amount),0)
					,@total_sell_amount_loading			= isnull(sum(total_sell_amount),0)
			from	dbo.insurance_policy_main_loading
			where	policy_code							= @policy_code  

			--loading
			select	@adjustment_buy_amount				= sum(adjustment_buy_amount		 )
					,@adjustment_admin_amount			= sum(adjustment_admin_amount	 )
					,@adjustment_discount_amount		= sum(adjustment_discount_amount )
			from	dbo.insurance_policy_main_period_adjusment
			where	policy_code							= @policy_code 

		end

		
		set @ppn_amount = dbo.xfn_get_ppn(@initial_discount_amount_period+ ISNULL(@adjustment_discount_amount,0)) --ROUND(((@initial_discount_amount_period+ ISNULL(@adjustment_discount_amount,0))*dbo.xfn_get_ppn(@initial_discount_amount_period)),0)
		set @pph_amount = dbo.xfn_get_pph(@initial_discount_amount_period+ ISNULL(@adjustment_discount_amount,0)) --ROUND(((@initial_discount_amount_period+ ISNULL(@adjustment_discount_amount,0))*dbo.xfn_get_pph(@initial_discount_amount_period)),0)
		--select @ppn_amount,@pph_amount
	   update	dbo.insurance_policy_main
	   set		total_premi_buy_amount		= @total_buy_amount_period			+ @total_buy_amount_loading + @initial_discount_amount_period	+ @adjustment_buy_amount	- @total_admin_period - @total_stamp_period
				,total_discount_amount		= @initial_discount_amount_period	+ @p_adjustment_discount_amount 
				,total_adjusment_amount		= @adjustment_buy_amount			+ @adjustment_discount_amount + @adjustment_admin_amount
		
				,total_net_premi_amount		= @total_buy_amount_period			+ @total_buy_amount_loading		+ @adjustment_buy_amount + @adjustment_discount_amount + @adjustment_admin_amount - @ppn_amount + @pph_amount--  
				,stamp_fee_amount			= @total_stamp_period
				,admin_fee_amount			= @total_admin_period 
	   where code = @policy_code
	    
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



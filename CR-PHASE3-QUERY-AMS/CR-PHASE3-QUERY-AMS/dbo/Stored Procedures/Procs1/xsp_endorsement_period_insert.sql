CREATE PROCEDURE dbo.xsp_endorsement_period_insert
(
	@p_id							  bigint = 0 output
	,@p_endorsement_code			  nvarchar(50)
	,@p_old_or_new					  nvarchar(3) 
	,@p_sum_insured					  decimal(18, 2)
	--,@p_rate_depreciation			  decimal(9, 6)
	,@p_coverage_code				  nvarchar(50)
	,@p_year_period					  int
	--
	,@p_cre_date					  datetime
	,@p_cre_by						  nvarchar(15)
	,@p_cre_ip_address				  nvarchar(15)
	,@p_mod_date					  datetime
	,@p_mod_by						  nvarchar(15)
	,@p_mod_ip_address				  nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max) 
			,@collateral_category_code			nvarchar(50)
			,@insurance_type					nvarchar(10)
			,@insurance_code					nvarchar(50)
			,@sppa_code							nvarchar(50)
			,@main_coverage						nvarchar(1)
			,@initial_admin_fee_amount			decimal(18, 2)
			,@initial_sell_admin_fee_amount     decimal(18, 2)
			,@initial_stamp_fee_amount     		decimal(18, 2)
			,@initial_buy_rate		            decimal(9, 6)  = 0
			,@initial_sell_rate		            decimal(9, 6)  = 0
			,@initial_buy_amount	            decimal(18, 2) = 0
			,@initial_sell_amount	            decimal(18, 2) = 0
			,@initial_discount_pct				decimal(18, 2) = 0
			,@initial_discount_amount           decimal(18, 2) = 0
			,@sum_insured						decimal(18, 2)
			,@buy_amount					    decimal(18, 2) = 0
			,@sell_amount					    decimal(18, 2) = 0
			,@total_buy_amount				    decimal(18, 2) = 0
			,@total_sell_amount				    decimal(18, 2) = 0 
			,@rate_depreciation					decimal(9, 6)  = 0
			,@depreciation_code					nvarchar(50)
			,@new_eff_date						datetime
			,@new_exp_date						datetime;

	begin try
		
		select	@new_eff_date = eff_date
				,@new_exp_date = exp_date
		from	dbo.endorsement_detail
		where	endorsement_code = @p_endorsement_code
				and old_or_new	 = 'NEW' ;
		
		select @main_coverage = is_main_coverage
		from   dbo.master_coverage
		where  code = @p_coverage_code

		select @insurance_type  = ipm.insurance_type
			   ,@insurance_code = ipm.insurance_code
		from   dbo.insurance_policy_main ipm
			   inner join dbo.endorsement_main em on (em.policy_code = ipm.code)
		where  em.code = @p_endorsement_code
		
		--select depreciation code
		--select	@depreciation_code = ipm.depreciation_code
		--from	dbo.endorsement_main em
		--		inner join dbo.insurance_policy_main ipm on (ipm.code = em.policy_code)
		--where	em.code = @p_endorsement_code ;

		--set depreciation rate
		--select @rate_depreciation	= rate
		--	   ,@sum_insured		= @p_sum_insured * (rate/100.00)
		--from	master_depreciation_detail
		--where	depreciation_code	= @depreciation_code
		--and		tenor				= (@p_year_period * 12);  
		     
		if (@p_year_period > ceiling((datediff(year, @new_eff_date, @new_exp_date) * 1.0)))
		begin
			set @msg = 'Period (Year) must be less or equal than Period (Month)' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists (select 1 from dbo.endorsement_period where id = @p_id and endorsement_code = @p_endorsement_code and coverage_code = @p_coverage_code and year_period = @p_year_period and old_or_new = @p_old_or_new)
		begin
			set @msg = 'Coverage already exist' ;

			raiserror(@msg, 16, -1) ;
		end
		if exists (select 1 from  dbo.master_coverage where code = @p_coverage_code and is_main_coverage = '1')
		begin
			if exists(select 1 from dbo.endorsement_period where endorsement_code = @p_endorsement_code and year_period = @p_year_period and old_or_new = @p_old_or_new)
			begin
				set @msg = 'Year Period already exist';
				raiserror(@msg, 16, -1);
			end 
		end

		if exists (select 1 from  dbo.master_coverage where code = @p_coverage_code and is_main_coverage = '1')
		begin
			if exists (select 1 from dbo.endorsement_period ep 
								inner join dbo.master_coverage mc on (mc.code = ep.coverage_code) 
					   where ep.endorsement_code = @p_coverage_code and mc.is_main_coverage = '1' and year_period = @p_year_period)
			begin
				set @msg = 'Main Coverage already exist' ;

				raiserror(@msg, 16, -1) ;
			end
		end 

		if @p_year_period = '1' and @main_coverage = '1'
		begin
				select	top 1 @initial_admin_fee_amount		  = admin_fee_buy_amount
							  ,@initial_sell_admin_fee_amount = admin_fee_sell_amount
						      ,@initial_stamp_fee_amount      = stamp_fee_amount
				from	master_insurance_fee 
				where	insurance_code = @insurance_code
				and		cast(eff_date as date) <= dbo.xfn_get_system_date()
				order by eff_date desc

		end
        else
        begin
				set @initial_admin_fee_amount		= 0
				set @initial_sell_admin_fee_amount	= 0
				set @initial_stamp_fee_amount		= 0
		end
		
		--if (@initial_admin_fee_amount is null)
		--begin
		--	set @msg = 'Please setting Fee in Master Insurance';
		--	raiserror(@msg, 16, -1) ;
		--end
		--begin try  
		--	 exec dbo.xsp_endorsement_period_getrate @p_endorsement_code	= @p_endorsement_code       
		--											 ,@p_coverage_code		= @p_coverage_code                  
		--											 ,@p_year_period		= @p_year_period   
		--											 ,@p_sum_insured		= @p_sum_insured	              
		--											 ,@p_buy_rate			= @initial_buy_rate		output               
		--											 ,@p_sell_rate			= @initial_sell_rate	output             
		--											 ,@p_buy_amount			= @initial_buy_amount	output           
		--											 ,@p_sell_amount		= @initial_sell_amount	output         
		--											 ,@p_discount_pct		= @initial_discount_pct output  
														 
		--end try 
		--begin catch  
		--	begin
		--		if	(left(error_message(),1) = 'v')
		--		begin
		--			set @msg = replace(error_message(),'v;','');
		--			raiserror(@msg, 16, -1) ;

		--		end
  --              else
  --              begin
		--			set @msg = replace(error_message(),'e;','');
		--			raiserror(@msg, 16, -1) ;
		--		end
		--	end
		--end catch   

		if (@initial_buy_rate > 0)
		begin
			set @buy_amount              = @sum_insured * (@initial_buy_rate/100.00)
			set @sell_amount             = @sum_insured * (@initial_sell_rate/100.00)
		end
        else
        begin
			set @buy_amount              = @initial_buy_amount
			set @sell_amount             = @initial_sell_amount
		end
    
		set @initial_discount_amount = @buy_amount * (@initial_discount_pct/100.00)
		set @total_buy_amount        = @buy_amount - @initial_discount_amount + @initial_stamp_fee_amount + @initial_admin_fee_amount
		set @total_sell_amount       = @sell_amount + @initial_stamp_fee_amount + @initial_sell_admin_fee_amount
	
		insert into dbo.endorsement_period
		(
		    endorsement_code,
		    old_or_new,
		    sum_insured,
		    rate_depreciation,
		    coverage_code,
		    year_period,
		    initial_buy_rate,
		    initial_sell_rate,
		    initial_buy_amount,
		    initial_sell_amount,
		    buy_amount,
		    sell_amount,
		    initial_discount_pct,
		    initial_discount_amount,
		    initial_buy_admin_fee_amount,
		    initial_sell_admin_fee_amount,
		    initial_stamp_fee_amount,
		    total_buy_amount,
		    total_sell_amount,
		    remain_buy,
		    remain_sell,
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(   @p_endorsement_code 
		    ,@p_old_or_new
		    ,@p_sum_insured 
		    ,@rate_depreciation 
		    ,@p_coverage_code
		    ,@p_year_period 
		    ,@initial_buy_rate 
		    ,@initial_sell_rate 
		    ,@initial_buy_amount 
		    ,@initial_sell_amount 
		    ,@buy_amount 
		    ,@sell_amount
		    ,@initial_discount_pct 
		    ,@initial_discount_amount 
		    ,@initial_admin_fee_amount 
		    ,@initial_sell_admin_fee_amount 
		    ,@initial_stamp_fee_amount
		    ,@total_buy_amount
		    ,@total_sell_amount 
		    ,@total_buy_amount
		    ,@total_sell_amount
		    --
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)
		set @p_id = @@identity ;

		EXEC dbo.xsp_endorsement_main_update_amount @p_endorsement_code = @p_endorsement_code,           
		                                            @p_mod_date			= @p_mod_date, 
		                                            @p_mod_by			= @p_mod_by,                    
		                                            @p_mod_ip_address	= @p_mod_ip_address            
		
		
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










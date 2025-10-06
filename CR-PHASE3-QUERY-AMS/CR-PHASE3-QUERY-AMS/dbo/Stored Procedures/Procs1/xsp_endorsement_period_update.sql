CREATE PROCEDURE dbo.xsp_endorsement_period_update
(
	@p_id							  bigint
	,@p_endorsement_code			  nvarchar(50)
	,@p_old_or_new					  nvarchar(3)
	,@p_sum_insured					  decimal(18, 2)
	,@p_rate_depreciation			  decimal(9, 6)
	,@p_coverage_code				  nvarchar(50)
	,@p_year_period					  int
	,@p_initial_buy_rate			  decimal(9, 6)
	,@p_initial_sell_rate			  decimal(9, 6)
	,@p_initial_buy_amount			  decimal(18, 2)
	,@p_initial_sell_amount			  decimal(18, 2)
	,@p_buy_amount					  decimal(18, 2)
	,@p_sell_amount					  decimal(18, 2)
	,@p_initial_discount_pct		  decimal(9, 6)
	,@p_initial_discount_amount		  decimal(18, 2)
	,@p_initial_buy_admin_fee_amount  decimal(18, 2)
    ,@p_initial_sell_admin_fee_amount decimal(18, 2)
	,@p_initial_stamp_fee_amount	  decimal(18, 2)
	,@p_total_buy_amount			  decimal(18, 2)
	,@p_total_sell_amount			  decimal(18, 2)
	,@p_remain_buy					  decimal(18, 2)
	,@p_remain_sell					  decimal(18, 2)
   
	--
	,@p_mod_date					  datetime
	,@p_mod_by						  nvarchar(15)
	,@p_mod_ip_address				  nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max) 
			,@insurance_type					nvarchar(10)
			,@old_periode						int
			,@old_coverage_code					nvarchar(50)
			,@initial_buy_rate					decimal(9, 6)  = 0
			,@initial_sell_rate					decimal(9, 6)  = 0
			,@initial_buy_amount				decimal(18, 2) = 0
			,@initial_sell_amount				decimal(18, 2) = 0
			,@initial_discount_pct				decimal(18, 2) = 0
			,@initial_discount_amount			decimal(18, 2) = 0
			,@sum_insured						decimal(18, 2)
			,@buy_amount						decimal(18, 2) = 0
			,@sell_amount						decimal(18, 2) = 0
			,@total_buy_amount					decimal(18, 2) = 0
			,@total_sell_amount					decimal(18, 2) = 0 
			,@initial_admin_fee_amount			decimal(18, 2)
			,@initial_sell_admin_fee_amount     decimal(18, 2)
			,@initial_stamp_fee_amount     		decimal(18, 2)
			,@main_coverage						nvarchar(1)
			,@insurance_code					nvarchar(50)
			,@new_eff_date						datetime
			,@new_exp_date						datetime;

	begin try
		select	@new_eff_date = eff_date
				,@new_exp_date = exp_date
		from	dbo.endorsement_detail
		where	endorsement_code = @p_endorsement_code
				and old_or_new	 = 'NEW' ;

	    select @insurance_type = ipm.insurance_type
		from   dbo.insurance_policy_main ipm
			   inner join dbo.endorsement_main em on (em.policy_code = ipm.code)
		where  em.code = @p_endorsement_code
		
		if (@p_year_period > ceiling((datediff(year, @new_eff_date, @new_exp_date) * 1.0)))
		begin
			set @msg = 'Period (Year) must be less or equal than Period (Month)' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists(select 1 from dbo.endorsement_period where id <> @p_id and endorsement_code = @p_endorsement_code and year_period = @p_year_period and old_or_new = @p_old_or_new)
		begin
			set @msg = 'Year Period already exist';
			raiserror(@msg, 16, -1);
		end 

		select	@old_periode		= year_period
				,@old_coverage_code	= coverage_code
		from	dbo.endorsement_period
		where	id = @p_id
		and		endorsement_code = @p_endorsement_code

		if	((@p_year_period <> @old_periode) or (@p_coverage_code <> @old_coverage_code))
		begin

			select @main_coverage = is_main_coverage
			from   dbo.master_coverage
			where  code = @p_coverage_code

			select	@insurance_type  = ipm.insurance_type
					,@insurance_code = ipm.insurance_code
			from   dbo.insurance_policy_main ipm
				   inner join dbo.endorsement_main em on (em.policy_code = ipm.code)
			where  em.code = @p_endorsement_code

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

			 exec dbo.xsp_endorsement_period_getrate @p_endorsement_code	= @p_endorsement_code       
													 ,@p_coverage_code		= @p_coverage_code                  
													 ,@p_year_period		= @p_year_period   
													 ,@p_sum_insured		= @p_sum_insured	              
													 ,@p_buy_rate			= @initial_buy_rate		output               
													 ,@p_sell_rate			= @initial_sell_rate	output             
													 ,@p_buy_amount			= @initial_buy_amount	output           
													 ,@p_sell_amount		= @initial_sell_amount	output         
													 ,@p_discount_pct		= @initial_discount_pct output  

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
    
			set @initial_discount_amount	 = @buy_amount * (@initial_discount_pct/100.00)
			set @total_buy_amount			 = @buy_amount - @initial_discount_amount + @initial_stamp_fee_amount + @initial_admin_fee_amount
			set @total_sell_amount			 = @sell_amount + @initial_stamp_fee_amount + @initial_sell_admin_fee_amount

			update	endorsement_period
			set		endorsement_code			   = @p_endorsement_code			 
					,old_or_new					   = @p_old_or_new					 
					,sum_insured				   = @p_sum_insured					 
					,rate_depreciation			   = @p_rate_depreciation			 
					,coverage_code				   = @p_coverage_code				 
					,year_period				   = @p_year_period					 
					,initial_buy_rate			   = @initial_buy_rate			 
					,initial_sell_rate			   = @initial_sell_rate			 
					,initial_buy_amount			   = @initial_buy_amount			 
					,initial_sell_amount		   = @initial_sell_amount			 
					,buy_amount					   = @sell_amount					 
					,sell_amount				   = @p_sell_amount					 
					,initial_discount_pct		   = @initial_discount_pct		 
					,initial_discount_amount	   = @initial_discount_amount		 
					,initial_buy_admin_fee_amount  = @initial_admin_fee_amount 
					,initial_sell_admin_fee_amount = @initial_sell_admin_fee_amount
					,initial_stamp_fee_amount	   = @initial_stamp_fee_amount	 
					,total_buy_amount			   = @total_buy_amount			 
					,total_sell_amount			   = @total_sell_amount			 
					,remain_buy					   = @total_buy_amount					 
					,remain_sell				   = @total_sell_amount					 

					--
					,mod_date					   = @p_mod_date
					,mod_by						   = @p_mod_by
					,mod_ip_address				   = @p_mod_ip_address
			where	id							   = @p_id ;

		end
		else
		begin
			update	endorsement_period
			set		endorsement_code			   = @p_endorsement_code			 
					,old_or_new					   = @p_old_or_new					 
					,sum_insured				   = @p_sum_insured					 
					,rate_depreciation			   = @p_rate_depreciation			 
					,coverage_code				   = @p_coverage_code				 
					,year_period				   = @p_year_period					 
					,initial_buy_rate			   = @p_initial_buy_rate			 
					,initial_sell_rate			   = @p_initial_sell_rate			 
					,initial_buy_amount			   = @p_initial_buy_amount			 
					,initial_sell_amount		   = @p_initial_sell_amount			 
					,buy_amount					   = @p_buy_amount					 
					,sell_amount				   = @p_sell_amount					 
					,initial_discount_pct		   = @p_initial_discount_pct		 
					,initial_discount_amount	   = @p_initial_discount_amount		 
					,initial_buy_admin_fee_amount  = @p_initial_buy_admin_fee_amount 
					,initial_sell_admin_fee_amount = @p_initial_sell_admin_fee_amount
					,initial_stamp_fee_amount	   = @p_initial_stamp_fee_amount	 
					,total_buy_amount			   = @p_total_buy_amount			 
					,total_sell_amount			   = @p_total_sell_amount			 
					,remain_buy					   = @p_remain_buy					 
					,remain_sell				   = @p_remain_sell					 

					--
					,mod_date					   = @p_mod_date
					,mod_by						   = @p_mod_by
					,mod_ip_address				   = @p_mod_ip_address
			where	id							   = @p_id ;
		end

		exec dbo.xsp_endorsement_main_update_amount @p_endorsement_code = @p_endorsement_code,           
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


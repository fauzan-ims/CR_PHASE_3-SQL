CREATE PROCEDURE [dbo].[xsp_insurance_register_period_insert]
(
	@p_id					bigint = 0 output
	,@p_register_code		nvarchar(50)
	,@p_coverage_code		nvarchar(50)
	,@p_year_periode		int	= 0
	--				    
	,@p_cre_date	    datetime
	,@p_cre_by		    nvarchar(15)
	,@p_cre_ip_address  nvarchar(15)
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	
	declare @msg					        nvarchar(max)
			,@collateral_code		        nvarchar(50)
			,@sum_insured			        decimal(18, 2) = 0
			,@rate_depreciation		        decimal(9, 6)  = 0
			,@initial_buy_rate		        decimal(9, 6)  = 0
			,@initial_sell_rate		        decimal(9, 6)  = 0
			,@initial_buy_amount	        decimal(18, 2) = 0
			,@initial_sell_amount	        decimal(18, 2) = 0
			,@initial_discount_pct	        decimal(9, 6)  = 0
			,@initial_discount_amount       decimal(18, 2) = 0
			,@initial_admin_fee_amount      decimal(18, 2) 
			,@initial_sell_admin_fee_amount decimal(18,2)
			,@initial_stamp_fee_amount		decimal(18, 2)
			,@deduction_amount				decimal(18, 2) = 0
			,@buy_amount					decimal(18, 2) = 0
			,@sell_amount					decimal(18, 2) = 0
			,@total_buy_amount				decimal(18, 2) = 0
			,@total_sell_amount				decimal(18, 2) = 0 
			,@insurance_code				nvarchar(50)
			,@depreciation_code				nvarchar(50)
			,@main_coverage					nvarchar(1)
			,@is_commercial					nvarchar(1)
			,@is_authorized					nvarchar(1)
			,@collateral_year				int
			,@insurance_coverage_code		nvarchar(50)
			,@loading_loading_code			nvarchar(50)
			,@loading_age_from				int
			,@loading_age_to				int
			,@loading_rate_type				nvarchar(10)
			,@loading_rate_pct				decimal(9,6)
			,@loading_rate_amount			decimal(18,2)
			,@loading_loading_type			nvarchar(10)
			,@loading_buy_rate_pct			decimal(9,6)
			,@loading_buy_rate_amount		decimal(18,2)
			,@payment_type					nvarchar(10)
			,@loading_total_buy_amount      decimal(18,2)
			,@loading_total_sell_amount     decimal(18,2)
			,@insurance_type                nvarchar(10)
			,@collateral_type				nvarchar(10)
			,@count							int
			,@year_period_max				int
			,@rate							decimal(9,6)
		
	begin try
		
		--select	@year_period_max = ceiling((irr.year_period*1.0)/12)
		--from	dbo.insurance_register irr
		--		inner join dbo.insurance_register_period irp on irp.register_code = irr.code
		--where	irp.register_code = @p_register_code ;

		--if @p_year_periode > @year_period_max
		--begin
		--	set @msg = 'Period (Year) must be equal to or below the period of the month of the year.';
		--	raiserror(@msg, 16, -1) ;
		--end  

		--if not exists
		--(
		--	select	1
		--	from	dbo.master_coverage
		--	where	code = @p_coverage_code
		--	and is_active = '1'
		--)
		--begin
		--	set @msg = N'Please setting insurance coverage first.' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		if exists 
			(
				select	1
				from	dbo.insurance_register
				where	code = @p_register_code
				and		isnull(CURRENCY_CODE, '') = ''
			)
		begin
			set	@msg = 'Please input Currency'
			raiserror(@msg, 16, -1)
		end

		select 
				@sum_insured				= ira.sum_insured_amount
			   ,@insurance_code				= insurance_code
			   ,@depreciation_code			= ira.depreciation_code
			   ,@payment_type				= ir.insurance_payment_type
			   ,@insurance_type				= ir.insurance_type
		from   dbo.insurance_register ir
		left join dbo.insurance_register_asset ira on (ira.register_code = ir.code)
		where  ir.code = @p_register_code
		
		select @main_coverage = is_main_coverage
		from   dbo.master_coverage
		where  code = @p_coverage_code
			
		select @rate_depreciation = rate,
			   @sum_insured = @sum_insured * (rate/100.00)
		from master_depreciation_detail
		where depreciation_code = @depreciation_code
				and tenor = (@p_year_periode * 12);


		if @p_year_periode = '1' and @main_coverage = '1'
		begin
			select	top 1 @initial_admin_fee_amount			= admin_fee_buy_amount
							,@initial_sell_admin_fee_amount = admin_fee_sell_amount
						    ,@initial_stamp_fee_amount		= stamp_fee_amount
			from	master_insurance_fee 
			where	insurance_code = @insurance_code
			and		cast(eff_date as date) <= dbo.xfn_get_system_date()
			order by eff_date desc
		end
        else
        begin
			set @initial_admin_fee_amount = 0
			set @initial_sell_admin_fee_amount = 0
			set @initial_stamp_fee_amount = 0
		end
        
		--if (@initial_admin_fee_amount is null)
		--begin
		--	SET @msg = 'Please setting Fee in Master Insurance';
		--	raiserror(@msg, 16, -1) ;
		--end
		--begin try 
		--	 exec dbo.xsp_insurance_register_period_getrate @p_insurance_register_code	= @p_register_code,        
		--													@p_coverage_code			= @p_coverage_code,                  
		--													@p_year_periode				= @p_year_periode,                    
		--													@p_buy_rate					= @initial_buy_rate		output,               
		--													@p_sell_rate				= @initial_sell_rate	output,             
		--													@p_buy_amount				= @initial_buy_amount	output,           
		--													@p_sell_amount				= @initial_sell_amount	output,         
		--													@p_discount_pct				= @initial_discount_pct output   

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
		set @total_buy_amount        = isnull(@buy_amount - @initial_discount_amount + @initial_stamp_fee_amount + @initial_admin_fee_amount,0)
		set @total_sell_amount       = @sell_amount + @initial_stamp_fee_amount + @initial_sell_admin_fee_amount
		 
		if @insurance_type = 'NON LIFE' and @collateral_type = 'PROP'
		begin
			set @rate_depreciation = '100.00';

			if @p_year_periode <> 1
			begin
				set @msg = 'Non Life and Collateral Type Property Insurance used single rate, Please input Year (Period) = 1';
				raiserror(@msg, 16, -1);
			end
		end 

		        
		if  (@p_year_periode  > (select ceiling((year_period*1.0)/12) FROM dbo.insurance_register where code = @p_register_code) )
		begin
			set @msg = 'Coverage period must be less or equal to registration period.' ;
			raiserror(@msg, 16, -1) ;
		end

		--if @rate_depreciation < 1
		--begin
		--	set @msg = 'Depreciation Rate must be greather than 0';
		--	raiserror(@msg, 16, -1) ;
		--END

		-- jika tidak additional
		if exists(select 1 from dbo.insurance_register where code = @p_register_code and register_type <> 'ADDITIONAL')
		begin

			if exists (select 1 from dbo.insurance_register_period where register_code = @p_register_code and coverage_code = @p_coverage_code and year_periode = @p_year_periode)
			begin
				set @msg = 'Coverage already exist.' ;
				raiserror(@msg, 16, -1) ;
			end

			if exists (select 1 from  dbo.master_coverage where code = @p_coverage_code and is_main_coverage = '1')
			begin
				if exists (select 1 from dbo.insurance_register_period irp 
									inner join dbo.master_coverage mc on (mc.code = irp.coverage_code) 
						   where register_code = @p_register_code and mc.is_main_coverage = '1' and year_periode = @p_year_periode)
				begin
					set @msg = 'Main Coverage already exist' ;
					raiserror(@msg, 16, -1) ;
				end
			end 


		--validasi jika belom ada main coverage ditahun tersebut
		if exists
		(
			select	1
			from	dbo.insurance_register_period irp
			where	register_code		 = @p_register_code
					and irp.year_periode = @p_year_periode
		)
		begin
			if exists
			(
				select	1
				from	dbo.master_coverage
				where	code				 = @p_coverage_code
						and is_main_coverage = '0'
			)
			begin
				if not exists
				(
					select	1
					from	dbo.insurance_register_period  irp
							inner join dbo.master_coverage mc on (mc.code = irp.coverage_code)
					where	register_code			= @p_register_code
							and mc.is_main_coverage = '1'
							and irp.year_periode	= @p_year_periode
				)
				begin
					set @msg = N'Please add Main Coverage first' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;
		end ;
		else
		begin
			if exists
			(
				select	1
				from	dbo.master_coverage
				where	code				 = @p_coverage_code
						and is_main_coverage = '0'
			)
			begin
				set @msg = N'Please add Main Coverage first' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;
			
			
		end

		insert into insurance_register_period
		(
			register_code
			,coverage_code
			,is_main_coverage
			,year_periode
			,deduction_amount
			,buy_amount
			,total_buy_amount
			,rate_depreciation
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_register_code
			,@p_coverage_code
			,@main_coverage
			,@p_year_periode
			,@deduction_amount
			,@buy_amount
			,@total_buy_amount
			,@rate_depreciation
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		set @p_id = @@identity ;
		
		begin
		
			select	@insurance_coverage_code = code
			from	dbo.master_insurance_coverage
			where	insurance_code		= @insurance_code
					and coverage_code	= @p_coverage_code
			
			declare @Temp table
			(
				rate_type		 nvarchar(10)
				,rate_pct		 decimal(9, 6)
				,rate_amount	 decimal(18, 2)
				,loading_type	 nvarchar(10)
				,buy_rate_pct	 decimal(9, 6)
				,buy_rate_amount decimal(18, 2)
				,loading_code	 nvarchar(50)
				,loading_name	 nvarchar(250)
			) ;
			
			--insert @Temp
			exec dbo.xsp_application_collateral_insurance_loading_getrate @p_insurance_code   = @insurance_code
																		  ,@p_is_commercial   = @is_commercial
																		  ,@p_is_authorized   = @is_authorized
																		  ,@p_coverage_code   = @p_coverage_code
																		  ,@p_collateral_year = @collateral_year
																		  ,@p_year_periode    = @p_year_periode ;
			
			declare curr_efam_loading cursor fast_forward read_only for 
			select 
                    loading_code,
                    isnull(buy_rate_pct,0),
                    isnull(rate_pct,0),
                    isnull(buy_rate_amount,0),
                    isnull(rate_amount,0),
					rate_type
			from @Temp

			open curr_efam_loading
		
			fetch next from curr_efam_loading into
			  @loading_loading_code	
			  ,@loading_buy_rate_pct
			  ,@loading_rate_pct
			  ,@loading_buy_rate_amount
			  ,@loading_rate_amount 
			  ,@loading_rate_type
			 
			while @@fetch_status = 0
			begin

				if @loading_rate_type = 'AMOUNT'
				begin
					set @loading_total_buy_amount  = isnull(@loading_buy_rate_amount,0)
					set @loading_total_sell_amount = isnull(@loading_rate_amount,0)
				end
                else
                begin
					set @loading_total_buy_amount  = (isnull(@loading_buy_rate_pct,0)/100.00) * isnull(@buy_amount,0)
					set @loading_total_sell_amount = (isnull(@loading_rate_pct,0)/100.00) * isnull(@sell_amount,0)
				end
				
				if @main_coverage = '1'
				begin
					exec dbo.xsp_insurance_register_loading_insert @p_id				  = 0,
																   @p_register_code		  = @p_register_code,
																   @p_loading_code		  = @loading_loading_code,
																   @p_year_period		  = @p_year_periode,
																   @p_initial_buy_rate	  = @loading_buy_rate_pct,
																   @p_initial_sell_rate   = @loading_rate_pct,
																   @p_initial_buy_amount  = @loading_buy_rate_amount,
																   @p_initial_sell_amount = @loading_rate_amount,
																   @p_total_buy_amount    = @loading_total_buy_amount,
																   @p_total_sell_amount   = @loading_total_sell_amount,
																   @p_cre_date			  = @p_cre_date,
																   @p_cre_by			  = @p_cre_by,
																   @p_cre_ip_address	  = @p_cre_ip_address,
																   @p_mod_date			  = @p_mod_date,
																   @p_mod_by			  = @p_mod_by,
																   @p_mod_ip_address	  = @p_mod_ip_address;
				
				end

				fetch next from curr_efam_loading into 
					  @loading_loading_code	
					  ,@loading_buy_rate_pct
					  ,@loading_rate_pct
					  ,@loading_buy_rate_amount
					  ,@loading_rate_amount
					  ,@loading_rate_type
			end
		
		close curr_efam_loading
		deallocate curr_efam_loading
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


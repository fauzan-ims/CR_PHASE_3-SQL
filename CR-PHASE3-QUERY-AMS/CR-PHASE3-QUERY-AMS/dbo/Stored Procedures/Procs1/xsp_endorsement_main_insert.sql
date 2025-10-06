CREATE PROCEDURE dbo.xsp_endorsement_main_insert
(
	@p_code							nvarchar(50) output
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_endorsement_status			nvarchar(10)
	,@p_endorsement_date			datetime
	,@p_policy_code					nvarchar(50)
	,@p_endorsement_type			nvarchar(15)
	,@p_endorsement_remarks			nvarchar(4000)
	--,@p_endorsement_request_code    nvarchar(50) = null
	,@p_endorsement_payment_amount	decimal(18, 2)
	,@p_endorsement_received_amount decimal(18, 2)
	,@p_endorsement_reason_code		nvarchar(50)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg									nvarchar(max)
			,@year									nvarchar(2)
			,@month									nvarchar(2)
			,@code									nvarchar(50)
			,@currency_code							nvarchar(3)
			,@occupation_code						nvarchar(50)
			,@region_code							nvarchar(50)
			,@collateral_category_code				nvarchar(50)
			,@object_name							nvarchar(4000)
			,@insured_name							nvarchar(250)
			,@insured_qq_name						nvarchar(250) 
			,@policy_eff_date						datetime
			,@policy_exp_date						datetime
			,@p_id									bigint 
			,@loading_code							nvarchar(50)
			,@year_period							int
			,@initial_buy_rate						decimal(9, 6)
			,@initial_sell_rate						decimal(9, 6)
			,@initial_buy_amount					decimal(18, 2)
			,@initial_sell_amount 					decimal(18, 2)
			,@total_buy_amount						decimal(18, 2)
			,@total_sell_amount						decimal(18, 2)
			,@remain_buy							decimal(18, 2)
			,@remain_sell							decimal(18, 2)
			,@coverage_code							nvarchar(50) 
			,@year_period_period					int	
			,@initial_buy_rate_period				decimal(9, 6)
			,@initial_sell_rate_period				decimal(9, 6)
			,@initial_buy_amount_period				decimal(18, 2)
			,@initial_sell_amount_period			decimal(18, 2)
			,@initial_discount_pct_period			decimal(9, 6)
			,@initial_discount_amount_period		decimal(18, 2)
			,@buy_amount_period					 	decimal(18, 2) --insurance_policy_main_period
			,@sell_amount_period				 	decimal(18, 2) --decimal(9, 6) --insurance_policy_main_period
			,@initial_admin_fee_amount_period	 	decimal(18, 2) --insurance_policy_main_period
			,@adjustment_amount_period			 	decimal(18, 2) --insurance_policy_main_period
			,@initial_buy_admin_fee_amount_period 	decimal(18, 2)	= 0
			,@initial_sell_admin_fee_amount_period 	decimal(18, 2) --
			,@initial_stamp_fee_amount_period 		decimal(18, 2)
			,@total_buy_amount_period				decimal(18, 2)
			,@total_sell_amount_period				decimal(18, 2)
			,@remain_buy_period						decimal(18, 2)
			,@remain_sell_period					decimal(18, 2) 
			,@sum_insured							decimal(18, 2)	= 0
			,@rate_depreciation						decimal(9, 6) 
			,@policy_process_status					nvarchar(20)
			,@code_period							nvarchar(50);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'AMSEND'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'ENDORSEMENT_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = '0' ;

	begin try
		
		select	 
				--@occupation_code			= occupation_code
				--,@region_code				= region_code
				--,@collateral_category_code	= collateral_category_code
				@object_name				= object_name
				,@insured_name				= insured_name
				,@insured_qq_name			= insured_qq_name
				,@policy_eff_date			= ipm.policy_eff_date
				,@policy_exp_date			= policy_exp_date
				,@currency_code				= currency_code
				,@policy_process_status     = isnull(policy_process_status,'')
				,@code_period				= ipmp.code
		from	dbo.insurance_policy_main ipm
				left join dbo.insurance_policy_main_period ipmp on (ipm.code = ipmp.policy_code)
		where	ipm.code					= @p_policy_code ;

		if @p_endorsement_date < @policy_eff_date
		begin
			set @msg = 'Endorsement must be greater than Effective Date';
			raiserror(@msg, 16, -1);
		end 
	
		if @p_endorsement_date > @policy_exp_date
		begin
			set @msg = 'Endorsement must be less than Expired Date';
			raiserror(@msg, 16, -1);
		end 

		if not exists(select 1 from dbo.endorsement_request where endorsement_code = @p_code) and (@policy_process_status <> '')
		begin
			set @msg = 'This policy already proceed in ' + upper(left(@policy_process_status,1))+lower(substring(@policy_process_status,2,len(@policy_process_status)));
			raiserror(@msg, 16, -1) ;
		end

		insert into endorsement_main
		(
			code
			,branch_code
			,branch_name
			,endorsement_status
			,endorsement_date
			,policy_code
			,endorsement_type
			,endorsement_remarks
			--,endorsement_request_code
			,currency_code
			,endorsement_payment_amount
			,endorsement_received_amount
			,endorsement_reason_code
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_endorsement_status
			,@p_endorsement_date
			,@p_policy_code
			,@p_endorsement_type
			,@p_endorsement_remarks
			--,@p_endorsement_request_code
			,@currency_code
			,@p_endorsement_payment_amount
			,@p_endorsement_received_amount
			,@p_endorsement_reason_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		update dbo.insurance_policy_main
		set	   policy_process_status = 'ENDORSEMENT'
		where  code = @p_policy_code
	
		exec dbo.xsp_endorsement_detail_insert @p_id						= @p_id output 
											   ,@p_endorsement_code			= @p_code
											   ,@p_old_or_new				= 'NEW'
											   ,@p_occupation_code			= @occupation_code			
											   ,@p_region_code				= @region_code				
											   ,@p_collateral_category_code = @collateral_category_code	
											   ,@p_object_name				= @object_name				
											   ,@p_insured_name				= @insured_name				
											   ,@p_insured_qq_name			= @insured_qq_name			
											   ,@p_eff_date					= @policy_eff_date
											   ,@p_exp_date					= @policy_exp_date
											   ,@p_cre_date					= @p_cre_date
											   ,@p_cre_by					= @p_cre_by
											   ,@p_cre_ip_address			= @p_cre_ip_address
											   ,@p_mod_date					= @p_mod_date
											   ,@p_mod_by					= @p_mod_by
											   ,@p_mod_ip_address			= @p_mod_ip_address
											   
		exec dbo.xsp_endorsement_detail_insert @p_id						= @p_id output 
											   ,@p_endorsement_code			= @p_code
											   ,@p_old_or_new				= 'OLD'
											   ,@p_occupation_code			= @occupation_code			
											   ,@p_region_code				= @region_code				
											   ,@p_collateral_category_code = @collateral_category_code	
											   ,@p_object_name				= @object_name				
											   ,@p_insured_name				= @insured_name				
											   ,@p_insured_qq_name			= @insured_qq_name			
											   ,@p_eff_date					= @policy_eff_date
											   ,@p_exp_date					= @policy_exp_date
											   ,@p_cre_date					= @p_cre_date
											   ,@p_cre_by					= @p_cre_by
											   ,@p_cre_ip_address			= @p_cre_ip_address
											   ,@p_mod_date					= @p_mod_date
											   ,@p_mod_by					= @p_mod_by
											   ,@p_mod_ip_address			= @p_mod_ip_address

		/* cursor insurance_policy_main_period */
		declare insurance_policy_main_period cursor fast_forward read_only for

		select	rate_depreciation
				--,sum_insured
				,coverage_code
				,year_periode
				--,initial_buy_rate
				--,initial_sell_rate
				--,initial_buy_amount
				--,initial_sell_amount
				--,initial_discount_pct
				--,initial_discount_amount
				--,initial_admin_fee_amount
				--,initial_stamp_fee_amount
				,adjustment_amount
				,buy_amount
				--,sell_amount
				,total_buy_amount 
				--,total_sell_amount 
		from	dbo.insurance_policy_main_period 
		where	policy_code	= @p_policy_code ;
	
		open insurance_policy_main_period
		
		fetch next from insurance_policy_main_period into						
		@rate_depreciation		
		--,@sum_insured			
		,@coverage_code						
		,@year_period_period				
		--,@initial_buy_rate_period			
		--,@initial_sell_rate_period			
		--,@initial_buy_amount_period			
		--,@initial_sell_amount_period		
		--,@initial_discount_pct_period		
		--,@initial_discount_amount_period	
		--,@initial_admin_fee_amount_period	
		--,@initial_stamp_fee_amount_period	
		,@adjustment_amount_period
		,@buy_amount_period
		--,@sell_amount_period
		,@total_buy_amount_period			
		--,@total_sell_amount_period						
		
		while @@fetch_status = 0
		begin
			
			exec dbo.xsp_endorsement_period_insert @p_id					= 0
												   ,@p_endorsement_code		= @p_code
												   ,@p_old_or_new			= 'OLD'
												   ,@p_sum_insured			= @sum_insured
												   ,@p_coverage_code		= @coverage_code
												   ,@p_year_period			= @year_period_period
												   ,@p_cre_date				= @p_cre_date
												   ,@p_cre_by				= @p_cre_by
												   ,@p_cre_ip_address		= @p_cre_ip_address
												   ,@p_mod_date				= @p_mod_date
												   ,@p_mod_by				= @p_mod_by
												   ,@p_mod_ip_address		= @p_mod_ip_address
			
			--exec dbo.xsp_endorsement_period_insert @p_id								= 0
			--									   ,@p_endorsement_code					= @p_code
			--									   ,@p_old_or_new						= 'OLD' 
			--									   ,@p_sum_insured						= @sum_insured		
			--									   --,@p_rate_depreciation				= @rate_depreciation	
			--									   ,@p_coverage_code					= @coverage_code		
			--									   ,@p_year_period						= @year_period_period	
			--									   ,@p_cre_date							= @p_cre_date
			--									   ,@p_cre_by							= @p_cre_by
			--									   ,@p_cre_ip_address					= @p_cre_ip_address
			--									   ,@p_mod_date							= @p_mod_date
			--									   ,@p_mod_by							= @p_mod_by
												   --,@p_mod_ip_address					= @p_mod_ip_address

			--exec dbo.xsp_endorsement_period_insert @p_id								= 0
			--									   ,@p_endorsement_code					= @p_code
			--									   ,@p_old_or_new						= 'NEW' 
			--									   ,@p_sum_insured						= @sum_insured		
			--									   ,@p_rate_depreciation				= @rate_depreciation	
			--									   ,@p_coverage_code					= @coverage_code		
			--									   ,@p_year_period						= @year_period_period	
			--									   ,@p_cre_date							= @p_cre_date
			--									   ,@p_cre_by							= @p_cre_by
			--									   ,@p_cre_ip_address					= @p_cre_ip_address
			--									   ,@p_mod_date							= @p_mod_date
			--									   ,@p_mod_by							= @p_mod_by
			--									   ,@p_mod_ip_address					= @p_mod_ip_address

			exec dbo.xsp_endorsement_period_insert @p_id					= 0
												   ,@p_endorsement_code		= @p_code
												   ,@p_old_or_new			= 'NEW'
												   ,@p_sum_insured			= @sum_insured
												   ,@p_coverage_code		= @coverage_code
												   ,@p_year_period			= @year_period_period
												   ,@p_cre_date				= @p_cre_date
												   ,@p_cre_by				= @p_cre_by
												   ,@p_cre_ip_address		= @p_cre_ip_address
												   ,@p_mod_date				= @p_mod_date
												   ,@p_mod_by				= @p_mod_by
												   ,@p_mod_ip_address		= @p_mod_ip_address
		    
		fetch next from insurance_policy_main_period into
		@rate_depreciation		
		--,@sum_insured			
		,@coverage_code						
		,@year_period_period				
		--,@initial_buy_rate_period			
		--,@initial_sell_rate_period			
		--,@initial_buy_amount_period			
		--,@initial_sell_amount_period		
		--,@initial_discount_pct_period		
		--,@initial_discount_amount_period	
		--,@initial_admin_fee_amount_period	
		--,@initial_stamp_fee_amount_period	
		,@adjustment_amount_period
		,@buy_amount_period
		--,@sell_amount_period
		,@total_buy_amount_period			
		--,@total_sell_amount_period			
		end
		
		close insurance_policy_main_period
		deallocate insurance_policy_main_period
		/* end cursor insurance_policy_main_period */
		
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

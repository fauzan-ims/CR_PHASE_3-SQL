CREATE PROCEDURE dbo.xsp_endorsement_main_paid 
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@policy_code						nvarchar(50)
			,@period_code						nvarchar(50)
			,@endorse_sum_insured				decimal(18, 2)
			,@endorse_rate_depreciation			decimal(9, 6)
			,@endorse_coverage_code				nvarchar(50)
			,@endorse_year_periode				int
			,@endorse_initial_buy_rate			decimal(9, 6)
			,@endorse_initial_sell_rate			decimal(9, 6)
			,@endorse_initial_buy_amount		decimal(18, 2)
			,@endorse_initial_sell_amount		decimal(18, 2)
			,@endorse_initial_discount_pct		decimal(9, 6)
			,@endorse_initial_discount_amount	decimal(18, 2)
			,@endorse_initial_admin_fee_amount	decimal(18, 2)
			,@endorse_initial_stamp_fee_amount	decimal(18, 2)
			,@endorse_buy_amount				decimal(18, 2)
			,@endorse_sell_amount				decimal(18, 2)
			,@insured_name						nvarchar(250)
			,@insured_qq_name					nvarchar(250)
			,@object_name						nvarchar(250)
			,@policy_eff_date					datetime
			,@policy_exp_date					datetime
			,@payment_request_code				nvarchar(50)
            ,@endorsement_count					int
			,@endorsement_count_period			nvarchar(1)
			,@is_main_coverage					nvarchar(1);

	begin try	
		
		select	@policy_code	    = em.policy_code
				,@endorsement_count = isnull(ipm.endorsement_count,0)
				,@endorsement_count_period = isnull(ipmp.endorsement_count,'0')
		from	dbo.endorsement_main em
				inner join insurance_policy_main ipm on (ipm.code = em.policy_code)
				left join dbo.insurance_policy_main_period ipmp on (ipmp.policy_code = ipm.code)
		where	em.code			 = @p_code

		select	@insured_name	 = insured_name 
			   ,@insured_qq_name = insured_qq_name
			   ,@object_name     = object_name
			   ,@policy_eff_date = eff_date
			   ,@policy_exp_date = exp_date
		from   dbo.endorsement_detail
        where  endorsement_code = @p_code 
		and	   old_or_new = 'NEW'

		select @payment_request_code = code
		from dbo.efam_interface_payment_request
		where payment_source_no = @p_code
	
		if exists (select 1 from dbo.endorsement_main where code = @p_code and endorsement_status in ('HOLD','APPROVE'))
		begin
			update	dbo.endorsement_main 
			set		endorsement_status	  = 'PAID'
					,payment_request_code = @payment_request_code
					--
					,mod_date			  = @p_mod_date		
					,mod_by				  = @p_mod_by			
					,mod_ip_address		  = @p_mod_ip_address
			where	code				  = @p_code
		
			begin -- update policy period

			declare curr_endorse_period cursor fast_forward read_only for
			select sum_insured
					,rate_depreciation
					,coverage_code
					,year_period 
					,initial_buy_rate
					,initial_sell_rate
					,initial_buy_amount
					,initial_sell_amount
					,initial_discount_pct
					,initial_discount_amount
					,initial_buy_admin_fee_amount
					,initial_stamp_fee_amount
					,remain_buy
					,remain_sell
			from dbo.endorsement_period
			where endorsement_code = @p_code
			and	  old_or_new = 'NEW'
			order by year_period
			
			open curr_endorse_period
			fetch next from curr_endorse_period 
			into @endorse_sum_insured				
				 ,@endorse_rate_depreciation			
				 ,@endorse_coverage_code				
				 ,@endorse_year_periode				
				 ,@endorse_initial_buy_rate			
				 ,@endorse_initial_sell_rate			
				 ,@endorse_initial_buy_amount		
				 ,@endorse_initial_sell_amount		
				 ,@endorse_initial_discount_pct		
				 ,@endorse_initial_discount_amount	
				 ,@endorse_initial_admin_fee_amount	
				 ,@endorse_initial_stamp_fee_amount	
				 ,@endorse_buy_amount				
				 ,@endorse_sell_amount				
			
			while @@fetch_status = 0
			begin
				if not exists -- jika data di proses dari 
				(
					select	1
					from	dbo.insurance_policy_main_period
					where	policy_code			= @policy_code
							and year_periode	= @endorse_year_periode
							and coverage_code	= @endorse_coverage_code
				)
			 
                begin
					set @endorsement_count_period = @endorsement_count_period + 1

					select @is_main_coverage = is_main_coverage
					from  dbo.master_coverage
					where code = @endorse_coverage_code

					exec dbo.xsp_insurance_policy_main_period_insert @p_code						= @period_code OUTPUT,             
					                                                 @p_policy_code					= @policy_code,                
					                                                 @p_sum_insured					= @endorse_sum_insured,               
					                                                 @p_rate_depreciation			= @endorse_rate_depreciation,          
					                                                 @p_coverage_code				= @endorse_coverage_code,
					                                                 @p_is_main_coverage			= @is_main_coverage,              																	               
					                                                 @p_year_periode				= @endorse_year_periode,                 
					                                                 @p_initial_buy_rate			= @endorse_initial_buy_rate,          
					                                                 @p_initial_sell_rate			= @endorse_initial_sell_rate,         
					                                                 @p_initial_buy_amount			= @endorse_initial_buy_amount,        
					                                                 @p_initial_sell_amount			= @endorse_initial_sell_amount,       
					                                                 @p_initial_discount_pct		= @endorse_initial_discount_pct,      
					                                                 @p_initial_discount_amount		= @endorse_initial_discount_amount,   
					                                                 @p_initial_admin_fee_amount	= @endorse_initial_admin_fee_amount,  
					                                                 @p_initial_stamp_fee_amount	= @endorse_initial_stamp_fee_amount,  
					                                                 @p_adjustment_amount			= 0,         
					                                                 @p_buy_amount					= @endorse_buy_amount,                
					                                                 @p_sell_amount					= @endorse_sell_amount,               
					                                                 @p_total_buy_amount			= @endorse_buy_amount,          
					                                                 @p_total_sell_amount			= @endorse_sell_amount,
																	 @p_endorsement_count			= @endorsement_count_period,         
					                                                 @p_cre_date					= @p_mod_date, 
					                                                 @p_cre_by						= @p_mod_by,                     
					                                                 @p_cre_ip_address				= @p_mod_ip_address,             
					                                                 @p_mod_date					= @p_mod_date, 
					                                                 @p_mod_by						= @p_mod_by,                     
					                                                 @p_mod_ip_address				= @p_mod_ip_address  

					exec dbo.xsp_insurance_policy_main_period_adjusment_insert @p_id							= 0,
																			   @p_policy_code					= @policy_code,
																			   @p_year_periode					= @endorse_year_periode,
																			   @p_adjustment_buy_amount			= 0,
																			   @p_adjustment_admin_amount		= 0,
																			   @p_adjustment_discount_amount	= 0,
																			   @p_cre_date						= @p_mod_date,
																			   @p_cre_by						= @p_mod_by,
																			   @p_cre_ip_address				= @p_mod_ip_address,
																			   @p_mod_date						= @p_mod_date,
																			   @p_mod_by						= @p_mod_by,
																			   @p_mod_ip_address				= @p_mod_ip_address
		
				end

			    fetch next from curr_endorse_period 
				into @endorse_sum_insured				
					,@endorse_rate_depreciation			
					,@endorse_coverage_code				
					,@endorse_year_periode				
					,@endorse_initial_buy_rate			
					,@endorse_initial_sell_rate			
					,@endorse_initial_buy_amount		
					,@endorse_initial_sell_amount		
					,@endorse_initial_discount_pct		
					,@endorse_initial_discount_amount	
					,@endorse_initial_admin_fee_amount	
					,@endorse_initial_stamp_fee_amount	
					,@endorse_buy_amount				
					,@endorse_sell_amount				
			
			end
			
			close curr_endorse_period
			deallocate curr_endorse_period
            
			-- hapus yang tidak ada di period, next enhancment di rubah menggunakan status
			begin
				delete dbo.insurance_policy_main_period
				where policy_code = @policy_code
						and cast(year_periode as nvarchar(4))+coverage_code not in (
							select	cast(year_period as nvarchar(4))+coverage_code
							from	dbo.endorsement_period
							where	endorsement_code = @p_code
									and old_or_new = 'NEW'
						)

			end
            
			-- update 5 kolom
			begin
				update dbo.insurance_policy_main
				set    insured_name			= @insured_name
					   ,insured_qq_name		= @insured_qq_name
					   ,object_name			= @object_name
					   ,policy_eff_date		= @policy_eff_date
					   ,policy_exp_date		= @policy_exp_date
					   --
					   ,mod_date			= @p_mod_date		
					   ,mod_by				= @p_mod_by			
					   ,mod_ip_address		= @p_mod_ip_address
				where code = @policy_code
			end
            
			begin
				exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0,          
																  @p_policy_code		= @policy_code,          
																  @p_history_date		= @p_mod_date,
																  @p_history_type		= 'ENDORSEMENT PAID',    
																  @p_policy_status		= 'ACTIVE',              
																  @p_history_remarks	= 'ENDORSEMENT PAID',    
																  @p_cre_date			= @p_mod_date,
																  @p_cre_by				= @p_mod_by,
																  @p_cre_ip_address		= @p_mod_ip_address,
																  @p_mod_date			= @p_mod_date,
																  @p_mod_by				= @p_mod_by,
																  @p_mod_ip_address		= @p_mod_ip_address
		
				--update endorsement_count
				update dbo.insurance_policy_main
				set	   endorsement_count      = @endorsement_count + 1
					   ,policy_process_status = null
				where code = @policy_code
			end

			end
		end
		else
		begin
			raiserror('Error data already proceed',16,1) ;
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




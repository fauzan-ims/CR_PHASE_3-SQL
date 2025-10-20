CREATE PROCEDURE dbo.xsp_sppa_request_proceed 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					    nvarchar(max)
			,@branch_code			    nvarchar(50)
			,@branch_name			    nvarchar(50)
			,@insurance_code		    nvarchar(50)
			,@insurance_type		    nvarchar(50)
			,@sppa_code				    nvarchar(50)
			,@fa_code				    nvarchar(50)
			,@insured_name			    nvarchar(250)
			,@object_name			    nvarchar(4000)
			,@currency_code			    nvarchar(3)
			,@sum_insured			    decimal(18, 2)
			,@from_year				    int
			,@to_year				    int
			,@policy_no				    nvarchar(50)		
			,@code					    nvarchar(50)
			,@insurance_register_code   nvarchar(50)
			,@insurance_payment_type    nvarchar(10)
			,@collateral_type			nvarchar(10)
			,@sppa_detail_id			bigint
			,@rate_depreciation			decimal(9,6)
			,@coverage_code				nvarchar(50)
			,@year_period				int
			,@depre_code				nvarchar(50)
			,@remarks					nvarchar(4000)
			,@sppa_remark				nvarchar(4000)
			,@accessories				nvarchar(4000)
			,@register_type				nvarchar(50)
			,@system_date				datetime = dbo.fn_get_system_date()
				
	begin try
		if exists (select 1 from dbo.sppa_request where code = @p_code and register_status = 'HOLD')
		begin
			select	@branch_code				= ir.branch_code
					,@branch_name				= ir.branch_name
					,@insurance_code			= ir.insurance_code
					,@insured_name				= ms.insurance_name
					,@insurance_type			= ir.insurance_type
					,@sppa_code					= sr.sppa_code			
					,@currency_code				= ir.currency_code	
					,@insurance_register_code	= ir.code
					,@insurance_payment_type	= insurance_payment_type 
					,@sppa_remark				= ir.register_remarks
					,@register_type				= ir.register_type
			from	dbo.sppa_request sr
					inner join dbo.insurance_register ir on (ir.code				= sr.register_code)
					inner join dbo.master_insurance ms on (ms.code				= ir.insurance_code)
			where	sr.code				= @p_code

			
			--Asuransi Collateral
			if exists (select 1 from insurance_register where code = @insurance_register_code and insurance_type = 'NON LIFE')
			begin
				select @from_year = 1
					   ,@to_year  = round(ceiling((year_period*1.0)/12),0,0)
				from dbo.insurance_register where code = @insurance_register_code
			end

			set @remarks = @p_code + ' - ' + @sppa_remark
			
			-- 1 register 1 sppa
			exec dbo.xsp_sppa_main_insert @p_code				= @sppa_code OUTPUT
										  ,@p_sppa_branch_code	= @branch_code
										  ,@p_sppa_branch_name	= @branch_name
										  ,@p_sppa_date			= @system_date
										  ,@p_sppa_status		= 'HOLD' 
										  ,@p_sppa_remarks		= @remarks 
										  ,@p_insurance_code	= @insurance_code
										  ,@p_insurance_type	= @insurance_type 
										  ,@p_cre_date			= @p_cre_date		
										  ,@p_cre_by			= @p_cre_by			
										  ,@p_cre_ip_address	= @p_cre_ip_address
										  ,@p_mod_date			= @p_mod_date		
										  ,@p_mod_by			= @p_mod_by			
										  ,@p_mod_ip_address	= @p_mod_ip_address
			
			if(@register_type <> 'PERIOD')
			begin
				declare curr_sppa cursor fast_forward read_only for
				select	ira.fa_code
						,ira.sum_insured_amount
						--,period.sum_insured
						,ass.item_name
						,ira.depreciation_code
						,ipm.policy_no
						,ira.accessories
				from dbo.sppa_request sr
				inner join dbo.insurance_register ir on (ir.code = sr.register_code)
				inner join dbo.insurance_register_asset ira on (ira.register_code = ir.code and ira.insert_type = 'NEW')
				outer apply (select sum(irp.sum_insured_amount) 'sum_insured' from dbo.insurance_register_asset irp where irp.register_code = ir.code and irp.insert_type = 'NEW') period
				inner join dbo.asset ass on (ass.code = ira.fa_code)
				left join dbo.insurance_policy_main ipm on (ipm.code = ir.policy_code)
				where sr.code = @p_code
				
				open curr_sppa
				
				fetch next from curr_sppa 
				into @fa_code
					,@sum_insured
					,@object_name
					,@depre_code
					,@policy_no
					,@accessories
				
				while @@fetch_status = 0
				begin
				    exec dbo.xsp_sppa_detail_insert @p_id						= @sppa_detail_id output
													,@p_sppa_code				= @sppa_code
													,@p_sppa_request_code		= @p_code
													,@p_fa_code					= @fa_code 
													,@p_insured_name			= @insured_name
													,@p_object_name				= @object_name
													,@p_currency_code			= @currency_code
													,@p_sum_insured_amount		= @sum_insured
													,@p_from_year				= @from_year 
													,@p_to_year					= @to_year 
													,@p_result_status			= 'ON PROCESS'
													,@p_result_date				= @p_cre_date
													,@p_result_total_buy_amount = 0 
													,@p_result_policy_no		= @policy_no
													,@p_result_reason			= null
													,@p_accessories				= @accessories
													,@p_cre_date				= @p_cre_date		
													,@p_cre_by					= @p_cre_by			
													,@p_cre_ip_address			= @p_cre_ip_address
													,@p_mod_date				= @p_mod_date		
													,@p_mod_by					= @p_mod_by
													,@p_mod_ip_address			= @p_mod_ip_address

													declare curr_sppa_detail cursor fast_forward read_only for
													select	mdd.rate
															,irp.coverage_code
															,irp.year_periode
													from dbo.sppa_request sr
													inner join dbo.insurance_register ir on (ir.code = sr.register_code)
													inner join dbo.insurance_register_period irp on (irp.register_code = ir.code and 1 = 1)
													inner join dbo.master_depreciation_detail mdd on (mdd.depreciation_code = @depre_code and (irp.year_periode * 12) = mdd.tenor)
													where sr.code = @p_code
													
													open curr_sppa_detail
													
													fetch next from curr_sppa_detail 
													into @rate_depreciation
														,@coverage_code
														,@year_period
													
													while @@fetch_status = 0
													begin
						
															exec dbo.xsp_sppa_detail_asset_coverage_insert @p_id							= 0
																										   ,@p_sppa_detail_id				= @sppa_detail_id
																										   ,@p_rate_depreciation			= @rate_depreciation
																										   ,@p_is_loading					= '0'
																										   ,@p_coverage_code				= @coverage_code
																										   ,@p_year_periode					= @year_period
																										   ,@p_initial_buy_rate				= 0
																										   ,@p_initial_buy_amount			= 0
																										   ,@p_initial_discount_pct			= 0
																										   ,@p_initial_discount_amount		= 0
																										   ,@p_initial_discount_pph			= 0
																										   ,@p_initial_discount_ppn			= 0
																										   ,@p_initial_admin_fee_amount		= 0
																										   ,@p_initial_stamp_fee_amount		= 0
																										   ,@p_buy_amount					= 0
																										   ,@p_cre_date						= @p_cre_date		
																										   ,@p_cre_by						= @p_cre_by			
																										   ,@p_cre_ip_address				= @p_cre_ip_address
																										   ,@p_mod_date						= @p_mod_date		
																										   ,@p_mod_by						= @p_mod_by			
																										   ,@p_mod_ip_address				= @p_mod_ip_address
							
					
														fetch next from curr_sppa_detail 
														into @rate_depreciation
															,@coverage_code
															,@year_period
													end
					
													close curr_sppa_detail
													deallocate curr_sppa_detail
				
				    fetch next from curr_sppa 
					into @fa_code
						,@sum_insured
						,@object_name
						,@depre_code
						,@policy_no
						,@accessories
				end
				
				close curr_sppa
				deallocate curr_sppa
			end
			else
			begin
				declare curr_sppa cursor fast_forward read_only for
				select	ira.fa_code
						--,ira.sum_insured_amount
						,period.sum_insured
						,ass.item_name
						,ira.depreciation_code
						,ipm.policy_no
						,ira.accessories
				from dbo.sppa_request sr
				inner join dbo.insurance_register ir on (ir.code = sr.register_code)
				inner join dbo.insurance_register_asset ira on (ira.register_code = ir.code and ira.insert_type = 'EXISTING')
				outer apply (select sum(irp.sum_insured_amount) 'sum_insured' from dbo.insurance_register_asset irp where irp.register_code = ir.code and irp.insert_type = 'EXISTING') period
				inner join dbo.asset ass on (ass.code = ira.fa_code)
				left join dbo.insurance_policy_main ipm on (ipm.code = ir.policy_code)
				where sr.code = @p_code
				
				open curr_sppa
				
				fetch next from curr_sppa 
				into @fa_code
					,@sum_insured
					,@object_name
					,@depre_code
					,@policy_no
					,@accessories
				
				while @@fetch_status = 0
				begin
				    exec dbo.xsp_sppa_detail_insert @p_id						= @sppa_detail_id output
													,@p_sppa_code				= @sppa_code
													,@p_sppa_request_code		= @p_code
													,@p_fa_code					= @fa_code 
													,@p_insured_name			= @insured_name
													,@p_object_name				= @object_name
													,@p_currency_code			= @currency_code
													,@p_sum_insured_amount		= @sum_insured
													,@p_from_year				= @from_year 
													,@p_to_year					= @to_year 
													,@p_result_status			= 'ON PROCESS'
													,@p_result_date				= @p_cre_date
													,@p_result_total_buy_amount = 0 
													,@p_result_policy_no		= @policy_no
													,@p_result_reason			= null
													,@p_accessories				= @accessories
													,@p_cre_date				= @p_cre_date		
													,@p_cre_by					= @p_cre_by			
													,@p_cre_ip_address			= @p_cre_ip_address
													,@p_mod_date				= @p_mod_date		
													,@p_mod_by					= @p_mod_by
													,@p_mod_ip_address			= @p_mod_ip_address

													declare curr_sppa_detail cursor fast_forward read_only for
													select	mdd.rate
															,irp.coverage_code
															,irp.year_periode
													from dbo.sppa_request sr
													inner join dbo.insurance_register ir on (ir.code = sr.register_code)
													inner join dbo.insurance_register_period irp on (irp.register_code = ir.code and 1 = 1)
													inner join dbo.master_depreciation_detail mdd on (mdd.depreciation_code = @depre_code and (irp.year_periode * 12) = mdd.tenor)
													where sr.code = @p_code
													
													open curr_sppa_detail
													
													fetch next from curr_sppa_detail 
													into @rate_depreciation
														,@coverage_code
														,@year_period
													
													while @@fetch_status = 0
													begin
						
															exec dbo.xsp_sppa_detail_asset_coverage_insert @p_id							= 0
																										   ,@p_sppa_detail_id				= @sppa_detail_id
																										   ,@p_rate_depreciation			= @rate_depreciation
																										   ,@p_is_loading					= '0'
																										   ,@p_coverage_code				= @coverage_code
																										   ,@p_year_periode					= @year_period
																										   ,@p_initial_buy_rate				= 0
																										   ,@p_initial_buy_amount			= 0
																										   ,@p_initial_discount_pct			= 0
																										   ,@p_initial_discount_amount		= 0
																										   ,@p_initial_discount_pph			= 0
																										   ,@p_initial_discount_ppn			= 0
																										   ,@p_initial_admin_fee_amount		= 0
																										   ,@p_initial_stamp_fee_amount		= 0
																										   ,@p_buy_amount					= 0
																										   ,@p_cre_date						= @p_cre_date		
																										   ,@p_cre_by						= @p_cre_by			
																										   ,@p_cre_ip_address				= @p_cre_ip_address
																										   ,@p_mod_date						= @p_mod_date		
																										   ,@p_mod_by						= @p_mod_by			
																										   ,@p_mod_ip_address				= @p_mod_ip_address
							
					
														fetch next from curr_sppa_detail 
														into @rate_depreciation
															,@coverage_code
															,@year_period
													end
					
													close curr_sppa_detail
													deallocate curr_sppa_detail
				
				    fetch next from curr_sppa 
					into @fa_code
						,@sum_insured
						,@object_name
						,@depre_code
						,@policy_no
						,@accessories
				end
				
				close curr_sppa
				deallocate curr_sppa
			end

				

			update	dbo.sppa_request
			set		sppa_code			 = @sppa_code
					,register_status	 = 'POST'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code
					    
		end
        else
		begin
			SET @msg = 'Data already proceed';
			raiserror(@msg, 16, -1) ;
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
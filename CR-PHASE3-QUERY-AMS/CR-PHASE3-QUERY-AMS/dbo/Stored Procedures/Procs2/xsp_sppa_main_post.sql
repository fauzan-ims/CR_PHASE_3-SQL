/*
	alterd : Nia, 26 Mei 2020
*/
CREATE PROCEDURE [dbo].[xsp_sppa_main_post] 
(
	@p_code				NVARCHAR(50)
	--
	,@p_cre_date		DATETIME
	,@p_cre_by			NVARCHAR(15)
	,@p_cre_ip_address	NVARCHAR(15)
	,@p_mod_date		DATETIME
	,@p_mod_by			NVARCHAR(15)
	,@p_mod_ip_address	NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg										NVARCHAR(MAX)
			,@insurance_policy_main_period_adjusment_id BIGINT
			,@register_code								NVARCHAR(50)
			,@register_period_id						BIGINT
			,@register_loading_id						BIGINT
			,@loading_code								NVARCHAR(50)
			,@result_status								NVARCHAR(20)
			,@branch_code								NVARCHAR(50)
			,@branch_name								NVARCHAR(250)
			,@register_name								NVARCHAR(250)
			,@register_qq_name							NVARCHAR(250)
			,@collateral_type							NVARCHAR(250)
			,@register_object_name						NVARCHAR(4000)
			,@sum_insured								DECIMAL(18, 2)
			,@insurance_code							NVARCHAR(50)
			,@insurance_name							NVARCHAR(250)
			,@insurance_type							NVARCHAR(50)
			,@depreciation_code							NVARCHAR(50)
			,@collateral_category_code					NVARCHAR(50)
			,@insurance_payment_type					NVARCHAR(10)
			,@occupation_code							NVARCHAR(50)
			,@register_remarks							NVARCHAR(250)
			,@currency_code								NVARCHAR(4000)
			,@region_code								NVARCHAR(50)
			,@rate_depreciation							DECIMAL(9, 6)
			,@year_periode								INT
			,@year_period								INT
			,@from_date									DATETIME
			,@to_date									DATETIME
			,@initial_sell_rate							DECIMAL(9, 6)
			,@initial_sell_amount						DECIMAL(18, 2)
			,@initial_sell_admin_fee_amount				DECIMAL(18, 2)
			,@deduction_amount							DECIMAL(18, 2)
			,@sell_amount								DECIMAL(18, 2)
			,@total_buy_amount							DECIMAL(18, 2)
			,@total_sell_amount							DECIMAL(18, 2)
			,@total_sell_loading_amount					DECIMAL(18, 2)
			,@result_policy_no							NVARCHAR(50)
			,@from_year									INT
			,@to_year									INT
			,@register_period							INT
			,@insurance_policy_main_code				NVARCHAR(50) 
			,@source_type								NVARCHAR(20)
			,@is_main_coverage							NVARCHAR(1)
			,@eff_rate									DECIMAL(9, 6)
			,@fa_code									NVARCHAR(50)
			,@sppa_detail_id							BIGINT
			,@code_policy_asset							NVARCHAR(50)
			,@collateral_year							NVARCHAR(4)
			,@is_authorized_workshop					NVARCHAR(1)
			,@is_commercial								NVARCHAR(1)
			,@is_loading								NVARCHAR(1)
			,@initial_buy_rate							DECIMAL(9,6)
			,@initial_buy_amount						DECIMAL(18,2)
			,@initial_discount_pct						DECIMAL(9,6)
			,@initial_discount_amount					DECIMAL(18,2)
			,@initial_discount_ppn						DECIMAL(18,2)
			,@initial_discount_pph						DECIMAL(18,2)
			,@initial_admin_fee_amount					DECIMAL(18,2)
			,@initial_stamp_fee_amount					DECIMAL(18,2)
			,@buy_amount								DECIMAL(18,2)
			,@code_period								NVARCHAR(50)
			,@sum_buy_amount							DECIMAL(18,2)
			,@sum_initial_buy_amount					DECIMAL(18,2)
			,@sum_initial_discount_amount				DECIMAL(18,2)
			,@sum_initial_admin_fee_amount				DECIMAL(18,2)
			,@sum_initial_stamp_fee_amount				DECIMAL(18,2)
			,@sum_initial_discount_pct					DECIMAL(9,6)
			,@period_buy_amount							DECIMAL(18,2)
			,@period_initial_discount_pct				DECIMAL(9,6)
			,@period_initial_discount_amount			DECIMAL(18,2)
			,@period_initial_admin_fee_amount			DECIMAL(18,2)
			,@period_initial_stamp_fee_amount			DECIMAL(18,2)
			,@coverage_code								NVARCHAR(50)
			,@register_type								NVARCHAR(50)
			,@policy_code								NVARCHAR(50)
			,@sppa_code									NVARCHAR(50)
			,@policy_asset_coverage_id					INT
			,@policy_asset_code							NVARCHAR(50)
			,@accessories								NVARCHAR(4000)
			,@insert_type								NVARCHAR(20)
			,@new_year_period							INT
			,@new_to_date								DATETIME
			,@max_year_before_add_period				INT
			,@plat_list									NVARCHAR(MAX)

     --ALIP 26/08/2025 ERR.2508.000562
	if exists
(
    select	1
    from	dbo.sppa_detail sd
    inner join dbo.sppa_main sm on sm.code = sd.sppa_code
    inner join dbo.asset_vehicle av on av.asset_code = sd.fa_code
    where sm.code = @p_code
          and sd.fa_code in
              (
                  select	sdt.asset_code
                  from		dbo.sale s
				  inner join dbo.sale_detail sdt on sdt.sale_code = s.code
                  where		s.status not in ( 'CANCEL', 'REJECT' )
              )
)
begin
    select @plat_list = string_agg(av.plat_no, ', ')
    from dbo.sppa_detail sd
        join dbo.sppa_main sm
            on sm.code = sd.sppa_code
        join dbo.asset_vehicle av
            on av.asset_code = sd.fa_code
    where sm.code = @p_code
          and sd.fa_code in
              (
                  select sdt.asset_code
                  from dbo.sale s
                      join dbo.sale_detail sdt
                          on sdt.sale_code = s.code
                  where s.status not in ( 'cancel', 'reject' )
              );

    set @msg = N'Asset Are In Sales Request Process, For Plat No: ' + @plat_list;
    raiserror(@msg, 16, -1);
end;


	BEGIN TRY
		IF EXISTS
		(
			SELECT	1
			FROM	dbo.sppa_main
			WHERE	code			= @p_code
					AND sppa_status <> 'ON PROCESS'
		)
		BEGIN
			SET @msg = 'Error data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.sppa_detail
			where	sppa_code				  = @p_code
					and (
							result_status	  <> 'APPROVED'
							and result_status <> 'REJECT'
						)
		)
		begin
			set @msg = 'Invalid SPPA Result' ;
			raiserror(@msg, 16, -1) ;
		end ;
        else
			begin
				update	dbo.sppa_main 
				set		sppa_status		= 'POST'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code
			 
				--looping sppa_detail dan di group by by policy no
				--declare efam_cur_sppa cursor local fast_forward for
				select	@register_code			= sr.register_code
						,@result_policy_no		= sd.result_policy_no
						,@result_status			= sd.result_status
						,@from_year				= sd.from_year
						,@to_year				= sd.to_year
						,@register_type			= ir.register_type
						,@policy_code			= ir.policy_code
				from	dbo.sppa_detail sd
						inner join dbo.sppa_request sr on (sr.code = sd.sppa_request_code)
						inner join dbo.insurance_register ir on (ir.code = sr.register_code)
				where	sd.sppa_code	= @p_code

				select @max_year_before_add_period = max(year_periode) 
				from dbo.insurance_policy_main_period
				where policy_code = @policy_code
				
				if @result_status = 'APPROVED'
				begin
				      select @branch_code				 = branch_code			
							 ,@branch_name				 = branch_name		    
							 ,@register_name			 = register_name				
							 ,@register_qq_name	         = register_qq_name	        
							 ,@register_object_name		 = register_object_name		
							 ,@insurance_code			 = insurance_code
							 ,@insurance_name            = isnull(mi.insurance_name,'')			    
							 ,@insurance_type			 = ir.insurance_type	
							 ,@insurance_payment_type    = insurance_payment_type			
							 ,@register_remarks		     = 'Policy Register '+ register_remarks		    
							 ,@currency_code			 = currency_code
							 ,@from_date				 = from_date	
							 ,@to_date					 = to_date
							 ,@register_period		     = ir.year_period
							 ,@source_type				 = ir.source_type
							 ,@eff_rate        			 = eff_rate   
					  from  dbo.insurance_register ir
							left join dbo.master_insurance mi on (mi.code = ir.insurance_code)
					  where ir.code = @register_code

					  if(@register_type = 'NEW')
					  begin
							--ambil looping dari sppa detail distinct policy no, dan diinsert
							--- UNTUK MENGCOPY POLICY MAIN 
							exec dbo.xsp_insurance_policy_main_insert @p_code							= @insurance_policy_main_code output		
					  										  ,@p_sppa_code						= @p_code
					  										  ,@p_register_code					= @register_code
					  										  ,@p_branch_code					= @branch_code
					  										  ,@p_branch_name					= @branch_name
					  										  ,@p_source_type					= @source_type
					  										  ,@p_policy_status					= 'ACTIVE'
					  										  ,@p_policy_payment_status			= 'HOLD'
					  										  ,@p_insured_name					= @insurance_name
					  										  ,@p_insured_qq_name				= @register_qq_name
					  										  ,@p_policy_payment_type			= 'FTFP'
					  										  ,@p_object_name					= @register_object_name
					  										  ,@p_insurance_code				= @insurance_code
					  										  ,@p_insurance_type				= @insurance_type
					  										  ,@p_currency_code					= @currency_code
					  										  ,@p_cover_note_no					= null
					  										  ,@p_cover_note_date				= null
					  										  ,@p_policy_no						= @result_policy_no
					  										  ,@p_policy_eff_date				= @from_date
					  										  ,@p_policy_exp_date				= @to_date
					  										  ,@p_eff_rate						= @eff_rate
					  										  ,@p_file_name						= null
					  										  ,@p_paths							= null
					  										  ,@p_invoice_no					= null
					  										  ,@p_invoice_date					= null
					  										  ,@p_from_year						= @from_year
					  										  ,@p_to_year						= @to_year
					  										  ,@p_total_premi_buy_amount		= 0
					  										  ,@p_total_discount_amount			= 0
					  										  ,@p_total_net_premi_amount		= 0
					  										  ,@p_stamp_fee_amount				= 0
					  										  ,@p_admin_fee_amount				= 0
					  										  ,@p_total_adjusment_amount		= 0
					  										  ,@p_is_policy_existing			= 'F'
					  										  ,@p_endorsement_count				= 0
					  										  ,@p_cre_date						= @p_cre_date	 					
					  										  ,@p_cre_by						= @p_cre_by		
					  										  ,@p_cre_ip_address				= @p_cre_ip_address
					  										  ,@p_mod_date						= @p_mod_date	 
					  										  ,@p_mod_by						= @p_mod_by	 
					  										  ,@p_mod_ip_address				= @p_mod_ip_address	
							
							declare curr_pol_main cursor fast_forward read_only for
							select	irp.coverage_code
									,irp.year_periode
									,irp.is_main_coverage
							from dbo.insurance_register_period irp
							left join dbo.sppa_request sr on (sr.register_code = irp.register_code)
							where irp.register_code = @register_code

							open curr_pol_main
							
							fetch next from curr_pol_main 
							into @coverage_code
								,@year_periode
								,@is_main_coverage
							
							while @@fetch_status = 0
							begin
							    --insert dari table baru di grouping per coverage dan year
								exec dbo.xsp_insurance_policy_main_period_insert @p_code						= @code_period
																				 ,@p_policy_code				= @insurance_policy_main_code
																				 ,@p_rate_depreciation			= 0
																				 ,@p_coverage_code				= @coverage_code
																				 ,@p_is_main_coverage			= @is_main_coverage
																				 ,@p_year_periode				= @year_periode
																				 ,@p_adjustment_amount			= 0
																				 ,@p_total_buy_amount			= 0
																				 ,@p_discount_pct				= 0
																				 ,@p_discount_amount			= 0
																				 ,@p_admin_fee_amount			= 0
																				 ,@p_stamp_fee_amount			= 0
																				 ,@p_buy_amount					= 0
																				 ,@p_cre_date					= @p_cre_date
																				 ,@p_cre_by						= @p_cre_by	
																				 ,@p_cre_ip_address				= @p_cre_ip_address
																				 ,@p_mod_date					= @p_mod_date	
																				 ,@p_mod_by						= @p_mod_by	
																				 ,@p_mod_ip_address				= @p_mod_ip_address  
								
							    fetch next from curr_pol_main 
								into @coverage_code
									,@year_periode
									,@is_main_coverage
							end
							
							close curr_pol_main
							deallocate curr_pol_main

							--insert ke INSURANCE_POLICY_ASSET, ambil dari sppa detail
							declare curr_pol_asset cursor fast_forward read_only for
							select	distinct
									sd.fa_code
									,sd.sum_insured_amount
									,ira.depreciation_code
									,ira.collateral_type
									,ira.collateral_category_code
									,ira.occupation_code
									,ira.region_code
									,ira.collateral_year
									,ira.is_authorized_workshop
									,ira.is_commercial
									,sd.id
									,sd.accessories
									,ira.insert_type
							from dbo.sppa_detail sd
							left join dbo.sppa_request sr on (sr.code = sd.sppa_request_code)
							left join dbo.insurance_register_asset ira on (ira.register_code = sr.register_code and sd.fa_code = ira.fa_code)
							where ira.register_code = @register_code
							and sd.sppa_code = @p_code
							
							open curr_pol_asset
							
							fetch next from curr_pol_asset 
							into @fa_code
								,@sum_insured
								,@depreciation_code
								,@collateral_type
								,@collateral_category_code
								,@occupation_code
								,@region_code
								,@collateral_year
								,@is_authorized_workshop
								,@is_commercial
								,@sppa_detail_id
								,@accessories
								,@insert_type

							
							while @@fetch_status = 0
							begin
							    exec dbo.xsp_insurance_policy_asset_insert @p_code							= @code_policy_asset output
						    										   ,@p_policy_code					= @insurance_policy_main_code
						    										   ,@p_fa_code						= @fa_code
						    										   ,@p_sum_insured_amount			= @sum_insured
						    										   ,@p_depreciation_code			= @depreciation_code
						    										   ,@p_collateral_type				= @collateral_type
						    										   ,@p_collateral_category_code		= @collateral_category_code
						    										   ,@p_occupation_code				= @occupation_code
						    										   ,@p_region_code					= @region_code
						    										   ,@p_collateral_year				= @collateral_year
						    										   ,@p_is_authorized_workshop		= @is_authorized_workshop
						    										   ,@p_is_commercial				= @is_commercial
																	   ,@p_sppa_code					= @p_code
																	   ,@p_accessories					= @accessories
																	   ,@p_insert_type					= @insert_type
						    										   ,@p_cre_date						= @p_cre_date	
						    										   ,@p_cre_by						= @p_cre_by	
						    										   ,@p_cre_ip_address				= @p_cre_ip_address
						    										   ,@p_mod_date						= @p_mod_date
						    										   ,@p_mod_by						= @p_mod_by	
						    										   ,@p_mod_ip_address				= @p_mod_ip_address


								--insert ke INSURANCE_POLICY_ASSET_COVERAGE, ambil dari tabel baru
								declare curr_pol_asset_coverage cursor fast_forward read_only for
								select	sdac.rate_depreciation 
										,sdac.is_loading
										,sdac.initial_buy_rate
										,sdac.initial_buy_amount
										,sdac.initial_discount_pct
										,sdac.initial_discount_amount
										,sdac.initial_discount_pph
										,sdac.initial_discount_ppn
										,sdac.initial_admin_fee_amount
										,sdac.initial_stamp_fee_amount
										,sdac.buy_amount
										,sdac.coverage_code
										,sdac.year_periode
								from dbo.sppa_detail_asset_coverage sdac
								where sdac.sppa_detail_id = @sppa_detail_id

								open curr_pol_asset_coverage
								
								fetch next from curr_pol_asset_coverage 
								into @rate_depreciation
									,@is_loading
									,@initial_buy_rate
									,@initial_buy_amount
									,@initial_discount_pct
									,@initial_discount_amount
									,@initial_discount_pph
									,@initial_discount_ppn
									,@initial_admin_fee_amount
									,@initial_stamp_fee_amount
									,@buy_amount
									,@coverage_code
									,@year_period
								
								while @@fetch_status = 0
								begin

									exec dbo.xsp_insurance_policy_asset_coverage_insert @p_id							= 0
																						,@p_register_asset_code			= @code_policy_asset
																						,@p_rate_depreciation			= @rate_depreciation
																						,@p_is_loading					= @is_loading
																						,@p_coverage_code				= @coverage_code
																						,@p_year_periode				= @year_period
																						,@p_initial_buy_rate			= @initial_buy_rate
																						,@p_initial_buy_amount			= @initial_buy_amount
																						,@p_initial_discount_pct		= @initial_discount_pct
																						,@p_initial_discount_amount		= @initial_discount_amount
																						,@p_initial_discount_pph		= @initial_discount_pph
																						,@p_initial_discount_ppn		= @initial_discount_ppn
																						,@p_initial_admin_fee_amount	= @initial_admin_fee_amount
																						,@p_initial_stamp_fee_amount	= @initial_stamp_fee_amount
																						,@p_buy_amount					= @buy_amount
																						,@p_coverage_type				= 'NEW'
																						,@p_sppa_code					= @p_code
																						,@p_cre_date					= @p_cre_date	
																						,@p_cre_by						= @p_cre_by	
																						,@p_cre_ip_address				= @p_cre_ip_address
																						,@p_mod_date					= @p_mod_date
																						,@p_mod_by						= @p_mod_by	
																						,@p_mod_ip_address				= @p_mod_ip_address	
									
							
									fetch next from curr_pol_asset_coverage 
									into @rate_depreciation
										,@is_loading
										,@initial_buy_rate
										,@initial_buy_amount
										,@initial_discount_pct
										,@initial_discount_amount
										,@initial_discount_pph
										,@initial_discount_ppn
										,@initial_admin_fee_amount
										,@initial_stamp_fee_amount
										,@buy_amount
										,@coverage_code
										,@year_period
								end
								
								close curr_pol_asset_coverage
								deallocate curr_pol_asset_coverage
								
							
							    fetch next from curr_pol_asset 
								into @fa_code
									,@sum_insured
									,@depreciation_code
									,@collateral_type
									,@collateral_category_code
									,@occupation_code
									,@region_code
									,@collateral_year
									,@is_authorized_workshop
									,@is_commercial
									,@sppa_detail_id
									,@accessories
									,@insert_type
							end
							
							close curr_pol_asset
							deallocate curr_pol_asset

							select	 @sum_buy_amount				= sum(ipac.buy_amount)
									,@sum_initial_buy_amount		= sum(ipac.initial_buy_amount)
									,@sum_initial_discount_amount	= sum(ipac.initial_discount_amount)
									,@sum_initial_admin_fee_amount	= sum(ipac.initial_admin_fee_amount)
									,@sum_initial_stamp_fee_amount	= sum(ipac.initial_stamp_fee_amount)
									,@sum_initial_discount_pct		= sum(ipac.initial_discount_pct)
							from dbo.insurance_policy_asset_coverage ipac
							left join dbo.insurance_policy_asset ipa on (ipac.register_asset_code = ipa.code)
							where ipa.policy_code = @insurance_policy_main_code

							-- summary ke header
							update	dbo.insurance_policy_main
							set		total_premi_buy_amount	= @sum_initial_buy_amount
									,total_discount_amount	= @sum_initial_discount_amount
									,total_adjusment_amount	= 0
									,total_net_premi_amount = @sum_buy_amount
									,stamp_fee_amount		= @sum_initial_stamp_fee_amount
									,admin_fee_amount		= @sum_initial_admin_fee_amount
									--
									,mod_date				= @p_mod_date		
									,mod_by					= @p_mod_by			
									,mod_ip_address			= @p_mod_ip_address
							where code = @insurance_policy_main_code


							--summary ke period
							declare curr_update_period cursor fast_forward read_only for
							select	 sum(ipac.buy_amount)
									,sum(ipac.initial_discount_pct)
									,sum(ipac.initial_discount_amount)
									,sum(ipac.initial_admin_fee_amount)
									,sum(ipac.initial_stamp_fee_amount)
									,ipac.coverage_code
							from dbo.insurance_policy_asset_coverage ipac
							left join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
							where ipa.policy_code = @insurance_policy_main_code
							group by ipac.coverage_code
						
							open curr_update_period
						
							fetch next from curr_update_period 
							into @period_buy_amount
								,@period_initial_discount_pct
								,@period_initial_discount_amount
								,@period_initial_admin_fee_amount
								,@period_initial_stamp_fee_amount
								,@coverage_code
							
							while @@fetch_status = 0
							begin
							    --summary ke period per coverage
								update	dbo.insurance_policy_main_period
								set		buy_amount				= @period_buy_amount
										,discount_pct			= @period_initial_discount_pct
										,discount_amount		= @period_initial_discount_amount
										,admin_fee_amount		= @period_initial_admin_fee_amount
										,stamp_fee_amount		= @period_initial_stamp_fee_amount
										,adjustment_amount		= 0
										,total_buy_amount		= @period_buy_amount - @period_initial_discount_amount + @period_initial_admin_fee_amount + @period_initial_stamp_fee_amount
										--
										,mod_date				= @p_mod_date		
										,mod_by					= @p_mod_by			
										,mod_ip_address			= @p_mod_ip_address
								where policy_code = @insurance_policy_main_code
								and coverage_code = @coverage_code
							
							    fetch next from curr_update_period 
								into @period_buy_amount
									,@period_initial_discount_pct
									,@period_initial_discount_amount
									,@period_initial_admin_fee_amount
									,@period_initial_stamp_fee_amount
									,@coverage_code
							end
						
							close curr_update_period
							deallocate curr_update_period

							-- INSERT HISTORY
							exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0,					   
										                                        @p_policy_code		= @insurance_policy_main_code,		 
										                                        @p_history_date		= @p_mod_date,						 
										                                        @p_history_type		= 'ENTRY', 						 
										                                        @p_policy_status	= 'ACTIVE',						 
										                                        @p_history_remarks	=  @register_remarks,				 
										                                        @p_cre_date			= @p_cre_date,						 
										                                        @p_cre_by			= @p_cre_by,						 
										                                        @p_cre_ip_address	= @p_cre_ip_address,				 
										                                        @p_mod_date			= @p_mod_date,						 
										                                        @p_mod_by			= @p_mod_by,						 
										                                        @p_mod_ip_address	= @p_mod_ip_address
					end
					else
					begin
					  	begin -- update policy main 
					  		update dbo.insurance_policy_main
					  		set		policy_payment_status = 'HOLD'
					  				,cover_note_no			= null
					  				,cover_note_date		= null
					  				,invoice_no				= null
					  				,invoice_date			= null
					  				,sppa_code				= @p_code
					  				--
					  				,mod_date					= @p_mod_date
					  				,mod_by						= @p_mod_by
					  				,mod_ip_address				= @p_mod_ip_address
					  		where	code = @policy_code
					  	end

						if(@register_type = 'ADDITIONAL')
						begin
					  		begin -- insert ke policy asset
					  		--insert ke INSURANCE_POLICY_ASSET, ambil dari sppa detail
					  			declare curr_pol_asset cursor fast_forward read_only for
					  			select	sd.fa_code
					  					,sd.sum_insured_amount
					  					,ira.depreciation_code
					  					,ira.collateral_type
					  					,ira.collateral_category_code
					  					,ira.occupation_code
					  					,ira.region_code
					  					,ira.collateral_year
					  					,ira.is_authorized_workshop
					  					,ira.is_commercial
					  					,sd.id
										,sd.accessories
										,ira.insert_type
										,ir.policy_code
					  			from dbo.sppa_detail sd
					  			inner join dbo.sppa_request sr on (sr.code = sd.sppa_request_code)
					  			inner join dbo.insurance_register_asset ira on (ira.register_code = sr.register_code and sd.fa_code = ira.fa_code and ira.insert_type = 'NEW')
								inner join dbo.insurance_register ir on (ir.code = ira.register_code)
					  			where ira.register_code = @register_code
								and sd.sppa_code = @p_code
					  			
					  			open curr_pol_asset
					  			
					  			fetch next from curr_pol_asset 
					  			into @fa_code
					  				,@sum_insured
					  				,@depreciation_code
					  				,@collateral_type
					  				,@collateral_category_code
					  				,@occupation_code
					  				,@region_code
					  				,@collateral_year
					  				,@is_authorized_workshop
					  				,@is_commercial
					  				,@sppa_detail_id
									,@accessories
									,@insert_type
									,@insurance_policy_main_code
					  
					  			
					  			while @@fetch_status = 0
					  			begin
					  			    exec dbo.xsp_insurance_policy_asset_insert @p_code							= @code_policy_asset output
						    												   ,@p_policy_code					= @insurance_policy_main_code
						    												   ,@p_fa_code						= @fa_code
						    												   ,@p_sum_insured_amount			= @sum_insured
						    												   ,@p_depreciation_code			= @depreciation_code
						    												   ,@p_collateral_type				= @collateral_type
						    												   ,@p_collateral_category_code		= @collateral_category_code
						    												   ,@p_occupation_code				= @occupation_code
						    												   ,@p_region_code					= @region_code
						    												   ,@p_collateral_year				= @collateral_year
						    												   ,@p_is_authorized_workshop		= @is_authorized_workshop
						    												   ,@p_is_commercial				= @is_commercial
																			   ,@p_sppa_code					= @p_code
																			   ,@p_accessories					= @accessories
																			   ,@p_insert_type					= @insert_type
						    												   ,@p_cre_date						= @p_cre_date	
						    												   ,@p_cre_by						= @p_cre_by	
						    												   ,@p_cre_ip_address				= @p_cre_ip_address
						    												   ,@p_mod_date						= @p_mod_date
						    												   ,@p_mod_by						= @p_mod_by	
						    												   ,@p_mod_ip_address				= @p_mod_ip_address

					  				--insert ke INSURANCE_POLICY_ASSET_COVERAGE, ambil dari tabel baru
					  				declare curr_pol_asset_coverage cursor fast_forward read_only for
					  				select	sdac.rate_depreciation 
					  						,sdac.is_loading
					  						,sdac.initial_buy_rate
					  						,sdac.initial_buy_amount
					  						,sdac.initial_discount_pct
					  						,sdac.initial_discount_amount
					  						,sdac.initial_discount_pph
					  						,sdac.initial_discount_ppn
					  						,sdac.initial_admin_fee_amount
					  						,sdac.initial_stamp_fee_amount
					  						,sdac.buy_amount
					  						,sdac.coverage_code
					  						,sdac.year_periode
					  				from dbo.sppa_detail_asset_coverage sdac
					  				where sdac.sppa_detail_id = @sppa_detail_id
					  
					  				open curr_pol_asset_coverage
					  				
					  				fetch next from curr_pol_asset_coverage 
					  				into @rate_depreciation
					  					,@is_loading
					  					,@initial_buy_rate
					  					,@initial_buy_amount
					  					,@initial_discount_pct
					  					,@initial_discount_amount
					  					,@initial_discount_pph
					  					,@initial_discount_ppn
					  					,@initial_admin_fee_amount
					  					,@initial_stamp_fee_amount
					  					,@buy_amount
					  					,@coverage_code
					  					,@year_period
					  				
					  				while @@fetch_status = 0
					  				begin
					  
					  					exec dbo.xsp_insurance_policy_asset_coverage_insert @p_id							= 0
					  																		,@p_register_asset_code			= @code_policy_asset
					  																		,@p_rate_depreciation			= @rate_depreciation
					  																		,@p_is_loading					= @is_loading
					  																		,@p_coverage_code				= @coverage_code
					  																		,@p_year_periode				= @year_period
					  																		,@p_initial_buy_rate			= @initial_buy_rate
					  																		,@p_initial_buy_amount			= @initial_buy_amount
					  																		,@p_initial_discount_pct		= @initial_discount_pct
					  																		,@p_initial_discount_amount		= @initial_discount_amount
					  																		,@p_initial_discount_pph		= @initial_discount_pph
					  																		,@p_initial_discount_ppn		= @initial_discount_ppn
					  																		,@p_initial_admin_fee_amount	= @initial_admin_fee_amount
					  																		,@p_initial_stamp_fee_amount	= @initial_stamp_fee_amount
					  																		,@p_buy_amount					= @buy_amount
																							,@p_coverage_type				= 'NEW'
																							,@p_sppa_code					= @p_code
					  																		,@p_cre_date					= @p_cre_date	
					  																		,@p_cre_by						= @p_cre_by	
					  																		,@p_cre_ip_address				= @p_cre_ip_address
					  																		,@p_mod_date					= @p_mod_date
					  																		,@p_mod_by						= @p_mod_by	
					  																		,@p_mod_ip_address				= @p_mod_ip_address	
					  					
					  			
					  					fetch next from curr_pol_asset_coverage 
					  					into @rate_depreciation
					  						,@is_loading
					  						,@initial_buy_rate
					  						,@initial_buy_amount
					  						,@initial_discount_pct
					  						,@initial_discount_amount
					  						,@initial_discount_pph
					  						,@initial_discount_ppn
					  						,@initial_admin_fee_amount
					  						,@initial_stamp_fee_amount
					  						,@buy_amount
					  						,@coverage_code
					  						,@year_period
					  				end
					  				
					  				close curr_pol_asset_coverage
					  				deallocate curr_pol_asset_coverage
					  				
					  			
					  			    fetch next from curr_pol_asset 
					  				into @fa_code
					  					,@sum_insured
					  					,@depreciation_code
					  					,@collateral_type
					  					,@collateral_category_code
					  					,@occupation_code
					  					,@region_code
					  					,@collateral_year
					  					,@is_authorized_workshop
					  					,@is_commercial
					  					,@sppa_detail_id
										,@accessories
										,@insert_type
										,@insurance_policy_main_code
					  			end
					  			
					  			close curr_pol_asset
					  			deallocate curr_pol_asset

							--begin -- update hasil summary ke header
					  		select	 @sum_buy_amount				= isnull(sum(ipac.buy_amount),0)
					  				,@sum_initial_discount_amount	= isnull(sum(ipac.initial_discount_amount),0)
					  				,@sum_initial_admin_fee_amount	= isnull(sum(ipac.initial_admin_fee_amount),0)
					  				,@sum_initial_stamp_fee_amount	= isnull(sum(ipac.initial_stamp_fee_amount),0)
					  				,@sum_initial_discount_pct		= isnull(sum(ipac.initial_discount_pct),0)
					  		from dbo.insurance_policy_asset_coverage ipac
					  		left join dbo.insurance_policy_asset ipa on (ipac.register_asset_code = ipa.code and ipa.insert_type = 'NEW')
					  		where ipa.policy_code = @policy_code
					  
					  		-- summary ke header
					  		update	dbo.insurance_policy_main
					  		set		total_premi_buy_amount	= @sum_buy_amount
					  				,total_discount_amount	= @sum_initial_discount_amount
					  				,total_adjusment_amount	= 0
					  				,total_net_premi_amount = @sum_buy_amount - @sum_initial_discount_amount
					  				,stamp_fee_amount		= @sum_initial_stamp_fee_amount
					  				,admin_fee_amount		= @sum_initial_admin_fee_amount
					  				--
					  				,mod_date				= @p_mod_date		
					  				,mod_by					= @p_mod_by			
					  				,mod_ip_address			= @p_mod_ip_address
					  		where code						= @policy_code
					  	end
					  
					  		begin -- update ke period
					  			declare curr_update_period cursor fast_forward read_only for
					  			select	 sum(ipac.buy_amount)
					  					,sum(ipac.initial_discount_pct)
					  					,sum(ipac.initial_discount_amount)
					  					,sum(ipac.initial_admin_fee_amount)
					  					,sum(ipac.initial_stamp_fee_amount)
					  					,ipac.coverage_code
					  			from dbo.insurance_policy_asset_coverage ipac
					  			left join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
					  			where ipa.policy_code = @insurance_policy_main_code
					  			group by ipac.coverage_code
					  	
					  			open curr_update_period
					  	
					  			fetch next from curr_update_period 
					  			into @period_buy_amount
					  				,@period_initial_discount_pct
					  				,@period_initial_discount_amount
					  				,@period_initial_admin_fee_amount
					  				,@period_initial_stamp_fee_amount
					  				,@coverage_code
					  			
					  			while @@fetch_status = 0
					  			begin
					  			    --summary ke period per coverage
					  				update	dbo.insurance_policy_main_period
					  				set		buy_amount				= @period_buy_amount
					  						,discount_pct			= @period_initial_discount_pct
					  						,discount_amount		= @period_initial_discount_amount
					  						,admin_fee_amount		= @period_initial_admin_fee_amount
					  						,stamp_fee_amount		= @period_initial_stamp_fee_amount
					  						,adjustment_amount		= 0
					  						,total_buy_amount		= @period_buy_amount - @period_initial_discount_amount + @period_initial_admin_fee_amount + @period_initial_stamp_fee_amount
					  						--
					  						,mod_date				= @p_mod_date		
					  						,mod_by					= @p_mod_by			
					  						,mod_ip_address			= @p_mod_ip_address
					  				where policy_code = @policy_code
					  				and coverage_code = @coverage_code
					  			
					  			    fetch next from curr_update_period 
					  				into @period_buy_amount
					  					,@period_initial_discount_pct
					  					,@period_initial_discount_amount
					  					,@period_initial_admin_fee_amount
					  					,@period_initial_stamp_fee_amount
					  					,@coverage_code
					  			end
					  	
					  			close curr_update_period
					  			deallocate curr_update_period

					  		end
						end
						else if (@register_type = 'PERIOD')
						begin
							declare curr_add_peiode_coverage cursor fast_forward read_only for
							select	ir.policy_code
									,ir.year_period / 12
									,ir.to_date
									,sd.id
									,ipa.code
					  		from dbo.sppa_detail sd
					  		inner join dbo.sppa_request sr on (sr.code = sd.sppa_request_code)
					  		inner join dbo.insurance_register_asset ira on (ira.register_code = sr.register_code and sd.fa_code = ira.fa_code and ira.insert_type = 'EXISTING')
							inner join dbo.insurance_register ir on (ir.code = ira.register_code)
							inner join dbo.insurance_policy_asset ipa on (ipa.policy_code = ir.policy_code and ipa.FA_CODE = ira.FA_CODE)
					  		where ira.register_code = @register_code
							and sd.sppa_code = @p_code

							open curr_add_peiode_coverage
							
							fetch next from curr_add_peiode_coverage 
							into @insurance_policy_main_code
								,@new_year_period
								,@new_to_date
								,@sppa_detail_id
								,@code_policy_asset
							
							while @@fetch_status = 0
							begin
							    --insert ke INSURANCE_POLICY_ASSET_COVERAGE, ambil dari tabel baru
								declare curr_pol_asset_coverage2 cursor fast_forward read_only for
								select	sdac.rate_depreciation 
										,sdac.is_loading
										,sdac.initial_buy_rate
										,sdac.initial_buy_amount
										,sdac.initial_discount_pct
										,sdac.initial_discount_amount
										,sdac.initial_discount_pph
										,sdac.initial_discount_ppn
										,sdac.initial_admin_fee_amount
										,sdac.initial_stamp_fee_amount
										,sdac.buy_amount
										,sdac.coverage_code
										,sdac.year_periode + @max_year_before_add_period
								from dbo.sppa_detail_asset_coverage sdac
								where sdac.sppa_detail_id = @sppa_detail_id

								open curr_pol_asset_coverage2
								
								fetch next from curr_pol_asset_coverage2 
								into @rate_depreciation
									,@is_loading
									,@initial_buy_rate
									,@initial_buy_amount
									,@initial_discount_pct
									,@initial_discount_amount
									,@initial_discount_pph
									,@initial_discount_ppn
									,@initial_admin_fee_amount
									,@initial_stamp_fee_amount
									,@buy_amount
									,@coverage_code
									,@year_period
								
								while @@fetch_status = 0
								begin
									
									exec dbo.xsp_insurance_policy_asset_coverage_insert @p_id							= 0
																						,@p_register_asset_code			= @code_policy_asset
																						,@p_rate_depreciation			= @rate_depreciation
																						,@p_is_loading					= @is_loading
																						,@p_coverage_code				= @coverage_code
																						,@p_year_periode				= @year_period
																						,@p_initial_buy_rate			= @initial_buy_rate
																						,@p_initial_buy_amount			= @initial_buy_amount
																						,@p_initial_discount_pct		= @initial_discount_pct
																						,@p_initial_discount_amount		= @initial_discount_amount
																						,@p_initial_discount_pph		= @initial_discount_pph
																						,@p_initial_discount_ppn		= @initial_discount_ppn
																						,@p_initial_admin_fee_amount	= @initial_admin_fee_amount
																						,@p_initial_stamp_fee_amount	= @initial_stamp_fee_amount
																						,@p_buy_amount					= @buy_amount
																						,@p_coverage_type				= 'NEW'
																						,@p_sppa_code					= @p_code
																						,@p_cre_date					= @p_cre_date	
																						,@p_cre_by						= @p_cre_by	
																						,@p_cre_ip_address				= @p_cre_ip_address
																						,@p_mod_date					= @p_mod_date
																						,@p_mod_by						= @p_mod_by	
																						,@p_mod_ip_address				= @p_mod_ip_address	
									
							
									fetch next from curr_pol_asset_coverage2 
									into @rate_depreciation
										,@is_loading
										,@initial_buy_rate
										,@initial_buy_amount
										,@initial_discount_pct
										,@initial_discount_amount
										,@initial_discount_pph
										,@initial_discount_ppn
										,@initial_admin_fee_amount
										,@initial_stamp_fee_amount
										,@buy_amount
										,@coverage_code
										,@year_period
								end
								
								close curr_pol_asset_coverage2
								deallocate curr_pol_asset_coverage2
							   
							    
							
							    fetch next from curr_add_peiode_coverage 
								into @insurance_policy_main_code
									,@new_year_period
									,@new_to_date
									,@sppa_detail_id
									,@code_policy_asset
							end
							
							close curr_add_peiode_coverage
							deallocate curr_add_peiode_coverage

							declare curr_pol_main cursor fast_forward read_only for
							select	irp.coverage_code
									,@max_year_before_add_period + irp.year_periode
									,irp.is_main_coverage
							from dbo.insurance_register_period irp
							inner join dbo.sppa_request sr on (sr.register_code = irp.register_code)
							where irp.register_code = @register_code
							and sr.sppa_code = @p_code

							open curr_pol_main
							
							fetch next from curr_pol_main 
							into @coverage_code
								,@year_periode
								,@is_main_coverage
							
							while @@fetch_status = 0
							begin
							    --insert dari table baru di grouping per coverage dan year
								exec dbo.xsp_insurance_policy_main_period_insert @p_code						= @code_period
																				 ,@p_policy_code				= @insurance_policy_main_code
																				 ,@p_rate_depreciation			= 0
																				 ,@p_coverage_code				= @coverage_code
																				 ,@p_is_main_coverage			= @is_main_coverage
																				 ,@p_year_periode				= @year_periode
																				 ,@p_adjustment_amount			= 0
																				 ,@p_total_buy_amount			= 0
																				 ,@p_discount_pct				= 0
																				 ,@p_discount_amount			= 0
																				 ,@p_admin_fee_amount			= 0
																				 ,@p_stamp_fee_amount			= 0
																				 ,@p_buy_amount					= 0
																				 ,@p_cre_date					= @p_cre_date
																				 ,@p_cre_by						= @p_cre_by	
																				 ,@p_cre_ip_address				= @p_cre_ip_address
																				 ,@p_mod_date					= @p_mod_date	
																				 ,@p_mod_by						= @p_mod_by	
																				 ,@p_mod_ip_address				= @p_mod_ip_address  
								
							    fetch next from curr_pol_main 
								into @coverage_code
									,@year_periode
									,@is_main_coverage
							end
							
							close curr_pol_main
							deallocate curr_pol_main
	
							select	 @sum_buy_amount				= sum(ipac.buy_amount)
									,@sum_initial_buy_amount		= sum(ipac.initial_buy_amount)
									,@sum_initial_discount_amount	= sum(ipac.initial_discount_amount)
									,@sum_initial_admin_fee_amount	= sum(ipac.initial_admin_fee_amount)
									,@sum_initial_stamp_fee_amount	= sum(ipac.initial_stamp_fee_amount)
									,@sum_initial_discount_pct		= sum(ipac.initial_discount_pct)
							from dbo.insurance_policy_asset_coverage ipac
							left join dbo.insurance_policy_asset ipa on (ipac.register_asset_code = ipa.code and ipac.sppa_code = @p_code)
							where ipa.policy_code = @insurance_policy_main_code

							select	 sum(ipac.buy_amount)
									,sum(ipac.initial_buy_amount)
									,sum(ipac.initial_discount_amount)
									,sum(ipac.initial_admin_fee_amount)
									,sum(ipac.initial_stamp_fee_amount)
									,sum(ipac.initial_discount_pct)
							from dbo.insurance_policy_asset_coverage ipac
							left join dbo.insurance_policy_asset ipa on (ipac.register_asset_code = ipa.code and ipac.sppa_code = @p_code)
							where ipa.policy_code = @insurance_policy_main_code

							-- Update and summary Policy Header
							update	dbo.insurance_policy_main
					  		set		to_year					= to_year + @new_year_period
									,policy_exp_date		= @new_to_date
									,total_premi_buy_amount	= @sum_initial_buy_amount
									,total_discount_amount	= @sum_initial_discount_amount
									,total_adjusment_amount	= 0
									,total_net_premi_amount = @sum_buy_amount
									,stamp_fee_amount		= @sum_initial_stamp_fee_amount
									,admin_fee_amount		= @sum_initial_admin_fee_amount
					  				--
					  				,mod_date				= @p_mod_date		
					  				,mod_by					= @p_mod_by			
					  				,mod_ip_address			= @p_mod_ip_address
					  		where code						= @policy_code

							declare curr_update_period cursor fast_forward read_only for
							select	 sum(ipac.buy_amount)
									,sum(ipac.initial_discount_pct)
									,sum(ipac.initial_discount_amount)
									,sum(ipac.initial_admin_fee_amount)
									,sum(ipac.initial_stamp_fee_amount)
									,ipac.coverage_code
							from dbo.insurance_policy_asset_coverage ipac
							inner join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code and ipac.sppa_code = @p_code)
							where ipa.policy_code = @insurance_policy_main_code
							group by ipac.coverage_code
						
							open curr_update_period
						
							fetch next from curr_update_period 
							into @period_buy_amount
								,@period_initial_discount_pct
								,@period_initial_discount_amount
								,@period_initial_admin_fee_amount
								,@period_initial_stamp_fee_amount
								,@coverage_code
							
							while @@fetch_status = 0
							begin
							    --summary ke period per coverage
								update	dbo.insurance_policy_main_period
								set		buy_amount				= @period_buy_amount
										,discount_pct			= @period_initial_discount_pct
										,discount_amount		= @period_initial_discount_amount
										,admin_fee_amount		= @period_initial_admin_fee_amount
										,stamp_fee_amount		= @period_initial_stamp_fee_amount
										,adjustment_amount		= 0
										,total_buy_amount		= @period_buy_amount - @period_initial_discount_amount + @period_initial_admin_fee_amount + @period_initial_stamp_fee_amount
										--
										,mod_date				= @p_mod_date		
										,mod_by					= @p_mod_by			
										,mod_ip_address			= @p_mod_ip_address
								where policy_code = @insurance_policy_main_code
								and coverage_code = @coverage_code
								and year_periode > @max_year_before_add_period
							
							    fetch next from curr_update_period 
								into @period_buy_amount
									,@period_initial_discount_pct
									,@period_initial_discount_amount
									,@period_initial_admin_fee_amount
									,@period_initial_stamp_fee_amount
									,@coverage_code
							end
						
							close curr_update_period
							deallocate curr_update_period
						end
						

					  	--begin -- update hasil summary ke header
					  	--	select	 @sum_buy_amount				= isnull(sum(ipac.buy_amount),0)
					  	--			,@sum_initial_discount_amount	= isnull(sum(ipac.initial_discount_amount),0)
					  	--			,@sum_initial_admin_fee_amount	= isnull(sum(ipac.initial_admin_fee_amount),0)
					  	--			,@sum_initial_stamp_fee_amount	= isnull(sum(ipac.initial_stamp_fee_amount),0)
					  	--			,@sum_initial_discount_pct		= isnull(sum(ipac.initial_discount_pct),0)
					  	--	from dbo.insurance_policy_asset_coverage ipac
					  	--	left join dbo.insurance_policy_asset ipa on (ipac.register_asset_code = ipa.code and ipa.insert_type = 'NEW')
					  	--	where ipa.policy_code = @policy_code
					  
					  	--	-- summary ke header
					  	--	update	dbo.insurance_policy_main
					  	--	set		total_premi_buy_amount	= @sum_buy_amount
					  	--			,total_discount_amount	= @sum_initial_discount_amount
					  	--			,total_adjusment_amount	= 0
					  	--			,total_net_premi_amount = @sum_buy_amount - @sum_initial_discount_amount
					  	--			,stamp_fee_amount		= @sum_initial_stamp_fee_amount
					  	--			,admin_fee_amount		= @sum_initial_admin_fee_amount
					  	--			--
					  	--			,mod_date				= @p_mod_date		
					  	--			,mod_by					= @p_mod_by			
					  	--			,mod_ip_address			= @p_mod_ip_address
					  	--	where code						= @policy_code
					  	--end
					  
					  	--begin -- update ke period
					  	--	declare curr_update_period cursor fast_forward read_only for
					  	--	select	 sum(ipac.buy_amount)
					  	--			,sum(ipac.initial_discount_pct)
					  	--			,sum(ipac.initial_discount_amount)
					  	--			,sum(ipac.initial_admin_fee_amount)
					  	--			,sum(ipac.initial_stamp_fee_amount)
					  	--			,ipac.coverage_code
					  	--	from dbo.insurance_policy_asset_coverage ipac
					  	--	left join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
					  	--	where ipa.policy_code = @insurance_policy_main_code
					  	--	group by ipac.coverage_code
					  	
					  	--	open curr_update_period
					  	
					  	--	fetch next from curr_update_period 
					  	--	into @period_buy_amount
					  	--		,@period_initial_discount_pct
					  	--		,@period_initial_discount_amount
					  	--		,@period_initial_admin_fee_amount
					  	--		,@period_initial_stamp_fee_amount
					  	--		,@coverage_code
					  		
					  	--	while @@fetch_status = 0
					  	--	begin
					  	--	    --summary ke period per coverage
					  	--		update	dbo.insurance_policy_main_period
					  	--		set		buy_amount				= @period_buy_amount
					  	--				,discount_pct			= @period_initial_discount_pct
					  	--				,discount_amount		= @period_initial_discount_amount
					  	--				,admin_fee_amount		= @period_initial_admin_fee_amount
					  	--				,stamp_fee_amount		= @period_initial_stamp_fee_amount
					  	--				,adjustment_amount		= 0
					  	--				,total_buy_amount		= @period_buy_amount - @period_initial_discount_amount + @period_initial_admin_fee_amount + @period_initial_stamp_fee_amount
					  	--				--
					  	--				,mod_date				= @p_mod_date		
					  	--				,mod_by					= @p_mod_by			
					  	--				,mod_ip_address			= @p_mod_ip_address
					  	--		where policy_code = @policy_code
					  	--		and coverage_code = @coverage_code
					  		
					  	--	    fetch next from curr_update_period 
					  	--		into @period_buy_amount
					  	--			,@period_initial_discount_pct
					  	--			,@period_initial_discount_amount
					  	--			,@period_initial_admin_fee_amount
					  	--			,@period_initial_stamp_fee_amount
					  	--			,@coverage_code
					  	--	end
					  	
					  	--	close curr_update_period
					  	--	deallocate curr_update_period
					  	--end
					  
					  	begin -- insert ke history
					  		-- INSERT HISTORY
					  		exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0,					   
					  					                                        @p_policy_code		= @policy_code,		 
					  					                                        @p_history_date		= @p_mod_date,						 
					  					                                        @p_history_type		= 'ADDITIONAL', 						 
					  					                                        @p_policy_status	= 'ACTIVE',						 
					  					                                        @p_history_remarks	=  @register_remarks,				 
					  					                                        @p_cre_date			= @p_cre_date,						 
					  					                                        @p_cre_by			= @p_cre_by,						 
					  					                                        @p_cre_ip_address	= @p_cre_ip_address,				 
					  					                                        @p_mod_date			= @p_mod_date,						 
					  					                                        @p_mod_by			= @p_mod_by,						 
					  					                                        @p_mod_ip_address	= @p_mod_ip_address
					  	end
					  end	 
						
				end
				else if @result_status = 'REJECT'
				begin
						 update dbo.sppa_request
					     set	register_status = 'HOLD'
					     		,sppa_code		= null
					     where	code			= @p_code 
				end
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




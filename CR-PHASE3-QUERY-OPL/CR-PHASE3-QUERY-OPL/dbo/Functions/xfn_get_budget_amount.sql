CREATE FUNCTION dbo.xfn_get_budget_amount
(
	@p_class_code	   nvarchar(50)
	, @p_date		   datetime
	, @p_type		   nvarchar(15)
	, @p_unit_amount   decimal(18, 2)
	, @p_vat_amount	   decimal(18, 2)
	, @p_unit_code	   nvarchar(50)	 = null
	, @p_start_miles   int			 = 0
	, @p_monthly_miles int			 = 0
	, @p_periode	   int			 = 0
	, @p_year		   int			 = 0
	, @p_location	   nvarchar(10)  = ''
)
returns decimal(18, 2)
as
begin
	declare @total_budget_amount decimal(18, 2) = 0
			, @maintenence_code	 nvarchar(50)
			, @current_inflation_year1		 decimal(9, 5) 
			, @inflation		 decimal(9, 5) ;
			
	begin
		if (@p_type = 'MAINTENANCE')
		begin
			select	@maintenence_code = code
					, @inflation	  = inflation
			from	master_budget_maintenance
			where	unit_code	 = @p_unit_code
					and year	 = @p_year
					and location = @p_location
					and exp_date >= dbo.xfn_get_system_date() ;

			declare @detail_prob			   decimal(9, 6)
					,@detail_cycle_by		   nvarchar(5)
					,@detail_cycle_km		   int
					,@detail_unit			   decimal(18, 2)
					,@detail_cost			   decimal(18, 2)
					,@detail_labor			   decimal(18, 2)
					,@detail_total_cost		   decimal(18, 2) = 0
					,@current_period		   int			  = 1
					,@current_detail_cycle_km  int			  = 1
					,@current_inflation		   decimal(9, 6)  = 100
					,@cost_by_periode_before   decimal(18, 2) = 0
					,@cost_by_periode		   decimal(18, 2)
					,@cost_all_periode		   decimal(18, 2) = 0
					,@cost_all_service_periode decimal(18, 2) = 0 ;

			declare curr_budget_detail cursor fast_forward read_only for
			select
					grup.probability_pct
					, svc.unit_qty
					, svc.unit_cost
					, svc.labor_cost
					, svc.replacement_type
					, svc.replacement_cycle
			from	dbo.master_budget_maintenance_group_service	   svc
					inner join dbo.master_budget_maintenance_group grup on (grup.code = svc.budget_maintenance_group_code)
			where	svc.budget_maintenance_code = @maintenence_code
			and		(svc.unit_qty > 0 or svc.unit_cost > 0 or svc.labor_cost > 0)
			and		svc.replacement_cycle > 0 ;

			open curr_budget_detail ;

			fetch next from curr_budget_detail
			into @detail_prob
				 , @detail_unit
				 , @detail_cost
				 , @detail_labor
				 , @detail_cycle_by
				 , @detail_cycle_km ;

				while @@fetch_status = 0
				begin
					while @current_period <= @p_periode -- periode disini diisi bulan
					begin
			 
						if (@detail_cycle_by = 'MILES')
						begin
							-- 'perhitungan biaya per jenis' ;
							set @detail_total_cost = (@detail_cost * @detail_unit * @detail_prob / 100) + @detail_labor ;

							if(@current_period = 1)
							begin
								if (@p_start_miles > 0)
								begin
									set @cost_by_periode_before = floor(@p_start_miles / @detail_cycle_km) * @detail_total_cost ;
								end
							end

							set @current_detail_cycle_km = @p_start_miles + (@current_period * @p_monthly_miles) ;
							 
							set @cost_by_periode = floor(@current_detail_cycle_km / @detail_cycle_km) * @detail_total_cost ;

						end ;
						else
						begin --@detail_cycle_by = 'MONTH'
							set @detail_total_cost = (@detail_cost * @detail_unit * @detail_prob / 100) + @detail_labor ;
						 
							set @cost_by_periode = floor((@current_period *1.0) / @detail_cycle_km) * @detail_total_cost ;
				 
										
						end ;

						-- naikkan inflasi per tahun
						if (@current_period > 12 and @current_period <= 24) -- tahun 1 naik + inflasi
						begin
							set @current_inflation = 100.00 + @inflation  ;
							set @current_inflation_year1 = @current_inflation
						end 
						else if (@current_period > 24) -- tahun 2 naik ^ inflasi tahun 1
						begin
							set @current_inflation =  ((power( @current_inflation_year1/100,(ceiling(@current_period * 1.0 / 12) ) -1))  ) *100 ;
						end 
						-- total biaya per periode
						set @cost_all_periode = @cost_all_periode + ((@cost_by_periode - @cost_by_periode_before) * (@current_inflation / 100) );
					

						-- set variabel for next loop
						set @cost_by_periode_before = @cost_by_periode ;
						set @current_period = @current_period + 1 ;
					end ;

					set @cost_all_service_periode = @cost_all_service_periode + @cost_all_periode ;

					-- reset all variable by service
					set @current_inflation = 100
					set @current_period = 1 ;
					set @cost_by_periode_before = 0 ;
					set @cost_all_periode = 0 ;

					fetch next from curr_budget_detail
					into @detail_prob
							, @detail_unit
							, @detail_cost
							, @detail_labor
							, @detail_cycle_by
							, @detail_cycle_km ;
				end ;


				close curr_budget_detail ;
				deallocate curr_budget_detail ;
		 
		end 
		else
		begin
			select	top 1 @cost_all_service_periode = ((@p_unit_amount + @p_vat_amount) * (mbd.budget_rate / 100)) * @p_periode --periode disini diisi tahun
			from	dbo.master_budget_detail	 mbd
					inner join dbo.master_budget mb on (mb.code = mbd.budget_code)
			where	mb.exp_date		  >= @p_date
					and mb.type		  = @p_type
					and mb.class_code = @p_class_code
					and is_active	  = '1' 
			order by mbd.eff_date desc 
		end ;
	end ;

	return @cost_all_service_periode ;
end ;


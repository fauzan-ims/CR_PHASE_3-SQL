CREATE PROCEDURE [dbo].[xsp_master_budget_maintenance_simulation_getrows]
(
	@p_keywords					nvarchar(50) 
	,@p_pagenumber				int 
	,@p_rowspage				int 
	,@p_order_by				int 
	,@p_sort_by					nvarchar(5) = ''
	,@p_budget_maintenance_code nvarchar(50) = ''
	,@p_periode					nvarchar(10) = ''
	,@p_start_miles				bigint		 = 0
	,@p_monthly_miles			bigint		 = 0
	,@p_unit_code				nvarchar(50) = ''
	,@p_year					bigint		 = 0
	,@p_location				nvarchar(50) = ''
)
as
begin
	declare @total_budget_amount	  decimal(18, 2) = 0
			,@maintenence_code		  nvarchar(50)
			,@current_inflation_year1 decimal(9, 5)
			,@inflation				  decimal(9, 5)

	declare @table_temp table
	(
		month		   bigint
		,total_cost	   decimal(18, 2)
		,average_month decimal(18, 2)
		,type		   nvarchar(50)
	)

	declare @table_temp2 table
	(
		month		   bigint
		,total_cost	   decimal(18, 2)
		,average_month decimal(18, 2)
		,type		   nvarchar(50)
	)


	select	@maintenence_code = code
			,@inflation = inflation
	from	master_budget_maintenance
	where	code = @p_budget_maintenance_code ;

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
			,@cost_all_service_periode decimal(18, 2) = 0 
			,@interval				   bigint = 0
			,@yearly				   bigint
			,@monthly				   bigint
			,@next_monthly_miles	   bigint = 0 
			,@next_monthly			   bigint = 0 
			,@month					   bigint = 12
			,@rows_count			   int = 0 
			,@i					       int = 1
			,@total_cost			   decimal(18,2) = 0
			,@total_cost_month		   decimal(18,2)
			,@avg_cost				   decimal(18,2)
			,@peryear				   bigint = 12
			,@permonth				   bigint = 12
			,@cost_periode_not_null	   decimal(18,2) = 0
			,@first_period			   decimal(18,2) = 1

			
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

						if(@detail_cycle_by = 'MILES')
						begin
							set @total_cost = @cost_all_periode--@cost_by_periode

							if(@current_period = @peryear)
							begin
								if not exists(select 1 from @table_temp where type = @detail_cycle_by and month = @current_period)--(@current_period * @month))
								begin
									insert into @table_temp
									(
										month
										,total_cost
										,average_month
										,type
									)
									values
									(
										@current_period --* @month
										,@cost_all_periode--@cost_by_periode 
										,@cost_all_periode--@cost_by_periode --/(@current_period * @month)
										,@detail_cycle_by
									)
									set @peryear = @peryear + @month
								end
								else
								begin 
									update	@table_temp
									set		total_cost = total_cost + @total_cost
									where	type = @detail_cycle_by
									and		month = @current_period--(@current_period * @month)

									set @peryear = @peryear + @month
								end
							end

							if(@peryear > @p_periode)
							begin
								set @peryear = @month
							end
						end
						else
						begin
							set @total_cost = @cost_by_periode

							if(@current_period = @peryear)
							begin
								if not exists(select 1 from @table_temp where type = @detail_cycle_by and month = @current_period)--(@current_period * @month))
								begin
									insert into @table_temp
									(
										month
										,total_cost
										,average_month
										,type
									)
									values
									(
										@current_period --* @month
										,@cost_all_periode--@cost_by_periode
										,@cost_all_periode--@cost_by_periode --/ (@current_period * @month)
										,@detail_cycle_by
									)
									set @peryear = @peryear + @month
								end
								else
								begin
									update	@table_temp
									set		total_cost = total_cost + @total_cost
									where	type = @detail_cycle_by
									and		month = @current_period

									set @peryear = @peryear + @month
								end
							end

							if(@peryear > @p_periode)
							begin
								set @peryear = @month
							end
						end
					

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
		 


	--select	@rows_count = count(1)
	--from	@table_temp 
	--where	(
	--			month				like '%' + @p_keywords + '%'
	--			or total_cost		like '%' + @p_keywords + '%'
	--			or average_month	like '%' + @p_keywords + '%'
	--		)


	insert into @table_temp2
	(
		month
		,total_cost
		,average_month
		--,type
	)
	select		month
				,sum(total_cost)
				,sum(total_cost)--cast((total_cost/@month) as decimal(18,2)) 'average_month'
				--,type
				--,@rows_count 'rowcount'
	from		@table_temp
	group by	month


	select	@rows_count = count(1)
	from	@table_temp2 
	--where	(
	--			month				like '%' + @p_keywords + '%'
	--			or total_cost		like '%' + @p_keywords + '%'
	--			or average_month	like '%' + @p_keywords + '%'
	--		)

	select		month
				,round(total_cost,0)'total_cost'
				--,round(cast((total_cost/@month) as decimal(18,2)),0) 'average_month'
				,round(cast((total_cost/month) as decimal(18,2)),0) 'average_month'
				--,type
				,@rows_count 'rowcount'
	from		@table_temp2
	where		(
					month				like '%' + @p_keywords + '%'
					or total_cost		like '%' + @p_keywords + '%'
					or average_month	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(month as sql_variant)
													 when 2 then cast(total_cost as sql_variant)
													 when 3 then cast(average_month as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then cast(month as sql_variant)
													   when 2 then cast(total_cost as sql_variant)
													   when 3 then cast(average_month as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;

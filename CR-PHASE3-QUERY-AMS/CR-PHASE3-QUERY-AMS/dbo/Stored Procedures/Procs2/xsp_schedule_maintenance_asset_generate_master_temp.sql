create PROCEDURE dbo.xsp_schedule_maintenance_asset_generate_master_temp
(
	--@p_service_code	   nvarchar(50)
	@p_code				nvarchar(50)
	,@p_model_code		nvarchar(50)
	--
	,@p_cre_by			nvarchar(15)
	,@p_cre_date		datetime
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_by			nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@code						 nvarchar(50)
			,@usefull					 int
			,@maintenance_time			 int
			,@date_purc					 datetime
			,@maintenance_date			 datetime
			,@maintenance_type			 nvarchar(50)
			,@maintenance_cycle_time	 int
			,@asset_no					 nvarchar(10)
			,@maintenance_no			 int		  = 0
			,@counter_cycle				 int
			,@counter					 int
			,@week						 int
			,@day						 int
			,@miles_maintenance_vhcl	 int
			,@miles_result_vhcl			 int
			,@month_maintenance_vhcl	 int
			,@month_result_vhcl			 int
			,@hour_maintenance_vhcl		 int
			,@hour_result_vhcl			 int
			,@is_miles_vhcl				 int
			,@is_month_vhcl				 int
			,@is_hour_vhcl				 int
			,@miles_maintenance_elect	 int
			,@miles_result_elect		 int
			,@month_maintenance_elect	 int
			,@month_result_elect		 int
			,@hour_maintenance_elect	 int
			,@hour_result_elect			 int
			,@is_miles_elect			 int
			,@is_month_elect			 int
			,@is_hour_elect				 int
			,@miles_maintenance_furni	 int
			,@miles_result_furni		 int
			,@month_maintenance_furni	 int
			,@month_result_furni		 int
			,@hour_maintenance_furni	 int
			,@hour_result_furni			 int
			,@is_miles_furni			 int
			,@is_month_furni			 int
			,@is_hour_furni				 int
			,@miles_maintenance_mach	 int
			,@miles_result_mach			 int
			,@month_maintenance_mach	 int
			,@month_result_mach			 int
			,@hour_maintenance_mach		 int
			,@hour_result_mach			 int
			,@is_miles_mach				 int
			,@is_month_mach				 int
			,@is_hour_mach				 int 
			,@type_code					 nvarchar(50)
			,@model_code_vhcl			 nvarchar(50)
			,@model_code_elect			 nvarchar(50)
			,@model_code_furni			 nvarchar(50)
			,@model_code_mchn			 nvarchar(50)
			,@service_code				 nvarchar(50)
			,@desc_service				 nvarchar(250);

	begin try
		if exists
		(
			select	1
			from	dbo.asset_maintenance_schedule
			where	asset_code			   = @p_code
					and maintenance_status = 'DONE'
		)
		begin
			raiserror('Generate failed. There are already processed data', 16, 1) ;
			return ;
		end ;

		if(@model_code_vhcl = null or @model_code_vhcl = '')
		begin
			set @msg = 'Please Insert Model Detail Vehicle';
			raiserror(@msg ,16,-1);
		end

		if(@model_code_elect = null or @model_code_elect = '')
		begin
			set @msg = 'Please Insert Model Detail Electronic';
			raiserror(@msg ,16,-1);
		end

		if(@model_code_furni = null or @model_code_furni = '')
		begin
			set @msg = 'Please Insert Model Detail Furniture';
			raiserror(@msg ,16,-1);
		end

		if(@model_code_mchn = null or @model_code_mchn = '')
		begin
			set @msg = 'Please Insert Model Detail Machine';
			raiserror(@msg ,16,-1);
		end
		
		select	@maintenance_no = min(maintenance_no)
		from	dbo.asset_maintenance_schedule
		where	asset_code = @p_code ;

		update dbo.asset
		set		use_life = mdcc.usefull
		from	dbo.asset ast
		inner join dbo.master_depre_category_commercial mdcc on ast.depre_category_comm_code = mdcc.code
		where ast.code = @p_code
		
		declare curr_generate_master cursor fast_forward read_only FOR
        
		select	ass.code														
				,maintenance_time
				,maintenance_type
				,ass.maintenance_cycle_time
				,ass.purchase_date
				,ass.use_life
				,ass.type_code
				,mmd.is_miles
				,mmd.is_month
				,mmd.is_hour
				,mmd.miles_cycle
				,mmd.month_cycle
				,mmd.hour_cycle
				,avh.model_code
				,asce.model_code
				,asf.model_code
				,asm.model_code
				--,amt.service_code
				,mmd.service_code
				,ms.description
		from	dbo.asset ass
				--left join dbo.master_depre_category_commercial mdc on (mdc.code = ass.depre_category_comm_code and mdc.company_code = ass.company_code)
				left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
				left join dbo.asset_electronic asce on (asce.asset_code = ass.code)
				left join dbo.asset_furniture asf on (asf.asset_code = ass.code)
				left join dbo.asset_machine asm on (asm.asset_code = ass.code)
				left join ifinbam.dbo.master_model_detail mmd on (avh.model_code = mmd.model_code)
				left join ifinbam.dbo.master_service ms on (ms.code = mmd.service_code)
				--left join dbo.asset_maintenance_temp amt on (ass.code = amt.asset_code)
				--left join ifinbam.dbo.master_model_detail mmd on (amt.service_code = mmd.service_code)
				--left join ifinbam.dbo.master_service ms on (ms.code = amt.service_code)
		where	ass.code = @p_code 
				--and amt.service_code = @p_service_code
				and	mmd.model_code = @p_model_code; 
				
		open curr_generate_master
		
		fetch next from curr_generate_master 
		into 
			 @code						
			,@maintenance_time			
			,@maintenance_type			
			,@maintenance_cycle_time	
			,@date_purc					
			,@usefull					
			,@type_code					
			,@is_miles_vhcl				
			,@is_month_vhcl				
			,@is_hour_vhcl				
			,@miles_maintenance_vhcl
			,@month_maintenance_vhcl
			,@hour_maintenance_vhcl	
			,@model_code_vhcl			
			,@model_code_elect			
			,@model_code_furni			
			,@model_code_mchn			
			,@service_code				
			,@desc_service				
			
		while @@fetch_status = 0
		begin
				
				if @maintenance_type = 'MONTH'	
				begin
					set @usefull = (@usefull * 12) / @maintenance_time ;
					set @maintenance_date = dateadd(month, @month_maintenance_vhcl, cast(@date_purc as date)) ;
					set @counter = 1 ;

						if(@is_miles_vhcl = '1')
						begin
							set @miles_result_vhcl = @miles_maintenance_vhcl;
							--set @maintenance_date = null;
						end
						else
						begin
							set @miles_result_vhcl = 0;
						end

						if(@is_month_vhcl = '1')
						begin
							set @month_result_vhcl = @month_maintenance_vhcl;
						end
						else
						begin
							set @month_result_vhcl = 0;
						end

						if(@is_hour_vhcl = '1')
						begin
							set	@hour_result_vhcl = @hour_maintenance_vhcl;
							--set @maintenance_date = null;
						end
						else
						begin
							set @hour_result_vhcl = 0;
						end
				
					while (@counter <= @usefull)
					begin
						set @counter_cycle = 1 ;

						while (@counter_cycle <= @maintenance_cycle_time)
						begin
							set @maintenance_no = isnull(@maintenance_no, 0) + 1 ;

												
								exec dbo.xsp_asset_maintenance_schedule_insert @p_id					 = 0
																			   ,@p_asset_code			 = @p_code
																			   ,@p_maintenance_no		 = @maintenance_no
																			   ,@p_maintenance_date		 = @maintenance_date
																			   ,@p_maintenance_status	 = 'NOT DUE'
																			   ,@p_last_status_date		 = @p_cre_date
																			   ,@p_reff_trx_no			 = @msg --''
																			   ,@p_miles				 = @miles_result_vhcl
																			   ,@p_month				 = @month_result_vhcl
																			   ,@p_hour					 = @hour_result_vhcl
																			   ,@p_service_code			 = @service_code
																			   ,@p_service_name			 = @desc_service
																			   ,@p_cre_by				 = @p_cre_by
																			   ,@p_cre_date				 = @p_cre_date
																			   ,@p_cre_ip_address		 = @p_cre_ip_address
																			   ,@p_mod_by				 = @p_mod_by
																			   ,@p_mod_date				 = @p_mod_date
																			   ,@p_mod_ip_address		 = @p_mod_ip_address
								
						
						
							set @maintenance_date = dateadd(month, @month_maintenance_vhcl, cast(@maintenance_date as date)) ;
							set @counter_cycle = @counter_cycle + 1 ;

								if(@is_miles_vhcl = '1')
								begin
									set @miles_result_vhcl = @miles_result_vhcl + @miles_maintenance_vhcl
								end
								else
								begin
									set @miles_result_vhcl = 0;
								end

								if(@is_month_vhcl = '1')
								begin
									set @month_result_vhcl = @month_result_vhcl + @month_maintenance_vhcl;
								end
								else
								begin
									set @month_result_vhcl = 0;
								end

								if(@is_hour_vhcl = '1')
								begin
									set	@hour_result_vhcl = @hour_result_vhcl + @hour_maintenance_vhcl;
								end
								else
								begin
									set @hour_result_vhcl = 0;
								end
						end ;
								set @counter = @counter + 1 ;
							end ;
				end ;
				else if @maintenance_type = 'WEEK'
				begin
					set @week = 52 ;
					set @usefull = (@usefull * @week) / @maintenance_time ;
					set @maintenance_date = dateadd(week, @month_maintenance_vhcl, cast(@date_purc as date)) ;
					set @counter = 1 ;

				
						if(@is_miles_vhcl = '1')
						begin
							set @miles_result_vhcl = @miles_maintenance_vhcl;
							--set @maintenance_date = null;
						end
						else
						begin
							set @miles_result_vhcl = 0;
						end

						if(@is_month_vhcl = '1')
						begin
							set @month_result_vhcl = @month_maintenance_vhcl;
						end
						else
						begin
							set @month_result_vhcl = 0;
						end

						if(@is_hour_vhcl = '1')
						begin
							set	@hour_result_vhcl = @hour_maintenance_vhcl;
							--set @maintenance_date = null;
						end
						else
						begin
							set @hour_result_vhcl = 0;
						end
					
					
			while (@counter <= @usefull)
			begin
				set @counter_cycle = 1 ;

				while (@counter_cycle <= @maintenance_cycle_time)
				begin
					set @maintenance_no = isnull(@maintenance_no, 0) + 1 ;

					
						exec dbo.xsp_asset_maintenance_schedule_insert @p_id					 = 0
																		,@p_asset_code			 = @p_code
																		,@p_maintenance_no		 = @maintenance_no
																		,@p_maintenance_date	 = @maintenance_date
																		,@p_maintenance_status	 = 'NOT DUE'
																		,@p_last_status_date	 = @p_cre_date
																		,@p_reff_trx_no			 = @msg --''
																		,@p_miles				 = @miles_result_vhcl
																		,@p_month				 = @month_result_vhcl
																		,@p_hour				 = @hour_result_vhcl
																		,@p_service_code		 = @service_code
																		,@p_service_name		 = @desc_service
																		,@p_cre_by				 = @p_cre_by
																		,@p_cre_date			 = @p_cre_date
																		,@p_cre_ip_address		 = @p_cre_ip_address
																		,@p_mod_by				 = @p_mod_by
																		,@p_mod_date			 = @p_mod_date
																		,@p_mod_ip_address		 = @p_mod_ip_address
				
					set @maintenance_date = dateadd(week, @month_maintenance_vhcl, cast(@maintenance_date as date)) ;
					set @counter_cycle = @counter_cycle + 1 ;

					
						if(@is_miles_vhcl = '1')
						begin
							set @miles_result_vhcl = @miles_result_vhcl + @miles_maintenance_vhcl
						end
						else
						begin
							set @miles_result_vhcl = 0;
						end

						if(@is_month_vhcl = '1')
						begin
							set @month_result_vhcl = @month_result_vhcl + @month_maintenance_vhcl;
						end
						else
						begin
							set @month_result_vhcl = 0;
						end

						if(@is_hour_vhcl = '1')
						begin
							set	@hour_result_vhcl = @hour_result_vhcl + @hour_maintenance_vhcl;
						end
						else
						begin
							set @hour_result_vhcl = 0;
						end
                        
				end ;
						set @counter = @counter + 1 ;
					end ;
		end ;
				else if @maintenance_type = 'DAY'
				begin
					set @day = datepart(dayofyear, dateadd(day, -1, '1/1/' + convert(char(4), datepart(year, @date_purc) + 1))) ;
					set @usefull = (@usefull * @day) / @maintenance_time ;
					set @maintenance_date = dateadd(day, @month_maintenance_vhcl, cast(@date_purc as date)) ;
					set @counter = 1 ;

					
						if(@is_miles_vhcl = '1')
						begin
							set @miles_result_vhcl = @miles_maintenance_vhcl;
							--set @maintenance_date = null;
						end
						else
						begin
							set @miles_result_vhcl = 0;
						end

						if(@is_month_vhcl = '1')
						begin
							set @month_result_vhcl = @month_maintenance_vhcl;
						end
						else
						begin
							set @month_result_vhcl = 0;
						end

						if(@is_hour_vhcl = '1')
						begin
							set	@hour_result_vhcl = @hour_maintenance_vhcl;
							--set @maintenance_date = null;
						end
						else
						begin
							set @hour_result_vhcl = 0;
						end
					

			while (@counter <= @usefull)
			begin
				set @counter_cycle = 1 ;

				while (@counter_cycle <= @maintenance_cycle_time)
				begin
					set @maintenance_no = isnull(@maintenance_no, 0) + 1 ;

					
						exec dbo.xsp_asset_maintenance_schedule_insert @p_id					 = 0
																		,@p_asset_code			 = @p_code
																		,@p_maintenance_no		 = @maintenance_no
																		,@p_maintenance_date	 = @maintenance_date
																		,@p_maintenance_status	 = 'NOT DUE'
																		,@p_last_status_date	 = @p_cre_date
																		,@p_reff_trx_no			 = @msg --''
																		,@p_miles				 = @miles_result_vhcl
																		,@p_month				 = @month_result_vhcl
																		,@p_hour				 = @hour_result_vhcl
																		,@p_service_code		 = @service_code
																		,@p_service_name		 = @desc_service
																		,@p_cre_by				 = @p_cre_by
																		,@p_cre_date			 = @p_cre_date
																		,@p_cre_ip_address		 = @p_cre_ip_address
																		,@p_mod_by				 = @p_mod_by
																		,@p_mod_date			 = @p_mod_date
																		,@p_mod_ip_address		 = @p_mod_ip_address
				
					

					set @maintenance_date = dateadd(day, @month_maintenance_vhcl, cast(@maintenance_date as date)) ;
					set @counter_cycle = @counter_cycle + 1 ;

					
						if(@is_miles_vhcl = '1')
						begin
							set @miles_result_vhcl = @miles_result_vhcl + @miles_maintenance_vhcl
						end
						else
						begin
							set @miles_result_vhcl = 0;
						end

						if(@is_month_vhcl = '1')
						begin
							set @month_result_vhcl = @month_result_vhcl + @month_maintenance_vhcl;
						end
						else
						begin
							set @month_result_vhcl = 0;
						end

						if(@is_hour_vhcl = '1')
						begin
							set	@hour_result_vhcl = @hour_result_vhcl + @hour_maintenance_vhcl;
						end
						else
						begin
							set @hour_result_vhcl = 0;
						end
				end ;

				set @counter = @counter + 1 ;
			end ;
		end ;
				else if @maintenance_type = 'YEAR'
				begin
					set @maintenance_date = dateadd(year, @month_maintenance_vhcl, cast(@date_purc as date)) ;
					set @counter = 1 ;

					
						if(@is_miles_vhcl = '1')
						begin
							set @miles_result_vhcl = @miles_maintenance_vhcl;
							--set @maintenance_date = null;
						end
						else
						begin
							set @miles_result_vhcl = 0;
						end

						if(@is_month_vhcl = '1')
						begin
							set @month_result_vhcl = @month_maintenance_vhcl;
						end
						else
						begin
							set @month_result_vhcl = 0;
						end

						if(@is_hour_vhcl = '1')
						begin
							set	@hour_result_vhcl = @hour_maintenance_vhcl;
							--set @maintenance_date = null;
						end
						else
						begin
							set @hour_result_vhcl = 0;
						end
					
					while (@counter <= @usefull)
					begin
						set @counter_cycle = 1 ;

						while (@counter_cycle <= @maintenance_cycle_time)
						begin
							set @maintenance_no = isnull(@maintenance_no, 0) + 1 ;

						
								exec dbo.xsp_asset_maintenance_schedule_insert @p_id					 = 0
																				,@p_asset_code			 = @p_code
																				,@p_maintenance_no		 = @maintenance_no
																				,@p_maintenance_date	 = @maintenance_date
																				,@p_maintenance_status	 = 'NOT DUE'
																				,@p_last_status_date	 = @p_cre_date
																				,@p_reff_trx_no			 = @msg --''
																				,@p_miles				 = @miles_result_vhcl
																				,@p_month				 = @month_result_vhcl
																				,@p_hour				 = @hour_result_vhcl
																				,@p_service_code		 = @service_code
																				,@p_service_name		 = @desc_service
																				,@p_cre_by				 = @p_cre_by
																				,@p_cre_date			 = @p_cre_date
																				,@p_cre_ip_address		 = @p_cre_ip_address
																				,@p_mod_by				 = @p_mod_by
																				,@p_mod_date			 = @p_mod_date
																				,@p_mod_ip_address		 = @p_mod_ip_address
							
							set @maintenance_date = dateadd(year, @month_maintenance_vhcl, cast(@maintenance_date as date)) ;
							set @counter_cycle = @counter_cycle + 1 ;

							
								if(@is_miles_vhcl = '1')
								begin
									set @miles_result_vhcl = @miles_result_vhcl + @miles_maintenance_vhcl
								end
								else
								begin
									set @miles_result_vhcl = 0;
								end

								if(@is_month_vhcl = '1')
								begin
									set @month_result_vhcl = @month_result_vhcl + @month_maintenance_vhcl;
								end
								else
								begin
									set @month_result_vhcl = 0;
								end

								if(@is_hour_vhcl = '1')
								begin
									set	@hour_result_vhcl = @hour_result_vhcl + @hour_maintenance_vhcl;
								end
								else
								begin
									set @hour_result_vhcl = 0;
								end
						end ;

				set @counter = @counter + 1 ;
			end ;
		end ;
			
		    fetch next from curr_generate_master 
			into 
				 @code					
				,@maintenance_time		
				,@maintenance_type		
				,@maintenance_cycle_time
				,@date_purc				
				,@usefull				
				,@type_code				
				,@is_miles_vhcl			
				,@is_month_vhcl			
				,@is_hour_vhcl			
				,@miles_maintenance_vhcl
				,@month_maintenance_vhcl
				,@hour_maintenance_vhcl	
				,@model_code_vhcl		
				,@model_code_elect		
				,@model_code_furni		
				,@model_code_mchn		
				,@service_code			
				,@desc_service			
				
		end
		
		close curr_generate_master
		deallocate curr_generate_master

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

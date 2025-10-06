CREATE PROCEDURE dbo.xsp_maintenance_post
(
	@p_code			    nvarchar(50)
	,@p_start_date		datetime	= null
	,@p_finish_date		datetime	= null
	--
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@status						nvarchar(20)
			,@asset_code					nvarchar(50)
			,@asset_code_maintenance		nvarchar(50)
			,@last_status_date				datetime
			,@maintenance_by				nvarchar(50)
			,@company_code					nvarchar(50)
			,@trx_no						nvarchar(50)
			,@remarks						nvarchar(4000)
			,@year							nvarchar(4)
			,@month							nvarchar(2)
			,@code							nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@address						nvarchar(250)
			,@phone_no						nvarchar(50)
			,@vendor_name					nvarchar(250)
			,@requestor_name				nvarchar(250)
			,@work_date						datetime
			,@area_phone					nvarchar(5)
			,@actual_km						bigint
			,@service_code					nvarchar(50)
			,@service_name					nvarchar(250)
			,@id_asset_maintenance_schedule	int
			,@service_type					nvarchar(50)
			,@hour_meter					int
			,@is_maintenance				nvarchar(1)
			,@code_wo						nvarchar(50)
			,@quantity						int
            ,@spk_no						nvarchar(50)
			,@free_service					nvarchar(1)
			,@last_km_service				int
			,@last_meter					int
			,@is_miles						nvarchar(1)
			,@is_month						nvarchar(1)
			,@is_hour						nvarchar(1)
			,@miles_cycle					int
			,@month_cycle					int
			,@hour_cycle					int
			,@miles_cycle_temp				int
			,@month_cycle_temp				int
			,@hour_cycle_temp				int
			,@finish_date					datetime
			,@maintenance_date				datetime
			,@purchase_date					datetime
			,@count_data_shcedule			int
			,@maintenance_no				nvarchar(50)
			,@is_request_replacement		nvarchar(1)
			,@replacement_status			nvarchar(50)
			,@replacement_code				nvarchar(50)

	begin try
		if (isnull(@p_start_date, '') = '' or isnull(@p_finish_date, '') = '')
		begin
			set @msg = 'Please Input Start Date & Finish Date.';
			raiserror(@msg, 16, -1);
		end

		

		select		@spk_no			= spk_no
					,@free_service	= free_service
		from		dbo.maintenance 
		where		code = @p_code

		if(@free_service = '0')
		begin
			--validasi untuk SPK No
			if  (isnull(@spk_no, '') = '')
			begin
				set	@msg = 'Print Surat Perintah Kerja First.'
				raiserror(@msg, 16, -1) ;
			end
         end
         
		select	@status						= dor.status
				,@asset_code				= dor.asset_code
				,@asset_code_maintenance	= ams.asset_code
				,@last_status_date			= ams.last_status_date
				,@maintenance_by			= dor.maintenance_by
				,@company_code				= dor.company_code
				,@remarks					= dor.remark
				,@branch_code				= dor.branch_code
				,@branch_name				= dor.branch_name
				,@requestor_name			= dor.requestor_name
				,@address					= dor.vendor_address
				,@phone_no					= dor.vendor_phone
				,@vendor_name				= dor.vendor_name
				,@work_date					= dor.work_date
				,@actual_km					= dor.actual_km
				,@hour_meter				= dor.hour_meter
				,@last_km_service			= dor.last_km_service
				,@last_meter				= ass.last_meter
				,@finish_date				= dor.finish_date
				,@purchase_date				= ass.purchase_date
				,@is_request_replacement	= dor.is_request_replacement
		from	dbo.maintenance dor
		left join dbo.asset_maintenance_schedule ams on (ams.asset_code = dor.asset_code)
		left join dbo.maintenance_detail md on  (md.maintenance_code = dor.code)
		inner join dbo.asset ass on ass.code = dor.asset_code
		where	dor.code = @p_code ;

		if isnull(@is_request_replacement,'0') = '1'
		begin
			select	@replacement_status = rp.status 
					,@replacement_code	= rp.code
			from	ifinopl.dbo.asset_replacement_detail rps
					inner join ifinopl.dbo.asset_replacement rp on rp.code = rps.replacement_code
			where	reff_no = @p_code
			
			if isnull(@replacement_status,'') = 'HOLD' OR isnull(@replacement_status,'') = 'ON PROCESS'
			begin
				set @msg = N'Please Posting Or Cancel Transaction Replacement Before Done Maintenance';
				raiserror(@msg, 16, -1);
				return;
			end
		end

		if (@status = 'APPROVE')
		begin
				update	dbo.maintenance
				set		status			= 'DONE'
						,start_date		= @p_start_date
						,finish_date	= @p_finish_date
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;

				if(@service_type = 'ROUTINE')
				begin
					update	dbo.asset
					set		last_meter			= case when @actual_km = 0 
															then @hour_meter
														else @actual_km
													end
							,last_service_date	= @last_status_date
							,process_status		= 'MAINTENANCE ROUTINE'
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @asset_code
				end
				else if (@service_type = 'NON ROUTINE')
				begin
					update	dbo.asset
					set		last_meter			= case when @actual_km = 0 
															then @hour_meter
														else @actual_km
													end
							,last_service_date	= @last_status_date
							,process_status		= 'MAINTENANCE NON ROUTINE'
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @asset_code
				end
				else if (@service_type = 'CLAIM')
				begin
					update	dbo.asset
					set		last_meter			= case when @actual_km = 0 
															then @hour_meter
														else @actual_km
													end
							,last_service_date	= @last_status_date
							,process_status		= 'MAINTENANCE CLAIM'
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @asset_code
				end
                
				--insert ke work order
				exec dbo.xsp_work_order_insert @p_code					= @code_wo output
											   ,@p_company_code			= @company_code
											   ,@p_asset_code			= @asset_code
											   ,@p_maintenance_code		= @p_code
											   ,@p_maintenance_by		= @maintenance_by
											   ,@p_status				= 'HOLD'
											   ,@p_remark				= @remarks
											   ,@p_file_name			= null
											   ,@p_file_paths			= null
											   ,@p_actual_km			= @actual_km
											   ,@p_work_date			= @work_date
											   ,@p_last_km_service		= @last_km_service
											   ,@p_last_meter			= @last_meter
											   --
											   ,@p_cre_date				= @p_mod_date	  
											   ,@p_cre_by				= @p_mod_by		
											   ,@p_cre_ip_address		= @p_mod_ip_address
											   ,@p_mod_date				= @p_mod_date	  
											   ,@p_mod_by				= @p_mod_by		
											   ,@p_mod_ip_address		= @p_mod_ip_address

				--insert ke work order detail
				declare curr_wo_detail cursor fast_forward read_only for

				select service_code 
						,service_name
						,service_type
						,quantity
						,asset_maintenance_schedule_id
				from dbo.maintenance_detail 
				where maintenance_code = @p_code
				
				open curr_wo_detail
				
				fetch next from curr_wo_detail 
				into @service_code
					,@service_name
					,@service_type
					,@quantity
					,@id_asset_maintenance_schedule
				
				while @@fetch_status = 0
				begin

				    exec dbo.xsp_work_order_detail_insert @p_id									= 0
				    									  ,@p_work_order_code					= @code_wo
				    									  ,@p_asset_maintenance_schedule_id		= @id_asset_maintenance_schedule
				    									  ,@p_service_code						= @service_code
				    									  ,@p_service_name						= @service_name
				    									  ,@p_service_type						= @service_type
				    									  ,@p_service_fee						= 0
				    									  ,@p_quantity							= @quantity
				    									  ,@p_pph_amount						= 0
				    									  ,@p_ppn_amount						= 0
				    									  ,@p_total_amount						= 0
				    									  ,@p_payment_amount					= 0
				    									  ,@p_tax_code							= ''
				    									  ,@p_tax_name							= ''
				    									  ,@p_ppn_pct							= 0
				    									  ,@p_pph_pct							= 0
				    									  ,@p_part_number						= ''
				    									  ,@p_cre_date							= @p_mod_date	  
				    									  ,@p_cre_by							= @p_mod_by		
				    									  ,@p_cre_ip_address					= @p_mod_ip_address
				    									  ,@p_mod_date							= @p_mod_date	  
				    									  ,@p_mod_by							= @p_mod_by		
				    									  ,@p_mod_ip_address					= @p_mod_ip_address

					-- Cursor untuk update schedule maintenance di asset yang tidak dilakukan maintenance yang kurang dari work date
					if exists
					(
						select	1
						from	dbo.asset_maintenance_schedule
						where	asset_code			   = @asset_code
								and
								(
									maintenance_date   <= @p_finish_date
									or	miles		   <= @actual_km
									or	hour		   <= @hour_meter
								)
								and maintenance_status = 'SCHEDULE PENDING'
								and reff_trx_no		   = ''
								and id not in
									(
										select	asset_maintenance_schedule_id
										from	dbo.maintenance_detail
										where	maintenance_code = @p_code
									)
					)
					begin
						declare curr_asset_non_main cursor fast_forward read_only for
						select	id
						from	dbo.asset_maintenance_schedule
						where	asset_code			   = @asset_code
								and
								(
									maintenance_date   <= @p_finish_date
									or	miles		   <= @actual_km
									or	hour		   <= @hour_meter
								)
								and maintenance_status = 'SCHEDULE PENDING'
								and reff_trx_no		   = ''
								and id not in
									(
										select	asset_maintenance_schedule_id
										from	dbo.maintenance_detail
										where	maintenance_code = @p_code
									) ;

						open curr_asset_non_main ;

						fetch next from curr_asset_non_main
						into @id_asset_maintenance_schedule ;

						while @@fetch_status = 0
						begin
							update	dbo.asset_maintenance_schedule
							set		maintenance_status	= 'SERVICE SKIPED'
									,last_status_date	= @p_mod_date
									,reff_trx_no		= '-'
									--
									,mod_date			= @p_mod_date
									,mod_by				= @p_mod_by
									,mod_ip_address		= @p_mod_ip_address
							where	asset_code = @asset_code
									and id	   = @id_asset_maintenance_schedule ;

							fetch next from curr_asset_non_main
							into @id_asset_maintenance_schedule ;
						end ;

						close curr_asset_non_main ;
						deallocate curr_asset_non_main ;
					end ;

					if exists
					(
						select	1
						from	dbo.maintenance_detail
						where	maintenance_code = @p_code
								and service_code = 'ROUTINE'
								and asset_maintenance_schedule_id <> 0
					)
					begin

						select	@is_miles	  = mmd.is_miles
								,@is_month	  = mmd.is_month
								,@is_hour	  = mmd.is_hour
								,@miles_cycle = mmd.miles_cycle
								,@month_cycle = mmd.month_cycle
								,@hour_cycle  = mmd.hour_cycle
						from	dbo.asset								  ass
								left join dbo.asset_vehicle				  avh on (avh.asset_code = ass.code)
								left join ifinbam.dbo.master_model_detail mmd on (avh.model_code = mmd.model_code)
								left join ifinbam.dbo.master_service	  ms on (ms.code		 = mmd.service_code)
						where	ass.code = @asset_code ;

						--if(@is_miles = '1')
						begin
							set @miles_cycle_temp = @actual_km + @miles_cycle
						end
			
						--if(@is_month = '1')
						begin
							set @maintenance_date = dateadd(month, isnull(@month_cycle,1), @p_finish_date);
							set @month_cycle_temp = datediff(month, @purchase_date, @maintenance_date)
						end
				
						select	@count_data_shcedule = count(1)
						from	dbo.asset_maintenance_schedule
						where	asset_code = @asset_code ;

						set @maintenance_no = @count_data_shcedule + 1

						exec dbo.xsp_asset_maintenance_schedule_insert @p_id = 0
																	   ,@p_asset_code = @asset_code
																	   ,@p_maintenance_no = @maintenance_no
																	   ,@p_maintenance_date = @maintenance_date
																	   ,@p_maintenance_status = 'SCHEDULE PENDING'
																	   ,@p_last_status_date = @p_mod_date
																	   ,@p_reff_trx_no = ''
																	   ,@p_miles = @miles_cycle_temp
																	   ,@p_month = @month_cycle_temp
																	   ,@p_hour = null
																	   ,@p_service_code = @service_code
																	   ,@p_service_name = @service_name
																	   ,@p_service_type = @service_type
																	   ,@p_cre_by = @p_mod_by
																	   ,@p_cre_date = @p_mod_date
																	   ,@p_cre_ip_address = @p_mod_ip_address
																	   ,@p_mod_by = @p_mod_by
																	   ,@p_mod_date = @p_mod_date
																	   ,@p_mod_ip_address = @p_mod_ip_address ;
					end ;
					
						update	dbo.asset_maintenance_schedule
						set		maintenance_status	= 'SCHEDULE DONE'
								,last_status_date	= @p_mod_date
								,reff_trx_no		= @p_code
								,service_date		= @p_finish_date
								,miles				= @actual_km
								--
								,mod_date			= @p_mod_date
								,mod_by				= @p_mod_by
								,mod_ip_address		= @p_mod_ip_address
						where	asset_code = @asset_code
								and id	   = @id_asset_maintenance_schedule ;
				    
				
				    fetch next from curr_wo_detail 
					into @service_code
						,@service_name
						,@service_type
						,@quantity
						,@id_asset_maintenance_schedule
				end
				
				close curr_wo_detail
				deallocate curr_wo_detail

				-- Cursor untuk insert schedule baru diluar schedule asli dengan service type routin
				if exists
				(
					select	1
					from	dbo.maintenance_detail
					where	maintenance_code					  = @p_code
							and asset_maintenance_schedule_id	  = 0
				)
				begin
					declare curr_main_not_schedule cursor fast_forward read_only for
					select	service_code
							,service_name
					from	dbo.maintenance_detail
					where	maintenance_code				  = @p_code
							and asset_maintenance_schedule_id = 0 ;

					open curr_main_not_schedule ;

					fetch next from curr_main_not_schedule
					into @service_code
						 ,@service_name ;

					while @@fetch_status = 0
					begin
						exec dbo.xsp_asset_maintenance_schedule_insert @p_id					= 0
																	   ,@p_asset_code			= @asset_code
																	   ,@p_maintenance_no		= ''
																	   ,@p_maintenance_date		= @p_mod_date
																	   ,@p_maintenance_status	= 'AD HOC DONE'
																	   ,@p_last_status_date		= @p_mod_date
																	   ,@p_reff_trx_no			= @p_code
																	   ,@p_miles				= @actual_km
																	   ,@p_month				= null
																	   ,@p_hour					= null
																	   ,@p_service_code			= @service_code
																	   ,@p_service_name			= @service_name
																	   ,@p_service_type			= @service_type
																	   ,@p_service_date			= @work_date
																	   ,@p_cre_by				= @p_mod_by
																	   ,@p_cre_date				= @p_mod_date
																	   ,@p_cre_ip_address		= @p_mod_ip_address
																	   ,@p_mod_by				= @p_mod_by
																	   ,@p_mod_date				= @p_mod_date
																	   ,@p_mod_ip_address		= @p_mod_ip_address ;

						fetch next from curr_main_not_schedule
						into @service_code
							 ,@service_name ;
					end ;

					close curr_main_not_schedule ;
					deallocate curr_main_not_schedule ;
				end ;

				if(@free_service = '1')
				begin
					exec dbo.xsp_work_order_post_for_free_service @p_code				= @code_wo
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
					
				end

				-- JIKA REPLACEMENT YES, DAN STATUSNYA POST. PANGGIL RETURN ASSET REPLACEMENT

				if @is_request_replacement = '1'
				begin
					if @replacement_status = 'POST'
						begin
							exec ifinopl.dbo.xsp_asset_replacement_return_asset @p_code				= @replacement_code,                       -- nvarchar(50)
							                                                    @p_mod_date			= @p_mod_date, -- datetime
							                                                    @p_mod_by			= @p_mod_by,                     -- nvarchar(15)
							                                                    @p_mod_ip_address	= @p_mod_ip_address              -- nvarchar(15)
							
						end
				end
				--set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
				--set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

				--exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
				--											,@p_branch_code			 = @branch_code
				--											,@p_sys_document_code	 = ''
				--											,@p_custom_prefix		 = 'WOHR'
				--											,@p_year				 = @year
				--											,@p_month				 = @month
				--											,@p_table_name			 = 'HANDOVER_REQUEST'
				--											,@p_run_number_length	 = 5
				--											,@p_delimiter			 = '.'
				--											,@p_run_number_only		 = '0' ;

				--insert into handover (maintenance out) jika maintenance by external
				--if(@maintenance_by = 'EXT')
				--begin
				--	set @remarks = 'Maintenance Asset ' + @asset_code
				--	insert into dbo.handover_request
				--	(
				--		code
				--		,branch_code
				--		,branch_name
				--		,type
				--		,status
				--		,date
				--		,handover_from
				--		,handover_to
				--		,handover_address
				--		,handover_phone_area
				--		,handover_phone_no
				--		,eta_date
				--		,fa_code
				--		,remark
				--		,reff_code
				--		,reff_name
				--		,handover_code
				--		,cre_date
				--		,cre_by
				--		,cre_ip_address
				--		,mod_date
				--		,mod_by
				--		,mod_ip_address
				--	)
				--	values
				--	(
				--		@code
				--		,@branch_code
				--		,@branch_name
				--		,'MAINTENANCE OUT'
				--		,'HOLD'
				--		,@p_mod_date
				--		,@requestor_name
				--		,@vendor_name
				--		,@address
				--		,@area_phone
				--		,@phone_no
				--		,@work_date
				--		,@asset_code
				--		,@remarks
				--		,@p_code
				--		,'ASSET MAINTENANCE'
				--		,null
				--		,@p_mod_date	  
				--		,@p_mod_by		  
				--		,@p_mod_ip_address
				--		,@p_mod_date	  
				--		,@p_mod_by		  
				--		,@p_mod_ip_address
				--	)
				--end
				
				
			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'MAINTENANCE'
			-- End of send mail attachment based on setting ================================================
					
		end
		else
		begin
			set @msg = 'Data Already Proceed.';
			raiserror(@msg ,16,-1);
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

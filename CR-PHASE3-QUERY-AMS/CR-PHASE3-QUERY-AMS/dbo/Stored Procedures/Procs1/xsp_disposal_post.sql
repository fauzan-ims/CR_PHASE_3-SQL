CREATE PROCEDURE dbo.xsp_disposal_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@status				nvarchar(20)
			,@company_code			nvarchar(50)
			,@code_detail			nvarchar(50)
			,@date					datetime = getdate()
			,@asset_code			nvarchar(50)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid				int 
			,@max_day				int
			,@disposal_date			datetime
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@nett_book_value		decimal(18,2)
			,@process_code			nvarchar(50)
			,@code_asset			nvarchar(50)
			,@is_gps				nvarchar(1)
			,@gps_status			nvarchar(20)
			,@id_monitoring_gps		bigint
            ,@remark_h				nvarchar(400)
            ,@remark				nvarchar(400)

	begin try
		select	@status				= dor.status
				,@company_code		= dor.company_code
				,@asset_code		= dd.asset_code
				,@disposal_date		= dor.disposal_date
				,@branch_code		= dor.branch_code
				,@branch_name		= dor.branch_name
				,@nett_book_value	= ast.net_book_value_comm
				,@date				= dor.disposal_date -- for wom
				,@remark_h			= dor.remarks
		from	dbo.disposal dor
		inner join dbo.disposal_detail dd on (dd.disposal_code = dor.code)
		inner join dbo.asset ast on dd.asset_code = ast.code
		where	dor.code = @p_code ;

		if (@status = 'ON PROCESS')
		begin
				set @process_code = 'DISPOSAL'
				exec dbo.xsp_efam_journal_disposal_register @p_disposal_code		= @p_code
				                                            ,@p_process_code		= @process_code
				                                            ,@p_company_code		= @company_code
				                                            ,@p_reff_source_no		= ''
				                                            ,@p_reff_source_name	= ''
				                                            ,@p_mod_date			= @p_mod_date
				                                            ,@p_mod_by				= @p_mod_by
				                                            ,@p_mod_ip_address		= @p_mod_ip_address
			    

				UPDATE	dbo.disposal
				set		status			= 'APPROVED'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;

				update	dbo.asset
				set		disposal_date	= @date
						,status			= 'DISPOSED'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code in (select asset_code from dbo.disposal_detail where disposal_code = @p_code)

				declare curr_disposal cursor fast_forward read_only for                
				select asset_code 
				from dbo.disposal_detail 
				where disposal_code = @p_code

				open curr_disposal				
				fetch next from curr_disposal 
				into @code_asset
				
				while @@fetch_status = 0
				begin
					if not exists(select 1 from dbo.asset_mutation_history where asset_code = @code_asset and document_refference_no = @p_code)
					begin
						exec dbo.xsp_asset_mutation_history_insert @p_id						 = 0
															   ,@p_asset_code					 = @code_asset
															   ,@p_date							 = @date
															   ,@p_document_refference_no		 = @p_code
															   ,@p_document_refference_type		 = 'DSP'
															   ,@p_usage_duration				 = 0
															   ,@p_from_branch_code				 = @branch_code
															   ,@p_from_branch_name				 = @branch_name
															   ,@p_to_branch_code				 = ''
															   ,@p_to_branch_name				 = ''
															   ,@p_from_location_code			 = ''
															   ,@p_to_location_code				 = ''
															   ,@p_from_pic_code				 = ''
															   ,@p_to_pic_code					 = ''
															   ,@p_from_division_code			 = ''
															   ,@p_from_division_name			 = ''
															   ,@p_to_division_code				 = ''
															   ,@p_to_division_name				 = ''
															   ,@p_from_department_code			 = ''
															   ,@p_from_department_name			 = ''
															   ,@p_to_department_code			 = ''
															   ,@p_to_department_name			 = ''
															   ,@p_from_sub_department_code		 = ''
															   ,@p_from_sub_department_name		 = ''
															   ,@p_to_sub_department_code		 = ''
															   ,@p_to_sub_department_name		 = ''
															   ,@p_from_unit_code				 = ''
															   ,@p_from_unit_name				 = ''
															   ,@p_to_unit_code					 = ''
															   ,@p_to_unit_name					 = ''
															   ,@p_cre_date						 = @p_mod_date	  
															   ,@p_cre_by						 = @p_mod_by		  
															   ,@p_cre_ip_address				 = @p_mod_ip_address
															   ,@p_mod_date						 = @p_mod_date	  
															   ,@p_mod_by						 = @p_mod_by		  
															   ,@p_mod_ip_address				 = @p_mod_ip_address
					end
				
				    fetch next from curr_disposal 
					into @code_asset
				end
				
				close curr_disposal
				deallocate curr_disposal		
				
		end
		else
		begin
			set @msg = 'Data already proceed.';
			raiserror(@msg ,16,-1);
		end
		
		declare curr_disposal_post cursor fast_forward read_only for 
		select asset_code 
				,@remark_h + ' - ' + description
		from dbo.disposal_detail
		where disposal_code = @p_code
		
		open curr_disposal_post
		
		fetch next from curr_disposal_post 
		into @code_detail,@remark
		
		while @@fetch_status = 0
		BEGIN
			-- Ambil data IS_GPS, GPS_STATUS, BRANCH dari ASSET
			select 
				@is_gps = is_gps,
				@gps_status = gps_status,
				@branch_code = branch_code,
				@branch_name = branch_name
			from dbo.asset
			where code = @code_detail;

		    update	dbo.asset
			set		status			= 'DISPOSED'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @code_detail

			-- Insert ke GPS_UNSUBCRIBE_REQUEST jika IS_GPS = 1 dan GPS_STATUS = 'SUBCRIBE'
			if exists 
			(
				select	1
				from	dbo.asset 
				where	code = @asset_code 
						and is_gps = '1' and gps_status = 'SUBSCRIBE'
			)
			begin
				
				select	@id_monitoring_gps = id
				from	dbo.monitoring_gps
				where	fa_code = @asset_code
						and status = 'SUBSCRIBE'
				
				declare @p_request_no nvarchar(50);
				exec dbo.xsp_gps_unsubcribe_request_insert @p_request_no		= @p_request_no output, 
				                                           @p_id				= @id_monitoring_gps,   
				                                           @p_source_reff_name	= N'DISPOSAL',      
				                                           @p_cre_date			= @p_mod_date,			
				                                           @p_cre_by			= @p_mod_by,            
				                                           @p_cre_ip_address	= @p_mod_ip_address,    
				                                           @p_mod_date			= @p_mod_date,			
				                                           @p_mod_by			= @p_mod_by,            
				                                           @p_mod_ip_address	= @p_mod_ip_address,
														   @p_source_reff_no	= @p_code,
															@p_remarks			= @remark
			END
		
		    fetch next from curr_disposal_post 
			into @code_detail,@remark
		end
		
		close curr_disposal_post
		deallocate curr_disposal_post

		-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'DISPOSAL'
			-- End of send mail attachment based on setting ================================================
		
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

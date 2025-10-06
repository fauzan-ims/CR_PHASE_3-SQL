CREATE PROCEDURE dbo.xsp_maintenance_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						  nvarchar(max)
			,@status					  nvarchar(20)
			,@asset_code				  nvarchar(50)
			,@service_code_detail		  nvarchar(50)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid					  int
			,@max_day					  int
			,@transaction_date			  datetime
			,@company_code				  nvarchar(50)
			,@service_name_detail		  nvarchar(250)
			,@interface_remarks			  nvarchar(4000)
			,@req_date					  datetime
			,@reff_approval_category_code nvarchar(50)
			,@path						  nvarchar(250)
			,@url_path					  nvarchar(250)
			,@approval_path				  nvarchar(4000)
			,@request_code				  nvarchar(50)
			,@branch_code				  nvarchar(50)
			,@branch_name				  nvarchar(250)
			,@expired_date				  datetime
			,@requestor_code			  nvarchar(50)
			,@requestor_name			  nvarchar(250)
			,@table_name				  nvarchar(50)
			,@primary_column			  nvarchar(50)
			,@dim_value					  nvarchar(50)
			,@reff_dimension_code		  nvarchar(50)
			,@reff_dimension_name		  nvarchar(250)
			,@dimension_code			  nvarchar(50)
			,@approval_code				  nvarchar(50)
			,@file_name					  nvarchar(250)
			,@estimate_start_date		  datetime
			,@estimate_finish_date		  datetime
			,@count_return				  int
			,@path2						  nvarchar(250)

	begin try
		select	@status				  = dor.status
				,@asset_code		  = dor.asset_code
				,@service_code_detail = md.service_code
				,@transaction_date	  = dor.transaction_date
				,@company_code		  = dor.company_code
				,@service_name_detail = md.service_name
				,@expired_date		  = dor.estimated_finish_date
				,@requestor_code	  = dor.mod_by
				,@requestor_name	  = sem.name
				,@branch_code         = dor.branch_code
				,@branch_name		  = dor.branch_name
				,@file_name			  = isnull(dor.file_name,'')
				,@estimate_start_date = dor.estimated_start_date
				,@estimate_finish_date = dor.estimated_finish_date
				,@count_return			= dor.count_return
		from	dbo.maintenance							dor
				left join dbo.maintenance_detail		md on (md.maintenance_code = dor.code)
				left join ifinsys.dbo.sys_employee_main sem on sem.code			   = dor.mod_by
		where	dor.code = @p_code ;


		if exists
		(
			select	1
			from	sale					   a
					inner join dbo.sale_detail b on a.code = b.sale_code
			where	b.asset_code = @asset_code
					and a.status not in
		(
			'CANCEL', 'REJECT'
		)
		)
		begin
			set @msg = N'Asset Is In Sales Request Process.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@file_name = '')
		begin
			set @msg = N'Please upload quotation.' ;

			raiserror(@msg, 16, -1) ;
		end

		if (@estimate_start_date is null)
		begin
			set @msg = N'Please input estimated start date.' ;

			raiserror(@msg, 16, -1) ;
		end

		if (@estimate_finish_date is null)
		begin
			set @msg = N'Please input estimated finish date.' ;

			raiserror(@msg, 16, -1) ;
		END
       
		IF EXISTS
		(
			SELECT 1
			FROM dbo.MAINTENANCE dor
			WHERE dor.CODE = @p_code
				  AND (ACTUAL_KM < LAST_KM_SERVICE)
		)
		BEGIN
			SET @msg = N'Actual KM must be greather then Last KM Service';

			RAISERROR(@msg, 16, -1);
		END

		if (
			   @status = 'HOLD'
			   and	@service_code_detail <> ''
		   )
		begin
			update	dbo.maintenance
			set		status = 'ON PROCESS'
					--
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;

			--update	dbo.asset
			--set		process_status			= 'ON REPAIR'
			--		--
			--		,mod_date		= @p_mod_date
			--		,mod_by			= @p_mod_by
			--		,mod_ip_address = @p_mod_ip_address
			--where	code			= @asset_code

			---- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'APRQTR'
			--                                                ,@p_doc_code		= @p_code
			--                                                ,@p_attachment_flag = 0
			--                                                ,@p_attachment_file = ''
			--                                                ,@p_attachment_path = ''
			--                                                ,@p_company_code	= @company_code
			--                                                ,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'MAINTENANCE'
			---- End of send mail attachment based on setting ================================================
			set @interface_remarks = N'Approval Maintenance For ' + @p_code ;
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code = 'MNT' ;

			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'PATHMNT' ;

			select	@path2 = @url_path + value
			from	dbo.sys_global_param
			where	code = 'PATHMNTR' ;

			--set approval path
			if (@count_return = 0)
			begin
				set @approval_path = @path + @p_code ;
			end
			else
			begin
				set @approval_path = @path2 + @p_code ;
			end
			exec dbo.xsp_ams_interface_approval_request_insert @p_code = @request_code output
															   ,@p_branch_code = @branch_code
															   ,@p_branch_name = @branch_name
															   ,@p_request_status = N'HOLD'
															   ,@p_request_date = @req_date
															   ,@p_request_amount = 0
															   ,@p_request_remarks = @interface_remarks
															   ,@p_reff_module_code = N'IFINAMS'
															   ,@p_reff_no = @p_code
															   ,@p_reff_name = N'MAINTENANCE APPROVAL'
															   ,@p_paths = @approval_path
															   ,@p_approval_category_code = @reff_approval_category_code
															   ,@p_approval_status = N'HOLD'
															   ,@p_expired_date = @expired_date
															   ,@p_requestor_code = @requestor_code
															   ,@p_requestor_name = @requestor_name
															   ,@p_cre_date = @p_mod_date
															   ,@p_cre_by = @p_mod_by
															   ,@p_cre_ip_address = @p_mod_ip_address
															   ,@p_mod_date = @p_mod_date
															   ,@p_mod_by = @p_mod_by
															   ,@p_mod_ip_address = @p_mod_ip_address ;

			declare curr_appv cursor fast_forward read_only for
			select	approval_code
					,reff_dimension_code
					,reff_dimension_name
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'MNT' ;

			open curr_appv ;

			fetch next from curr_appv
			into @approval_code
				 ,@reff_dimension_code
				 ,@reff_dimension_name
				 ,@dimension_code ;

			while @@fetch_status = 0
			begin
				select	@table_name		 = table_name
						,@primary_column = primary_column
				from	dbo.sys_dimension
				where	code = @dimension_code ;

				exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
														  ,@p_reff_code		= @p_code
														  ,@p_reff_table	= 'MAINTENANCE'
														  ,@p_output		= @dim_value output ;

				exec dbo.xsp_ams_interface_approval_request_dimension_insert @p_id					= 0
																			 ,@p_request_code		= @request_code
																			 ,@p_dimension_code		= @reff_dimension_code
																			 ,@p_dimension_value	= @dim_value
																			 ,@p_cre_date			= @p_mod_date
																			 ,@p_cre_by				= @p_mod_by
																			 ,@p_cre_ip_address		= @p_mod_ip_address
																			 ,@p_mod_date			= @p_mod_date
																			 ,@p_mod_by				= @p_mod_by
																			 ,@p_mod_ip_address		= @p_mod_ip_address ;

				fetch next from curr_appv
				into @approval_code
					 ,@reff_dimension_code
					 ,@reff_dimension_name
					 ,@dimension_code ;
			end ;

			close curr_appv ;
			deallocate curr_appv ;
		end ;
		else if (
					@status = 'HOLD'
					and @service_code_detail is null
				)
		begin
			set @msg = N'Please input Maintenance Detail' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (
					@status = 'HOLD'
					and @service_code_detail = ''
				)
		begin
			set @msg = N'Please Input Type Service' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin
			set @msg = N'Data Already Proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

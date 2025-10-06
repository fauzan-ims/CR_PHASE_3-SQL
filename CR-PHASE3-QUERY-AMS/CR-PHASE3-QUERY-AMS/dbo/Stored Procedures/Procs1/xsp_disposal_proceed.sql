CREATE PROCEDURE [dbo].[xsp_disposal_proceed]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@status							nvarchar(20)
			,@asset_code						nvarchar(50)
			,@reason_type						nvarchar(50)
			,@is_valid							int 
			,@max_day							int
			,@disposal_date						datetime
			,@company_code						nvarchar(50)
			,@interface_remarks					nvarchar(4000)
			,@req_date							datetime
			,@item_name							nvarchar(250)
			,@reff_approval_category_code		nvarchar(50)
			,@request_code						nvarchar(50)
			,@net_book_value					decimal(18,2)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@approval_code						nvarchar(50)
			,@reff_dimension_code				nvarchar(50)
			,@reff_dimension_name				nvarchar(250)
			,@dimension_code					nvarchar(50)
			,@table_name						nvarchar(50)
			,@primary_column					nvarchar(50)
			,@dim_value							nvarchar(50)
			,@process_code						nvarchar(50)
			,@value_approval					nvarchar(250)
			,@path								nvarchar(250)
			,@url_path							nvarchar(250)
			,@approval_path						nvarchar(4000)
			,@requestor_code					nvarchar(50)
			,@requestor_name					nvarchar(250)

	begin try -- 
		select	@status				= dor.status
				,@reason_type		= case dor.reason_type
										when 'BRKN' then 'BROKEN'
										when 'DSTR' then 'DESTROYED'
										when 'GRNT' then 'GUARANTEED'
										when 'OTRS' then 'OTHERS'
										else dor.reason_type
									end
				,@disposal_date		= dor.disposal_date
				,@company_code		= dor.company_code
				,@net_book_value	= disposaldetail.net_book_value
				,@branch_code		= dor.branch_code
				,@branch_name		= dor.branch_name
				,@requestor_code	= dor.mod_by
				,@requestor_name	= sem.name
		from	dbo.disposal dor
				outer apply (select sum(dd.net_book_value) 'net_book_value' from dbo.disposal_detail dd where dd.disposal_code = dor.code) disposaldetail
				left join ifinsys.dbo.sys_employee_main sem on sem.code = dor.mod_by
		where	dor.code = @p_code ;

		if (@status = 'HOLD' and @reason_type = '')
		begin
				set @msg = 'Please fill in the reason first.';
				raiserror(@msg ,16,-1);

				-- send mail attachment based on setting ================================================
				--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'APRQTR'
				--												,@p_doc_code		= @p_code
				--												,@p_attachment_flag = 0
				--												,@p_attachment_file = ''
				--												,@p_attachment_path = ''
				--												,@p_company_code	= @company_code
				--												,@p_trx_no			= @p_code
				--												,@p_trx_type		= 'DISPOSAL'
				-- End of send mail attachment based on setting ================================================

		end
		else if (@status = 'HOLD' and @reason_type <> '')
		begin
			update	dbo.disposal
			set		status			= 'ON PROCESS'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			--Journal
			set @process_code = 'DISPOSAL'
			exec dbo.xsp_efam_journal_disposal_register @p_disposal_code		= @p_code
			                                            ,@p_process_code		= @process_code
			                                            ,@p_company_code		= @company_code
			                                            ,@p_reff_source_no		= ''
			                                            ,@p_reff_source_name	= ''
			                                            ,@p_mod_date			= @p_mod_date
			                                            ,@p_mod_by				= @p_mod_by
			                                            ,@p_mod_ip_address		= @p_mod_ip_address

			set @interface_remarks = 'Approval Disposal For ' + @p_code + '. Because ' + @reason_type ;
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'DISPOSAL' ;

			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'PATHDSA'

			--set approval path
			set	@approval_path = @path + @p_code

			exec dbo.xsp_ams_interface_approval_request_insert @p_code						= @request_code output
															   ,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_request_status			= N'HOLD'
																,@p_request_date			= @req_date
																,@p_request_amount			= @net_book_value
																,@p_request_remarks			= @interface_remarks
																,@p_reff_module_code		= N'IFINAMS'
																,@p_reff_no					= @p_code
																,@p_reff_name				= N'DISPOSAL APPROVAL'
																,@p_paths					= @approval_path
																,@p_approval_category_code	= @reff_approval_category_code
																,@p_approval_status			= N'HOLD'
																,@p_expired_date			= @disposal_date
																,@p_requestor_code			= @requestor_code
																,@p_requestor_name			= @requestor_name
																,@p_cre_date				= @p_mod_date
																,@p_cre_by					= @p_mod_by
																,@p_cre_ip_address			= @p_mod_ip_address
																,@p_mod_date				= @p_mod_date
																,@p_mod_by					= @p_mod_by
																,@p_mod_ip_address			= @p_mod_ip_address


			declare curr_appv cursor fast_forward read_only for
			select 	approval_code
					,reff_dimension_code
					,reff_dimension_name
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'DISPOSAL'
			
			open curr_appv
			
			fetch next from curr_appv 
			into @approval_code
				,@reff_dimension_code
				,@reff_dimension_name
				,@dimension_code
			
			while @@fetch_status = 0
			begin
				select	@table_name					 = table_name
						,@primary_column			 = primary_column
				from	dbo.sys_dimension
				where	code						 = @dimension_code

				exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
															,@p_reff_code	= @p_code
															,@p_reff_table	= 'DISPOSAL'
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
					,@dimension_code
			end
			
			close curr_appv
			deallocate curr_appv
			
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

CREATE PROCEDURE dbo.xsp_application_main_proceed_to_approval
(
	@p_application_no	 NVARCHAR(50) 
	,@p_approval_code	 NVARCHAR(50)
	,@p_is_simulation	 NVARCHAR(1)
	,@p_last_return		 NVARCHAR(3)
	,@p_approval_comment NVARCHAR(4000) = ''
	--
	,@p_mod_date		DATETIME
	,@p_mod_by			NVARCHAR(15)
	,@p_mod_ip_address	NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg						  NVARCHAR(max)
			,@branch_code				  nvarchar(50)
			,@branch_name				  nvarchar(250)
			,@client_name				  nvarchar(250)
			,@application_external_no	  nvarchar(50)
			,@total_application			  decimal(18, 2)
			,@interface_remarks			  nvarchar(4000)
			,@req_date					  datetime
			,@reff_approval_category_code nvarchar(50)
			,@path						  nvarchar(250)
			,@url_path					  nvarchar(250)
			,@approval_path				  nvarchar(4000)
			,@page_type					  nvarchar(50)	= N'/banberjalan'
			,@request_code				  nvarchar(50)
			,@reff_dimension_code		  nvarchar(50)
			,@dimension_code			  nvarchar(50)
			,@dim_value					  nvarchar(50) 
			--
			,@approval_code				  nvarchar(50)
			,@value_approval			  nvarchar(250)
			,@requestor_code			  nvarchar(50)
			,@requestor_name			  nvarchar(250)
			,@level						  int
			,@approval_level			  int
			,@minimum_approval			  int
			,@is_mandatory_level		  nvarchar(1)
			,@emp_position_code			  nvarchar(50)
			,@emp_position_name			  nvarchar(250)
			,@emp_code					  nvarchar(50)
			,@emp_name					  nvarchar(250)
			,@email						  nvarchar(250)
			,@id_schedule				  int
			,@code_interface			  nvarchar(50)
			,@approval_interface_code	  nvarchar(50) 
			,@employee_name				  nvarchar(250)

	begin TRY

		-- untuk getnext level
		begin  

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = @p_approval_code

			select	*
			from	dbo.application_information
			where	application_no = @p_application_no

			if exists
			(
				select	1
				from	dbo.application_information
				where	application_no = @p_application_no
						and isnull(approval_code, '') = ''
			) 
			begin 
				if exists
				(
					select	1
					from	dbo.master_approval
					where	code			 = @p_approval_code             
							and is_active	 = '1'
				)
				begin
					select	@branch_code				= am.branch_code
							,@branch_name				= am.branch_name
							,@client_name				= isnull(am.client_name, cm.client_name)
							,@application_external_no	= am.application_external_no
					from	dbo.application_main am
							left join dbo.client_main cm on (cm.code = am.client_code)
					where	am.application_no = @p_application_no ;


					if (@p_is_simulation = '0')
					BEGIN
						--(+)Raffi 2025-06-19 : imon 2506000175 penambahan validasi generate heula exposurena
						--if not exists (select 1 from dbo.application_exposure where application_no = @p_application_no)			
						--begin
						--	set @msg = 'Please Generate Exposure Before Proceed';
						--	raiserror(@msg, 16, 1) ;
						--end ;
						select	@total_application = isnull(sum(isnull(asset_amount, 0)), 0)--isnull(sum(isnull(asset_amount, 0)) - sum(isnull(asset_rv_amount, 0)), 0)
						from	dbo.application_asset
						where	application_no = @p_application_no ;

						select	@total_application = @total_application + isnull(sum(isnull(amount_finance_amount, 0)), 0)
						from	dbo.application_exposure
						where	application_no = @p_application_no ;
					end ;
					else
					begin
						select	@total_application = isnull(avg(isnull(roa_pct, 0)), 0)
						from	dbo.application_asset
						where	application_no = @p_application_no ;
					end ;
					
					set @interface_remarks = 'Approval '+ @p_approval_code + ' ' + @application_external_no + ' - ' + @client_name ;
					set @req_date = dbo.xfn_get_system_date() ;

					--select path di global param
					select	@url_path = value
					from	dbo.sys_global_param
					where	code = 'URL_PATH' ;

					select	@path = @url_path + value
					from	dbo.sys_global_param
					where	code = 'APVAPP'

					--set approval path
					set	@approval_path = @path + @p_application_no + @page_type
					exec dbo.xsp_opl_interface_approval_request_insert @p_code						= @request_code output
																		,@p_branch_code				= @branch_code
																		,@p_branch_name				= @branch_name
																		,@p_request_status			= N'HOLD'
																		,@p_request_date			= @req_date
																		,@p_request_amount			= @total_application
																		,@p_request_remarks			= @interface_remarks
																		,@p_reff_module_code		= N'IFINOPL'
																		,@p_reff_no					= @p_application_no
																		,@p_reff_name				= N'APPLICATION APPROVAL'
																		,@p_paths					= @approval_path
																		,@p_approval_category_code	= @reff_approval_category_code
																		,@p_approval_status			= N''
																		,@p_cre_date				= @p_mod_date
																		,@p_cre_by					= @p_mod_by
																		,@p_cre_ip_address			= @p_mod_ip_address
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_ip_address			= @p_mod_ip_address ;

					declare master_approval_dimension cursor for

					select 	reff_dimension_code
							,dimension_code
					from	dbo.master_approval_dimension
					where	approval_code = @p_approval_code

					open master_approval_dimension		
					fetch next from master_approval_dimension
					into @reff_dimension_code
						,@dimension_code
				
					while @@fetch_status = 0

					begin 

					exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
																,@p_reff_code	= @p_application_no
																,@p_reff_table	= 'APPLICATION_MAIN'
																,@p_output		= @dim_value output ;

					exec dbo.xsp_opl_interface_approval_request_dimension_insert @p_id						= 0
																					,@p_request_code		= @request_code
																					,@p_dimension_code		= @reff_dimension_code
																					,@p_dimension_value		= @dim_value
																					,@p_cre_date			= @p_mod_date
																					,@p_cre_by				= @p_mod_by
																					,@p_cre_ip_address		= @p_mod_ip_address
																					,@p_mod_date			= @p_mod_date
																					,@p_mod_by				= @p_mod_by
																					,@p_mod_ip_address		= @p_mod_ip_address ;
				

					fetch next from master_approval_dimension
					into @reff_dimension_code
						,@dimension_code
					end
				
					close master_approval_dimension
					deallocate master_approval_dimension
					
				end
				else
				begin
					set @msg = 'Please setting Master Approval';
					raiserror(@msg, 16, 1) ;
				end ;
			end ;
			else
			begin
				select	@approval_code = max(am.code)
				from	dbo.opl_interface_approval_request piar
						inner join ifinapv.dbo.apv_interface_approval_request apiar on apiar.code = piar.code
						inner join ifinapv.dbo.approval_request ar on ar.code					  = apiar.code
						inner join ifinapv.dbo.approval_main am on am.request_code				  = ar.code
				where	apiar.reff_no					= @p_application_no
						and piar.approval_category_code = @reff_approval_category_code
						and piar.approval_status		= 'RETURN' ;

				select	@level = current_active_level
				from	ifinapv.dbo.approval_main
				where	code = @approval_code ;

				select	@approval_interface_code = max(code)
				from	dbo.opl_interface_approval_request
				where	reff_no = @p_application_no ;

				update	dbo.opl_interface_approval_request
				set		approval_status = ''
						,request_status	= 'HOLD'
						,job_status		= 'HOLD'
						,settle_date	= null
				where	code = @approval_interface_code ;

				update	ifinapv.dbo.apv_interface_approval_request
				set		approval_status = ''
				where	code = @approval_interface_code ;
				
				if (isnull(@p_last_return, '') = 'YES')
				begin 
					-- loop untuk semua schedule untuk masuk ke target
					declare curr_app_sche cursor fast_forward read_only for
					select	id
							,emp_position_code
							,emp_position_name
							,emp_code
							,emp_name
					from	ifinapv.dbo.approval_schedule
					where	approval_code	   = @approval_code
							and approval_level = @level
							--and type_schedule = 'RETURN'
	
					open curr_app_sche ;
	
					fetch next from curr_app_sche
					into @id_schedule
						,@emp_position_code
						,@emp_position_name
						,@emp_code
						,@emp_name ;
	
					while @@fetch_status = 0
					begin

						update	ifinapv.dbo.approval_schedule
						set		result_date		= null
								,result_status	= ''
								,result_remarks = ''
						where	id				= @id_schedule


						exec ifinapv.dbo.xsp_approval_target_insert @p_id						= 0
																	,@p_approval_code			= @approval_code
																	,@p_approval_level			= @level
																	,@p_approval_schedule_id	= @id_schedule
																	,@p_emp_position_code		= @emp_position_code
																	,@p_emp_position_name		= @emp_position_name
																	,@p_emp_code				= @emp_code
																	,@p_emp_name				= @emp_name
																	,@p_link_email				= null
																	,@p_link_token				= null
																	,@p_link_expired_date		= null
																	,@p_link_last_access_date	= null
																	,@p_result_date				= null
																	,@p_result_status			= 'HOLD'
																	,@p_result_remarks			= ''
																	,@p_last_approval_level		= @level
																	,@p_cre_date				= @p_mod_date
																	,@p_cre_by					= @p_mod_by
																	,@p_cre_ip_address			= @p_mod_ip_address
																	,@p_mod_date				= @p_mod_date
																	,@p_mod_by					= @p_mod_by
																	,@p_mod_ip_address			= @p_mod_ip_address ;
	
						exec ifinapv.dbo.xsp_approval_request_notification @p_code				= @approval_code
																			,@p_emp_name		= @emp_code
																			,@p_cre_date		= @p_mod_date
																			,@p_cre_by			= @p_mod_by
																			,@p_cre_ip_address	= @p_mod_ip_address
																			,@p_mod_date		= @p_mod_date
																			,@p_mod_by			= @p_mod_by
																			,@p_mod_ip_address	= @p_mod_ip_address ;
							 
						fetch next from curr_app_sche
						into @id_schedule
							,@emp_position_code
							,@emp_position_name
							,@emp_code
							,@emp_name ;
					end ;
	
					close curr_app_sche ;
					deallocate curr_app_sche ;
						
					update ifinapv.dbo.approval_main
					set		current_active_level	= @level
							,last_remark			= @p_approval_comment
							--
							,mod_date				= @p_mod_date
							,mod_by					= @p_mod_by
							,mod_ip_address			= @p_mod_ip_address
					where	code					= @approval_code
					
					select	@employee_name = name
					from	ifinsys.dbo.sys_employee_main
					where	code = @p_mod_by ;
	
					exec ifinapv.dbo.xsp_approval_log_insert @p_id					= 0
															 ,@p_approval_code		= @approval_code
															 ,@p_log_status			= 'APPROVE'
															 ,@p_log_date			= @p_mod_date
															 ,@p_log_emp_code		= @p_mod_by
															 ,@p_log_emp_name		= @employee_name
															 ,@p_log_remarks		= @p_approval_comment
															 ,@p_approval_level		= 0
															 ,@p_cre_date			= @p_mod_date
															 ,@p_cre_by				= @p_mod_by
															 ,@p_cre_ip_address		= @p_mod_ip_address
															 ,@p_mod_date			= @p_mod_date
															 ,@p_mod_by				= @p_mod_by
															 ,@p_mod_ip_address		= @p_mod_ip_address ;

				end 
				else
				begin 
					-- loop untuk semua schedule untuk masuk ke target
					declare curr_app_sche cursor fast_forward read_only for
					select	id
							,emp_position_code
							,emp_position_name
							,emp_code
							,emp_name
					from	ifinapv.dbo.approval_schedule
					where	approval_code	   = @approval_code
							and approval_level = 1
							--and type_schedule = 'RETURN'
	
					open curr_app_sche ;
	
					fetch next from curr_app_sche
					into @id_schedule
						,@emp_position_code
						,@emp_position_name
						,@emp_code
						,@emp_name ;
	
					while @@fetch_status = 0
					begin

						update	ifinapv.dbo.approval_schedule
						set		result_date		= null
								,result_status	= ''
								,result_remarks = ''
						where	id				= @id_schedule


						exec ifinapv.dbo.xsp_approval_target_insert @p_id						= 0
																	,@p_approval_code			= @approval_code
																	,@p_approval_level			= 1
																	,@p_approval_schedule_id	= @id_schedule
																	,@p_emp_position_code		= @emp_position_code
																	,@p_emp_position_name		= @emp_position_name
																	,@p_emp_code				= @emp_code
																	,@p_emp_name				= @emp_name
																	,@p_link_email				= null
																	,@p_link_token				= null
																	,@p_link_expired_date		= null
																	,@p_link_last_access_date	= null
																	,@p_result_date				= null
																	,@p_result_status			= 'HOLD'
																	,@p_result_remarks			= ''
																	,@p_last_approval_level		= @level
																	,@p_cre_date				= @p_mod_date
																	,@p_cre_by					= @p_mod_by
																	,@p_cre_ip_address			= @p_mod_ip_address
																	,@p_mod_date				= @p_mod_date
																	,@p_mod_by					= @p_mod_by
																	,@p_mod_ip_address			= @p_mod_ip_address ;
	
						exec ifinapv.dbo.xsp_approval_request_notification @p_code				= @approval_code
																			,@p_emp_name		= @emp_code
																			,@p_cre_date		= @p_mod_date
																			,@p_cre_by			= @p_mod_by
																			,@p_cre_ip_address	= @p_mod_ip_address
																			,@p_mod_date		= @p_mod_date
																			,@p_mod_by			= @p_mod_by
																			,@p_mod_ip_address	= @p_mod_ip_address ;
							 
						fetch next from curr_app_sche
						into @id_schedule
							,@emp_position_code
							,@emp_position_name
							,@emp_code
							,@emp_name ;
					end ;
	
					close curr_app_sche ;
					deallocate curr_app_sche ;
						
					update ifinapv.dbo.approval_main
					set		current_active_level	= 1
							,last_remark			= @p_approval_comment
							--
							,mod_date				= @p_mod_date
							,mod_by					= @p_mod_by
							,mod_ip_address			= @p_mod_ip_address
					where	code					= @approval_code
					
					select	@employee_name = name
					from	ifinsys.dbo.sys_employee_main
					where	code = @p_mod_by ;
	
					exec ifinapv.dbo.xsp_approval_log_insert @p_id					= 0
															 ,@p_approval_code		= @approval_code
															 ,@p_log_status			= 'APPROVE'
															 ,@p_log_date			= @p_mod_date
															 ,@p_log_emp_code		= @p_mod_by
															 ,@p_log_emp_name		= @employee_name
															 ,@p_log_remarks		= @p_approval_comment
															 ,@p_approval_level		= 0
															 ,@p_cre_date			= @p_mod_date
															 ,@p_cre_by				= @p_mod_by
															 ,@p_cre_ip_address		= @p_mod_ip_address
															 ,@p_mod_date			= @p_mod_date
															 ,@p_mod_by				= @p_mod_by
															 ,@p_mod_ip_address		= @p_mod_ip_address ;
				end
			end

			update	dbo.application_information
			set		approval_code		= null
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	application_no		= @p_application_no ;
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






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_application_main_proceed_to_approval] TO [ims-raffyanda]
    AS [dbo];


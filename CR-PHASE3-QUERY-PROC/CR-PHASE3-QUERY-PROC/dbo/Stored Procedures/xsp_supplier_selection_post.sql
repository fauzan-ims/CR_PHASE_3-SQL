CREATE PROCEDURE [dbo].[xsp_supplier_selection_post]
(
	@p_code			    nvarchar(50)
	,@p_last_return		nvarchar(3)		= ''
	,@p_result_remarks	nvarchar(4000)	= ''
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
declare @msg						  nvarchar(max)
		,@branch_code				  nvarchar(50)
		,@branch_name				  nvarchar(250)
		,@item_code					  nvarchar(50)
		,@item_name					  nvarchar(250)
		,@interface_remarks			  nvarchar(4000)
		,@req_date					  datetime
		,@reff_approval_category_code nvarchar(50)
		,@request_code				  nvarchar(50)
		,@req_amount				  decimal(18, 2)
		,@table_name				  nvarchar(50)
		,@primary_column			  nvarchar(50)
		,@dimension_code			  nvarchar(50)
		,@dim_value					  nvarchar(50)
		,@reff_dimension_code		  nvarchar(50)
		,@reff_dimension_name		  nvarchar(250)
		,@approval_code				  nvarchar(50)
		,@value_approval			  nvarchar(250)
		,@path						  nvarchar(250)
		,@url_path					  nvarchar(250)
		,@approval_path				  nvarchar(4000)
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
		,@comment_return_entry		  nvarchar(4000)
		,@approval_interface_code	  nvarchar(50)
		,@application_no			  nvarchar(50)
		,@asset_no					  nvarchar(50)
		,@description_log			  nvarchar(4000)
		,@date						  datetime = dbo.xfn_get_system_date()


	begin try

		if exists
		(
			select	1
			from	dbo.supplier_selection_detail
			where	isnull(tax_code, '') = ''
					and selection_code	 = @p_code
		)
		begin
			set @msg = N'Please insert tax first.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
						from	dbo.supplier_selection
			where	status = 'ON PROCESS'
					and code = @p_code
		)
		begin
			set @msg = N'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1

			from	dbo.supplier_selection_detail
			where	isnull(supplier_code, '') = ''
					and selection_code		  = @p_code
		)
		begin
			set @msg = N'Please insert supplier first.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.supplier_selection_detail
			where	amount			   = 0
					and selection_code = @p_code
		)
		begin
			set @msg = N'Amount must be greater than 0.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--if not exists (select 1 from dbo.proc_interface_approval_request where reff_no = @p_code and approval_status = 'RETURN')
		if exists(select 1 from dbo.supplier_selection where code = @p_code and count_return = 0)
		begin
			update	dbo.supplier_selection
			set		status			= 'ON PROCESS'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			/* declare variables */
			declare curr_apv cursor fast_forward read_only for
			select	ss.branch_code
					,ss.branch_name
					,ss.selection_date	
			from dbo.supplier_selection ss
			left join ifinsys.dbo.sys_employee_main sem on sem.code = ss.mod_by
			where ss.code = @p_code

			open curr_apv

			fetch next from curr_apv 
			into @branch_code
				,@branch_name
				,@req_date

			while @@fetch_status = 0
			begin
				set @interface_remarks = 'Approval Supplier Selection For ' + @p_code;
				--set @req_date = dbo.xfn_get_system_date() ;

				select	@reff_approval_category_code = reff_approval_category_code
				from	dbo.master_approval
				where	code						 = 'SSAPV' ;

				select	@req_amount = sum(((ssd.amount - ssd.discount_amount) * ssd.quantity) + ssd.ppn_amount - ssd.pph_amount)
				from	dbo.supplier_selection ss
						inner join dbo.supplier_selection_detail ssd on (ss.code = ssd.selection_code)
				where	ss.code = @p_code

				--select path di global param
				select	@url_path = value
				from	dbo.sys_global_param
				where	code = 'URL_PATH' ;

				select	@path = @url_path + value
				from	dbo.sys_global_param
				where	code = 'PATHSS'

				--set approval path
				set	@approval_path = @path + @p_code

				select	@requestor_name = name
				from	ifinsys.dbo.sys_employee_main
				where	code = @p_mod_by ;

				exec dbo.xsp_proc_interface_approval_request_insert @p_code						= @request_code output
																	,@p_branch_code				= @branch_code
																	,@p_branch_name				= @branch_name
																	,@p_request_status			= 'HOLD'
																	,@p_request_date			= @req_date
																	,@p_request_amount			= @req_amount
																	,@p_request_remarks			= @interface_remarks
																	,@p_reff_module_code		= 'IFINPROC'
																	,@p_reff_no					= @p_code
																	,@p_reff_name				= 'SUPPLIER SELECTION APPROVAL'
																	,@p_paths					= @approval_path
																	,@p_approval_category_code	= @reff_approval_category_code
																	,@p_approval_status			= 'HOLD'
																	,@p_requestor_code			= @p_mod_by
																	,@p_requesttor_name			= @requestor_name
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
				where	approval_code = 'SSAPV'

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
																,@p_reff_table	= 'SUPPLIER_SELECTION'
																,@p_output		= @dim_value output ;

					exec dbo.xsp_proc_interface_approval_request_dimension_insert @p_id						= 0
																				  ,@p_request_code			= @request_code
																				  ,@p_dimension_code		= @reff_dimension_code
																				  ,@p_dimension_value		= @dim_value
																				  ,@p_cre_date				= @p_mod_date
																				  ,@p_cre_by				= @p_mod_by
																				  ,@p_cre_ip_address		= @p_mod_ip_address
																				  ,@p_mod_date				= @p_mod_date
																				  ,@p_mod_by				= @p_mod_by
																				  ,@p_mod_ip_address		= @p_mod_ip_address
					fetch next from curr_appv 
					into @approval_code
						,@reff_dimension_code
						,@reff_dimension_name
						,@dimension_code
				end

				close curr_appv
				deallocate curr_appv

				fetch next from curr_apv 
				into @branch_code
					,@branch_name
					,@req_date
			end

			close curr_apv
			deallocate curr_apv
		end
		else
		begin
					--select	@approval_code	= max(am.code)
					--		,@level			= am.current_active_level
					--from	dbo.proc_interface_approval_request					  piar
					--		inner join ifinapv.dbo.apv_interface_approval_request apiar on apiar.code	= piar.code
					--		inner join ifinapv.dbo.approval_request				  ar on ar.code			= apiar.code
					--		inner join ifinapv.dbo.approval_main				  am on am.request_code = ar.code
					--where	apiar.reff_no = @p_code
					--group by am.current_active_level

					select		top 1
								@approval_code	= am.code
								,@level			= am.current_active_level
					from		dbo.proc_interface_approval_request					  piar
								inner join ifinapv.dbo.apv_interface_approval_request apiar on apiar.code	= piar.code
								inner join ifinapv.dbo.approval_request				  ar on ar.code			= apiar.code
								inner join ifinapv.dbo.approval_main				  am on am.request_code = ar.code
					where		apiar.reff_no = @p_code
					order by	am.cre_date desc ;

					select	@comment_return_entry = isnull(comment_return_entry, '')
					from	ifinapv.dbo.approval_schedule
					where	approval_code	   = @approval_code
							and approval_level = 0 ;

					--validasi jika ada comment return yang tidak diisi
					if @comment_return_entry = ''
					begin
						set @msg = 'Please input comment return in view approval.';
    					raiserror(@msg, 16, -1) ;
					end

					update	dbo.supplier_selection
					set		status			= 'ON PROCESS'
							--
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	code			= @p_code ;

					select	@approval_interface_code = max(code)
					from	dbo.proc_interface_approval_request
					where	reff_no = @p_code ;

					update	dbo.proc_interface_approval_request
					set		approval_status = ''
							,request_status	= 'HOLD'
							,job_status		= 'HOLD'
							,settle_date	= null
					where	code = @approval_interface_code ;

					update	ifinapv.dbo.apv_interface_approval_request
					set		approval_status = ''
					where	code = @approval_interface_code ;

					if(@p_last_return = 'YES')
					begin
						--declare curr_approve cursor fast_forward read_only for
						--select	approval_level
						--		,minimum_approval
						--		,is_mandatory_level
						--		,emp_position_code
						--		,emp_position_name
						--		,emp_code
						--		,emp_name
						--		,email
						--from	ifinapv.dbo.approval_schedule
						--where	approval_code	   = @approval_code
						--		and approval_level = @level
						--		and type_schedule	is null
						
						--open curr_approve
						
						--fetch next from curr_approve 
						--into @approval_level
						--	,@minimum_approval
						--	,@is_mandatory_level
						--	,@emp_position_code
						--	,@emp_position_name
						--	,@emp_code
						--	,@emp_name
						--	,@email
						
						--while @@fetch_status = 0
						--begin
						--		exec ifinapv.dbo.xsp_approval_schedule_insert @p_id					= 0
						--													,@p_approval_code		= @approval_code
						--													,@p_approval_level		= @approval_level
						--													,@p_minimum_approval	= @minimum_approval
						--													,@p_is_mandatory_level	= @is_mandatory_level
						--													,@p_emp_position_code	= @emp_position_code
						--													,@p_emp_position_name	= @emp_position_name
						--													,@p_emp_code			= @emp_code
						--													,@p_emp_name			= @emp_name
						--													,@p_result_date			= null
						--													,@p_result_status		= ''
						--													,@p_result_remarks		= ''
						--													,@p_email				= @email
						--													,@p_type_schedule		= 'RETURN'
						--													,@p_cre_date			= @p_mod_date
						--													,@p_cre_by				= @p_mod_by
						--													,@p_cre_ip_address		= @p_mod_ip_address
						--													,@p_mod_date			= @p_mod_date
						--													,@p_mod_by				= @p_mod_by
						--													,@p_mod_ip_address		= @p_mod_ip_address
						--    fetch next from curr_approve 
						--	into @approval_level
						--		,@minimum_approval
						--		,@is_mandatory_level
						--		,@emp_position_code
						--		,@emp_position_name
						--		,@emp_code
						--		,@emp_name
						--		,@email
						--end
						
						--close curr_approve
						--deallocate curr_approve

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
																			  ,@p_emp_name			= @emp_code
																			  ,@p_cre_date			= @p_mod_date
																			  ,@p_cre_by			= @p_mod_by
																			  ,@p_cre_ip_address	= @p_mod_ip_address
																			  ,@p_mod_date			= @p_mod_date
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

						update	ifinapv.dbo.approval_schedule
						set		result_date			= null
								,result_status		= ''
								,result_remarks		= ''
								--
								,mod_date			= @p_mod_date
								,mod_by				= @p_mod_by
								,mod_ip_address		= @p_mod_ip_address
						where	approval_code		= @approval_code
								and approval_level	= @level ;
						
						update ifinapv.dbo.approval_main
						set		current_active_level	= @level
								,last_remark			= @p_result_remarks
								,approval_status		= 'HOLD'
								--
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code = @approval_code

						select	@emp_name = name
						from	ifinsys.dbo.sys_employee_main
						where	code = @p_mod_by ;

						exec ifinapv.dbo.xsp_approval_log_insert @p_id				= 0
																,@p_approval_code	= @approval_code
																,@p_log_status		= 'ENTRY'
																,@p_log_date		= @p_mod_date
																,@p_log_emp_code	= @p_mod_by
																,@p_log_emp_name	= @emp_name
																,@p_log_remarks		= @p_result_remarks
																,@p_approval_level	= 0
																,@p_cre_date		= @p_mod_date
																,@p_cre_by			= @p_mod_by
																,@p_cre_ip_address	= @p_mod_ip_address
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address ;
					end
					else
					begin
						--declare curr_approve cursor fast_forward read_only for
						--select	approval_level
						--		,minimum_approval
						--		,is_mandatory_level
						--		,emp_position_code
						--		,emp_position_name
						--		,emp_code
						--		,emp_name
						--		,email
						--from	ifinapv.dbo.approval_schedule
						--where	approval_code	   = @approval_code
						--		and approval_level = 1
						--		and type_schedule	is null
						
						--open curr_approve
						
						--fetch next from curr_approve 
						--into @approval_level
						--	,@minimum_approval
						--	,@is_mandatory_level
						--	,@emp_position_code
						--	,@emp_position_name
						--	,@emp_code
						--	,@emp_name
						--	,@email
						
						--while @@fetch_status = 0
						--begin
						--		exec ifinapv.dbo.xsp_approval_schedule_insert @p_id					= 0
						--													,@p_approval_code		= @approval_code
						--													,@p_approval_level		= 1
						--													,@p_minimum_approval	= @minimum_approval
						--													,@p_is_mandatory_level	= @is_mandatory_level
						--													,@p_emp_position_code	= @emp_position_code
						--													,@p_emp_position_name	= @emp_position_name
						--													,@p_emp_code			= @emp_code
						--													,@p_emp_name			= @emp_name
						--													,@p_result_date			= null
						--													,@p_result_status		= ''
						--													,@p_result_remarks		= ''
						--													,@p_email				= @email
						--													,@p_type_schedule		= 'APPROVE'
						--													,@p_cre_date			= @p_mod_date
						--													,@p_cre_by				= @p_mod_by
						--													,@p_cre_ip_address		= @p_mod_ip_address
						--													,@p_mod_date			= @p_mod_date
						--													,@p_mod_by				= @p_mod_by
						--													,@p_mod_ip_address		= @p_mod_ip_address
						--    fetch next from curr_approve 
						--	into @approval_level
						--		,@minimum_approval
						--		,@is_mandatory_level
						--		,@emp_position_code
						--		,@emp_position_name
						--		,@emp_code
						--		,@emp_name
						--		,@email
						--end
						
						--close curr_approve
						--deallocate curr_approve

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
								and type_schedule is null
	
						open curr_app_sche ;
	
						fetch next from curr_app_sche
						into @id_schedule
							 ,@emp_position_code
							 ,@emp_position_name
							 ,@emp_code
							 ,@emp_name ;
	
						while @@fetch_status = 0
						begin
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
																			  ,@p_emp_name			= @emp_code
																			  ,@p_cre_date			= @p_mod_date
																			  ,@p_cre_by			= @p_mod_by
																			  ,@p_cre_ip_address	= @p_mod_ip_address
																			  ,@p_mod_date			= @p_mod_date
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

						update	ifinapv.dbo.approval_schedule
						set		result_date			= null
								,result_status		= ''
								,result_remarks		= ''
								--
								,mod_date			= @p_mod_date
								,mod_by				= @p_mod_by
								,mod_ip_address		= @p_mod_ip_address
						where	approval_code		= @approval_code
								and approval_level	= 1 ;
						
						update ifinapv.dbo.approval_main
						set		current_active_level	= 1
								,last_remark			= @p_result_remarks
								,approval_status		= 'HOLD'
								--
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code = @approval_code

						select	@emp_name = name
						from	ifinsys.dbo.sys_employee_main
						where	code = @p_mod_by ;

						exec ifinapv.dbo.xsp_approval_log_insert @p_id				= 0
																,@p_approval_code	= @approval_code
																,@p_log_status		= 'ENTRY'
																,@p_log_date		= @p_mod_date
																,@p_log_emp_code	= @p_mod_by
																,@p_log_emp_name	= @emp_name
																,@p_log_remarks		= 'Entry data return approval'
																,@p_approval_level	= 0
																,@p_cre_date		= @p_mod_date
																,@p_cre_by			= @p_mod_by
																,@p_cre_ip_address	= @p_mod_ip_address
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address ;
					end
		end
		
		declare curr_log cursor fast_forward read_only for
		select	d.asset_no
				,a.item_name
		from	dbo.supplier_selection_detail		  a
				left join dbo.quotation_review_detail b on a.reff_no = b.quotation_review_code collate Latin1_General_CI_AS
				left join dbo.procurement			  c on c.code	 = isnull(b.reff_no, a.reff_no) collate Latin1_General_CI_AS
				inner join dbo.procurement_request	  d on d.code	 = c.procurement_request_code
		where	a.selection_code = @p_code ;
		
		open curr_log
		
		fetch next from curr_log 
		into @asset_no
			,@item_name
		
		while @@fetch_status = 0
		begin
			select @application_no = isnull(application_no,'')
			from ifinopl.dbo.application_asset 
			where asset_no = @asset_no

			if(@application_no <> '')
			begin
				set @description_log = 'Supplier selection proceed without quotation, Asset no : ' + @asset_no + ' - ' + @item_name
		
				exec ifinopl.dbo.xsp_application_log_insert @p_id					= 0
															,@p_application_no		= @application_no
															,@p_log_date			= @date
															,@p_log_description		= @description_log
															,@p_cre_date			= @p_mod_date
															,@p_cre_by				= @p_mod_by
															,@p_cre_ip_address		= @p_mod_ip_address
															,@p_mod_date			= @p_mod_date
															,@p_mod_by				= @p_mod_by
															,@p_mod_ip_address		= @p_mod_ip_address
			end

		    fetch next from curr_log 
			into @asset_no
				,@item_name
		end
		
		close curr_log
		deallocate curr_log

		


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

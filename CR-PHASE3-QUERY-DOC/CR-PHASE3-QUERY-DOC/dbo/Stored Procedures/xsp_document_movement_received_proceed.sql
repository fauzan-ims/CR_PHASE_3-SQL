CREATE PROCEDURE dbo.xsp_document_movement_received_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					   nvarchar(max)
			,@document_request_code	   nvarchar(50)
			,@document_main_code	   nvarchar(50)
			,@document_code			   nvarchar(50)
			,@is_reject				   nvarchar(1)
			,@remarks				   nvarchar(4000)
			,@branch_code			   nvarchar(50)
			,@branch_name			   nvarchar(250)
			,@agreement_no			   nvarchar(50)
			,@collateral_no			   nvarchar(50)
			,@asset_no				   nvarchar(50)
			,@movement_date			   datetime
			,@return_date			   datetime
			,@movement_type			   nvarchar(50)
			,@movement_location		   nvarchar(50)
			,@history_status		   nvarchar(20)
			,@movement_status		   nvarchar(20)
			,@document_status		   nvarchar(20)
			,@movement_remark		   nvarchar(250)
			,@document_movement_from   nvarchar(250)
			,@document_movement_to	   nvarchar(250)
			,@movement_to_agreement_no nvarchar(50)
			,@movement_by_emp_name	   nvarchar(250)
			,@movement_to_client_name  nvarchar(250)
			,@movement_to_branch_code  nvarchar(50)
			,@movement_to_branch_name  nvarchar(250)
			,@movement_to_dept_code	   nvarchar(50)
			,@movement_to_dept_name	   nvarchar(250)
			,@movement_from_dept_code  nvarchar(50)
			,@movement_from_dept_name  nvarchar(250)
			,@document_no			   nvarchar(50)
			,@document_type			   nvarchar(20) ;

	begin try
		select	@branch_code = branch_code
				,@branch_name = branch_name
				,@movement_date = movement_date
				,@movement_type = movement_type
				,@movement_location = movement_location
				,@movement_status = movement_status
				,@movement_remark = movement_remarks
				,@movement_by_emp_name = movement_by_emp_name
				,@return_date = estimate_return_date
				,@movement_to_agreement_no = movement_to_agreement_no
				,@movement_to_client_name = movement_to_client_name
				,@movement_to_branch_code = movement_to_branch_code
				,@movement_to_branch_name = movement_to_branch_name
				,@movement_to_dept_code = movement_to_dept_code
				,@movement_to_dept_name = movement_to_dept_name
				,@movement_from_dept_code = movement_from_dept_code
				,@movement_from_dept_name = movement_from_dept_name
		from	dbo.document_movement
		where	code = @p_code ;

		if not exists
		(
			select	1
			from	dbo.document_movement_detail
			where	movement_code = @p_code
		)
		begin
			set @msg = N'Please add document before Proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@movement_status <> 'HOLD')
		begin
			raiserror('Data already proceed', 16, 1) ;
		end ;
		else
		begin
			set @movement_status = N'ON PROCESS' ;

			declare cursor_movement cursor fast_forward read_only for
			select	dmd.document_code
			from	dbo.document_movement_detail dmd
					left join dbo.document_pending dp on dp.code = dmd.document_pending_code
			where	movement_code = @p_code ;

			open cursor_movement ;

			fetch next from cursor_movement
			into @document_code
				 ,@is_reject
				 ,@remarks
				 ,@agreement_no
				 ,@collateral_no
				 ,@asset_no ;

			while @@fetch_status = 0
			begin

				-- movement location = ENTRY
				set @movement_status = N'ON PROCESS' ;
				set @document_status = N'ON HAND' ;
				set @movement_remark = N'First Entry ' + @movement_remark ;
				set @document_movement_from = N'VENDOR' ;
				set @document_movement_to = N'BRANCH' ;

				exec dbo.xsp_document_main_insert @p_code						= @document_main_code output -- nvarchar(50)
												  ,@p_branch_code				= @branch_code
												  ,@p_branch_name				= @branch_name
												  ,@p_custody_branch_code		= N'' -- nvarchar(50)
												  ,@p_custody_branch_name		= N'' -- nvarchar(250)
												  ,@p_document_type				= @document_type
												  ,@p_plafond_no				= N'' -- nvarchar(50)
												  ,@p_agreement_no				= N'' -- nvarchar(50)
												  ,@p_client_no					= N'' -- nvarchar(50)
												  ,@p_client_name				= N'' -- nvarchar(250)
												  ,@p_collateral_no				= N'' -- nvarchar(50)
												  ,@p_collateral_name			= N'' -- nvarchar(250)
												  ,@p_plafond_collateral_no		= N'' -- nvarchar(50)
												  ,@p_plafond_collateral_name	= N'' -- nvarchar(250)
												  ,@p_asset_no					= N'' -- nvarchar(50)
												  ,@p_asset_name				= N'' -- nvarchar(250)
												  ,@p_locker_position			= 'OUT LOCKER'
												  ,@p_locker_code				= null
												  ,@p_drawer_code				= null
												  ,@p_row_code					= null
												  ,@p_document_status			= 'ON HAND'
												  ,@p_mutation_type				= ''
												  ,@p_mutation_location			= @document_movement_to
												  ,@p_mutation_from				= @document_movement_from
												  ,@p_mutation_to				= @document_movement_to
												  ,@p_mutation_by				= ''
												  ,@p_mutation_date				= @movement_date
												  ,@p_mutation_return_date		= null
												  ,@p_last_mutation_type		= null
												  ,@p_last_mutation_date		= null
												  ,@p_last_locker_position		= null
												  ,@p_last_locker_code			= null
												  ,@p_last_drawer_code			= null
												  ,@p_last_row_code				= null
												  ,@p_borrow_thirdparty_type	= N'' -- nvarchar(20)
												  ,@p_first_receive_date		= @movement_date
												  ,@p_release_customer_date		= null
												  ---
												  ,@p_cre_date					= @p_mod_date
												  ,@p_cre_by					= @p_mod_by
												  ,@p_cre_ip_address			= @p_mod_ip_address
												  ,@p_mod_date					= @p_mod_date
												  ,@p_mod_by					= @p_mod_by
												  ,@p_mod_ip_address			= @p_mod_ip_address ;

				exec dbo.xsp_document_history_insert @p_id						= 0
													 ,@p_document_code			= @document_code
													 ,@p_document_status		= @document_status
													 ,@p_movement_type			= @history_status
													 ,@p_movement_location		= @movement_location
													 ,@p_movement_from			= @document_movement_from
													 ,@p_movement_to			= @document_movement_to
													 ,@p_movement_by			= @movement_by_emp_name
													 ,@p_movement_date			= @movement_date
													 ,@p_movement_return_date	= @return_date
													 ,@p_locker_position		= 'OUT LOCKER'
													 ,@p_locker_code			= null
													 ,@p_drawer_code			= null
													 ,@p_row_code				= null
													 ,@p_remarks				= @movement_remark
													 ,@p_cre_date				= @p_mod_date
													 ,@p_cre_by					= @p_mod_by
													 ,@p_cre_ip_address			= @p_mod_ip_address
													 ,@p_mod_date				= @p_mod_date
													 ,@p_mod_by					= @p_mod_by
													 ,@p_mod_ip_address			= @p_mod_ip_address ;

				fetch next from cursor_movement
				into @document_code
					 ,@is_reject
					 ,@remarks
					 ,@agreement_no
					 ,@collateral_no
					 ,@asset_no ;
			end ;

			close cursor_movement ;
			deallocate cursor_movement ;

			update	dbo.document_movement
			set		movement_status = @movement_status
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;
		end ;
	end try
	begin catch
		if cursor_status('global', 'cursor_movement') >= -1
		begin
			if cursor_status('global', 'cursor_movement') > -1
			begin
				close cursor_movement ;
			end ;

			deallocate cursor_movement ;
		end ;

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

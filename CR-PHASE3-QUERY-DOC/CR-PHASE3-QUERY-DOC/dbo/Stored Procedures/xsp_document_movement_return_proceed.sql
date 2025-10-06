CREATE PROCEDURE dbo.xsp_document_movement_return_proceed
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
			,@document_code			   nvarchar(50)
			,@branch_name			   nvarchar(250)
			,@movement_date			   datetime
			,@return_date			   datetime
			,@movement_location		   nvarchar(50)
			,@history_status		   nvarchar(20)
			,@movement_status		   nvarchar(20)
			,@document_status		   nvarchar(20)
			,@movement_remark		   nvarchar(250)
			,@document_movement_from   nvarchar(250)
			,@document_movement_to	   nvarchar(250)
			,@movement_by_emp_name	   nvarchar(250)
			,@movement_to_branch_name  nvarchar(250)
			,@movement_to_dept_name	   nvarchar(250)
			,@movement_from_dept_name  nvarchar(250)
			,@history_remark		   nvarchar(250) ;

	begin try
		select	 @branch_name				= branch_name
				,@movement_date				= movement_date 
				,@movement_location			= movement_location
				,@movement_status			= movement_status
				,@movement_remark			= movement_remarks
				,@movement_by_emp_name		= movement_by_emp_name
				,@return_date				= estimate_return_date 
				,@movement_to_branch_name	= movement_to_branch_name 
				,@movement_to_dept_name		= movement_to_dept_name 
				,@movement_from_dept_name	= movement_from_dept_name
		from	dbo.document_movement
		where	code						= @p_code ;

		if not exists
		(
			select	1
			from	dbo.document_movement_detail
			where	movement_code = @p_code
		)
		begin
			set @msg = 'Please add document before Proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@movement_status <> 'HOLD')
		begin
			raiserror('Data already proceed', 16, 1) ;
		end ;
		else
		begin
			set @movement_status = 'ON PROCESS' ;

			declare cursor_movement cursor fast_forward read_only for
			select	dmd.document_code
			from	dbo.document_movement_detail dmd
			where	movement_code = @p_code ;

			open cursor_movement ;

			fetch next from cursor_movement
			into @document_code;

			while @@fetch_status = 0
			begin
				set @movement_status	= 'ON PROCESS' ;
				set @document_status	= 'ON TRANSIT - RETURN' ;
				set @history_status		= 'RETURN - PROCEED' ;

				if (@movement_location	= 'BRANCH')
				begin
					set @document_movement_from = @branch_name ;
					set @document_movement_to	= @movement_to_branch_name ;
					set @history_remark			= 'RETURN FROM BRANCH ' +  @document_movement_from + ' ' + @movement_remark;

					update	dbo.document_main
					set		document_status = @document_status
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	code			= @document_code ;
				end ;
				else if (@movement_location = 'DEPARTMENT')
				begin
					set @document_movement_from = @movement_from_dept_name ;
					set @document_movement_to	= @branch_name ;
					set @history_remark			= 'RETURN FROM DEPARTMENT ' + @document_movement_from + ' ' + @movement_remark;

					update	dbo.document_main
					set		document_status = @document_status
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	code			= @document_code ;
				end ;

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
													 ,@p_remarks				= @history_remark
													 ,@p_cre_date				= @p_mod_date
													 ,@p_cre_by					= @p_mod_by
													 ,@p_cre_ip_address			= @p_mod_ip_address
													 ,@p_mod_date				= @p_mod_date
													 ,@p_mod_by					= @p_mod_by
													 ,@p_mod_ip_address			= @p_mod_ip_address ;

				fetch next from cursor_movement
				into @document_code ;
			end ;

			close cursor_movement ;
			deallocate cursor_movement ;

			update	dbo.document_movement
			set		movement_status = @movement_status
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
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

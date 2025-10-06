CREATE PROCEDURE dbo.xsp_document_movement_send_post
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
			,@agreement_no			nvarchar(50)
			,@plafond_no			nvarchar(50)
			,@collateral_no			nvarchar(50)
			---
			,@document_main_code	nvarchar(50)
			,@branch_name			nvarchar(50)
			,@movement_date			datetime
			,@return_date			datetime
			,@movement_location		nvarchar(50)
			,@movement_status		nvarchar(10)
			,@document_status		nvarchar(20)
			,@movement_remark		nvarchar(250)
			,@thirdparty_type		nvarchar(50)
			,@mutation_type			nvarchar(20)
			,@mutation_date			datetime
			,@received_name			nvarchar(50)
			,@received_by			nvarchar(250)
			,@received_id_no		nvarchar(50)
			,@remark_history		nvarchar(250)
			,@mutation_location		nvarchar(50)
			,@estimate_return_date	datetime
			,@movement_by_emp_name	nvarchar(250)
			,@document_movement_to	nvarchar(50)
			,@history_movement_to	nvarchar(50)
			,@history_movement_by	nvarchar(250)
			,@history_movement_type nvarchar(50) 
			,@flag_borrow			nvarchar(15) = null

	begin try
		select	@branch_name				= dmv.branch_name
				,@movement_date				= dmv.movement_date
				,@movement_location			= dmv.movement_location
				,@movement_status			= dmv.movement_status
				,@movement_remark			= dmv.movement_remarks
				,@return_date				= isnull(dmv.estimate_return_date, null)
				,@thirdparty_type			= dmv.movement_to_thirdparty_type --sgs.general_code
				,@received_name				= dmv.received_name
				,@received_by				= dmv.received_by
				,@received_id_no			= dmv.received_id_no
				,@mutation_type				= dm.mutation_type
				,@mutation_date				= dm.mutation_date
				,@mutation_location			= dmv.movement_location
				,@estimate_return_date		= dmv.estimate_return_date
				,@document_movement_to		= isnull(dmv.movement_to, dmv.movement_to_branch_name)
				,@movement_by_emp_name		= dmv.movement_by_emp_name
		from	dbo.document_movement dmv
				left join dbo.document_movement_detail dmd on (dmv.code = dmd.movement_code)
				left join dbo.document_main dm on (dmd.document_code	= dm.code) 
		where	dmv.code					= @p_code ;
		 

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

		if (@movement_status <> 'ON PROCESS')
		begin
			raiserror('Data already Process', 16, 1) ;
		end ;
		else
		begin 
			
			declare cursor_movement cursor fast_forward read_only for
			select	dmd.document_code
			from	dbo.document_movement_detail dmd
			where	movement_code = @p_code ;

			open cursor_movement ;

			fetch next from cursor_movement
			into @document_main_code ;

			while @@fetch_status = 0
			begin 

				begin
					set @movement_status = 'ON TRANSIT'

					if (@movement_location = 'CLIENT')
					begin
						
						set @movement_status = 'POST'
						set @document_status = 'RELEASE' ;

						update	dbo.document_main
						set		document_status			= @document_status
								,mutation_type			= 'RELEASE'
								,mutation_location		= 'RELEASE PERMANENT'
								,mutation_from			= @branch_name
								,mutation_to			= @received_name
								,mutation_by			= @movement_by_emp_name
								,mutation_date			= @movement_date
								,mutation_return_date	= null
								,last_mutation_type		= @mutation_type
								,last_mutation_date		= @mutation_date
								,borrow_thirdparty_type = null
								,release_customer_date	= @movement_date
								---
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code					= @document_main_code ;

						set @history_movement_to = @received_name ;
						set @history_movement_by = @movement_by_emp_name ;
						set @history_movement_type = 'RELEASE' ;
						set @remark_history = 'RELEASE PERMANENT. RECEIVED BY ' + @received_name + ' WITH ID NO ' + @received_id_no + ' - ' + upper(@movement_remark) ;
					end ;
					else if (@movement_location = 'BRANCH')
					begin
						set @document_status = N'ON TRANSIT - BORROW' ; 

						update	dbo.document_main
						set		document_status			= @document_status
								,mutation_type			= 'BORROW'
								,mutation_location		= 'BRANCH'
								,mutation_from			= null
								,mutation_to			= null
								,mutation_by			= null
								,mutation_date			= null
								,mutation_return_date	= @estimate_return_date
								,last_mutation_type		= @mutation_location
								,last_mutation_date		= @mutation_date
								,borrow_thirdparty_type = @thirdparty_type
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code					= @document_main_code ;
						
						set @history_movement_to = isnull(@document_movement_to, '') ;
						set @history_movement_by = @movement_by_emp_name ;
						set @history_movement_type = 'BORROW' ;
						set @remark_history = 'SEND TO BRANCH '+ isnull(@document_movement_to, '') + ' ' + @movement_remark ;
					end ;
					else if (@movement_location = 'DEPARTMENT')
					begin
						set @document_status = N'ON TRANSIT - BORROW' ; 

						update	dbo.document_main
						set		document_status			= @document_status
								,mutation_type			= 'BORROW'
								,mutation_location		= 'DEPARTMENT'
								,mutation_from			= null
								,mutation_to			= null
								,mutation_by			= null
								,mutation_date			= null
								,mutation_return_date	= @estimate_return_date
								,last_mutation_type		= @mutation_location
								,last_mutation_date		= @mutation_date
								,borrow_thirdparty_type = @thirdparty_type
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code					= @document_main_code ;
					
						set @history_movement_to = isnull(@document_movement_to, '') ;
						set @history_movement_by = @movement_by_emp_name ;
						set @history_movement_type = 'BORROW' ;
						set @remark_history = 'SEND TO DEPARTMENT '+ isnull(@document_movement_to, '') + ' ' + @movement_remark ;
						
					end ;
					else if (@movement_location = 'THIRD PARTY')
					begin
						set @document_status = 'ON BORROW' ;
						set @movement_status = 'POST'

						update	dbo.document_main
						set		document_status			= @document_status
								,mutation_type			= 'BORROW'
								,mutation_location		= 'THIRD PARTY'
								,mutation_from			= null
								,mutation_to			= null
								,mutation_by			= null
								,mutation_date			= null
								,mutation_return_date	= @estimate_return_date
								,last_mutation_type		= @mutation_location
								,last_mutation_date		= @mutation_date
								,borrow_thirdparty_type = @thirdparty_type
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code					= @document_main_code ;

						set @history_movement_to = isnull(@document_movement_to, '') ;
						set @history_movement_by = @movement_by_emp_name ;
						set @history_movement_type = 'BORROW' ;
						set @remark_history = 'SEND TO BORROW THIRD PARTY '+ @document_movement_to + ' ' + @movement_remark ;
					end ;
					else if (@movement_location = 'BORROW CLIENT')
					begin
						set @document_status = 'ON BORROW' ;
						set @flag_borrow = 'ON BORROW'

						update	dbo.document_main
						set		document_status			= @document_status
								,mutation_type			= 'BORROW'
								,mutation_location		= 'BORROW CLIENT'
								,mutation_from			= null
								,mutation_to			= null
								,mutation_by			= null
								,mutation_date			= null
								,mutation_return_date	= @estimate_return_date
								,last_mutation_type		= @mutation_location
								,last_mutation_date		= @mutation_date
								,borrow_thirdparty_type = @thirdparty_type
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	code					= @document_main_code ;

						set @history_movement_to = isnull(@document_movement_to,'') ;
						set @history_movement_by = isnull(@movement_by_emp_name,'') ;
						set @history_movement_type = 'BORROW' ;
						set @remark_history = 'SEND TO BORROW CUSTOMER '+ @history_movement_to + ' ' + @movement_remark ;
					end ;
			end ;
			
				exec dbo.xsp_document_history_insert @p_id						= 0
													 ,@p_document_code			= @document_main_code
													 ,@p_document_status		= @document_status
													 ,@p_movement_type			= @history_movement_type
													 ,@p_movement_location		= @movement_location
													 ,@p_movement_from			= @branch_name
													 ,@p_movement_to			= @history_movement_to
													 ,@p_movement_by			= @history_movement_by
													 ,@p_movement_date			= @movement_date
													 ,@p_movement_return_date	= @return_date
													 ,@p_locker_position		= 'OUT LOCKER'
													 ,@p_locker_code			= null
													 ,@p_drawer_code			= null
													 ,@p_row_code				= null
													 ,@p_remarks				= @remark_history
													 ,@p_cre_date				= @p_mod_date
													 ,@p_cre_by					= @p_mod_by
													 ,@p_cre_ip_address			= @p_mod_ip_address
													 ,@p_mod_date				= @p_mod_date
													 ,@p_mod_by					= @p_mod_by
													 ,@p_mod_ip_address			= @p_mod_ip_address ;

				fetch next from cursor_movement
				into @document_main_code ;
			end ;

			close cursor_movement ;
			deallocate cursor_movement ;

			update	dbo.document_movement
			set		movement_status		= @movement_status
					,flag_borrow		= @flag_borrow
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;
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

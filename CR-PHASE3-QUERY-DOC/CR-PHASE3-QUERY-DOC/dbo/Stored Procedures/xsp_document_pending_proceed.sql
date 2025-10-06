CREATE PROCEDURE dbo.xsp_document_pending_proceed
(
	@p_code			   nvarchar(50)
	,@p_emp_name	   nvarchar(250) = ''
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@document_pending_branch_code		nvarchar(20)
			,@document_pending_branch_name		nvarchar(250)
			,@document_pending_status			nvarchar(50)
			,@code								nvarchar(50)
			,@system_date						DATETIME = dbo.xfn_get_system_date()
			,@p_id								int ;

	begin try
		select	@document_pending_branch_code		= branch_code
				,@document_pending_branch_name		= branch_name
				,@document_pending_status			= document_status
		from	document_pending
		where   code				= @p_code;

		if (@document_pending_status <> 'HOLD')
		begin
			raiserror('Data already proceed!!!', 16, -1)
		end

		if not exists
		(
			select	1
			from	document_movement
			where	movement_status		  = 'HOLD'
					and branch_code		  = @document_pending_branch_code
					and movement_type	  = 'RECEIVED'
					and movement_location = 'ENTRY'
					and movement_from	  = 'VENDOR'
					and movement_to		  = 'BRANCH'
		)
		begin
			exec dbo.xsp_document_movement_insert @p_code					= @code output 
												  ,@p_branch_code			= @document_pending_branch_code
												  ,@p_branch_name			= @document_pending_branch_name
												  ,@p_movement_date			= @system_date
												  ,@p_movement_status		= 'HOLD'
												  ,@p_movement_type			= 'RECEIVED'
												  ,@p_movement_location		= 'ENTRY'
												  ,@p_movement_from			= 'VENDOR'
												  ,@p_movement_to			= 'BRANCH'
												  ,@p_movement_by_emp_code	= @p_cre_by
												  ,@p_movement_by_emp_name	= @p_emp_name
												  ,@p_movement_courier_code = null
												  ,@p_movement_remarks		= null
												  ,@p_receive_status		= null
												  ,@p_receive_date			= null
												  ,@p_receive_remark		= null
												  --
												  ,@p_cre_date				= @p_cre_date		
												  ,@p_cre_by				= @p_cre_by			
												  ,@p_cre_ip_address		= @p_cre_ip_address	
												  ,@p_mod_date				= @p_mod_date		
												  ,@p_mod_by				= @p_mod_by			
												  ,@p_mod_ip_address		= @p_mod_ip_address	

		end 
		else
		begin
			select	@code = code 
			from	document_movement 
			where	movement_status		  = 'HOLD'
					and branch_code		  = @document_pending_branch_code
					and movement_type	  = 'RECEIVED'
					and movement_location = 'ENTRY'
					and movement_from	  = 'VENDOR'
					and movement_to		  = 'BRANCH'
		end
		
		exec dbo.xsp_document_movement_detail_insert @p_id							= @p_id output
														,@p_movement_code			= @code
														,@p_document_code			= null
														,@p_document_request_code	= null
														,@p_document_pending_code	= @p_code
														,@p_is_reject				= '0'
														,@p_remarks					= 'First Entry'
														
														,@p_cre_date				= @p_cre_date		
														,@p_cre_by					= @p_cre_by			
														,@p_cre_ip_address			= @p_cre_ip_address	
														,@p_mod_date				= @p_mod_date		
														,@p_mod_by					= @p_mod_by			
														,@p_mod_ip_address			= @p_mod_ip_address	

		update	dbo.document_pending
		set		document_status		= 'POST'
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;

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



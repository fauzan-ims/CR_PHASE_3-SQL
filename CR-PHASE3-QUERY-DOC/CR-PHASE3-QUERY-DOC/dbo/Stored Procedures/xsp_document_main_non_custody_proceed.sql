CREATE PROCEDURE dbo.xsp_document_main_non_custody_proceed
(
	@p_code			   nvarchar(50)
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
			,@document_main_branch_code			nvarchar(20)
			,@document_main_custody_branch_code nvarchar(20)
			,@document_main_branch_name			nvarchar(250)
			,@document_main_custody_branch_name	nvarchar(250)
			,@code								nvarchar(50)
			,@document_main_agreement_no		nvarchar(50)
			,@document_main_client_name			nvarchar(250)
			,@system_date						datetime	 = dbo.xfn_get_system_date()
			,@p_id								int ;

	begin try
		select	@document_main_branch_code			= branch_code
				,@document_main_branch_name			= branch_name
				,@document_main_custody_branch_code = custody_branch_code
				,@document_main_custody_branch_name = custody_branch_name
		from	dbo.document_main
		where	code								= @p_code ;

		if exists
		(
			select	1
			from	document_movement
			where	movement_status		  = 'HOLD'
					and movement_type	  = 'SEND'
					and movement_location = 'BRANCH'
					and movement_from	  = @document_main_branch_code
					and movement_to		  = @document_main_custody_branch_code
		)
		begin
			select	@code = code
			from	document_movement
			where	movement_status		  = 'HOLD' 
					and movement_type	  = 'SEND'
					and movement_location = 'BRANCH'
					and movement_from	  = @document_main_branch_code
					and movement_to		  = @document_main_custody_branch_code ;
		end ;
		else
		begin
			exec dbo.xsp_document_movement_insert @p_code							= @code output
												  ,@p_branch_code					= @document_main_branch_code
												  ,@p_branch_name					= @document_main_branch_name
												  ,@p_movement_date					= @system_date
												  ,@p_movement_status				= 'HOLD'
												  ,@p_movement_type					= 'SEND'
												  ,@p_movement_location				= 'BRANCH'
												  ,@p_movement_from					= null
												  ,@p_movement_to					= null
												  ,@p_movement_to_agreement_no		= null
												  ,@p_movement_to_client_name		= null
												  ,@p_movement_to_branch_code		= @document_main_custody_branch_code
												  ,@p_movement_to_branch_name		= @document_main_custody_branch_name
												  ,@p_movement_from_dept_code		= null
												  ,@p_movement_from_dept_name		= null
												  ,@p_movement_to_dept_code			= null
												  ,@p_movement_to_dept_name			= null
												  ,@p_movement_by_emp_code			= ''
												  ,@p_movement_by_emp_name			= ''
												  ,@p_movement_courier_code			= null
												  ,@p_movement_remarks				= N'SEND DOCUMENT BRANCH'
												  ,@p_receive_status				= null
												  ,@p_receive_date					= null
												  ,@p_receive_remark				= null
												  ,@p_estimate_return_date			= null
												  ,@p_received_by					= null
												  ,@p_received_id_no				= null
												  ,@p_received_name					= null
												  ,@p_movement_to_thirdparty_type	= null
												  ,@p_cre_date						= @p_cre_date
												  ,@p_cre_by						= @p_cre_by
												  ,@p_cre_ip_address				= @p_cre_ip_address
												  ,@p_mod_date						= @p_mod_date
												  ,@p_mod_by						= @p_mod_by
												  ,@p_mod_ip_address				= @p_mod_ip_address ;
		
		end ;

		exec dbo.xsp_document_movement_detail_insert @p_id						= @p_id output
													 ,@p_movement_code			= @code
													 ,@p_document_code			= @p_code
													 ,@p_document_request_code	= null
													 ,@p_document_pending_code	= null
													 ,@p_is_reject				= '0'
													 ,@p_remarks				= 'SEND DOCUMENT TO BRANCH'
													 ,@p_cre_date				= @p_cre_date
													 ,@p_cre_by					= @p_cre_by
													 ,@p_cre_ip_address			= @p_cre_ip_address
													 ,@p_mod_date				= @p_mod_date
													 ,@p_mod_by					= @p_mod_by
													 ,@p_mod_ip_address			= @p_mod_ip_address ;
		
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

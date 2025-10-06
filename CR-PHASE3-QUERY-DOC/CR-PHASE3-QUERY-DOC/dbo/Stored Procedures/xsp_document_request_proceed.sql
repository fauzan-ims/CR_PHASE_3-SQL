CREATE PROCEDURE dbo.xsp_document_request_proceed
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
	declare @msg										nvarchar(max)
			,@system_date								datetime = dbo.xfn_get_system_date()
			,@document_status							nvarchar(20)
			,@document_request_branch_code				nvarchar(50)
			,@document_request_branch_name				nvarchar(250)
			,@document_request_type						nvarchar(20)
			,@document_request_location					nvarchar(20)
			,@document_request_from						nvarchar(50)
			,@document_request_to						nvarchar(50)
			,@document_request_status					nvarchar(50)
			,@document_request_remarks					nvarchar(4000)
			,@document_code								nvarchar(50)
			,@code										nvarchar(50) = ''
			,@document_request_to_agreement_no			nvarchar(50)	 
			,@document_request_to_client_name			nvarchar(250)	 
			,@document_request_to_branch_code			nvarchar(50)	 
			,@document_request_to_branch_name			nvarchar(250)	 
			,@document_request_from_dept_code			nvarchar(50)	 
			,@document_request_from_dept_name			nvarchar(250)	 
			,@document_request_to_dept_code				nvarchar(50)	 
			,@document_request_to_dept_name				nvarchar(250)	 
			,@document_request_to_thirdparty_type		nvarchar(50)	 
			,@id										int
			,@asset_code								nvarchar(50)

	begin try
		select	@document_request_branch_code			= branch_code
				,@document_request_branch_name			= branch_name
				,@document_request_type					= request_type
				,@document_request_location				= request_location
				,@document_request_from					= request_from
				,@document_request_to					= request_to
				,@document_request_status				= request_status
				,@document_request_remarks				= remarks
				,@document_code							= document_code
				,@document_request_to_agreement_no		= request_to_agreement_no
				,@document_request_to_client_name		= request_to_client_name	
				,@document_request_to_branch_code		= request_to_branch_code	
				,@document_request_to_branch_name		= request_to_branch_name	
				,@document_request_from_dept_code		= request_from_dept_code	
				,@document_request_from_dept_name		= request_from_dept_name	
				,@document_request_to_dept_code			= request_to_dept_code		
				,@document_request_to_dept_name			= request_to_dept_name		
				,@document_request_to_thirdparty_type	= request_to_thirdparty_type
				,@asset_code							= asset_no
		from	document_request
		where   code									= @p_code;

		--if document code is null ambil dari document main berdasarkan asset
		if (@document_code = '' or @document_code = null)
		begin
			select @document_code = code 
			from dbo.document_main
			where document_type = 'ASSET'
			and asset_no = @asset_code
		end
		

		if exists (
				---branch
				-- rerquest_to_branch_code
				-- movement_to_branch_code

				--detp
				--request_to_dept_code
				--movement_to_dept_code

				--third_party
				--request_to_thirdparty
				--movement_to_thirdparty

				--client
				--request_to_agreement_no
				--movement_to_agrrement_no

				select	1
				from	document_movement
				where	branch_code					= @document_request_branch_code
				and		movement_status				= 'HOLD'
				and		movement_type				= @document_request_type
				and		movement_location			= @document_request_location
				and     MOVEMENT_TO_BRANCH_CODE		= isnull(@document_request_to_branch_code, '')
				and		MOVEMENT_TO_DEPT_CODE		= isnull(@document_request_to_dept_code, '')
				and		MOVEMENT_TO_THIRDPARTY_TYPE = isnull(@document_request_to_thirdparty_type, '')
				and     MOVEMENT_TO_AGREEMENT_NO	= isnull(@document_request_to_agreement_no, '')
		)
		begin
				SELECT	@code					= CODE
				from	dbo.DOCUMENT_MOVEMENT
				where	branch_code				= @document_request_branch_code
						and movement_status		= 'HOLD'
						and movement_type		= @document_request_type
						and movement_location	= @document_request_location ;
		end
		else
		begin
				exec dbo.xsp_document_movement_insert @p_code							= @code output 
													  ,@p_branch_code					= @document_request_branch_code
													  ,@p_branch_name					= @document_request_branch_name
													  ,@p_movement_date					= @system_date
													  ,@p_movement_status				= 'HOLD'
													  ,@p_movement_type					= @document_request_type
													  ,@p_movement_location				= @document_request_location
													  ,@p_movement_from					= @document_request_from
													  ,@p_movement_to					= @document_request_to
			 										  ,@p_movement_to_agreement_no		= @document_request_to_agreement_no
													  ,@p_movement_to_client_name		= @document_request_to_client_name	
													  ,@p_movement_to_branch_code		= @document_request_to_branch_code	
													  ,@p_movement_to_branch_name		= @document_request_to_branch_name	
													  ,@p_movement_from_dept_code		= @document_request_from_dept_code	
													  ,@p_movement_from_dept_name		= @document_request_from_dept_name	
													  ,@p_movement_to_dept_code			= @document_request_to_dept_code
													  ,@p_movement_to_dept_name			= @document_request_to_dept_name
													  ,@p_movement_by_emp_code			= @p_cre_by
													  ,@p_movement_by_emp_name			= ''
													  ,@p_movement_courier_code			= null
													  ,@p_movement_remarks				= @document_request_remarks
													  ,@p_receive_status				= null
													  ,@p_receive_date					= null
													  ,@p_receive_remark				= null  
													  ,@p_estimate_return_date			= null
			 										  ,@p_received_by					= null
			 										  ,@p_received_id_no				= null
			 										  ,@p_received_name					= null
													  ,@p_movement_to_thirdparty_type	= @document_request_to_thirdparty_type
													  --
													  ,@p_cre_date						= @p_cre_date		
													  ,@p_cre_by						= @p_cre_by			
													  ,@p_cre_ip_address				= @p_cre_ip_address	
													  ,@p_mod_date						= @p_mod_date		
													  ,@p_mod_by						= @p_mod_by			
													  ,@p_mod_ip_address				= @p_mod_ip_address	
		end

			exec dbo.xsp_document_movement_detail_insert @p_id							= @id output
															,@p_movement_code			= @code
															,@p_document_code			= @document_code
															,@p_document_request_code	= @p_code
															,@p_document_pending_code	= null
															,@p_is_reject				= '0'
															,@p_remarks					= @document_request_remarks
															--
															,@p_cre_date				= @p_cre_date		
															,@p_cre_by					= @p_cre_by			
															,@p_cre_ip_address			= @p_cre_ip_address	
															,@p_mod_date				= @p_mod_date		
															,@p_mod_by					= @p_mod_by			
															,@p_mod_ip_address			= @p_mod_ip_address	
		
		update	dbo.document_request
		set		request_status		= 'POST'
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


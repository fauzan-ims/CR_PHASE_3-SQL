CREATE PROCEDURE dbo.xsp_document_movement_detail_delete
(
	@p_id			   int
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@document_request_code nvarchar(50)
			,@document_pending_code nvarchar(50) 
			,@movement_code			nvarchar(50) 
			,@document_code			nvarchar(50) 
			,@asset_no				nvarchar(50) 

	begin try
		select	@document_request_code = isnull(document_request_code, '')
				,@document_pending_code = isnull(document_pending_code, '')
				,@document_code = document_code
				,@movement_code = movement_code
		from	dbo.document_movement_detail
		where	id = @p_id ;

		if exists
		(
			select	1
			from	dbo.document_movement
			where	code			  = @movement_code
					and movement_location = 'CLIENT'
		)
		begin
			select	@asset_no = asset_no
			from	dbo.document_main
			where	code = @document_code ;

			delete dbo.document_movement_detail
			where	document_code in
					(
						select	code
						from	dbo.document_main
						where	asset_no = @asset_no
					) ;
		end

		if (@document_request_code <> '')
		begin
			update	dbo.document_request
			set		request_status	= 'HOLD'
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @document_request_code ;
		end ;
		else
		begin
			update	dbo.document_pending
			set		document_status = 'HOLD'
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @document_pending_code ;
		end ;

		delete document_movement_detail
		where	id = @p_id ;
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

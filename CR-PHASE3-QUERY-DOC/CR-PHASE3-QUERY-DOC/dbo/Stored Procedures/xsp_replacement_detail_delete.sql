CREATE PROCEDURE dbo.xsp_replacement_detail_delete
(
	@p_id nvarchar(50)
)
as
begin
	declare @msg				nvarchar(max)
			,@request_id		nvarchar(50);

	begin try

		select	@request_id		= replacement_request_detail_id--replacement_request_id
		from	dbo.replacement_detail
		where	id				= @p_id ;

		update	dbo.replacement_request
		set		status				= 'HOLD'
				,replacement_code	= null
		where	id					= @request_id
		
		delete replacement_detail
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

CREATE PROCEDURE dbo.xsp_supplier_selection_delete
(
	@p_code			nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	
	declare @status			nvarchar(20)
	
	select	@status			= status
	from	supplier_selection
	where	code	= @p_code
	 
	if (@status = 'POST')
	begin
		raiserror ('STATUS POST CAN NOT BE DELETED',16,1)
		return
	end
	
	if (@status = 'CANCEL')
	begin
		raiserror ('STATUS CANCEL CAN NOT BE DELETED',16,1)
		return
	end

	delete	supplier_selection
	where	code	= @p_code
	and		status = 'NEW'

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
end

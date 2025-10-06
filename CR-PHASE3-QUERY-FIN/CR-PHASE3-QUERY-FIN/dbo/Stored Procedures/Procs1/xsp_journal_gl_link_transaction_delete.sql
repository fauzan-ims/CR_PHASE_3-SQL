CREATE PROCEDURE dbo.xsp_journal_gl_link_transaction_delete
(
	@p_id							bigint
	,@p_gl_link_code				nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin TRY
    
		delete	dbo.journal_gl_link_transaction	
		where	id						= @p_id
		and		gl_link_code			= @p_gl_link_code

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
end ;

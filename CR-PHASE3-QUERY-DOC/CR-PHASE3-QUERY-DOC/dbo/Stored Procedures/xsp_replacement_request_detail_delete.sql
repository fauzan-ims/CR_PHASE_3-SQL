
create procedure dbo.xsp_replacement_request_detail_delete
(
	@id bigint
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete replacement_request_detail
		where	id = @id ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;
		
		if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
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
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

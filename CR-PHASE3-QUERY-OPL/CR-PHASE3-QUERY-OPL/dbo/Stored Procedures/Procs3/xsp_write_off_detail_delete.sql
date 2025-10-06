CREATE PROCEDURE dbo.xsp_write_off_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete write_off_detail
		where	id = @p_id ;
	end try
	begin catch
		declare  @error int
		set  @error = @@error
	 
		if ( @error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used();
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;

		raiserror(@msg, 16, -1) ;

		return ; 
	end catch ;
end ;


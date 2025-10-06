
CREATE procedure [dbo].[xsp_cashier_received_request_delete]
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete cashier_received_request
		where	code = @p_code ;
	end try
	begin catch
		if (LEN(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE();
		end;

		raiserror(@msg, 16, -1) ;
		return ;  
	end catch;
end ;

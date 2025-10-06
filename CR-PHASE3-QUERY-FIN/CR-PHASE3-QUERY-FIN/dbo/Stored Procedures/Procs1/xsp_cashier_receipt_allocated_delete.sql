CREATE PROCEDURE dbo.xsp_cashier_receipt_allocated_delete
(
	@p_id bigint
)
as
begin
	declare @msg				nvarchar(max) 
			,@receipt_code		nvarchar(50);

	begin try
		select	@receipt_code	= receipt_code
		from	dbo.cashier_receipt_allocated
		where	id = @p_id ;

		delete cashier_receipt_allocated
		where	id = @p_id ;

		update	dbo.receipt_main
		set		cashier_code	= null
		where	code			= @receipt_code

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

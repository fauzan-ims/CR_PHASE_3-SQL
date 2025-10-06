CREATE PROCEDURE dbo.xsp_master_transaction_parameter_delete
(
	@p_id bigint
)
as
begin
	declare @msg			 nvarchar(max)
			,@dashboard_code nvarchar(50)
			,@process_code	 nvarchar(50)
			,@order_key		 int ;

	begin try
		select	@process_code = process_code
				,@order_key	  = order_key
		from	dbo.master_transaction_parameter
		where	id = @p_id ;

		update	dbo.master_transaction_parameter
		set		order_key = order_key - 1
		where	order_key		 > @order_key
				and process_code = @process_code ;

		delete master_transaction_parameter
		where	id = @p_id ;
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

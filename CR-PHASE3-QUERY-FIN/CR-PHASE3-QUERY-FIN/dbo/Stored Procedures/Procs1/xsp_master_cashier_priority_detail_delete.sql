CREATE PROCEDURE dbo.xsp_master_cashier_priority_detail_delete
(
	@p_id						bigint
)
as
BEGIN

	declare		@msg						nvarchar(max) 
				,@order_no					INT
				,@cashier_priority_code		nvarchar(50);

	begin TRY
		
		select	@order_no				= order_no
				,@cashier_priority_code = cashier_priority_code
		from	dbo.master_cashier_priority_detail
		where	id						= @p_id

		update	dbo.master_cashier_priority_detail
		set		order_no = order_no - 1
		where	order_no > @order_no
        AND		cashier_priority_code = @cashier_priority_code

		delete master_cashier_priority_detail
		where	id		= @p_id

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

CREATE PROCEDURE dbo.xsp_suspend_merger_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg					nvarchar(max) 
			,@sum_amount			decimal(18, 2) 
			,@suspend_code			nvarchar(50)
			,@suspend_merger_code	nvarchar(50);

	begin try
		select	@suspend_merger_code	= suspend_merger_code
				,@suspend_code			= suspend_code
		from	dbo.suspend_merger_detail
		where	id = @p_id ;

		delete suspend_merger_detail
		where	id = @p_id ;

		select	@sum_amount		= sum(suspend_amount)
		from	dbo.suspend_merger_detail
		where	suspend_merger_code = @suspend_merger_code

		update	dbo.suspend_merger
		set		merger_amount	= isnull(@sum_amount,0)
		where	code			= @suspend_merger_code

		update	dbo.suspend_main
		set		transaction_code	= null
				,transaction_name	= null
		where	code				= @suspend_code
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

CREATE PROCEDURE dbo.xsp_termination_detail_asset_delete
(
	@p_id bigint
)
as
begin
	declare @msg				nvarchar(max)
			,@code_termination	nvarchar(50)
			,@sum_refund_amount	decimal(18,2)

	begin try
		select @code_termination = termination_code 
		from dbo.termination_detail_asset
		where id = @p_id

		delete	termination_detail_asset
		where	id = @p_id ;

		select @sum_refund_amount = sum(refund_amount) 
		from dbo.termination_detail_asset
		where termination_code = @code_termination

		update	dbo.termination_main
		set		termination_approved_amount	= isnull(@sum_refund_amount,0)
		where	code = @code_termination ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

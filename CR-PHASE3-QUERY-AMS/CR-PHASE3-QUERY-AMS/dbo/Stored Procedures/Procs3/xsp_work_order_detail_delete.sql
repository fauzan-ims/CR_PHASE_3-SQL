CREATE PROCEDURE dbo.xsp_work_order_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg			nvarchar(max)
			,@code			nvarchar(50)
			,@ppn_amount	decimal(18,2)
			,@pph_amount	decimal(18,2)
			,@service_fee	decimal(18,2)

	begin try
		select @code = work_order_code 
		from dbo.work_order_detail
		where id = @p_id

		delete	work_order_detail
		where	id = @p_id ;

		select	@ppn_amount		= sum(ppn_amount)
				,@pph_amount	= sum(pph_amount)
				,@service_fee	= sum(service_fee)
		from dbo.work_order_detail
		where work_order_code = @code

		update dbo.work_order
		set		total_ppn_amount		= @ppn_amount
				,total_pph_amount		= @pph_amount
				,total_amount			= @service_fee
				,payment_amount			= @service_fee - @pph_amount + @ppn_amount
		where code = @code
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

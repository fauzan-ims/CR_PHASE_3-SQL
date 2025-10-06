CREATE PROCEDURE dbo.xsp_sale_detail_fee_delete
(
	@p_id bigint
)
as
begin
	declare @msg				nvarchar(max)
			,@sale_detail_id	int
			,@ppn_amount		decimal(18,2)
			,@pph_maount		decimal(18,2)
			,@fee_amount		decimal(18,2)

	begin try
		select @sale_detail_id = sale_detail_id 
		from dbo.sale_detail_fee
		where id = @p_id

		delete	sale_detail_fee
		where	id = @p_id ;

		select @ppn_amount		= isnull(sum(ppn_amount),0)
				,@pph_maount	= isnull(sum(pph_amount),0)
				,@fee_amount	= isnull(sum(fee_amount),0)
		from dbo.sale_detail_fee
		where sale_detail_id = @sale_detail_id

		update dbo.sale_detail
		set total_fee_amount			= @fee_amount + @ppn_amount - @pph_maount
			,total_pph_amount			= @pph_maount
			,total_ppn_amount			= @ppn_amount
		where id = @sale_detail_id
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

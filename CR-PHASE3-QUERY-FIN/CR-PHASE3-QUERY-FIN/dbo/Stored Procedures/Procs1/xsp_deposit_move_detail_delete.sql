CREATE PROCEDURE [dbo].[xsp_deposit_move_detail_delete]
(
	@p_id bigint
)
as
begin
	declare @msg nvarchar(max)
			,@depomocode nvarchar(50)
			,@toamount decimal(18,2)


	begin try
		SELECT @depomocode = DEPOSIT_MOVE_CODE, @toamount = TO_AMOUNT FROM dbo.DEPOSIT_MOVE_DETAIL where ID = @p_id
				update dbo.deposit_move 
		set		total_to_amount = total_to_amount - @toamount
		where code = @depomocode
		delete	from dbo.deposit_move_detail 
		where	id = @p_id ;
	end try
	begin catch
		declare @error int = @@error ;

		if @error = 547
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;

		if len(@msg) <> 0
			set @msg = N'V;' + @msg ;
		else if error_message() like '%V;%'
				or	error_message() like '%E;%'
			set @msg = error_message() ;
		else
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

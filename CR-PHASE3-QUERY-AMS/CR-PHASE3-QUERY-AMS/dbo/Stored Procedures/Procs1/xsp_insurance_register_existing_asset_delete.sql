CREATE PROCEDURE dbo.xsp_insurance_register_existing_asset_delete
(
	@p_id bigint
)
as
begin
	declare @msg			nvarchar(max)
			,@code_register	nvarchar(50)
			,@sum_insured	decimal(18,2)
			,@sum_premi		decimal(18,2)

	begin try
		select @code_register = register_code 
		from dbo.insurance_register_existing_asset
		where id = @p_id

		delete	insurance_register_existing_asset
		where	id = @p_id ;

		select @sum_premi		= sum(premi_sell_amount) 
				,@sum_insured	= sum(sum_insured_amount)
		from dbo.insurance_register_existing_asset
		where register_code = @code_register

		update	dbo.insurance_register_existing
		set		sum_insured_amount			= isnull(@sum_premi,0)
				,total_premi_sell_amount	= isnull(@sum_insured,0)
		where	code = @code_register ;

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

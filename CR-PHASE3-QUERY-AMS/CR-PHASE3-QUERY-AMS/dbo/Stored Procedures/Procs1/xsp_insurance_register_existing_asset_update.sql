CREATE PROCEDURE dbo.xsp_insurance_register_existing_asset_update
(
	@p_id				   bigint
	,@p_sum_insured_amount decimal(18, 2)	= 0
	,@p_premi_sell_amount  decimal(18, 2)	= 0
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@code_register	nvarchar(50)
			,@sum_insured	decimal(18,2)
			,@sum_premi		decimal(18,2)

	begin try
		update	insurance_register_existing_asset
		set		sum_insured_amount	= @p_sum_insured_amount
				,premi_sell_amount	= @p_premi_sell_amount
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id = @p_id ;

		select @code_register = register_code
		from dbo.insurance_register_existing_asset
		where id = @p_id

		select @sum_insured = sum(sum_insured_amount)
				,@sum_premi	= sum(premi_sell_amount) 
		from dbo.insurance_register_existing_asset
		where register_code =  @code_register

		update	dbo.insurance_register_existing
		set		sum_insured_amount			= @p_sum_insured_amount
				,total_premi_sell_amount	= @p_premi_sell_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code = @code_register ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
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

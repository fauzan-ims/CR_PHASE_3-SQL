CREATE PROCEDURE dbo.xsp_adjustment_detail_history_update
(
	@p_id							bigint	= 0 output
	,@p_adjustment_code				nvarchar(50)
	,@p_adjusment_transaction_code	nvarchar(50)
	,@p_amount						decimal(18, 2)
	,@p_currency_code				nvarchar(50)
		--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	adjustment_detail_history
		set		adjustment_code				= @p_adjustment_code
				,adjusment_transaction_code	= @p_adjusment_transaction_code
				,amount						= @p_amount
				,currency_code				= @p_currency_code
					--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id	= @p_id

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
end

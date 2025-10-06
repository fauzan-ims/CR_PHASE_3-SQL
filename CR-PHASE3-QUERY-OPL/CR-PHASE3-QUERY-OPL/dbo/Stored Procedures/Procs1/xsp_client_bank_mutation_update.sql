CREATE PROCEDURE [dbo].[xsp_client_bank_mutation_update]
(
	@p_id								bigint
	,@p_client_code						nvarchar(50)
	,@p_client_bank_code				nvarchar(50)
	,@p_month							nvarchar(15)
	,@p_year							nvarchar(4)
	,@p_debit_transaction_count			int
	,@p_debit_amount					decimal(18,2)
	,@p_credit_transaction_count		int
	,@p_credit_amount					decimal(18,2)
	,@p_balance_amount					decimal(18,2)
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) ;

	begin try

		update	dbo.client_bank_mutation
		set		client_code					= @p_client_code
				,client_bank_code			= @p_client_bank_code
				,month						= @p_month
				,year						= @p_year
				,debit_transaction_count	= @p_debit_transaction_count
				,debit_amount				= @p_debit_amount
				,credit_transaction_count	= @p_credit_transaction_count
				,credit_amount				= @p_credit_amount
				,balance_amount				= @p_balance_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id = @p_id ;

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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;






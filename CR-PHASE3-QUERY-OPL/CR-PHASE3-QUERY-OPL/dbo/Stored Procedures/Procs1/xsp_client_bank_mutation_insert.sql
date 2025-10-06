create PROCEDURE [dbo].[xsp_client_bank_mutation_insert]
(
	@p_id								bigint		   = 0 output
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
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) ;

	begin try

		insert into dbo.client_bank_mutation
		(
			client_code
			,client_bank_code
			,month
			,year
			,debit_transaction_count
			,debit_amount
			,credit_transaction_count
			,credit_amount
			,balance_amount
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_client_code -- CLIENT_CODE - nvarchar(50)
			,@p_client_bank_code-- CLIENT_BANK_CODE - nvarchar(50)
			,@p_month-- MONTH - nvarchar(15)
			,@p_year-- YEAR - nvarchar(4)
			,@p_debit_transaction_count -- DEBIT_TRANSACTION_COUNT - int
			,@p_debit_amount -- DEBIT_AMOUNT - decimal(18, 2)
			,@p_credit_transaction_count -- CREDIT_TRANSACTION_COUNT - int
			,@p_credit_amount -- CREDIT_AMOUNT - decimal(18, 2)
			,@p_balance_amount -- BALANCE_AMOUNT - decimal(18, 2)
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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






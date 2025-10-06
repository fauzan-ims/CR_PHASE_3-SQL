CREATE PROCEDURE dbo.xsp_ext_client_bank_book_insert
(
	@p_id				 bigint = 0 output
	,@p_client_code		 nvarchar(50)
	,@p_client_bank_code nvarchar(50)
	,@p_Month			 nvarchar(2)
	,@p_Year			 nvarchar(4)
	,@p_DebitTrxCount	 int			   = 0
	,@p_DebitAmt		 decimal(18, 2)	   = 0
	,@p_CreditTrxCount	 int			   = 0
	,@p_CreditAmt		 decimal(18, 2)	   = 0
	,@p_BalanceAmt		 decimal(18, 2)	   = 0
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(12)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(12)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		--if @p_Year + @p_Month >  convert(varchar(6), dbo.xfn_get_system_date(),112)
		--begin
		--	set @msg = 'Period must be less or equal than System Date';
		--	raiserror(@msg, 16, -1) ;
		--end
		--if exists (select 1 from client_bank_book where client_bank_code = @p_client_bank_code and periode_year = @p_Year and periode_month = @p_Month )
		--begin
		--	set @msg = 'Month - Year already exist';
		--	raiserror(@msg, 16, -1) ;
		--end

		--exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
		--										,@p_mod_date		= @p_mod_date
		--										,@p_mod_by			= @p_mod_by
		--										,@p_mod_ip_address	= @p_mod_ip_address
		insert into client_bank_book
		(
			client_code
			,periode_year
			,periode_month
			,client_bank_code
			,opening_balance_amount
			,ending_balance_amount
			,total_cr_mutation_amount
			,total_db_mutation_amount
			,freq_credit_mutation
			,freq_debet_mutation
			,average_cr_mutation_amount
			,average_db_mutation_amount
			,average_balance_amount
			,highest_balance_amount
			,lowest_balance_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_client_code
			,@p_Year
			,@p_Month
			,@p_client_bank_code
			,@p_BalanceAmt
			,0
			,@p_CreditAmt
			,@p_DebitAmt
			,0
			,0
			,0
			,0
			,0
			,0
			,0
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_client_code
			,@p_client_bank_code
			,@p_month
			,@p_year
			,@p_debittrxcount
			,@p_debitamt
			,@p_credittrxcount
			,@p_creditamt
			,@p_balanceamt
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

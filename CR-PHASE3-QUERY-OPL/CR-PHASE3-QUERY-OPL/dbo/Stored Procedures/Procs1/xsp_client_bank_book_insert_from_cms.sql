CREATE PROCEDURE dbo.xsp_client_bank_book_insert_from_cms
(
	@p_id						   bigint = 0 output
	,@p_client_code				   nvarchar(50)
	,@p_periode_year			   nvarchar(4)
	,@p_periode_month			   nvarchar(2)
	,@p_client_bank_code		   nvarchar(50)
	,@p_opening_balance_amount	   decimal(18, 2)
	,@p_ending_balance_amount	   decimal(18, 2)
	,@p_total_cr_mutation_amount   decimal(18, 2)
	,@p_total_db_mutation_amount   decimal(18, 2)
	,@p_freq_credit_mutation	   int
	,@p_freq_debet_mutation		   int
	,@p_average_cr_mutation_amount decimal(18, 2)
	,@p_average_db_mutation_amount decimal(18, 2)
	,@p_average_balance_amount	   decimal(18, 2)
	,@p_highest_balance_amount	   decimal(18, 2)
	,@p_lowest_balance_amount	   decimal(18, 2)
	--
	,@p_cre_date				   datetime
	,@p_cre_by					   nvarchar(12)
	,@p_cre_ip_address			   nvarchar(15)
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(12)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
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
		(	@p_client_code
			,@p_periode_year
			,@p_periode_month
			,@p_client_bank_code
			,@p_opening_balance_amount
			,@p_ending_balance_amount
			,@p_total_cr_mutation_amount
			,@p_total_db_mutation_amount
			,@p_freq_credit_mutation
			,@p_freq_debet_mutation
			,@p_average_cr_mutation_amount
			,@p_average_db_mutation_amount
			,@p_average_balance_amount
			,@p_highest_balance_amount
			,@p_lowest_balance_amount
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
end ;


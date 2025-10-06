CREATE PROCEDURE dbo.xsp_bank_mutation_history_update
(
	@p_id				   bigint
	,@p_bank_mutation_code nvarchar(50)
	,@p_transaction_date   datetime
	,@p_source_reff_code   nvarchar(50)
	,@p_source_reff_name   nvarchar(250)
	,@p_orig_amount		   decimal(18, 2)
	,@p_orig_currency_code nvarchar(3)
	,@p_exch_rate		   decimal(18, 6)
	,@p_base_amount		   decimal(18, 2)
	,@p_remarks			   nvarchar(4000)
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	bank_mutation_history
		set		bank_mutation_code	= @p_bank_mutation_code
				,transaction_date	= @p_transaction_date
				,source_reff_code	= @p_source_reff_code
				,source_reff_name	= @p_source_reff_name
				,orig_amount		= @p_orig_amount
				,orig_currency_code = @p_orig_currency_code
				,exch_rate			= @p_exch_rate
				,base_amount		= @p_base_amount
				,remarks			= @p_remarks
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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

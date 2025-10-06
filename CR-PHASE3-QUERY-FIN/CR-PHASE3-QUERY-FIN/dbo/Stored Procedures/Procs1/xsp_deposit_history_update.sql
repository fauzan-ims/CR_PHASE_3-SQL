CREATE PROCEDURE dbo.xsp_deposit_history_update
(
	@p_id				   bigint
	,@p_branch_code		   nvarchar(50)
	,@p_branch_name		   nvarchar(250)
	,@p_deposit_code	   nvarchar(50)
	,@p_transaction_date   datetime
	,@p_orig_amount		   decimal(18, 2)
	,@p_orig_currency_code nvarchar(3)
	,@p_exch_rate		   decimal(18, 6)
	,@p_base_amount		   decimal(18, 2)
	,@p_source_reff_code   nvarchar(50)
	,@p_source_reff_name   nvarchar(250)
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@sum_amount		decimal(18, 2)

	begin try
		update	deposit_history
		set		branch_code			= @p_branch_code
				,branch_name		= @p_branch_name
				,deposit_code		= @p_deposit_code
				,transaction_date	= @p_transaction_date
				,orig_amount		= @p_orig_amount
				,orig_currency_code = @p_orig_currency_code
				,exch_rate			= @p_exch_rate
				,base_amount		= @p_base_amount
				,source_reff_code	= @p_source_reff_code
				,source_reff_name	= @p_source_reff_name
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;

		select	@sum_amount	= isnull(sum(base_amount),0) 
		from	dbo.deposit_history 
		where	deposit_code	= @p_deposit_code
		
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

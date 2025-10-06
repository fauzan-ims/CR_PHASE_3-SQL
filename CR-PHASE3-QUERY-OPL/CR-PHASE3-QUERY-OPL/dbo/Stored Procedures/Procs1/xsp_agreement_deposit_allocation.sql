CREATE PROCEDURE dbo.xsp_agreement_deposit_allocation
	@p_branch_code		   nvarchar(50)
	,@p_branch_name		   nvarchar(250)
	,@p_agreement_no	   nvarchar(50)
	,@p_deposit_type	   nvarchar(50)
	,@p_transaction_date   datetime
	,@p_orig_amount		   decimal(18, 2)
	,@p_currency		   nvarchar(3)
	,@p_exch_rate		   decimal(18, 6)
	,@p_base_amount		   decimal(18, 2)
	,@p_deposit_amount	   decimal(18, 2)
	,@p_source_reff_module nvarchar(50)
	,@p_source_reff_code   nvarchar(50)
	,@p_source_reff_name   nvarchar(250)
	--						  
	,@p_cre_date		   datetime
	,@p_cre_by			   nvarchar(15)
	,@p_cre_ip_address	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
as
begin
	declare @msg		   nvarchar(max)
			,@deposit_code nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	dbo.agreement_deposit_main
			where	agreement_no			  = @p_agreement_no
					and deposit_type		  = @p_deposit_type
					and deposit_currency_code = @p_currency
		)
		begin
			update	dbo.agreement_deposit_main
			set		deposit_amount = deposit_amount + @p_deposit_amount
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	agreement_no			  = @p_agreement_no
					and deposit_type		  = @p_deposit_type
					and deposit_currency_code = @p_currency ;

			select	@deposit_code = code
			from	dbo.agreement_deposit_main
			where	agreement_no			  = @p_agreement_no
					and deposit_type		  = @p_deposit_type
					and deposit_currency_code = @p_currency ;
		end ;
		else
		begin 
			exec dbo.xsp_agreement_deposit_main_insert @p_code						= @deposit_code output
													   ,@p_branch_code				= @p_branch_code
													   ,@p_branch_name				= @p_branch_name
													   ,@p_agreement_no				= @p_agreement_no
													   ,@p_deposit_type				= @p_deposit_type
													   ,@p_deposit_currency_code	= @p_currency
													   ,@p_deposit_amount			= @p_deposit_amount
													   ,@p_cre_date					= @p_cre_date
													   ,@p_cre_by					= @p_cre_by
													   ,@p_cre_ip_address			= @p_cre_ip_address
													   ,@p_mod_date					= @p_mod_date
													   ,@p_mod_by					= @p_mod_by
													   ,@p_mod_ip_address			= @p_mod_ip_address ;
		end ;

		insert into dbo.agreement_deposit_history
		(
			branch_code
			,branch_name
			,agreement_deposit_code
			,agreement_no
			,deposit_type
			,transaction_date
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,source_reff_module
			,source_reff_code
			,source_reff_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_branch_code
			,@p_branch_name
			,@deposit_code
			,@p_agreement_no
			,@p_deposit_type
			,@p_transaction_date
			,@p_orig_amount
			,@p_currency
			,@p_exch_rate
			,@p_base_amount
			,@p_source_reff_module
			,@p_source_reff_code
			,@p_source_reff_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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

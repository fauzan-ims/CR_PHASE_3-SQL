CREATE PROCEDURE dbo.xsp_account_transfer_insert
(
	@p_code					   nvarchar(50) output
	,@p_transfer_status		   nvarchar(10)
	,@p_transfer_trx_date	   datetime = null
	,@p_transfer_value_date	   datetime
	,@p_cashier_amount		   decimal(18, 2) = null
	,@p_transfer_remarks	   nvarchar(4000)
	,@p_cashier_code		   nvarchar(50) = ''
	,@p_from_branch_code	   nvarchar(50)
	,@p_from_branch_name	   nvarchar(250)
	,@p_from_currency_code	   nvarchar(3)
	,@p_from_branch_bank_code  nvarchar(50)
	,@p_from_branch_bank_name  nvarchar(250)
	,@p_from_gl_link_code	   nvarchar(50)
	,@p_from_exch_rate		   decimal(18, 6)
	,@p_from_orig_amount	   decimal(18, 2) 
	,@p_to_branch_code		   nvarchar(50)
	,@p_to_branch_name		   nvarchar(250)
	,@p_to_currency_code	   nvarchar(3)
	,@p_to_branch_bank_code	   nvarchar(50)
	,@p_to_branch_bank_name	   nvarchar(250)
	,@p_to_gl_link_code		   nvarchar(50)
	,@p_to_exch_rate		   decimal(18, 6)
	,@p_to_orig_amount		   decimal(18, 2) 
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_from_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'ACT'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'ACCOUNT_TRANSFER'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		set @p_transfer_trx_date = dbo.xfn_get_system_date();
		if (@p_transfer_value_date > dbo.xfn_get_system_date()) 
			begin
				set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date','System Date');
				raiserror(@msg ,16,-1)
			end

		if (@p_from_orig_amount <= 0 and isnull(@p_cashier_code,'') = '')
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('From Amount','0');
			raiserror(@msg ,16,-1)
		end

		if (@p_cashier_code <> '')
		begin
			if exists	( 
							select	1 
							from	dbo.account_transfer 
							where	from_branch_bank_code = @p_from_branch_bank_code 
									and code <> @p_code 
									and	transfer_status = 'HOLD'
									and isnull(cashier_code,'') = @p_cashier_code
						)
			begin
					set @msg = 'There is another account transfer transaction for this cashier';
					raiserror(@msg ,16,-1)
			end
		end

		insert into account_transfer
		(
			code
			,transfer_status
			,transfer_trx_date
			,transfer_value_date
			,transfer_remarks
			,cashier_code
			,cashier_amount
			,from_branch_code
			,from_branch_name
			,from_currency_code
			,from_branch_bank_code
			,from_branch_bank_name
			,from_gl_link_code
			,from_exch_rate
			,from_orig_amount
			,to_branch_code
			,to_branch_name
			,to_currency_code
			,to_branch_bank_code
			,to_branch_bank_name
			,to_gl_link_code
			,to_exch_rate
			,to_orig_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_transfer_status
			,@p_transfer_trx_date
			,@p_transfer_value_date
			,@p_transfer_remarks
			,@p_cashier_code
			,@p_cashier_amount
			,@p_from_branch_code
			,@p_from_branch_name
			,@p_from_currency_code
			,@p_from_branch_bank_code
			,@p_from_branch_bank_name
			,@p_from_gl_link_code
			,@p_from_exch_rate
			,@p_from_orig_amount
			,@p_to_branch_code
			,@p_to_branch_name
			,@p_to_currency_code
			,@p_to_branch_bank_code
			,@p_to_branch_bank_name
			,@p_to_gl_link_code
			,@p_to_exch_rate
			,@p_to_orig_amount
			--	
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;
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


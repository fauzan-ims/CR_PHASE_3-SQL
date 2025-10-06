CREATE PROCEDURE dbo.xsp_received_voucher_insert
(
	@p_code							nvarchar(50) output
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_received_status				nvarchar(10)
	,@p_received_from				nvarchar(250)
	,@p_received_transaction_date	datetime = null
	,@p_received_value_date			datetime 
	,@p_received_orig_amount		decimal(18, 2)
	,@p_received_orig_currency_code nvarchar(3)
	,@p_received_exch_rate			decimal(18, 6)
	,@p_received_base_amount		decimal(18, 2)
	,@p_received_remarks			nvarchar(4000)
	,@p_branch_bank_code			nvarchar(50)
	,@p_branch_bank_name			nvarchar(50)
	,@p_branch_gl_link_code			nvarchar(50)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max)
			,@code	nvarchar(50) ;

	--if @p_is_reconcile = 'T'
	--	set @p_is_reconcile = '1' ;

	--if @p_is_reconcile = 'F'
	--	set @p_is_reconcile = '0' ;

	set @p_received_transaction_date = dbo.xfn_get_system_date();
	--set @p_received_transaction_date = @p_received_value_date;

	begin try
		if (@p_received_value_date > dbo.xfn_get_system_date()) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date','System Date');
			raiserror(@msg ,16,-1)
		end

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'MRV'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'RECEIVED_VOUCHER'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		set @p_code = @code ;

		insert into received_voucher
		(
			code
			,branch_code
			,branch_name
			,received_status
			,received_from
			,received_transaction_date
			,received_value_date
			,received_orig_amount
			,received_orig_currency_code
			,received_exch_rate
			,received_base_amount
			,received_remarks
			,branch_bank_code
			,branch_bank_name
			,branch_gl_link_code
			,is_reconcile
			,reconcile_date
			,reversal_code
			,reversal_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_received_status
			,@p_received_from
			,@p_received_transaction_date
			,@p_received_value_date
			,@p_received_orig_amount
			,@p_received_orig_currency_code
			,@p_received_exch_rate
			,@p_received_base_amount
			,@p_received_remarks
			,@p_branch_bank_code
			,@p_branch_bank_name
			,@p_branch_gl_link_code
			,0
			,null
			,null
			,null
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

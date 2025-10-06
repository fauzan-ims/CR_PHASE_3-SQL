CREATE PROCEDURE dbo.xsp_deposit_release_insert
(
	@p_code						  nvarchar(50) output
	,@p_branch_code				  nvarchar(50)
	,@p_branch_name				  nvarchar(250)
	,@p_release_status			  nvarchar(20)
	,@p_release_date			  datetime
	,@p_release_amount			  decimal(18, 2) = 0
	,@p_release_remarks			  nvarchar(4000)
	,@p_release_bank_name		  nvarchar(250)
	,@p_release_bank_account_no	  nvarchar(50)
	,@p_release_bank_account_name nvarchar(250)
	,@p_agreement_no			  nvarchar(50)
	,@p_currency_code			  nvarchar(3)
	--
	,@p_cre_date				  datetime
	,@p_cre_by					  nvarchar(15)
	,@p_cre_ip_address			  nvarchar(15)
	,@p_mod_date				  datetime
	,@p_mod_by					  nvarchar(15)
	,@p_mod_ip_address			  nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'DRL'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'DEPOSIT_RELEASE'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		if (@p_release_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
					raiserror(@msg ,16,-1)
				end

		insert into deposit_release
		(
			code
			,branch_code
			,branch_name
			,release_status
			,release_date
			,release_amount
			,release_remarks
			,release_bank_name
			,release_bank_account_no
			,release_bank_account_name
			,agreement_no
			,currency_code
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
			,@p_branch_code
			,@p_branch_name
			,@p_release_status
			,@p_release_date
			,@p_release_amount
			,@p_release_remarks
			,@p_release_bank_name
			,@p_release_bank_account_no
			,@p_release_bank_account_name
			,@p_agreement_no
			,@p_currency_code
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

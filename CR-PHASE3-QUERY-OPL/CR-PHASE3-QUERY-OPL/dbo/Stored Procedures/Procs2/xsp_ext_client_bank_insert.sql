CREATE PROCEDURE dbo.xsp_ext_client_bank_insert
(
	@p_code						nvarchar(50) output
	,@p_client_code				nvarchar(50) 
	,@p_BankName				nvarchar(250)	= ''
	,@p_BankBranch				nvarchar(250)	= ''
	,@p_BankAccNo				nvarchar(50)	= ''
	,@p_BankAccName				nvarchar(250)	= ''
	,@p_IsDefault				nvarchar(1)		= ''
	--
	,@p_cre_date		   datetime
	,@p_cre_by			   nvarchar(15)
	,@p_cre_ip_address	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
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
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'OPLCB'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_BANK'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_IsDefault = 'T'
		set @p_IsDefault = '1' ;
	else
		set @p_IsDefault = '0' ; 

	begin try
		--exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
		--										,@p_mod_date		= @p_mod_date
		--										,@p_mod_by			= @p_mod_by
		--										,@p_mod_ip_address	= @p_mod_ip_address
		insert into client_bank
		(
			code
			,client_code
			,currency_code
			,bank_code
			,bank_name
			,bank_branch
			,bank_account_no
			,bank_account_name
			,is_default
			,is_auto_debet_bank
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
			,@p_client_code
			,'IDR'
			,''
			,@p_BankName
			,upper(@p_BankBranch)
			,@p_BankAccNo
			,upper(@p_BankAccName)
			,@p_IsDefault
			,''
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;

		if @p_IsDefault = '1'
		begin
			update	dbo.client_bank
			set		is_default  = '0'
			where	client_code = @p_client_code
					and code	<> @p_code ;
		end ;

		--if @p_is_auto_debet_bank = '1'
		--begin
		--	update	dbo.client_bank
		--	set		is_auto_debet_bank = '0'
		--	where	client_code = @p_client_code
		--			and code	<> @p_code ;
		--end ;
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

 


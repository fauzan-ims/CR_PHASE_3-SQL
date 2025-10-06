CREATE PROCEDURE dbo.xsp_suspend_reversal_insert
(
	@p_code						   nvarchar(50)
	,@p_branch_code				   nvarchar(50)
	,@p_branch_name				   nvarchar(250)
	,@p_reversal_status			   nvarchar(20)
	,@p_reversal_date			   datetime
	,@p_reversal_amount			   decimal(18, 2)
	,@p_reversal_remarks		   nvarchar(20)
	,@p_reversal_bank_name		   nvarchar(250)
	,@p_reversal_bank_account_no   nvarchar(50)
	,@p_reversal_bank_account_name nvarchar(250)
	,@p_suspend_code			   nvarchar(50)
	,@p_suspend_currency_code	   nvarchar(3)
	,@p_suspend_amount			   decimal(18, 2)
	--
	,@p_cre_date				   datetime
	,@p_cre_by					   nvarchar(15)
	,@p_cre_ip_address			   nvarchar(15)
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		if exists (select 1 from sys_general_subcode_detail where code = @p_code)
		begin
    		SET @msg = 'Code already exist';
    		raiserror(@msg, 16, -1) ;
		end

		insert into suspend_reversal
		(
			code
			,branch_code
			,branch_name
			,reversal_status
			,reversal_date
			,reversal_amount
			,reversal_remarks
			,reversal_bank_name
			,reversal_bank_account_no
			,reversal_bank_account_name
			,suspend_code
			,suspend_currency_code
			,suspend_amount
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
			,@p_reversal_status
			,@p_reversal_date
			,@p_reversal_amount
			,@p_reversal_remarks
			,@p_reversal_bank_name
			,@p_reversal_bank_account_no
			,@p_reversal_bank_account_name
			,@p_suspend_code
			,@p_suspend_currency_code
			,@p_suspend_amount
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

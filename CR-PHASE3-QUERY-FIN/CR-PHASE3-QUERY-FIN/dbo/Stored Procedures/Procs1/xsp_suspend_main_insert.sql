CREATE PROCEDURE dbo.xsp_suspend_main_insert
(
	@p_code						nvarchar(50) output
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_suspend_date			datetime
	,@p_suspend_currency_code	nvarchar(3)
	,@p_suspend_amount			decimal(18, 2)
	,@p_suspend_remarks			nvarchar(4000)
	,@p_used_amount				decimal(18, 2)
	,@p_remaining_amount		decimal(18, 2)
	,@p_reff_name				nvarchar(250)
	,@p_reff_no					nvarchar(50)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)
			,@code			nvarchar(50);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'SPN'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'SUSPEND_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;
		set @p_code = @code

	begin try
		insert into suspend_main
		(
			code
			,branch_code
			,branch_name
			,suspend_date
			,suspend_currency_code
			,suspend_amount
			,suspend_remarks
			,used_amount
			,remaining_amount
			,reff_name
			,reff_no
			,transaction_code
			,transaction_name
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
			,@p_suspend_date
			,@p_suspend_currency_code
			,@p_suspend_amount
			,@p_suspend_remarks
			,@p_used_amount
			,@p_remaining_amount
			,@p_reff_name
			,@p_reff_no
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


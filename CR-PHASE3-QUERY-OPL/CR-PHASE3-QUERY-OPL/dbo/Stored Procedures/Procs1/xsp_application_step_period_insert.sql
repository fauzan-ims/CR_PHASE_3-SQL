CREATE PROCEDURE dbo.xsp_application_step_period_insert
(
	@p_code							nvarchar(50) output
	,@p_application_no				nvarchar(50)
	,@p_step_no						int
	,@p_recovery_flag				nvarchar(15)
	,@p_recovery_principal_amount	decimal(18, 2)
	,@p_recovery_installment_amount decimal(18, 2)
	,@p_even_method					nvarchar(15)
	,@p_payment_schedule_type_code	nvarchar(50)
	,@p_number_of_installment		int
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
	declare @msg		  nvarchar(max)
			,@year		  nvarchar(2)
			,@month		  nvarchar(2)
			,@code		  nvarchar(50)
			,@branch_code nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	select	@branch_code = branch_code
	from	dbo.application_main
	where	application_no = @p_application_no ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'ASP'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'APPLICATION_STEP_PERIOD'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		insert into application_step_period
		(
			code
			,application_no
			,step_no
			,recovery_flag
			,recovery_principal_amount
			,recovery_installment_amount
			,even_method
			,payment_schedule_type_code
			,number_of_installment
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
			,@p_application_no
			,@p_step_no
			,@p_recovery_flag
			,@p_recovery_principal_amount
			,@p_recovery_installment_amount
			,@p_even_method
			,@p_payment_schedule_type_code
			,@p_number_of_installment
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
	Begin catch
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


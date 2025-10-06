CREATE PROCEDURE dbo.xsp_termination_main_insert
(
	@p_code							nvarchar(50) output
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_policy_code					nvarchar(50)
	,@p_termination_status			nvarchar(10)
	,@p_termination_date			datetime
	,@p_termination_approved_amount decimal(18, 2) = 0
	,@p_termination_remarks			nvarchar(4000)
	,@p_termination_request_code    nvarchar(50) = NULL
	,@p_termination_reason_code     nvarchar(50)    
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
	declare @msg						nvarchar(max)
			,@year						nvarchar(2)
			,@month						nvarchar(2)
			,@policy_eff_date			datetime
			,@policy_exp_date			datetime
			,@day						decimal(7, 3)
            ,@days						decimal(7, 3) = 365
			,@period					int
			,@proposional_buy_amount	decimal(18,2) 
			,@outstanding_buy_amount	decimal(18,2) = 0
			,@termination_amount		decimal(18, 2)
			,@year_periode				int
			,@insurance_type            nvarchar(50)
			,@day_in_year				decimal(7, 3)
			,@outstanding_day_in_year	int
			,@from_year					int
			,@policy_process_status		nvarchar(10); 

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'TRM'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'TERMINATION_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;
	begin TRY

		SELECT @policy_eff_date			= policy_eff_date
			   ,@policy_exp_date		= policy_exp_date
			   ,@insurance_type			= insurance_type
			   ,@from_year              = ipm.from_year
		FROM   dbo.insurance_policy_main  ipm
		WHERE  code = @p_policy_code 

		--krna ambil dari sys 18 maret 21
		--IF (@p_termination_date < dbo.xfn_get_system_date())
		--BEGIN
		--	set @msg = 'Date must be greater than System Date' ;

		--	raiserror(@msg, 16, -1) ;
		--END
   
		IF (@p_termination_date > @policy_exp_date)
		BEGIN
			set @msg = 'Date must be less than Expired Date' ;

			raiserror(@msg, 16, -1) ;
		END

		IF (@p_termination_date < @policy_eff_date)
		BEGIN
			set @msg = 'Date must be greater than Effective Date' ;

			raiserror(@msg, 16, -1) ;
		END
   
		SELECT @policy_process_status = ISNULL(policy_process_status, '')
		FROM dbo.insurance_policy_main
		WHERE  code = @p_policy_code

		IF (@policy_process_status <> '')
		BEGIN
			set @msg = 'This policy already proceed in ' + UPPER(LEFT(@policy_process_status,1))+LOWER(SUBSTRING(@policy_process_status,2,LEN(@policy_process_status)));

			raiserror(@msg, 16, -1) ;
		END

		UPDATE dbo.insurance_policy_main
		SET	   policy_process_status = 'TERMINATE'
		WHERE  code = @p_policy_code

		SET @termination_amount = dbo.xfn_get_terminate(@p_policy_code, @p_termination_date)

		insert into termination_main
		(
			code
			,branch_code
			,branch_name
			,policy_code
			,termination_status
			,termination_date
			,termination_amount
			,termination_approved_amount
			,termination_remarks
			,termination_request_code
			,termination_reason_code
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
			,@p_policy_code
			,@p_termination_status
			,@p_termination_date
			,@termination_amount
			,@p_termination_approved_amount
			,@p_termination_remarks
			,@p_termination_request_code
			,@p_termination_reason_code
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







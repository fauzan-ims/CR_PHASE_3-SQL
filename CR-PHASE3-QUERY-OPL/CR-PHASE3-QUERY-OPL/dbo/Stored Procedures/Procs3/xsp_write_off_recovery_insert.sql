CREATE PROCEDURE dbo.xsp_write_off_recovery_insert
(
	@p_code				   nvarchar(50) = '' output
	,@p_branch_code		   nvarchar(50)
	,@p_branch_name		   nvarchar(250)
	,@p_wo_amount		   decimal(18, 2)
	,@p_wo_recovery_amount decimal(18, 2)
	,@p_recovery_status	   nvarchar(10)
	,@p_recovery_date	   datetime
	,@p_recovery_amount	   decimal(18, 2)
	,@p_recovery_remarks   nvarchar(4000)
	,@p_agreement_no	   nvarchar(50)
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
	declare @msg							 nvarchar(max)
			,@year							 nvarchar(2)
			,@month							 nvarchar(2)
			,@overdue_period				 int
			,@overdue_days					 int
			,@overdue_penalty_amount		 decimal(18, 2)
			,@overdue_installment_amount	 decimal(18, 2)
			,@outstanding_installment_amount decimal(18, 2)
			,@outstanding_deposit_amount	 decimal(18, 2)
			,@system_date					 date = cast(dbo.xfn_get_system_date() as date) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'OPLWOR'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'WRITE_OFF_RECOVERY'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		if exists
		(
			select	1
			from	write_off_recovery
			where	agreement_no		= @p_agreement_no
					and recovery_status  not in ('CANCEL', 'PAID' ) -- Hari - 05.Jul.2023 02:34 PM --	wo agar bisa berkalikali
		)
		begin
			select	@p_recovery_status = recovery_status
			from	write_off_recovery
			where	agreement_no		= @p_agreement_no
					and recovery_status not in ('CANCEL', 'PAID' ) -- Hari - 05.Jul.2023 02:34 PM --	wo agar bisa berkalikali

			set @msg = 'Agreement : ' + @p_agreement_no + ' already in transaction with Status : ' + @p_recovery_status ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_recovery_date > @system_date)
		begin
			set @msg = 'Date must be lower than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@p_wo_amount = wo_amount
		from	dbo.write_off_main
		where	agreement_no  = @p_agreement_no
				and wo_status = 'APPROVE' ;

		insert into dbo.write_off_recovery
		(
			code
			,branch_code
			,branch_name
			,recovery_status
			,recovery_date
			,wo_amount
			,wo_recovery_amount
			,recovery_amount
			,recovery_remarks
			,agreement_no
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
			,@p_recovery_status
			,@p_recovery_date
			,@p_wo_amount
			,@p_wo_recovery_amount
			,@p_recovery_amount
			,@p_recovery_remarks
			,@p_agreement_no
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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

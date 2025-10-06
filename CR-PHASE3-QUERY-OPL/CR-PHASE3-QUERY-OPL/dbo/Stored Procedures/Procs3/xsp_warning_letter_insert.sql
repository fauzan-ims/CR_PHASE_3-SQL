CREATE PROCEDURE dbo.xsp_warning_letter_insert
(
	@p_code			   nvarchar(50) = '' OUTPUT
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_letter_status  nvarchar(20)
	,@p_letter_date	   datetime
	,@p_letter_no	   nvarchar(50) = '' OUTPUT
	,@p_letter_type	   nvarchar(10)
	,@p_agreement_no   nvarchar(50) = ''
	,@p_generate_type  nvarchar(10) = 'MANUAL'
	,@p_client_no	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@year						 nvarchar(2)
			,@month						 nvarchar(2)
			,@code						 nvarchar(50)
			,@installment_amount		 decimal(18, 2)
			,@installment_no			 int
			,@overdue_days				 int
			,@overdue_penalty_amount	 decimal(18, 2)
			,@overdue_installment_amount decimal(18, 2)
			,@remark					 nvarchar(4000)
			,@agreement_external_no		 nvarchar(50)
			,@client_name				 nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_code output
												,@p_branch_code
												,''
												,'WL'
												,@year
												,@month
												,'WARNING_LETTER'
												,6
												,'.'
												,'0' ;

	exec dbo.xsp_get_next_unique_code_for_table		@p_letter_no output
													,@p_branch_code
													,''
													,@p_letter_type
													,@year
													,@month
													,'WARNING_LETTER'
													,6
													,'.'
													,'0'
													,'letter_no' ;
	
	begin try
		if (cast(@p_letter_date as date) <> cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_equal_to('Letter Date', 'System Date') ;
			raiserror(@msg, 16, -1) ;
		end ;

		select	@installment_amount = sum(inv.total_billing_amount)
				,@overdue_days = datediff(day, min(inv.invoice_due_date), dbo.xfn_get_system_date())
		from	dbo.invoice inv
		where	client_no			= @p_client_no
		and		inv.invoice_status	= 'POST'
		and		cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date)

		select	@client_name = client_name
		from	dbo.client_main
		where	client_no = @p_client_no

		set @overdue_penalty_amount = dbo.xfn_client_get_ovd_penalty(@p_client_no, dbo.xfn_get_system_date()) ; --overdue_penalty_amount
		set @overdue_installment_amount = dbo.xfn_client_get_ol_ar(@p_client_no, dbo.xfn_get_system_date()) ; -- overdue_installment_amount

		insert into warning_letter
		(
			code
			,branch_code
			,branch_name
			,letter_status
			,letter_date
			,letter_no
			,letter_type
			,agreement_no
			,max_print_count
			,print_count
			,generate_type
			,installment_amount
			,overdue_days
			,overdue_penalty_amount
			,overdue_installment_amount
			,installment_no
			,client_no
			,client_name
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
			,@p_letter_status
			,@p_letter_date
			,@p_letter_no
			,@p_letter_type
			,'-'
			,1
			,0
			,@p_generate_type
			,isnull(@installment_amount,0)
			,@overdue_days
			,isnull(@overdue_penalty_amount,0)
			,isnull(@overdue_installment_amount,0)
			,@installment_no
			,@p_client_no
			,@client_name
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;



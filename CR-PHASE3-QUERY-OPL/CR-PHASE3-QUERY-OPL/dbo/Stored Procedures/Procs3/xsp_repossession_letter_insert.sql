CREATE PROCEDURE dbo.xsp_repossession_letter_insert
(
	@p_code				nvarchar(50) output
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(250)
	,@p_letter_date		datetime
	,@p_letter_no		nvarchar(50) output
	,@p_letter_remarks	nvarchar(4000)
	,@p_agreement_no	nvarchar(50)
	,@p_letter_status	nvarchar(20)
	--
	,@p_cre_date	    datetime
	,@p_cre_by		    nvarchar(15)
	,@p_cre_ip_address  nvarchar(15)
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg							 nvarchar(max)
			,@year							 NVARCHAR(2)
			,@month							 nvarchar(2)
			,@rental_amount					 decimal(18, 2)
			,@installment_due_date			 datetime
			,@overdue_period				 int
			,@overdue_days					 int
			,@overdue_penalty_amount		 decimal(18, 2)
			--,@letter_eff_date				 datetime
            --,@letter_exp_date				 datetime

	begin TRY
    
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		SET @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		declare @p_unique_code nvarchar(50) ;
	
		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output 
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N'' 
													,@p_custom_prefix = 'RLM'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'REPOSSESSION_LETTER'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0'

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_letter_no output  
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N'' 
													,@p_custom_prefix = 'SKT'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'REPOSSESSION_LETTER'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0'
													,@p_specified_column = 'letter_no'
		
		if (@p_letter_date > dbo.xfn_get_system_date())
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Letter Date','System Date') ;
			raiserror(@msg, 16, -1) ;
		end

		if exists 
		(
			select	1
			from	dbo.repossession_letter
			where	agreement_no = @p_agreement_no
			and		letter_status in ('HOLD', 'POST')
		)
		begin
			set	@msg = 'Agreement Already In Process'
			raiserror(@msg, 16, -1)
		end
			
		select		@rental_amount					= ai.ovd_rental_amount
					,@installment_due_date			= ai.installment_due_date
					,@overdue_penalty_amount		= ai.ovd_penalty_amount
					,@overdue_days					= ai.ovd_days
					,@overdue_period				= ai.ovd_period
		from		dbo.agreement_information ai
		left join	dbo.agreement_main am on (am.agreement_no = ai.agreement_no)
		where		am.agreement_no = @p_agreement_no

		--set @letter_eff_date = dbo.xfn_get_system_date()
		--set	@letter_exp_date = dbo.xfn_get_system_date()

		insert into dbo.repossession_letter
		(
			code
			,branch_code
			,branch_name
			,letter_status
			,letter_date
			,letter_no
			,letter_remarks
			,letter_proceed_by
			,letter_executor_code
			,letter_collector_code
			,letter_signer_collector_code
			,letter_eff_date
			,letter_exp_date
			,agreement_no
			,rental_amount
			,rental_due_date
			,companion_name
			,companion_id_no
			,companion_job
			,overdue_period
			,overdue_days
			,overdue_penalty_amount
			,overdue_invoice_amount
			,outstanding_rental_amount
			,outstanding_deposit_amount
			,result_status
			,result_date
			,result_action
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
			,@p_letter_remarks
			,N'I'
			,null
			,null
			,null
			,null
			,null
			,@p_agreement_no
			,@rental_amount
			,@installment_due_date
			,null
			,null
			,null
			,@overdue_period
			,@overdue_days
			,@overdue_penalty_amount
			,dbo.xfn_agreement_get_ovd_rental_amount(@p_agreement_no, null)
			,dbo.xfn_agreement_get_os_principal(@p_agreement_no, getdate(), null)
			,dbo.xfn_agreement_get_deposit_installment(@p_agreement_no, getdate())
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
		) 

		set	@p_letter_no = @p_letter_no
		set @p_code = @p_code 
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


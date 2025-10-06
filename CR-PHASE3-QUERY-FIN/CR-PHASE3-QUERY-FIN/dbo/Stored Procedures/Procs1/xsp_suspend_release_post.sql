CREATE procedure [dbo].[xsp_suspend_release_post]
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg							nvarchar(max)
			,@gl_link_code					nvarchar(50)
			,@payment_request_code			nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@payment_branch_code			nvarchar(50)
			,@payment_branch_name			nvarchar(250)
			,@release_date					datetime
			,@release_amount				decimal(18, 2)
			,@release_bank_name				nvarchar(250)
			,@release_bank_account_no		nvarchar(50)
			,@release_bank_account_name		nvarchar(250)
			,@release_remarks				nvarchar(4000)
			,@suspend_currency_code			nvarchar(3)

	begin try
	
		if exists	(
						select	1 
						from	dbo.suspend_release sr
								inner join dbo.suspend_main sm on (sm.code = sr.suspend_code)
						where	sr.code = @p_code 
								and sr.suspend_amount <> sm.remaining_amount
					)
		begin
			set @msg = 'Please reselect this suspend because amount already changed';
			raiserror(@msg ,16,-1)
		end

		if exists	(	
						select	1	
						from	dbo.suspend_release sr
								inner join dbo.suspend_main sm on (sm.code = sr.suspend_code)
						where	sr.code = @p_code 
								and sr.release_amount > sm.remaining_amount
					)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Release Amount ','Suspend Amount');
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.suspend_release where code = @p_code and release_status <> 'ON PROCESS')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin									 
			select	@payment_branch_code		= sr.branch_code
				   ,@payment_branch_name		= sr.branch_name
				   ,@release_date				= release_date
				   ,@release_amount				= release_amount
				   ,@release_bank_name			= release_bank_name
				   ,@release_bank_account_no	= release_bank_account_no
				   ,@release_bank_account_name	= release_bank_account_name
				   ,@suspend_currency_code		= sr.suspend_currency_code
				   ,@release_remarks			= 'Releas Suspend, Suspend No ' + sr.suspend_code + ' - ' + sm.suspend_remarks + '. ' + release_remarks
			from	dbo.suspend_release sr
					inner join dbo.suspend_main sm on (sm.code = sr.suspend_code)
			where	sr.code = @p_code

			select	@gl_link_code = mt.gl_link_code 
			from	dbo.sys_global_param sgp
					inner join dbo.master_transaction mt on (mt.code = sgp.value)
			where	sgp.code = 'TRXSPND'

			if exists (SELECT 1 FROM dbo.SYS_GLOBAL_PARAM where CODE = 'BPFRS' and VALUE = 'HO')
			begin
			    select	@branch_name	= description
						,@branch_code	= value 
				from	dbo.sys_global_param
				where	code = 'HO'
			end
			else
			begin
			    set @branch_code = @payment_branch_code
			    set @branch_name = @payment_branch_name
			end

			exec dbo.xsp_payment_request_insert @p_code							= @payment_request_code output
												,@p_branch_code					= @branch_code
												,@p_branch_name					= @branch_name
												,@p_payment_branch_code			= @payment_branch_code
												,@p_payment_branch_name			= @payment_branch_name
			                                    ,@p_payment_source				= N'RELEASE SUSPEND'
												,@p_payment_request_date		= @release_date
												,@p_payment_source_no			= @p_code
												,@p_payment_status				= N'HOLD'
			                                    ,@p_payment_currency_code		= @suspend_currency_code
												,@p_payment_amount				= @release_amount
												,@p_payment_remarks				= @release_remarks
												,@p_to_bank_name				= @release_bank_name			
												,@p_to_bank_account_name		= @release_bank_account_no	
												,@p_to_bank_account_no			= @release_bank_account_name
												,@p_payment_transaction_code	= null
			                                    ,@p_tax_payer_reff_code         = null
			                                    ,@p_tax_type				    = null
			                                    ,@p_tax_file_no			        = null
			                                    ,@p_tax_file_name		        = null
												,@p_cre_date					= @p_cre_date		
												,@p_cre_by						= @p_cre_by			
												,@p_cre_ip_address				= @p_cre_ip_address
												,@p_mod_date					= @p_mod_date		
												,@p_mod_by						= @p_mod_by			
												,@p_mod_ip_address				= @p_mod_ip_address												

			
			exec dbo.xsp_payment_request_detail_insert @p_id						= 0
													   ,@p_payment_request_code		= @payment_request_code
													   ,@p_branch_code				= @branch_code
													   ,@p_branch_name				= @branch_name
													   ,@p_gl_link_code				= @gl_link_code
													   ,@p_agreement_no				= null
													   ,@p_facility_code			= null
													   ,@p_facility_name			= null
													   ,@p_purpose_loan_code		= null
													   ,@p_purpose_loan_name		= null
													   ,@p_purpose_loan_detail_code = null
													   ,@p_purpose_loan_detail_name = null
													   ,@p_orig_currency_code		= @suspend_currency_code
													   ,@p_orig_amount				= @release_amount
													   ,@p_division_code			= null
													   ,@p_division_name			= null
													   ,@p_department_code			= null
													   ,@p_department_name			= null
													   ,@p_remarks					= @release_remarks
													   ,@p_cre_date					= @p_cre_date		
													   ,@p_cre_by					= @p_cre_by			
													   ,@p_cre_ip_address			= @p_cre_ip_address
													   ,@p_mod_date					= @p_mod_date		
													   ,@p_mod_by					= @p_mod_by			
													   ,@p_mod_ip_address			= @p_mod_ip_address
			
			
			
			update	dbo.suspend_release
			set		release_status		= 'APPROVE'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
		end
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
end




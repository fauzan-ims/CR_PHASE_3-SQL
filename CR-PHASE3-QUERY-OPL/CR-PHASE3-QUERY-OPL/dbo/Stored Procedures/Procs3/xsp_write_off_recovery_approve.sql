CREATE PROCEDURE dbo.xsp_write_off_recovery_approve
(
	@p_code				nvarchar(50)
	--,@p_approval_reff	nvarchar(250)  = ''
	--,@p_approval_remark nvarchar(4000) = ''
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
--begin
--	declare @msg			  nvarchar(max)
--			,@recovery_amount decimal(18, 2)
--			,@branch_code	  nvarchar(50)
--			,@branch_name	  nvarchar(250)
--			,@currency		  nvarchar(10)
--			,@remark		  nvarchar(4000)
--			,@agreement_no	  nvarchar(50)
--			,@recovery_date	  datetime
--			,@code_cashier	  nvarchar(50) ;

--	begin try
--		if exists
--		(
--			select	1
--			from	dbo.write_off_recovery
--			where	code				= @p_code
--					and recovery_status <> 'ON PROCESS'
--		)
--		begin
--			set @msg = 'Error data already proceed' ;

--			raiserror(@msg, 16, 1) ;
--		end ;
--		else
--		begin
--			select	@recovery_amount = isnull(et.recovery_amount, 0)
--					,@agreement_no = et.agreement_no
--					,@remark = et.recovery_remarks
--					,@recovery_date = et.recovery_date
--					,@currency = am.currency_code
--					,@branch_code = et.branch_code
--					,@branch_name = et.branch_name
--			from	dbo.write_off_recovery et
--					inner join dbo.agreement_main am on (am.agreement_no = et.agreement_no)
--			where	code = @p_code ;
			
--			exec dbo.xsp_lms_interface_cashier_received_request_insert @p_code						= @code_cashier output
--																		,@p_branch_code				= @branch_code 
--																		,@p_branch_name				= @branch_name
--																		,@p_request_status			= N'HOLD'
--																		,@p_request_currency_code	= @currency 
--																		,@p_request_date			= @recovery_date
--																		,@p_request_amount			= @recovery_amount 
--																		,@p_request_remarks			= @remark
--																		,@p_agreement_no			= @agreement_no
--																		,@p_pdc_code				= null
--																		,@p_pdc_no					= null
--																		,@p_doc_ref_code			= @p_code
--																		,@p_doc_ref_name			= N'WO RECOVERY'
--																		,@p_process_date			= null
--																		,@p_process_reff_no			= null
--																		,@p_process_reff_name		= null
--																		,@p_cre_date				= @p_mod_date		
--																		,@p_cre_by					= @p_mod_by			
--																		,@p_cre_ip_address			= @p_mod_ip_address
--																		,@p_mod_date				= @p_mod_date		
--																		,@p_mod_by					= @p_mod_by			
--																		,@p_mod_ip_address			= @p_mod_ip_address

--			if not exists
--			(
--				select	1
--				from	dbo.journal_gl_link
--				where	code = 'RCVWO'
--			)
--			begin
--				set @msg = 'Please setting GL Link for Received Write Off with code RCVWO' ;

--				raiserror(@msg, 16, 1) ;
--			end ;

--			insert into dbo.lms_interface_cashier_received_request_detail
--			(
--				cashier_received_request_code
--				,branch_code
--				,branch_name
--				,gl_link_code
--				,agreement_no
--				,facility_code
--				,facility_name
--				,purpose_loan_code
--				,purpose_loan_name
--				,purpose_loan_detail_code
--				,purpose_loan_detail_name
--				,orig_currency_code
--				,orig_amount
--				,division_code
--				,division_name
--				,department_code
--				,department_name
--				,remarks
--				,cre_date
--				,cre_by
--				,cre_ip_address
--				,mod_date
--				,mod_by
--				,mod_ip_address
--			)
--			select	@code_cashier
--					,am.branch_code
--					,am.branch_name
--					,'RCVWO'
--					,am.agreement_no
--					,am.facility_code
--					,am.facility_name
--					,am.purpose_loan_code
--					,am.purpose_loan_name
--					,am.purpose_loan_detail_code
--					,am.purpose_loan_detail_name
--					,am.currency_code
--					,wor.recovery_amount
--					,null
--					,null
--					,null
--					,null
--					,wor.recovery_remarks
--					,@p_mod_date
--					,@p_mod_by
--					,@p_mod_ip_address
--					,@p_mod_date
--					,@p_mod_by
--					,@p_mod_ip_address
--			from	dbo.write_off_recovery wor
--					inner join dbo.agreement_main am on am.agreement_no = wor.agreement_no
--			where	code = @p_code ;

--			--declare @p_id bigint;
--			--exec dbo.xsp_lms_interface_cashier_received_request_detail_insert @p_id								 = @p_id OUTPUT           
--			--                                                                  ,@p_cashier_received_request_code  = @code_cashier
--			--                                                                  ,@p_branch_code                    = @branch_code
--			--                                                                  ,@p_branch_name                    = @branch_name
--			--                                                                  ,@p_gl_link_code                   = ''
--			--                                                                  ,@p_agreement_no                   = @agreement_no
--			--                                                                  ,@p_facility_code                  = 
--			--                                                                  ,@p_facility_name                  = 
--			--                                                                  ,@p_purpose_loan_code              = 
--			--                                                                  ,@p_purpose_loan_name              = 
--			--                                                                  ,@p_purpose_loan_detail_code       = 
--			--                                                                  ,@p_purpose_loan_detail_name       = 
--			--                                                                  ,@p_orig_currency_code             = 
--			--                                                                  ,@p_orig_amount                    = 
--			--                                                                  ,@p_division_code                  = 
--			--                                                                  ,@p_division_name                  = 
--			--                                                                  ,@p_department_code                = 
--			--                                                                  ,@p_department_name                = 
--			--                                                                  ,@p_remarks                        = 
--			--                                                                  ,@p_cre_date                       = 
--			--                                                                  ,@p_cre_by                         = 
--			--                                                                  ,@p_cre_ip_address                 = 
--			--                                                                  ,@p_mod_date                       = 
--			--                                                                  ,@p_mod_by                         = 
--			--                                                                  ,@p_mod_ip_address                 = 

--			update	dbo.write_off_recovery
--			set		recovery_status = 'ON PROCESS'
--					,mod_by			= @p_mod_by
--					,mod_date		= @p_mod_date
--					,mod_ip_address = @p_mod_ip_address
--			where	code			= @p_code ;
--		end ;

--		set @msg = dbo.xfn_finance_request_check_balance('CASHIER',@code_cashier)
--		if @msg <> ''
--		begin
--			raiserror(@msg,16,1);
--		end

--	end try
	--begin catch
	--	declare @error int ;

	--	set @error = @@error ;

	--	if (@error = 2627)
	--	begin
	--		set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
	--	end ;

	--	if (len(@msg) <> 0)
	--	begin
	--		set @msg = 'V' + ';' + @msg ;
	--	end ;
	--	else
	--	begin
	--		if (error_message() like '%V;%' or error_message() like '%E;%')
	--		begin
	--			set @msg = error_message() ;
	--		end
	--		else 
	--		begin
	--			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
	--		end
	--	end ;

	--	raiserror(@msg, 16, -1) ;

	--	return ;
	--end catch ; 
--end ;


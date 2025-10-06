/*
    Created : Louis, 25 may 2021
*/
CREATE PROCEDURE dbo.xsp_journal_gl_link_transaction_golive_generate
(
	@p_reff_no			nvarchar(50)
	,@p_type			nvarchar(15)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)

as
begin
	declare @msg							nvarchar(max)
			,@gllink_trx_code				nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@gl_link_code					nvarchar(50)
			,@transaction_amount			decimal(18,2)
			,@debet_or_credit				nvarchar(10)
			,@currency						nvarchar(3)
			,@agreement_no					nvarchar(50)
			,@orig_amount_db				decimal(18,2)
			,@orig_amount_cr				decimal(18,2)
			,@facility_code					nvarchar(50)
			,@facility_name					nvarchar(250)
			,@purpose_loan_code				nvarchar(50)
			,@purpose_loan_name				nvarchar(250)
			,@purpose_loan_detail_code		nvarchar(50)
			,@purpose_loan_detail_name		nvarchar(250)
			,@remark						nvarchar(4000)
			,@transaction_name				nvarchar(250)
			,@sp_name						nvarchar(250)
			,@process_code					nvarchar(50)
			,@reff_source_no				nvarchar(50)
			,@reff_source_name				nvarchar(250) 
			,@system_date					datetime ;
	
	begin try
		if (@p_type = 'APPLICATION')
		begin
			set @process_code = 'APPJRL';
			select	@branch_code				= am.branch_code
					,@branch_name				= am.branch_name
					,@agreement_no				= am.agreement_no
					,@currency					= am.currency_code
					,@facility_code				= am.facility_code
					,@facility_name				= mf.description 
					,@reff_source_no			= am.agreement_external_no
					,@reff_source_name			= 'APPLICATION GOLIVE - ' + am.application_external_no + ' - ' + cm.client_name
					,@transaction_name			= 'APPLICATION GOLIVE'
			from	dbo.application_main am
					inner join dbo.client_main cm on (cm.code = am.client_code)
					inner join dbo.master_facility mf on (mf.code = am.facility_code)
			where	application_no = @p_reff_no ;
		end ; 
		
		set @system_date = dbo.xfn_get_system_date()

		exec dbo.xsp_opl_interface_journal_gl_link_transaction_insert	@p_code						= @gllink_trx_code output
																		,@p_branch_code				= @branch_code
																		,@p_branch_name				= @branch_name
																		,@p_transaction_status		= 'HOLD'
																		,@p_transaction_date		= @system_date
																		,@p_transaction_value_date	= @system_date
																		,@p_transaction_code		= 'GO LIVE'
																		,@p_transaction_name		= @transaction_name
																		,@p_reff_module_code		= 'IFINOPL'
																		,@p_reff_source_no			= @reff_source_no
																		,@p_reff_source_name		= @reff_source_name
																		,@p_is_journal_reversal		= '0'
																		,@p_cre_date				= @p_mod_date
																		,@p_cre_by					= @p_mod_by
																		,@p_cre_ip_address			= @p_mod_ip_address
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_ip_address			= @p_mod_ip_address
		
		begin
			
			declare c_jurnal cursor local fast_forward read_only for
			select  mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
			from	dbo.master_transaction_parameter mtp 
					left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
					left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
			where	mtp.process_code = @process_code
			order by mtp.order_key

			open c_jurnal
			fetch c_jurnal 
			into @sp_name
				 ,@debet_or_credit
				 ,@gl_link_code
				 ,@transaction_name

			while @@fetch_status = 0
			begin
					-- nilainya exec dari MASTER_TRANSACTION.sp_name
					exec @transaction_amount = @sp_name @p_reff_no ; -- sp ini mereturn value angka 
	
					if (@debet_or_credit ='DEBIT')
						begin
							set @orig_amount_db = @transaction_amount
							set @orig_amount_cr = 0
						end
					else
					begin
							set @orig_amount_db = 0
							set @orig_amount_cr = @transaction_amount
					end

					if (isnull(@gl_link_code, '') = '')
					begin
						set @msg = 'Please Setting GL Link For ' + @transaction_name;
						raiserror(@msg, 16, -1);
					end
					
					if (@transaction_amount <> 0 )
					begin
						exec dbo.xsp_opl_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code
																							 ,@p_branch_code				= @branch_code
																							 ,@p_branch_name				= @branch_name
																							 ,@p_gl_link_code				= @gl_link_code
																							 ,@p_agreement_no				= @agreement_no
																							 ,@p_facility_code				= @facility_code			
																							 ,@p_facility_name				= @facility_name			
																							 ,@p_purpose_loan_code			= @purpose_loan_code		
																							 ,@p_purpose_loan_name			= @purpose_loan_name		
																							 ,@p_purpose_loan_detail_code	= @purpose_loan_detail_code
																							 ,@p_purpose_loan_detail_name	= @purpose_loan_detail_name
																							 ,@p_orig_currency_code			= @currency
																							 ,@p_orig_amount_db				= @orig_amount_db
																							 ,@p_orig_amount_cr				= @orig_amount_cr
																							 ,@p_exch_rate					= 1
																							 ,@p_base_amount_db				= @orig_amount_db
																							 ,@p_base_amount_cr				= @orig_amount_cr
																							 ,@p_division_code				= ''
																							 ,@p_division_name				= ''
																							 ,@p_department_code			= ''
																							 ,@p_department_name			= ''
																							 ,@p_remarks					= @transaction_name
																							 ,@p_cre_date					= @p_mod_date
																							 ,@p_cre_by						= @p_mod_by
																							 ,@p_cre_ip_address				= @p_mod_ip_address
																							 ,@p_mod_date					= @p_mod_date
																							 ,@p_mod_by						= @p_mod_by
																							 ,@p_mod_ip_address				= @p_mod_ip_address
					end
					
					fetch c_jurnal 
					into @sp_name
						 ,@debet_or_credit
						 ,@gl_link_code
						 ,@transaction_name

			end
			close c_jurnal
			deallocate c_jurnal

		end

		-- balancing
		begin  
			if ((
					select	sum(orig_amount_db) - sum(orig_amount_cr)
					from	dbo.opl_interface_journal_gl_link_transaction_detail
					where	gl_link_transaction_code = @gllink_trx_code
				) <> 0
			   )
			begin
				set @msg = 'Journal is not balance' ;

				raiserror(@msg, 16, -1) ;
			end ;
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
	
	





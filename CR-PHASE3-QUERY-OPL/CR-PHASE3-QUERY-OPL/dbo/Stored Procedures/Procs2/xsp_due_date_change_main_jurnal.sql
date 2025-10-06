CREATE PROCEDURE dbo.xsp_due_date_change_main_jurnal
(
	@p_reff_name				nvarchar(50)
	,@p_reff_code				nvarchar(50)
	,@p_value_date				datetime
	,@p_trx_date				datetime
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
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
			,@is_discount_jurnal			nvarchar(1)
			,@disc_amount					decimal(18,2)
			,@discount_gl_link_code			nvarchar(50)
			,@orig_amount_db_disc			decimal(18,2)
			,@orig_amount_cr_disc			decimal(18,2)
			,@remark						nvarchar(4000)
			,@transaction_name				nvarchar(250) ;
				
	
	begin try
		
		select	@branch_code				= ddt.branch_code
				,@branch_name				= ddt.branch_name
				,@agreement_no				= ddt.agreement_no
				,@currency					= am.currency_code
				,@facility_code				= am.facility_code
				,@facility_name				= am.facility_name
				,@purpose_loan_code			= ''
				,@purpose_loan_name			= ''
				,@purpose_loan_detail_code	= ''
				,@purpose_loan_detail_name	= ''
		from	dbo.due_date_change_main ddt 
				inner join agreement_main am on (am.agreement_no = ddt.agreement_no)
		where	code = @p_reff_code


		exec dbo.xsp_lms_interface_journal_gl_link_transaction_insert	@p_code						= @gllink_trx_code output
																		,@p_branch_code				= @branch_code
																		,@p_branch_name				= @branch_name
																		,@p_transaction_status		= 'HOLD'
																		,@p_transaction_date		= @p_trx_date
																		,@p_transaction_value_date	= @p_value_date
																		,@p_transaction_code		= @p_reff_code
																		,@p_transaction_name		= @p_reff_name
																		,@p_reff_module_code		= 'IFINLMS'
																		,@p_reff_source_no			= @p_reff_code
																		,@p_reff_source_name		= @p_reff_name
																		,@p_cre_date				= @p_mod_date
																		,@p_cre_by					= @p_mod_by
																		,@p_cre_ip_address			= @p_mod_ip_address
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_ip_address			= @p_mod_ip_address
		
		begin
		
			declare c_jurnal cursor local fast_forward read_only for
			select  mtp.gl_link_code
					,mtp.debet_or_credit
					,mtp.discount_gl_link_code
					,ddt.total_amount
					,mtp.is_discount_jurnal
					,ddt.disc_amount
					,mt.transaction_name
			from	dbo.due_date_change_transaction ddt
					inner join dbo.master_transaction_parameter mtp on (mtp.transaction_code=ddt.transaction_code and mtp.process_code ='due date')
					inner join dbo.master_transaction mt on (mt.code = ddt.transaction_code)
			where	due_date_change_code = @p_reff_code
			and		mtp.is_journal ='1'		

			open c_jurnal
			fetch c_jurnal 
			into @gl_link_code
				,@debet_or_credit
				,@discount_gl_link_code
				,@transaction_amount
				,@is_discount_jurnal
				,@disc_amount
				,@transaction_name
				

			while @@fetch_status = 0
			BEGIN
					set @transaction_amount = abs(@transaction_amount)
					if (@debet_or_credit ='DEBIT')
					begin
							set @orig_amount_db = @transaction_amount
							set @orig_amount_cr = 0
							set @orig_amount_cr_disc = @disc_amount
							set @orig_amount_db_disc = 0
					end
					else
					begin
							set @orig_amount_db = 0
							set @orig_amount_cr = @transaction_amount
							set @orig_amount_cr_disc = 0
							set @orig_amount_db_disc = @disc_amount
					end
					
					if (@transaction_amount > 0)
					begin
						exec dbo.xsp_lms_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code
																							,@p_branch_code					= @branch_code
																							,@p_branch_name					= @branch_name
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
																							,@p_department_code				= ''
																							,@p_department_name				= ''
																							,@p_remarks						= @transaction_name
																							,@p_cre_date					= @p_mod_date
																							,@p_cre_by						= @p_mod_by
																							,@p_cre_ip_address				= @p_mod_ip_address
																							,@p_mod_date					= @p_mod_date
																							,@p_mod_by						= @p_mod_by
																							,@p_mod_ip_address				= @p_mod_ip_address
					end
					
					if (@is_discount_jurnal ='1')
					begin
						if (@disc_amount <> 0)
						begin
							if (isnull(@discount_gl_link_code, '') = '')
							begin
								set @msg = 'Please Setting Discount GL Link For ' +@transaction_name;
								raiserror(@msg, 16, -1);
							end
							set @remark = 'DISCOUNT ' + @transaction_name ;
							set @disc_amount = @disc_amount * -1;
							exec dbo.xsp_lms_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code
																								 ,@p_branch_code				= @branch_code
																								 ,@p_branch_name				= @branch_name
																								 ,@p_gl_link_code				= @discount_gl_link_code
																								 ,@p_agreement_no				= @agreement_no
																								 ,@p_facility_code				= @facility_code			
																								 ,@p_facility_name				= @facility_name			
																								 ,@p_purpose_loan_code			= @purpose_loan_code		
																								 ,@p_purpose_loan_name			= @purpose_loan_name		
																								 ,@p_purpose_loan_detail_code	= @purpose_loan_detail_code
																								 ,@p_purpose_loan_detail_name	= @purpose_loan_detail_name
																								 ,@p_orig_currency_code			= @currency
																								 ,@p_orig_amount_db				= @orig_amount_db_disc
																								 ,@p_orig_amount_cr				= @orig_amount_cr_disc
																								 ,@p_exch_rate					= 1
																								 ,@p_base_amount_db				= @orig_amount_db_disc
																								 ,@p_base_amount_cr				= @orig_amount_cr_disc
																								 ,@p_division_code				= ''
																								 ,@p_division_name				= ''
																								 ,@p_department_code			= ''
																								 ,@p_department_name			= ''
																								 ,@p_remarks					= @remark
																								 ,@p_cre_date					= @p_mod_date
																								 ,@p_cre_by						= @p_mod_by
																								 ,@p_cre_ip_address				= @p_mod_ip_address
																								 ,@p_mod_date					= @p_mod_date
																								 ,@p_mod_by						= @p_mod_by
																								 ,@p_mod_ip_address				= @p_mod_ip_address
						end
					end
					
					--EXEC dbo.xsp_lms_interface_journal_gl_link_transaction_group_insert @p_gl_link_transaction_code		= @gllink_trx_code
					--																	,@p_branch_code					= @branch_code
					--																	,@p_branch_name					= @branch_name
					--																	,@p_gl_link_code				= @gl_link_code
					--																	,@p_facility_code				= @facility_code			
					--																	,@p_facility_name				= @facility_name			
					--																	,@p_purpose_loan_code			= @purpose_loan_code		
					--																	,@p_purpose_loan_name			= @purpose_loan_name		
					--																	,@p_purpose_loan_detail_code	= @purpose_loan_detail_code
					--																	,@p_purpose_loan_detail_name	= @purpose_loan_detail_name
					--																	,@p_orig_currency_code			= @currency
					--																	,@p_orig_amount_db				= @orig_amount_db
					--																	,@p_orig_amount_cr				= @orig_amount_cr
					--																	,@p_exch_rate					= 1
					--																	,@p_base_amount_db				= @orig_amount_db
					--																	,@p_base_amount_cr				= @orig_amount_cr
					--																	,@p_cre_date					= @p_mod_date
					--																	,@p_cre_by						= @p_mod_by
					--																	,@p_cre_ip_address				= @p_mod_ip_address
					--																	,@p_mod_date					= @p_mod_date
					--																	,@p_mod_by						= @p_mod_by
					--																	,@p_mod_ip_address				= @p_mod_ip_address
					
					
					
			
					
					
			
						
					fetch c_jurnal 
					into @gl_link_code
						 ,@debet_or_credit
						 ,@discount_gl_link_code
						 ,@transaction_amount
						 ,@is_discount_jurnal
						 ,@disc_amount
						 ,@transaction_name
						
			end
			close c_jurnal
			deallocate c_jurnal

		end

		-- balancing
		begin
			if ((
					select	sum(orig_amount_db) - sum(orig_amount_cr)
					from	dbo.lms_interface_journal_gl_link_transaction_detail
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
	
	

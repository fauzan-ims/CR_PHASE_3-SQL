CREATE PROCEDURE [dbo].[xsp_et_main_journal]
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
			,@remark						nvarchar(4000)
			,@discount_gl_link_code			nvarchar(50)
			,@orig_amount_db_disc			decimal(18,2)
			,@orig_amount_cr_disc			decimal(18,2)
			,@process_code					nvarchar(50)
			,@transaction_name				nvarchar(250)
			,@transaction_code				nvarchar(50) 
			,@agreement_branch_code			nvarchar(50)
			,@agreement_branch_name			nvarchar(250)
	
	begin try
		select	@branch_code				= et.branch_code
				,@branch_name				= et.branch_name
				,@agreement_no				= et.agreement_no
				,@currency					= am.currency_code
				,@facility_code				= am.facility_code
				,@facility_name				= am.facility_name
				,@purpose_loan_code			= null
				,@purpose_loan_name			= null
				,@purpose_loan_detail_code	= null
				,@purpose_loan_detail_name	= null
				,@process_code				= 'ET'
		from	dbo.et_main et 
				inner join agreement_main am on (am.agreement_no = et.agreement_no)
		where	code = @p_reff_code

		exec dbo.xsp_opl_interface_journal_gl_link_transaction_insert	@p_code						= @gllink_trx_code output
																		,@p_branch_code				= @branch_code
																		,@p_branch_name				= @branch_name
																		,@p_transaction_status		= 'HOLD'
																		,@p_transaction_date		= @p_trx_date
																		,@p_transaction_value_date	= @p_value_date
																		,@p_transaction_code		= @p_reff_code
																		,@p_transaction_name		= @p_reff_name
																		,@p_reff_module_code		= 'IFINOPL'
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
					,mtp.discount_gl_link_code
					,et.total_amount
					,mtp.debet_or_credit
					,mtp.is_discount_jurnal
					,et.disc_amount
					,mt.transaction_name
					,et.transaction_code
					,am.branch_code
					,am.branch_name
			from	dbo.et_transaction et
					inner join dbo.master_transaction_parameter mtp on (mtp.transaction_code=et.transaction_code and mtp.process_code = @process_code)
					inner join dbo.et_main em on (em.code = et.et_code)
					inner join dbo.agreement_main am on (am.agreement_no = em.agreement_no)
					inner join dbo.master_transaction mt on (mt.code = et.transaction_code)
			where	et.et_code = @p_reff_code 
			and mtp.is_journal = '1'

			open c_jurnal
			fetch c_jurnal 
			into @gl_link_code
				,@discount_gl_link_code
				,@transaction_amount
				,@debet_or_credit
				,@is_discount_jurnal
				,@disc_amount
				,@transaction_name
				,@transaction_code
				,@agreement_branch_code
				,@agreement_branch_name

			while @@fetch_status = 0
			begin
					set @transaction_amount = abs(@transaction_amount);
					if (isnull(@gl_link_code, '') = '')
					begin
						set @msg = 'Please Setting GL Link For ' + @transaction_name;
						raiserror(@msg, 16, -1);
					end

				
					if (@debet_or_credit ='DEBIT')
					begin
							if (@transaction_code ='OVD_INTER') --khusus utk ovd interest berbeda cara penjurnal disc
							begin
							    set @orig_amount_db = @transaction_amount
								set @orig_amount_cr = 0
								set @orig_amount_cr_disc = 0
								set @orig_amount_db_disc = @disc_amount
							end
							else
							begin
							    set @orig_amount_db = @transaction_amount
								set @orig_amount_cr = 0
								set @orig_amount_cr_disc = @disc_amount
								set @orig_amount_db_disc = 0
							end
							

					end
					else
					begin
							set @orig_amount_db = 0
							set @orig_amount_cr = @transaction_amount
							set @orig_amount_cr_disc = 0
							set @orig_amount_db_disc = @disc_amount
					end
					
					if (@transaction_amount <> 0 )
					begin
						exec dbo.xsp_opl_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code
																							 ,@p_branch_code				= @agreement_branch_code
																							 ,@p_branch_name				= @agreement_branch_name
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

							exec dbo.xsp_opl_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code
																								 ,@p_branch_code				= @agreement_branch_code
																								 ,@p_branch_name				= @agreement_branch_name
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
				
					fetch c_jurnal 
					into @gl_link_code
						,@discount_gl_link_code
						,@transaction_amount
						,@debet_or_credit
						,@is_discount_jurnal
						,@disc_amount
						,@transaction_name
						,@transaction_code
						,@agreement_branch_code
						,@agreement_branch_name

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
	
end

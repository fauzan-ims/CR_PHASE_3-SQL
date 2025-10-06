-- Louis Senin, 19 Juni 2023 18.22.39 -- 
CREATE PROCEDURE [dbo].[xsp_write_off_main_journal]
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
	declare @msg					nvarchar(max)
			,@gllink_trx_code		nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@agreement_branch_code nvarchar(50)
			,@agreement_branch_name nvarchar(250)
			,@gl_link_code			nvarchar(50)
			,@debet_or_credit		nvarchar(10)
			,@currency				nvarchar(3)
			,@agreement_no			nvarchar(50)
			,@agreement_detail_no	nvarchar(50)
			,@orig_amount_db		decimal(18, 2)
			,@orig_amount_cr		decimal(18, 2)
			,@transaction_name		nvarchar(250)
			,@sp_name				nvarchar(250)
			,@return_value			decimal(18, 2)
			,@invoice_detail_id		bigint 
			,@client_name			nvarchar(250)

	
	begin try 
		select	@branch_code				= ddt.branch_code
				,@branch_name				= ddt.branch_name
				,@currency					= am.currency_code  
				,@client_name				= am.client_name
				,@agreement_no				= am.agreement_no
		from	dbo.write_off_main ddt 
				inner join agreement_main am on (am.agreement_no = ddt.agreement_no)
		where	code = @p_reff_code
				and ddt.wo_amount > 0
		
		set @transaction_name = 'WRITE OFF NO : ' + @p_reff_code + ' for AGREEMENT NO : ' + @agreement_no + ' - ' + @client_name

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
																		,@p_reff_source_name		= @transaction_name
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
					,wof.id
					,wom.agreement_no
			from	dbo.master_transaction_parameter mtp 
					left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
					left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
					left join dbo.write_off_transaction wof on (wof.transaction_code = mt.code)
					inner join dbo.write_off_main wom on (wom.code = wof.wo_code)
			where	mtp.process_code = 'wo'
			and		wom.code = @p_reff_code
			and		mtp.is_journal = '1'

			open c_jurnal
			fetch c_jurnal 
			into @sp_name
				,@debet_or_credit
				,@gl_link_code
				,@transaction_name
				,@invoice_detail_id
				,@agreement_detail_no

			while @@fetch_status = 0
			begin
			
					-- nilainya exec dari MASTER_TRANSACTION.sp_name
					exec @return_value = @sp_name @agreement_detail_no, @p_value_date ; -- sp ini mereturn value angka 

					if (isnull(@gl_link_code, '') = '')
					begin
						set @msg = 'Please Setting GL Link For ' + @transaction_name;
						raiserror(@msg, 16, -1);
					end

					if (@debet_or_credit ='DEBIT')
					begin
							set @orig_amount_db = @return_value
							set @orig_amount_cr = 0
					end
					else
					begin
							set @orig_amount_db = 0
							set @orig_amount_cr = @return_value
					end
					
						select	@agreement_branch_code = branch_code
								,@agreement_branch_name = branch_name
						from	dbo.agreement_main
						where	agreement_no = @agreement_detail_no ;
						
						exec dbo.xsp_opl_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code
																							 ,@p_branch_code				= @agreement_branch_code
																							 ,@p_branch_name				= @agreement_branch_name
																							 ,@p_gl_link_code				= @gl_link_code
																							 ,@p_agreement_no				= @agreement_detail_no
																							 ,@p_facility_code				= null
																							 ,@p_facility_name				= null
																							 ,@p_purpose_loan_code			= null
																							 ,@p_purpose_loan_name			= null
																							 ,@p_purpose_loan_detail_code	= null
																							 ,@p_purpose_loan_detail_name	= null
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
																							 ,@p_add_reff_01				= ''
																							 ,@p_add_reff_02				= ''
																							 ,@p_add_reff_03				= ''
																							 ,@p_remarks					= @transaction_name
																							 ,@p_cre_date					= @p_mod_date
																							 ,@p_cre_by						= @p_mod_by
																							 ,@p_cre_ip_address				= @p_mod_ip_address
																							 ,@p_mod_date					= @p_mod_date
																							 ,@p_mod_by						= @p_mod_by
																							 ,@p_mod_ip_address				= @p_mod_ip_address

					fetch c_jurnal 
					into @sp_name
						,@debet_or_credit
						,@gl_link_code
						,@transaction_name
						,@invoice_detail_id
						,@agreement_detail_no

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

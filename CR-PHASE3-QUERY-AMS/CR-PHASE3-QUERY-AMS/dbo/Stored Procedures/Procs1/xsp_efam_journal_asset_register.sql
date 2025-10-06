CREATE PROCEDURE dbo.xsp_efam_journal_asset_register
(
	@p_process_code		 nvarchar(50) --- code general subcode
	,@p_asset_no		 nvarchar(50) --- asset code
	,@p_branch_code		 nvarchar(50)
	,@p_company_code	 nvarchar(50)
	,@p_reff_source_no	 nvarchar(50)
	,@p_reff_source_name nvarchar(250)
	--,@p_orig_currency_code nvarchar(3) = 'idr' --- code currency
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@gllink_trx_code	nvarchar(50)
			,@branch_name		nvarchar(50)
			,@sp_name			nvarchar(250)
			,@debit_or_credit	nvarchar(50)
			,@gl_link_code		nvarchar(50)
			,@transaction_name	nvarchar(250)
			,@currency_code		nvarchar(3)	  = 'IDR'
			,@exch_rate			decimal(18, 2) = 1
			,@amount			decimal(18, 2)
			,@orig_amount_db	decimal(18, 2)
			,@orig_amount_cr	decimal(18, 2)
			,@base_amount		decimal(18, 2)
			,@base_amount_db	decimal(18, 2)
			,@base_amount_cr	decimal(18, 2)
			,@description		nvarchar(250)
			,@asset_name		nvarchar(250)
			,@x_code			nvarchar(50)
			,@reff_source_name	nvarchar(250)

	begin try
		select	@branch_name = branch_name
				,@asset_name = item_name
		from	dbo.asset
		where	code = @p_asset_no ;

		--- selecr to branch mutation
		select	@description = description
		from	dbo.sys_general_subcode
		where	code = @p_process_code ;

		set @reff_source_name = 'Asset for ' + @p_asset_no 
		exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output -- nvarchar(50)
																	   ,@p_company_code				= @p_company_code
																	   ,@p_branch_code				= @p_branch_code
																	   ,@p_branch_name				= @branch_name
																	   ,@p_transaction_status		= 'HOLD'
																	   ,@p_transaction_date			= @p_mod_date
																	   ,@p_transaction_value_date	= @p_mod_date
																	   ,@p_transaction_code			= @p_asset_no
																	   ,@p_transaction_name			= 'REGISTER ASSET'
																	   ,@p_reff_module_code			= 'IFINAMS'
																	   ,@p_reff_source_no			= @p_reff_source_no
																	   ,@p_reff_source_name			= @reff_source_name
																	   ,@p_transaction_type			= 'ASSET'
																	   ---
																	   ,@p_cre_date					= @p_mod_date	  
																	   ,@p_cre_by					= @p_mod_by		  
																	   ,@p_cre_ip_address			= @p_mod_ip_address
																	   ,@p_mod_date					= @p_mod_date	  
																	   ,@p_mod_by					= @p_mod_by		  
																	   ,@p_mod_ip_address			= @p_mod_ip_address

		declare c_inf_jour_gl cursor fast_forward for
		select	mt.sp_name
				,mtp.debet_or_credit
				,mtp.gl_link_code
				,mt.transaction_name + ' ' + @asset_name
		from	dbo.master_transaction_parameter mtp
				inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
														and mt.company_code = mtp.company_code
				inner join dbo.journal_gl_link jgl on jgl.code	= mtp.gl_link_code
		where	process_code		 = @p_process_code
				and mtp.company_code = @p_company_code ;

		open c_inf_jour_gl ;

		fetch c_inf_jour_gl
		into @sp_name
			 ,@debit_or_credit
			 ,@gl_link_code
			 ,@transaction_name ;

		while @@fetch_status = 0
		begin

			-- exec sp
			declare @myTampTable table
			(
				amount decimal(18, 2)
			) ;

			insert	@myTampTable
			(
				amount
			)
			exec @sp_name @p_company_code
						  ,@x_code
						  ,@p_asset_no ;

			select	@amount = amount
			from	@mytamptable ;

			-- get exch rate

			-- set debit credit base orig * exch
			set @base_amount = @amount * @exch_rate ;

			-- set debit credit
			if @debit_or_credit = 'DEBIT'
			begin
					
				set @orig_amount_db = @amount ;
				set @orig_amount_cr = 0 ;
				set @base_amount_db = @base_amount ;
				set @base_amount_cr = 0 ;
			end ;
			else
			begin
				set @orig_amount_db = 0 ;
				set @orig_amount_cr = @amount ;
				set @base_amount_db = 0 ;
				set @base_amount_cr = @base_amount ;
			end ;

	
					
			exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert	@p_gl_link_transaction_code		= @gllink_trx_code -- nvarchar(50)
																					,@p_company_code				= @p_company_code
																					,@p_branch_code					= @p_branch_code
																					,@p_branch_name					= @branch_name
																					,@p_gl_link_code				= @gl_link_code
																					,@p_agreement_no				= @p_asset_no
																					,@p_facility_code				= '' -- kosong
																					,@p_facility_name				= '' -- kosong
																					,@p_purpose_loan_code			= '' -- kosong
																					,@p_purpose_loan_name			= '' -- kosong
																					,@p_purpose_loan_detail_code	= '' -- kosong
																					,@p_purpose_loan_detail_name	= '' -- kosong
																					,@p_orig_currency_code			= @currency_code
																					,@p_orig_amount_db				= @orig_amount_db
																					,@p_orig_amount_cr				= @orig_amount_cr
																					,@p_exch_rate					= @exch_rate 
																					,@p_base_amount_db				= @base_amount_db
																					,@p_base_amount_cr				= @base_amount_cr
																					,@p_division_code				= '' -- kosong
																					,@p_division_name				= '' -- kosong
																					,@p_department_code				= '' -- kosong
																					,@p_department_name				= '' -- kosong
																					,@p_remarks						= @transaction_name
																					---
																					,@p_cre_date					= @p_mod_date	  
																					,@p_cre_by						= @p_mod_by		  
																					,@p_cre_ip_address				= @p_mod_ip_address
																					,@p_mod_date					= @p_mod_date	  
																					,@p_mod_by						= @p_mod_by		  
																					,@p_mod_ip_address				= @p_mod_ip_address

			delete @myTampTable ;

			fetch c_inf_jour_gl
			into @sp_name
				 ,@debit_or_credit
				 ,@gl_link_code
				 ,@transaction_name ;
		end ;

		close c_inf_jour_gl ;
		deallocate c_inf_jour_gl ;

		select	@orig_amount_db = sum(orig_amount_db) 
				,@orig_amount_cr = sum(orig_amount_cr) 
		from  dbo.efam_interface_journal_gl_link_transaction_detail
		where gl_link_transaction_code = @gl_link_code

		--+ validasi : total detail =  payment_amount yang di header
		if (@orig_amount_db <> @orig_amount_cr)
		begin
			set @msg = 'Journal does not balance';
			raiserror(@msg, 16, -1) ;
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
end ;

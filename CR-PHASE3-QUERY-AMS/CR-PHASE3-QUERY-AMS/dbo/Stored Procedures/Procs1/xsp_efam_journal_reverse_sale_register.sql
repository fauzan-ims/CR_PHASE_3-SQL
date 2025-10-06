CREATE PROCEDURE dbo.xsp_efam_journal_reverse_sale_register
(
	@p_reverse_sale_code nvarchar(50)
	,@p_process_code	 nvarchar(50) --- code general subcode
	,@p_company_code	 nvarchar(50)
	--,@p_orig_currency_code nvarchar(3)	= 'IDR' --- code currency
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg				   nvarchar(max)
			,@asset_code		   nvarchar(50)
			,@asset_name		   nvarchar(250)
			,@gllink_trx_code	   nvarchar(50)	  = ''
			,@branch_code		   nvarchar(50)
			,@branch_name		   nvarchar(250)
			,@payment_branch_code  nvarchar(50)
			,@payment_branch_name  nvarchar(250)
			,@payment_source	   nvarchar(50)
			,@to_bank_account_no   nvarchar(50)	  = ''
			,@to_bank_account_name nvarchar(250)  = ''
			,@to_bank_name		   nvarchar(250)  = ''
			,@sp_name			   nvarchar(250)
			,@debit_or_credit	   nvarchar(50)
			,@gl_link_code		   nvarchar(50)
			,@gl_link_name		   nvarchar(250)
			,@transaction_name	   nvarchar(250)
			,@currency_code		   nvarchar(3)	  = 'IDR'
			,@exch_rate			   decimal(18, 2) = 1
			,@sale_amount		   decimal(18, 2)
			,@amount			   decimal(18, 2) = 0
			,@orig_amount_db	   decimal(18, 2)
			,@orig_amount_cr	   decimal(18, 2)
			,@base_amount		   decimal(18, 2)
			,@base_amount_db	   decimal(18, 2)
			,@base_amount_cr	   decimal(18, 2)
			,@orig_amount		   decimal(18, 2)
			,@description		   nvarchar(250)
			,@id_sale_detail	   bigint
			,@trx_date			   datetime
			,@detail_desc		   nvarchar(250)
			,@x_code			   nvarchar(50)
			,@cost_center_code	   nvarchar(50)
			,@cost_center_name	   nvarchar(250)
			,@sale_code			   nvarchar(50) 
			,@last_jurnal_code		nvarchar(50);

	begin try

		--- select branch
		select	@branch_code = branch_code
				,@branch_name = branch_name
				,@sale_amount = sale_amount
				,@to_bank_account_no = isnull(to_bank_account_no,'')
				,@to_bank_account_name = isnull(to_bank_account_name,'') 
				,@to_bank_name = isnull(to_bank_name,'') 
				,@description = 'REVERSAL FIXED ASSET SALE '+remark
				,@trx_date = reverse_sale_date
				,@sale_code = sale_code
		from	dbo.reverse_sale
		where	code = @p_reverse_sale_code ;
		 
				 
		declare @myTampTable table
				(
					amount decimal(18, 2)
				) ;

		--exec dbo.xsp_efam_interface_payment_request_insert @p_code						= @gllink_trx_code output
		--												   ,@p_company_code				= @p_company_code
		--												   ,@p_branch_code				= @branch_code
		--												   ,@p_branch_name				= @branch_name
		--												   ,@p_payment_branch_code		= @payment_branch_code
		--												   ,@p_payment_branch_name		= @payment_branch_name
		--												   ,@p_payment_source			= @payment_source
		--												   ,@p_payment_request_date		= @trx_date
		--												   ,@p_payment_source_no		= @p_reverse_sale_code
		--												   ,@p_payment_status			= 'HOLD'
		--												   ,@p_payment_currency_code	= @currency_code
		--												   ,@p_payment_amount			= @sale_amount
		--												   ,@p_payment_remarks			= @description
		--												   ,@p_to_bank_account_name		= @to_bank_account_name
		--												   ,@p_to_bank_name				= @to_bank_name
		--												   ,@p_to_bank_account_no		= @to_bank_account_no
		--												   ,@p_tax_type					= null
		--												   ,@p_tax_file_no				= null
		--												   ,@p_tax_payer_reff_code		= null
		--												   ,@p_tax_file_name			= null
		--												   ,@p_process_date				= null
		--												   ,@p_process_reff_no			= null
		--												   ,@p_process_reff_name		= null
		--												   ,@p_settle_date				= null
		--												   ,@p_job_status				= 'HOLD'
		--												   ,@p_failed_remarks			= ''
		--												   ----
		--												   ,@p_cre_date					= @p_mod_date	  
		--												   ,@p_cre_by					= @p_mod_by		  
		--												   ,@p_cre_ip_address			= @p_mod_ip_address
		--												   ,@p_mod_date					= @p_mod_date	  
		--												   ,@p_mod_by					= @p_mod_by		  
		--												   ,@p_mod_ip_address			= @p_mod_ip_address


		exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																	   ,@p_company_code				= @p_company_code
																	   ,@p_branch_code				= @branch_code
																	   ,@p_branch_name				= @branch_name
																	   ,@p_transaction_status		= 'HOLD'
																	   ,@p_transaction_date			= @trx_date
																	   ,@p_transaction_value_date	= @trx_date
																	   ,@p_transaction_code			= @p_reverse_sale_code
																	   ,@p_transaction_name			= 'FA SELL'
																	   ,@p_reff_module_code			= 'EFAM'
																	   ,@p_reff_source_no			= @p_reverse_sale_code
																	   ,@p_reff_source_name			= @description
																	   ,@p_is_journal_reversal		= ''
																	   ,@p_transaction_type			= 'FAMRSL'
																	   ---
																	   ,@p_cre_date					= @p_mod_date	  
																	   ,@p_cre_by					= @p_mod_by		  
																	   ,@p_cre_ip_address			= @p_mod_ip_address
																	   ,@p_mod_date					= @p_mod_date	  
																	   ,@p_mod_by					= @p_mod_by		  
																	   ,@p_mod_ip_address			= @p_mod_ip_address
		

		
		--declare c_inf_jour_gl cursor fast_forward for
		--select	mt.sp_name
		--		,mtp.debet_or_credit
		--		,mtp.gl_link_code
		--		,mt.transaction_name
		--		,jgl.name
		--from	dbo.master_transaction_parameter mtp
		--		inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
		--												and mt.company_code = mtp.company_code
		--		inner join dbo.journal_gl_link jgl on jgl.code				= mtp.gl_link_code
		--where	process_code		 = @p_process_code
		--		and mtp.company_code = @p_company_code ;

		--open c_inf_jour_gl ;

		--fetch c_inf_jour_gl
		--into @sp_name
		--	 ,@debit_or_credit
		--	 ,@gl_link_code
		--	 ,@transaction_name
		--	 ,@gl_link_name ;

		--while @@fetch_status = 0
		--begin
		
			-- cursor assets
			declare c_reverse_sale_asset cursor fast_forward for
			select	id
					,asset_code
					,ast.item_name
					,asd.cost_center_code
					,asd.cost_center_name
			from	dbo.reverse_sale_detail asd
			inner	join dbo.asset ast on asd.asset_code = ast.code
			where	reverse_sale_code = @p_reverse_sale_code ;

			open c_reverse_sale_asset ;

			fetch c_reverse_sale_asset
			into @id_sale_detail
				 ,@asset_code 
				 ,@asset_name
				 ,@cost_center_code
				 ,@cost_center_name;

			while @@fetch_status = 0
			begin
				
				select	top 1
						@last_jurnal_code = hd.code
				from	efam_interface_journal_gl_link_transaction_detail dt
						inner join dbo.efam_interface_journal_gl_link_transaction hd on hd.code = dt.gl_link_transaction_code
				where	agreement_no = @asset_code
				and		hd.transaction_code = @sale_code
				order by hd.id desc

				insert into dbo.efam_interface_journal_gl_link_transaction_detail
				    (gl_link_transaction_code
				    ,company_code
				    ,branch_code
				    ,branch_name
				    ,cost_center_code
				    ,cost_center_name
				    ,gl_link_code
				    ,contra_gl_link_code
				    ,agreement_no
				    ,facility_code
				    ,facility_name
				    ,purpose_loan_code
				    ,purpose_loan_name
				    ,purpose_loan_detail_code
				    ,purpose_loan_detail_name
				    ,orig_currency_code
				    ,orig_amount_db
				    ,orig_amount_cr
				    ,exch_rate
				    ,base_amount_db
				    ,base_amount_cr
				    ,division_code
				    ,division_name
				    ,department_code
				    ,department_name
				    ,remarks
				    ,cre_date
				    ,cre_by
				    ,cre_ip_address
				    ,mod_date
				    ,mod_by
				    ,mod_ip_address
				    )
				select	@gllink_trx_code
						,dt.company_code
						,dt.branch_code
						,dt.branch_name
						,cost_center_code
						,cost_center_name
						,gl_link_code
						,contra_gl_link_code
						,agreement_no
						,facility_code
						,facility_name
						,purpose_loan_code
						,purpose_loan_name
						,purpose_loan_detail_code
						,purpose_loan_detail_name
						,orig_currency_code
						,orig_amount_cr
						,orig_amount_db
						,exch_rate
						,base_amount_cr
						,base_amount_db
						,division_code
						,division_name
						,department_code
						,department_name
						,'REVERSAL ' + remarks
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	efam_interface_journal_gl_link_transaction_detail dt
						inner join dbo.efam_interface_journal_gl_link_transaction hd on hd.code = dt.gl_link_transaction_code
				where	hd.code = @last_jurnal_code -- Arga 05-Nov-2022 ket : for case multiple reverse with the same asset (+)
				and		agreement_no = @asset_code -- Arga 12-Nov-2022 ket : for case partial reverse by asset (+)
				-- Arga 05-Nov-2022 ket : for case multiple reverse with the same asset (-)
				--where	agreement_no = @asset_code
				--and		hd.transaction_code = @sale_code

				--set @detail_desc = 'REVERSAL '+ @transaction_name +', ASSET NO '+@asset_code +' '+@asset_name
				
				--delete @myTampTable
				
				--insert into @myTampTable
				--(
				--    amount
				--)
				--exec @sp_name @p_company_code
				--			,@p_reverse_sale_code
				--			,@asset_code;

				--select	@amount = isnull(amount,0)
				--from	@mytamptable ;
				 
				--if @gl_link_code = 'PALS' -- untuk PNL masukkan ke credit jika 
				--begin
				--	if @amount < 0 -- (asset < harga jual minus)
				--	begin
				--		set @detail_desc = 'REVERSAL PROFIT ON SALE ' +', ASSET NO '+@asset_code +' '+@asset_name
				--		set @amount = abs(@amount);
				--	end;
				--	else
				--	begin
				--		set @detail_desc = 'REVERSAL LOSS ON SALE ' +', ASSET NO '+@asset_code +' '+@asset_name
				--		set @amount = abs(@amount) * -1
				--	end;
				--end;
				--else
				--begin
				--	if @debit_or_credit = 'CREDIT'
				--	begin
				--		set @amount = abs(@amount) * -1;

				--		set @base_amount = @amount * @exch_rate ;

				--		set @orig_amount_db = 0 ;
				--		set @orig_amount_cr = @amount ;
				--		set @base_amount_db = 0 ;
				--		set @base_amount_cr = @base_amount ;
				--	end;
				--	else
				--	begin
				--		set @amount = abs(@amount);

				--		set @base_amount = @amount * @exch_rate ;

				--		set @orig_amount_db = @amount ;
				--		set @orig_amount_cr = 0 ;
				--		set @base_amount_db = @base_amount ;
				--		set @base_amount_cr = 0 ;
				--	end;
				--end;
					 
				--if @gl_link_code = 'ASSET'
				--begin
				--	set @gl_link_code = dbo.xfn_get_gl_code_asset('', @asset_code, @p_company_code)
				--end
				--else if @gl_link_code = 'PALS'
				--begin
				--	set @gl_link_code = dbo.xfn_get_gl_code_pals('', @asset_code, @p_company_code)
				--end	
			
				--exec dbo.xsp_efam_interface_payment_request_detail_insert @p_payment_request_code		= @gllink_trx_code
				--														  ,@p_company_code				= @p_company_code
				--														  ,@p_branch_code				= @branch_code
				--														  ,@p_branch_name				= @branch_name
				--														  ,@p_gl_link_code				= @gl_link_code
				--														  ,@p_agreement_no				= '' -- kosong
				--														  ,@p_facility_code				= '' -- kosong
				--														  ,@p_facility_name				= '' -- kosong
				--														  ,@p_purpose_loan_code			= '' -- kosong
				--														  ,@p_purpose_loan_name			= '' -- kosong
				--														  ,@p_purpose_loan_detail_code	= '' -- kosong
				--														  ,@p_purpose_loan_detail_name	= '' -- kosong
				--														  ,@p_orig_currency_code		= @currency_code
				--														  ,@p_orig_amount				= @amount
				--														  ,@p_division_code				= '' -- kosong
				--														  ,@p_division_name				= '' -- kosong
				--														  ,@p_department_code			= '' -- kosong
				--														  ,@p_department_name			= '' -- kosong
				--														  ,@p_remarks					= @detail_desc
				--														  ----
				--														  ,@p_cre_date					= @p_mod_date	  
				--														  ,@p_cre_by					= @p_mod_by		  
				--														  ,@p_cre_ip_address			= @p_mod_ip_address
				--														  ,@p_mod_date					= @p_mod_date	  
				--														  ,@p_mod_by					= @p_mod_by		  
				--														  ,@p_mod_ip_address			= @p_mod_ip_address

				--exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code
				--																	  ,@p_company_code				= @p_company_code
				--																	  ,@p_branch_code				= @branch_code
				--																	  ,@p_branch_name				= @branch_name
				--																	  ,@p_cost_center_code			= @cost_center_code
				--																	  ,@p_cost_center_name			= @cost_center_name
				--																	  ,@p_gl_link_code				= @gl_link_code
				--																	  ,@p_agreement_no				= ''
				--																	  ,@p_facility_code				= ''
				--																	  ,@p_facility_name				= ''
				--																	  ,@p_purpose_loan_code			= ''
				--																	  ,@p_purpose_loan_name			= ''
				--																	  ,@p_purpose_loan_detail_code	= ''
				--																	  ,@p_purpose_loan_detail_name	= ''
				--																	  ,@p_orig_currency_code		= @currency_code
				--																	  ,@p_orig_amount_db			= @orig_amount_db
				--																	  ,@p_orig_amount_cr			= @orig_amount_cr
				--																	  ,@p_exch_rate					= @exch_rate 
				--																	  ,@p_base_amount_db			= @base_amount_db
				--																	  ,@p_base_amount_cr			= @base_amount_cr
				--																	  ,@p_division_code				= ''
				--																	  ,@p_division_name				= ''
				--																	  ,@p_department_code			= ''
				--																	  ,@p_department_name			= ''
				--																	  ,@p_remarks					= @detail_desc
				--																	  -----
				--																	  ,@p_cre_date					= @p_mod_date	  
				--																	  ,@p_cre_by					= @p_mod_by		  
				--																	  ,@p_cre_ip_address			= @p_mod_ip_address
				--																	  ,@p_mod_date					= @p_mod_date	  
				--																	  ,@p_mod_by					= @p_mod_by		  
				--																	  ,@p_mod_ip_address			= @p_mod_ip_address
				

				delete @myTampTable ;

				fetch c_reverse_sale_asset
				into @id_sale_detail
					 ,@asset_code
					 ,@asset_name
					 ,@cost_center_code
					 ,@cost_center_name;
			end ;

			close c_reverse_sale_asset ;
			deallocate c_reverse_sale_asset ;

		--	fetch c_inf_jour_gl
		--	into @sp_name
		--		 ,@debit_or_credit
		--		 ,@gl_link_code
		--		 ,@transaction_name
		--		 ,@gl_link_name ;
		--end ;

		--close c_inf_jour_gl ;
		--deallocate c_inf_jour_gl ;
		
		-- data validation
		if not exists (select 1 from dbo.efam_interface_journal_gl_link_transaction_detail where gl_link_transaction_code = @gllink_trx_code)
		begin
			delete dbo.efam_interface_journal_gl_link_transaction where code = @gllink_trx_code
		end
		else
		begin
			select @msg = dbo.xfn_journal_validation(@gllink_trx_code)
			if (@msg <> '')
			begin
				set @msg += '. Your Transaction Journal Number is ' + @gllink_trx_code
				raiserror(@msg, 16, -1) ;
			end
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

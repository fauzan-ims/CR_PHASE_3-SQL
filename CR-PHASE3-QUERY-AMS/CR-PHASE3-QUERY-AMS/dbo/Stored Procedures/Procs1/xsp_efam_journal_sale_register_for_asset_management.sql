CREATE PROCEDURE dbo.xsp_efam_journal_sale_register_for_asset_management
(
	@p_sale_code		nvarchar(50)
	,@p_process_code	nvarchar(50) --- code general subcode
	,@p_company_code	nvarchar(50)
	,@p_id				bigint
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@asset_code		nvarchar(50)
			,@asset_name		nvarchar(250)
			,@gllink_trx_code	nvarchar(50)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
			,@sp_name			nvarchar(250)
			,@debit_or_credit	nvarchar(50)
			,@gl_link_code		nvarchar(50)
			,@gl_link_name		nvarchar(250)
			,@transaction_name	nvarchar(250)
			,@currency_code		nvarchar(3)	  = 'IDR'
			,@exch_rate			decimal(18, 2) = 1
			,@sale_amount		decimal(18, 2)
			,@amount			decimal(18, 2)
			,@orig_amount_db	decimal(18, 2)
			,@orig_amount_cr	decimal(18, 2)
			,@base_amount		decimal(18, 2)
			,@base_amount_db	decimal(18, 2)
			,@base_amount_cr	decimal(18, 2)
			,@orig_amount		decimal(18, 2)
			,@description		nvarchar(250)
			,@detail_desc		nvarchar(250)
			,@id_sale_detail	bigint
			,@trx_date			datetime
			,@x_code			nvarchar(50)
			,@cost_center_code	nvarchar(50)
			,@cost_center_name	nvarchar(250) 
			,@buy_type			nvarchar(50) 
			,@validation_mssg	nvarchar(max)
			,@is_expense		int
			,@is_valid			int
			,@category_code		nvarchar(50)
			,@purchase_price	decimal(18,2) ;

	begin try
		declare @myTampTable table
				(
					amount decimal(18, 2)
				) ;

		--- select branch
		select @branch_code = branch_code
			 , @branch_name = branch_name
			 , @sale_amount = sale_amount
			 , @trx_date	= sale_date
			 , @description = 'FA SALE '+ REMARK
		from dbo.sale
		where code = @p_sale_code;

		--- select asset code
		select @asset_code			= asset_code
				,@purchase_price	= ass.purchase_price
				,@category_code		= ass.category_code
		from dbo.sale_detail sd
		left join dbo.asset ass on (ass.code = sd.asset_code)
		where id = @p_id

		exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																	   ,@p_company_code				= @p_company_code
																	   ,@p_branch_code				= @branch_code
																	   ,@p_branch_name				= @branch_name
																	   ,@p_transaction_status		= 'HOLD'
																	   ,@p_transaction_date			= @trx_date
																	   ,@p_transaction_value_date	= @trx_date
																	   ,@p_transaction_code			= @p_sale_code
																	   ,@p_transaction_name			= 'FA SELL'
																	   ,@p_reff_module_code			= 'EFAM'
																	   ,@p_reff_source_no			= @p_sale_code
																	   ,@p_reff_source_name			= @description
																	   ,@p_is_journal_reversal		= ''
																	   ,@p_transaction_type			= 'FAMSLE'
																	   ------
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
				,mt.transaction_name
				--,jgl.name
		from	dbo.master_transaction_parameter mtp
				inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code  --ket : for WOM (-)
		where	process_code		 = @p_process_code
				and mtp.company_code = @p_company_code 
		order by	mtp.order_key;
		open c_inf_jour_gl ;

		fetch c_inf_jour_gl
		into @sp_name
			 ,@debit_or_credit
			 ,@gl_link_code
			 ,@transaction_name
			 --,@gl_link_name ;

		while @@fetch_status = 0
		begin 
					-- Arga 22-Oct-2022 ket : additional control for WOM (+)
					select @is_valid = dbo.xfn_depre_threshold_validation(@p_company_code, @category_code, @purchase_price)

					if @is_valid = 1
					begin
						set @detail_desc = @transaction_name +', ASSET NO '+@asset_code +' '+@asset_name
						set @amount = 0 ;
					
						-- exec sp
						insert	@myTampTable
						(
							amount
						)
						exec @sp_name @p_company_code
										,@p_sale_code
										,@asset_code ;


						select	@amount = abs(amount)
						from	@mytamptable ;
			 
						set @amount = isnull(@amount,0) 
							if @debit_or_credit = 'CREDIT'
							begin
								set @amount = abs(@amount) --* -1;
								set @base_amount = @amount * @exch_rate ;

								set @orig_amount_db = 0 ;
								set @orig_amount_cr = @amount ;
								set @base_amount_db = 0 ;
								set @base_amount_cr = @base_amount ;
							end;
							else
							begin
								set @amount = abs(@amount);
								set @base_amount = @amount * @exch_rate ;

								set @orig_amount_db = @amount ;
								set @orig_amount_cr = 0 ;
								set @base_amount_db = @base_amount ;
								set @base_amount_cr = 0 ;
							end;
						--end;

					
						-- Trisna 24-Oct-2022 ket : auto get value from master category (+)
						select @gl_link_code = dbo.xfn_get_gl_code_from_category(@asset_code, @p_company_code, @gl_link_code)
					
						if @gl_link_code in ('DFASST','DFASIN','DFEXIN')
							select @gl_link_code = dbo.xfn_get_gl_code_from_item_grup_gl(@asset_code, @p_company_code, @gl_link_code)
					
						set @gl_link_code = isnull(@gl_link_code,'')

						select @is_expense = dbo.xfn_checking_gl_expense(@gl_link_code)	
						if @is_expense = 0
						begin
							exec dbo.xsp_get_cost_center_default @p_gl_link_code	 = @gl_link_code
																,@p_cost_center_code = @cost_center_code output
																,@p_cost_center_name = @cost_center_name output								
						end

						exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert	@p_gl_link_transaction_code		= @gllink_trx_code
																								,@p_company_code				= @p_company_code
																								,@p_branch_code					= @branch_code
																								,@p_branch_name					= @branch_name
																								,@p_cost_center_code			= @cost_center_code
																								,@p_cost_center_name			= @cost_center_name
																								,@p_gl_link_code				= @gl_link_code
																								,@p_agreement_no				= @asset_code
																								,@p_facility_code				= ''
																								,@p_facility_name				= ''
																								,@p_purpose_loan_code			= ''
																								,@p_purpose_loan_name			= ''
																								,@p_purpose_loan_detail_code	= ''
																								,@p_purpose_loan_detail_name	= ''
																								,@p_orig_currency_code			= @currency_code
																								,@p_orig_amount_db				= @orig_amount_db
																								,@p_orig_amount_cr				= @orig_amount_cr
																								,@p_exch_rate					= @exch_rate 
																								,@p_base_amount_db				= @base_amount_db
																								,@p_base_amount_cr				= @base_amount_cr
																								,@p_division_code				= ''
																								,@p_division_name				= ''
																								,@p_department_code				= ''
																								,@p_department_name				= ''
																								,@p_remarks						= @detail_desc
																								------
																								,@p_cre_date					= @p_mod_date	  
																								,@p_cre_by						= @p_mod_by		  
																								,@p_cre_ip_address				= @p_mod_ip_address
																								,@p_mod_date					= @p_mod_date	  
																								,@p_mod_by						= @p_mod_by		  
																								,@p_mod_ip_address				= @p_mod_ip_address
					
						delete @myTampTable ;
					end

				fetch c_inf_jour_gl
				into @sp_name
					 ,@debit_or_credit
					 ,@gl_link_code
					 ,@transaction_name 
		end ;

		close c_inf_jour_gl ;
		deallocate c_inf_jour_gl ;
				
		-- data validation
		if not exists (select 1 from dbo.efam_interface_journal_gl_link_transaction_detail where gl_link_transaction_code = @gllink_trx_code)
		begin
			delete dbo.efam_interface_journal_gl_link_transaction where code = @gllink_trx_code
		end
		else
		begin
			select @validation_mssg = dbo.xfn_journal_validation(@gllink_trx_code)
			set @validation_mssg += '. Nomor Jurnal Transaksi anda adalah ' + @gllink_trx_code
			if (@validation_mssg <> '')
			begin
				set @msg = @validation_mssg
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

CREATE PROCEDURE dbo.xsp_efam_journal_change_item_register
(
	@p_change_category_code nvarchar(50)
	,@p_process_code		nvarchar(50) --- code general subcode
	,@p_company_code		nvarchar(50)
	,@p_reff_source_no		nvarchar(50)
	,@p_reff_source_name	nvarchar(250)
	--,@p_orig_currency_code nvarchar(3)	= 'IDR' --- code currency
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@asset_code			nvarchar(50)
			,@asset_name			nvarchar(250)
			,@gllink_trx_code		nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@sp_name				nvarchar(250)
			,@debit_or_credit		nvarchar(50)
			,@gl_link_code			nvarchar(50)
			,@transaction_name		nvarchar(250)
			,@from_category_code	nvarchar(50)
			,@from_category_name	nvarchar(250)
			,@to_category_code		nvarchar(50)
			,@to_category_name		nvarchar(250)
			,@type_code				nvarchar(50)
			,@asset_category		nvarchar(250)
			,@currency_code			nvarchar(3)	= 'IDR'
			,@exch_rate				decimal(18, 2) = 1
			,@amount				decimal(18, 2)
			,@orig_amount_db		decimal(18, 2)
			,@orig_amount_cr		decimal(18, 2)
			,@base_amount			decimal(18, 2)
			,@base_amount_db		decimal(18, 2)
			,@base_amount_cr		decimal(18, 2)
			,@description			nvarchar(250)
			,@detail_desc			nvarchar(250)
			,@x_code				nvarchar(50)
			,@x_id					bigint
			,@item_code				nvarchar(50) 
			,@cost_center_code		nvarchar(50)
			,@cost_center_name		nvarchar(250)
			,@trx_cost_center_code	nvarchar(50)
			,@trx_cost_center_name	nvarchar(250)
			,@is_valid				int
			,@purchase_price		decimal(18,2)
			,@trx_date				datetime
			,@total_depre			decimal(18,2)
			,@to_item_code			nvarchar(50)
			,@is_expense			int ;

	begin try
	
		--- select branch
		select	@branch_code		 = ac.branch_code
				,@branch_name		 = ac.branch_name
				,@asset_code		 = ast.code
				,@from_category_code = ac.from_category_code
				--,@from_category_name = mcf.description
				,@to_category_code	 = ac.to_category_code
				--,@to_category_name	 = mct.description
				,@asset_name		 = ast.item_name
				,@cost_center_code	 = ac.cost_center_code
				,@cost_center_name	 = ac.cost_center_name
				,@trx_cost_center_code	 = ac.cost_center_code
				,@trx_cost_center_name	 = ac.cost_center_name
				,@purchase_price	 = ast.purchase_price
				,@trx_date			 = ac.date
				,@total_depre		 = ast.total_depre_comm
				,@asset_code		 = ast.code
				,@to_item_code		 = ac.to_item_code
		from	dbo.change_item_type	 ac
				inner join dbo.asset ast on ast.code = ac.asset_code collate Latin1_General_CI_AS 
		where	ac.code				 = @p_change_category_code ;
		
		-- ambil description - by @p_process_code
		select @description = description + ' ASSET NO '+ @asset_name
		from dbo.sys_general_subcode
		where code = @p_process_code;
		
		exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																	   ,@p_company_code				= @p_company_code
																	   ,@p_branch_code				= @branch_code
																	   ,@p_branch_name				= @branch_name
																	   ,@p_transaction_status		= 'HOLD'
																	   ,@p_transaction_date			= @trx_date
																	   ,@p_transaction_value_date	= @trx_date
																	   ,@p_transaction_code			= @p_change_category_code
																	   ,@p_transaction_name			= @description
																	   ,@p_reff_module_code			= 'EFAM'
																	   ,@p_reff_source_no			= @p_change_category_code
																	   ,@p_reff_source_name			= 'FIXED ASSET CHANGE ITEM TYPE'
																	   ,@p_transaction_type			= 'FAMCIT'
																	   ---
																	   ,@p_cre_date					= @p_mod_date	  
																	   ,@p_cre_by					= @p_mod_by		  
																	   ,@p_cre_ip_address			= @p_mod_ip_address
																	   ,@p_mod_date					= @p_mod_date	  
																	   ,@p_mod_by					= @p_mod_by		  
																	   ,@p_mod_ip_address			= @p_mod_ip_address
		
		if @p_process_code = 'CHITY'
		begin
			if @total_depre = 0
			begin
				declare c_inf_jour_gl cursor fast_forward for
				select	mt.sp_name
						,mtp.debet_or_credit
						,mtp.gl_link_code
						,mt.transaction_name
				from	dbo.master_transaction_parameter mtp
						inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
																and mt.company_code = mtp.company_code 
				where	process_code		 = @p_process_code
						and mtp.company_code = @p_company_code 
						and mtp.transaction_code in ('APAS','HPAS')
				order by mtp.order_key
			end
			else
			begin
				declare c_inf_jour_gl cursor fast_forward for
				select	mt.sp_name
						,mtp.debet_or_credit
						,mtp.gl_link_code
						,mt.transaction_name
				from	dbo.master_transaction_parameter mtp
						inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
																and mt.company_code = mtp.company_code 
				where	process_code		 = @p_process_code
						and mtp.company_code = @p_company_code 
				order by mtp.order_key
			end
		end
		else if @p_process_code = 'CHITYNN'
		begin
					
			declare c_inf_jour_gl cursor fast_forward for
			select	mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
			from	dbo.master_transaction_parameter mtp
					inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
															and mt.company_code = mtp.company_code 
			where	process_code		 = @p_process_code
					and mtp.company_code = @p_company_code 	
			order by mtp.order_key	    
		end

		open c_inf_jour_gl ;

		fetch c_inf_jour_gl
		into @sp_name
			 ,@debit_or_credit
			 ,@gl_link_code
			 ,@transaction_name ;

		while @@fetch_status = 0
		begin
		
			-- Arga 22-Oct-2022 ket : additional control for WOM (+)
			select @is_valid = dbo.xfn_depre_threshold_validation(@p_company_code, @to_category_code, @purchase_price)
			if @is_valid = 1
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
							  ,@asset_code ;

				select	@amount = amount
				from	@mytamptable ;

				set @amount = isnull(@amount,0)
				set @orig_amount_db = 0 ;
				set @orig_amount_cr = 0 ;
				set @base_amount_db = 0 ;
				set @base_amount_cr = 0 ;
				
				if @debit_or_credit = 'DEBIT'
				begin
					set @detail_desc = @transaction_name +' ' + @to_category_name
					set @orig_amount_db = @amount ;
					set @base_amount_db = @amount * @exch_rate  ;
					set @item_code = @to_category_code ;
				end ;
				else
				begin
					set @detail_desc = @transaction_name +' ' + @from_category_name
					set @orig_amount_cr = @amount ;
					set @base_amount_cr = @amount * @exch_rate  ;
					set @item_code = @from_category_code ;
				end ;
				set @gl_link_code = dbo.xfn_get_gl_code_asset(@item_code, '', @p_company_code)
				--end
				
				-- Arga 25-Oct-2022 ket : auto get value from master category (+)
				select @gl_link_code = dbo.xfn_get_gl_code_from_category(@asset_code, @p_company_code, @gl_link_code)

				if @gl_link_code in ('DFASST','DFASIN')
					select @gl_link_code = dbo.xfn_get_gl_code_from_item_grup_gl(@asset_code, @p_company_code, @gl_link_code)

				if @gl_link_code = 'DFEXIN'
				begin
					select @gl_link_code = dbo.xfn_get_gl_code_from_item_grup_gl(@to_item_code, @p_company_code, @gl_link_code)
				end
				
				set @gl_link_code = isnull(@gl_link_code,'')
						
				select @is_expense = dbo.xfn_checking_gl_expense(@gl_link_code)	
				
				if @is_expense = 0
				begin
					exec dbo.xsp_get_cost_center_default @p_gl_link_code	 = @gl_link_code
					                                    ,@p_cost_center_code = @cost_center_code output
					                                    ,@p_cost_center_name = @cost_center_name output								
				end
				else
				begin
				    select @cost_center_code = @trx_cost_center_code
							,@cost_center_name = @trx_cost_center_name
				end

				exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code -- nvarchar(50)
																					  ,@p_company_code				= @p_company_code
																					  ,@p_branch_code				= @branch_code
																					  ,@p_branch_name				= @branch_name
																					  ,@p_cost_center_code			= @cost_center_code
																					  ,@p_cost_center_name			= @cost_center_name
																					  ,@p_gl_link_code				= @gl_link_code
																					  ,@p_agreement_no				= @asset_code
																					  ,@p_facility_code				= '' -- kosong
																					  ,@p_facility_name				= '' -- kosong
																					  ,@p_purpose_loan_code			= '' -- kosong
																					  ,@p_purpose_loan_name			= '' -- kosong
																					  ,@p_purpose_loan_detail_code	= '' -- kosong
																					  ,@p_purpose_loan_detail_name	= '' -- kosong
																					  ,@p_orig_currency_code		= @currency_code
																					  ,@p_orig_amount_db			= @orig_amount_db
																					  ,@p_orig_amount_cr			= @orig_amount_cr
																					  ,@p_exch_rate					= @exch_rate 
																					  ,@p_base_amount_db			= @base_amount_db
																					  ,@p_base_amount_cr			= @base_amount_cr
																					  ,@p_division_code				= '' -- kosong
																					  ,@p_division_name				= '' -- kosong
																					  ,@p_department_code			= '' -- kosong
																					  ,@p_department_name			= '' -- kosong
																					  ,@p_remarks					= @detail_desc
																					  ---
																					  ,@p_cre_date					= @p_mod_date	  
																					  ,@p_cre_by					= @p_mod_by		  
																					  ,@p_cre_ip_address			= @p_mod_ip_address
																					  ,@p_mod_date					= @p_mod_date	  
																					  ,@p_mod_by					= @p_mod_by		  
																					  ,@p_mod_ip_address			= @p_mod_ip_address
				delete @myTampTable ;
			end

			fetch c_inf_jour_gl
			into @sp_name
				 ,@debit_or_credit
				 ,@gl_link_code
				 ,@transaction_name ;
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
			select @msg = dbo.xfn_journal_validation(@gllink_trx_code)
			if (@msg <> '')
			begin
				set @msg += '. Nomor Jurnal Transaksi anda adalah ' + @gllink_trx_code
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

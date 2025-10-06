CREATE PROCEDURE dbo.xsp_efam_journal_adjusment_register
(
	@p_adjusment_code	 nvarchar(50)
	,@p_process_code	 nvarchar(50) --- code general subcode
	,@p_company_code	 nvarchar(50)
	,@p_reff_source_no	 nvarchar(50)
	,@p_reff_source_name nvarchar(250)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
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
			,@currency_code			nvarchar(3)	= 'IDR'
			,@exch_rate				decimal(18, 2) = 1
			,@amount				decimal(18, 2)
			,@orig_amount_db		decimal(18, 2)
			,@orig_amount_cr		decimal(18, 2)
			,@base_amount_db		decimal(18, 2)
			,@base_amount_cr		decimal(18, 2)
			,@description			nvarchar(250)
			,@transaction_date		datetime
			,@company_code			nvarchar(50) = @p_company_code
			,@category_code			nvarchar(50)
			,@purchase_price		decimal(18,2)
			,@is_valid				int
			,@trx_cost_center_code	nvarchar(50)
			,@trx_cost_center_name	nvarchar(250)
			,@cost_center_code		nvarchar(50)
			,@cost_center_name		nvarchar(250)
			,@is_expense			int 
			,@trx_code				nvarchar(50)
			,@order_key				int
			,@total_adjustment		decimal(18,2)
			,@reff_source_name		nvarchar(250)

	begin try
	
		--- select branch
		select @asset_code				= asset_code
			 , @transaction_date		= date
			 , @company_code			= company_code
			 ,@total_adjustment			= total_adjustment
		from dbo.adjustment
		where code = @p_adjusment_code
			  and company_code = @p_company_code;

		select @branch_code = branch_code
			 , @branch_name = branch_name
			 , @asset_name	= item_name
			 , @category_code = category_code
			 , @purchase_price = purchase_price
		from dbo.asset
		where code = @asset_code;
		
		-- ambil description - by @p_process_code
		select	@description = description + ' FOR ASET NO ' + @asset_code
		from	dbo.sys_general_subcode
		where	code = @p_process_code ;
		
		set @reff_source_name = 'Adjustment asset for ' + @p_adjusment_code
		exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																	   ,@p_company_code				= @p_company_code
																	   ,@p_branch_code				= @branch_code
																	   ,@p_branch_name				= @branch_name
																	   ,@p_transaction_status		= 'HOLD'
																	   ,@p_transaction_date			= @transaction_date
																	   ,@p_transaction_value_date	= @transaction_date
																	   ,@p_transaction_code			= @p_adjusment_code
																	   ,@p_transaction_name			= 'ADJUSTMENT ASSET'
																	   ,@p_reff_module_code			= 'IFINAMS'
																	   ,@p_reff_source_no			= @p_adjusment_code
																	   ,@p_reff_source_name			= @reff_source_name
																	   ,@p_transaction_type			= 'FAMADJ'
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
				,mt.transaction_name + ', ASET NO '+ @asset_code +' '+ @asset_name
				,mtp.transaction_code
				,mtp.order_key
		from	dbo.master_transaction_parameter mtp
				inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
														and mt.company_code = mtp.company_code
		where	process_code		 = @p_process_code
				and mtp.company_code = @p_company_code 
		order by mtp.order_key;

		open c_inf_jour_gl ;

		fetch c_inf_jour_gl
		into @sp_name
			 ,@debit_or_credit
			 ,@gl_link_code
			 ,@transaction_name
			 ,@trx_code
			 ,@order_key ;

		while @@fetch_status = 0
		begin
			
			-- Arga 22-Oct-2022 ket : additional control for WOM (+)
			select @is_valid = dbo.xfn_depre_threshold_validation(@company_code, @category_code, @purchase_price)
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
							  ,@p_adjusment_code
							  ,@asset_code ;

				select	@amount = isnull(amount,0)
				from	@mytamptable ;
				
				if @trx_code = 'BJA'
				begin
				    insert	@myTampTable
					(
						amount
					)
					exec @sp_name @p_company_code
								  ,@gllink_trx_code
								  ,@asset_code ;

					select	@amount = isnull(amount,0)
					from	@mytamptable ;
				end
				
				-- Arga 10-Nov-2022 ket : new condition based on discuss with zaka wom (same item with sp post) (-/+)
				if @total_adjustment < 0 and @amount < 0
				begin
					if @p_process_code = 'ADJPNM'
						set @amount = @amount
					else if @p_process_code = 'ADJMD'
						set @amount = abs(@amount)
				end
				else
					set @amount = abs(@amount)

				set @orig_amount_db = 0;
				set @orig_amount_cr = 0;
				set @base_amount_db = 0;
				set @base_amount_cr = 0;

				if (@amount > 0) -- kondisi normal ( adjustment positif)
				begin
					if @debit_or_credit = 'DEBIT'
					begin
						set @orig_amount_db = @amount;
						set @base_amount_db = @amount * @exch_rate;
					end;
					else
					begin
						set @orig_amount_cr = @amount;
						set @base_amount_cr = @amount * @exch_rate;
					end;
				end;
				else -- kondisi kurang ( adjustment negatif) -- debit credit nya di balik
				begin
					set @amount  = abs(@amount)
					if @debit_or_credit = 'DEBIT'
					begin
						set @orig_amount_cr = @amount;
						set @base_amount_cr = @amount * @exch_rate;
					end;
					else
					begin
						set @orig_amount_db = @amount;
						set @base_amount_db = @amount * @exch_rate;
					end;

				end
				
				-- Arga 25-Oct-2022 ket : auto get value from master category (+)
				select @gl_link_code = dbo.xfn_get_gl_code_from_category(@asset_code, @p_company_code, @gl_link_code)

				if @gl_link_code in ('DFASST','DFASIN')
					select @gl_link_code = dbo.xfn_get_gl_code_from_item_grup_gl(@asset_code, @p_company_code, @gl_link_code)

				--if @gl_link_code = 'DFEXIN'
				--begin
				--	select @gl_link_code = dbo.xfn_get_gl_code_from_item_grup_gl(@to_item_code, @p_company_code, @gl_link_code)
				--end
				
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
																					  ,@p_facility_code				= @order_key--'' -- kosong
																					  ,@p_facility_name				= @p_process_code--'' -- kosong
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
																					  ,@p_remarks					= @description
																					  ---
																					  ,@p_cre_date					= @p_mod_date	  
																					  ,@p_cre_by					= @p_mod_by		  
																					  ,@p_cre_ip_address			= @p_mod_ip_address
																					  ,@p_mod_date					= @p_mod_date	  
																					  ,@p_mod_by					= @p_mod_by		  
																					  ,@p_mod_ip_address			= @p_mod_ip_address
				delete @myTampTable ;
			end ;

			fetch c_inf_jour_gl
			into @sp_name
				,@debit_or_credit
				,@gl_link_code
				,@transaction_name
				,@trx_code
				,@order_key ;

		end
		
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


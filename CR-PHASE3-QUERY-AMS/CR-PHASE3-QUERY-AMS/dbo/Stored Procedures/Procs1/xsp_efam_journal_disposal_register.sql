CREATE PROCEDURE dbo.xsp_efam_journal_disposal_register
(
	@p_disposal_code	 nvarchar(50)
	,@p_process_code	 nvarchar(50) --- code general subcode
	,@p_company_code	 nvarchar(50)
	,@p_reff_source_no	 nvarchar(50)
	,@p_reff_source_name nvarchar(250)
	--,@p_orig_currency_code nvarchar(3)	= 'IDR' --- code currency
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@asset_code		nvarchar(50)
			,@gllink_trx_code	nvarchar(50)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
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
			,@disposal_date		datetime
			,@asset_name		nvarchar(250)
			,@detail_remark		nvarchar(250)
			,@disposal_remark	nvarchar(250)
			,@x_code			nvarchar(50) 
			,@cost_center_code	nvarchar(50)
			,@cost_center_name	nvarchar(250)
			,@is_valid			int
			,@company_code		nvarchar(50)
			,@category_code		nvarchar(50)
			,@purchase_price	decimal(18,2)
			,@validation_mssg	nvarchar(max)
			,@is_expense		int
			,@reff_source_name	nvarchar(250)
			,@branch_code_asset	nvarchar(50)
			,@branch_name_asset	nvarchar(250)


	begin try
	
		--- select branch
		select	@branch_code = branch_code
				,@branch_name = branch_name
				,@disposal_date = disposal_date
				,@company_code	= company_code
		from	dbo.disposal
		where	code = @p_disposal_code ;

		-- ambil description - by @p_process_code
		select	@description = description
		from	dbo.sys_general_subcode
		where	code = @p_process_code ;


		declare curr_branch_asset cursor fast_forward read_only for
		select ass.branch_code
				,ass.branch_name
		from dbo.disposal_detail dd
		inner join dbo.asset ass on (ass.code = dd.asset_code)
		where dd.disposal_code = @p_disposal_code
		group by ass.branch_code
		, ass.branch_name
		
		open curr_branch_asset
		
		fetch next from curr_branch_asset 
		into @branch_code_asset
			,@branch_name_asset
		
		while @@fetch_status = 0
		begin
		    set @reff_source_name = 'Disposed asset ' + @p_disposal_code
			exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																			,@p_company_code			= @p_company_code
																			,@p_branch_code				= @branch_code_asset
																			,@p_branch_name				= @branch_name_asset
																			,@p_transaction_status		= 'HOLD'
																			,@p_transaction_date		= @disposal_date
																			,@p_transaction_value_date	= @disposal_date
																			,@p_transaction_code		= @p_disposal_code
																			,@p_transaction_name		= 'DISPOSED ASSET'
																			,@p_reff_module_code		= 'IFINAMS'
																			,@p_reff_source_no			= @p_disposal_code
																			,@p_reff_source_name		= @reff_source_name
																			,@p_transaction_type		= 'FAMDSP'
																			---
																			,@p_cre_date				= @p_mod_date	  
																			,@p_cre_by					= @p_mod_by		  
																			,@p_cre_ip_address			= @p_mod_ip_address
																			,@p_mod_date				= @p_mod_date	  
																			,@p_mod_by					= @p_mod_by		  
																			,@p_mod_ip_address			= @p_mod_ip_address

			--declare curr_disposed_detail cursor fast_forward read_only for
			--select dd.id
			--from dbo.disposal_detail dd
			--inner join dbo.asset ass on (ass.code = dd.asset_code)
			--where dd.disposal_code = @p_disposal_code
			--and ass.branch_code = @branch_code_asset
						
			--open curr_disposed_detail
			
			--fetch next from curr_disposed_detail 
			--into @variable
			
			--while @@fetch_status = 0
			--begin
			    		
			--    fetch next from curr_disposed_detail 
			--	into @variable
			--end
			
			--close curr_disposed_detail
			--deallocate curr_disposed_detail

			set @validation_mssg = ''

			declare c_inf_jour_gl cursor fast_forward for
			select	mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
			from	dbo.master_transaction_parameter mtp
					inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
															and mt.company_code = mtp.company_code
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
						
				-- cursor assets
				declare c_disposal_asset cursor fast_forward for
				select	asset_code
						,ast.item_name
						,dd.description
						,dd.cost_center_code
						,dd.cost_center_name
						,ast.category_code
						,ast.purchase_price
						,ast.branch_code
						,ast.branch_name
				from	dbo.disposal_detail dd
						inner join dbo.asset ast on ast.code = dd.asset_code
				where	disposal_code = @p_disposal_code
				and ast.BRANCH_CODE = @branch_code_asset

				open c_disposal_asset ;

				fetch c_disposal_asset
				into @asset_code
					,@asset_name
					,@disposal_remark 
					,@cost_center_code
					,@cost_center_name
					,@category_code
					,@purchase_price
					,@branch_code
					,@branch_name

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
										,@x_code
										,@asset_code ;

						select	@amount = amount
						from	@mytamptable ;
						
						set @amount = isnull(@amount,0)

						-- get exch rate

						-- set debit credit base orig * exch
						set @base_amount = @amount * @exch_rate ;

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

				
						--if @gl_link_code = 'ASSET'
						--begin
						--	set @gl_link_code = dbo.xfn_get_gl_code_asset('', @asset_code, @p_company_code)
						--end

						set @detail_remark  = 'DISPOSAL '+ @transaction_name + ' - ASSET NO ' +@asset_code +' '+@asset_name +' ' +@disposal_remark ;
						
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


						exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @gllink_trx_code -- nvarchar(50)
																								,@p_company_code				= @p_company_code
																								,@p_branch_code					= @branch_code
																								,@p_branch_name					= @branch_name
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
																								,@p_remarks						= @detail_remark
																								---
																								,@p_cre_date					= @p_mod_date	  
																								,@p_cre_by						= @p_mod_by		  
																								,@p_cre_ip_address				= @p_mod_ip_address
																								,@p_mod_date					= @p_mod_date	  
																								,@p_mod_by						= @p_mod_by		  
																								,@p_mod_ip_address				= @p_mod_ip_address
						delete @myTampTable ;
					end

					fetch c_disposal_asset
					into @asset_code
						,@asset_name
						,@disposal_remark 
						,@cost_center_code
						,@cost_center_name
						,@category_code
						,@purchase_price
						,@branch_code
						,@branch_name
				end ;

				close c_disposal_asset ;
				deallocate c_disposal_asset ;

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
			where gl_link_transaction_code = @gllink_trx_code

			--+ validasi : total detail =  payment_amount yang di header
			if (@orig_amount_db <> @orig_amount_cr)
			begin
				set @msg = 'Journal does not balance';
				raiserror(@msg, 16, -1) ;
			end	

		    fetch next from curr_branch_asset 
			into @branch_code_asset
				,@branch_name_asset
		end
		
		close curr_branch_asset
		deallocate curr_branch_asset
		
		
		
		--set @validation_mssg = ''

		--declare c_inf_jour_gl cursor fast_forward for
		--select	mt.sp_name
		--		,mtp.debet_or_credit
		--		,mtp.gl_link_code
		--		,mt.transaction_name
		--from	dbo.master_transaction_parameter mtp
		--		inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
		--												and mt.company_code = mtp.company_code
		--where	process_code		 = @p_process_code
		--		and mtp.company_code = @p_company_code ;

		--open c_inf_jour_gl ;

		--fetch c_inf_jour_gl
		--into @sp_name
		--		,@debit_or_credit
		--		,@gl_link_code
		--		,@transaction_name ;

		--while @@fetch_status = 0
		--begin
					
		--	-- cursor assets
		--	declare c_disposal_asset cursor fast_forward for
		--	select	asset_code
		--			,ast.item_name
		--			,dd.description
		--			,dd.cost_center_code
		--			,dd.cost_center_name
		--			,ast.category_code
		--			,ast.purchase_price
		--			,ast.branch_code
		--			,ast.branch_name
		--	from	dbo.disposal_detail dd
		--			inner join dbo.asset ast on ast.code = dd.asset_code
		--	where	disposal_code = @p_disposal_code 

		--	open c_disposal_asset ;

		--	fetch c_disposal_asset
		--	into @asset_code
		--		,@asset_name
		--		,@disposal_remark 
		--		,@cost_center_code
		--		,@cost_center_name
		--		,@category_code
		--		,@purchase_price
		--		,@branch_code
		--		,@branch_name

		--	while @@fetch_status = 0
		--	begin
			
		--		-- Arga 22-Oct-2022 ket : additional control for WOM (+)
		--		select @is_valid = dbo.xfn_depre_threshold_validation(@company_code, @category_code, @purchase_price)
				
		--		if @is_valid = 1
		--		begin
		--			-- exec sp
		--			declare @myTampTable table
		--			(
		--				amount decimal(18, 2)
		--			) ;

		--			insert	@myTampTable
		--			(
		--				amount
		--			)
		--			exec @sp_name @p_company_code
		--							,@x_code
		--							,@asset_code ;

		--			select	@amount = amount
		--			from	@mytamptable ;
					
		--			set @amount = isnull(@amount,0)

		--			-- get exch rate

		--			-- set debit credit base orig * exch
		--			set @base_amount = @amount * @exch_rate ;

		--			if @debit_or_credit = 'DEBIT'
		--			begin
		--				set @orig_amount_db = @amount ;
		--				set @orig_amount_cr = 0 ;
		--				set @base_amount_db = @base_amount ;
		--				set @base_amount_cr = 0 ;
		--			end ;
		--			else
		--			begin
		--				set @orig_amount_db = 0 ;
		--				set @orig_amount_cr = @amount ;
		--				set @base_amount_db = 0 ;
		--				set @base_amount_cr = @base_amount ;
		--			end ;

			
		--			--if @gl_link_code = 'ASSET'
		--			--begin
		--			--	set @gl_link_code = dbo.xfn_get_gl_code_asset('', @asset_code, @p_company_code)
		--			--end

		--			set @detail_remark  = 'DISPOSAL '+ @transaction_name + ' - ASSET NO ' +@asset_code +' '+@asset_name +' ' +@disposal_remark ;
					
		--			-- Trisna 24-Oct-2022 ket : auto get value from master category (+)
		--			select @gl_link_code = dbo.xfn_get_gl_code_from_category(@asset_code, @p_company_code, @gl_link_code)
					
		--			if @gl_link_code in ('DFASST','DFASIN','DFEXIN')
		--				select @gl_link_code = dbo.xfn_get_gl_code_from_item_grup_gl(@asset_code, @p_company_code, @gl_link_code)
						
		--			set @gl_link_code = isnull(@gl_link_code,'')

		--			select @is_expense = dbo.xfn_checking_gl_expense(@gl_link_code)	
		--			if @is_expense = 0
		--			begin
		--			    exec dbo.xsp_get_cost_center_default @p_gl_link_code	 = @gl_link_code
		--			                                        ,@p_cost_center_code = @cost_center_code output
		--			                                        ,@p_cost_center_name = @cost_center_name output								
		--			end


		--			exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @gllink_trx_code -- nvarchar(50)
		--																					,@p_company_code				= @p_company_code
		--																					,@p_branch_code					= @branch_code
		--																					,@p_branch_name					= @branch_name
		--																					,@p_cost_center_code			= @cost_center_code
		--																					,@p_cost_center_name			= @cost_center_name
		--																					,@p_gl_link_code				= @gl_link_code
		--																					,@p_agreement_no				= @asset_code
		--																					,@p_facility_code				= '' -- kosong
		--																					,@p_facility_name				= '' -- kosong
		--																					,@p_purpose_loan_code			= '' -- kosong
		--																					,@p_purpose_loan_name			= '' -- kosong
		--																					,@p_purpose_loan_detail_code	= '' -- kosong
		--																					,@p_purpose_loan_detail_name	= '' -- kosong
		--																					,@p_orig_currency_code			= @currency_code
		--																					,@p_orig_amount_db				= @orig_amount_db
		--																					,@p_orig_amount_cr				= @orig_amount_cr
		--																					,@p_exch_rate					= @exch_rate 
		--																					,@p_base_amount_db				= @base_amount_db
		--																					,@p_base_amount_cr				= @base_amount_cr
		--																					,@p_division_code				= '' -- kosong
		--																					,@p_division_name				= '' -- kosong
		--																					,@p_department_code				= '' -- kosong
		--																					,@p_department_name				= '' -- kosong
		--																					,@p_remarks						= @detail_remark
		--																					---
		--																					,@p_cre_date					= @p_mod_date	  
		--																					,@p_cre_by						= @p_mod_by		  
		--																					,@p_cre_ip_address				= @p_mod_ip_address
		--																					,@p_mod_date					= @p_mod_date	  
		--																					,@p_mod_by						= @p_mod_by		  
		--																					,@p_mod_ip_address				= @p_mod_ip_address
		--			delete @myTampTable ;
		--		end

		--		fetch c_disposal_asset
		--		into @asset_code
		--			,@asset_name
		--			,@disposal_remark 
		--			,@cost_center_code
		--			,@cost_center_name
		--			,@category_code
		--			,@purchase_price
		--			,@branch_code
		--			,@branch_name
		--	end ;

		--	close c_disposal_asset ;
		--	deallocate c_disposal_asset ;

		--	fetch c_inf_jour_gl
		--	into @sp_name
		--			,@debit_or_credit
		--			,@gl_link_code
		--			,@transaction_name ;
		--end ;

		--close c_inf_jour_gl ;
		--deallocate c_inf_jour_gl ;
		
		--select	@orig_amount_db = sum(orig_amount_db) 
		--		,@orig_amount_cr = sum(orig_amount_cr) 
		--from  dbo.efam_interface_journal_gl_link_transaction_detail
		--where gl_link_transaction_code = @gl_link_code

		----+ validasi : total detail =  payment_amount yang di header
		--if (@orig_amount_db <> @orig_amount_cr)
		--begin
		--	set @msg = 'Journal does not balance';
		--	raiserror(@msg, 16, -1) ;
		--end	

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



CREATE PROCEDURE dbo.xsp_efam_journal_mutation_register
(
	@p_mutation_code	 nvarchar(50)
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
	declare @msg					nvarchar(max)
			,@asset_code			nvarchar(50)
			,@gllink_trx_code		nvarchar(50)
			,@from_branch_code		nvarchar(50)
			,@to_branch_code		nvarchar(50)
			,@from_branch_name		nvarchar(250)
			,@to_branch_name		nvarchar(250)
			,@to_division_code		nvarchar(50)
			,@to_division_name		nvarchar(250)
			,@to_department_code	nvarchar(50)
			,@to_department_name	nvarchar(250)
			,@from_division_code	nvarchar(50)
			,@from_division_name	nvarchar(250)
			,@from_department_code	nvarchar(50)
			,@from_department_name	nvarchar(250)
			,@sp_name				nvarchar(250)
			,@debit_or_credit		nvarchar(50)
			,@gl_link_code			nvarchar(50)
			,@transaction_name		nvarchar(250)
			,@remark_detail			nvarchar(250)
			,@currency_code			nvarchar(3)	  = 'IDR'
			,@exch_rate				decimal(18, 2) = 1
			,@amount				decimal(18, 2)
			,@base_amount			decimal(18, 2)
			,@orig_amount_db		decimal(18, 2)
			,@orig_amount_cr		decimal(18, 2)
			,@base_amount_db		decimal(18, 2)
			,@base_amount_cr		decimal(18, 2)
			,@description			nvarchar(250)
			,@asset_name			nvarchar(250)
			,@x_code				nvarchar(50) 
			,@cost_center_code		nvarchar(50)
			,@cost_center_name		nvarchar(250) 
			,@gl_link_name			nvarchar(250)
			,@trx_date				datetime 
			,@is_expense			int;

	begin try
	
		--- select branch mutation
		select	@from_branch_code		= from_branch_code
				,@from_branch_name		= from_branch_name
				,@from_division_code	= from_division_code
				,@from_division_name	= from_division_name
				,@from_department_code	= from_department_code
				,@from_department_name	= from_department_name
				,@to_branch_code		= to_branch_code
				,@to_branch_name		= to_branch_name
				,@to_division_code		= to_division_code
				,@to_division_name		= to_division_name
				,@to_department_code	= to_department_code
				,@to_department_name	= to_department_name
				--,@trx_date				= md.receive_date
				,@trx_date				= dbo.xfn_get_system_date() -- Arga 02-Nov-2022 ket : ganti tggl sistem for UAT (-/+) --getdate()
		from	dbo.mutation mt
			inner join dbo.mutation_detail md on md.mutation_code = mt.code
		where	code = @p_mutation_code 
		--and		md.asset_code = @p_reff_source_no; -- jurnal at received by asset (??? ini buat apa ??? soalnya reff_source_no selalu kosong dari sp mutation_recived)
		
		-- ambil description - by @p_process_code
		select	@description = description + ' FROM ' + @from_branch_name + ' TO ' + @to_branch_name
		from	dbo.sys_general_subcode
		where	code = @p_process_code ;
		
		exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																	   ,@p_company_code				= @p_company_code
																	   ,@p_branch_code				= @from_branch_code
																	   ,@p_branch_name				= @from_branch_name
																	   ,@p_transaction_status		= 'HOLD'
																	   ,@p_transaction_date			= @trx_date
																	   ,@p_transaction_value_date	= @trx_date
																	   ,@p_transaction_code			= @p_mutation_code
																	   ,@p_transaction_name			= 'FA MUTATION'
																	   ,@p_reff_module_code			= 'EFAM'
																	   ,@p_reff_source_no			= @p_mutation_code
																	   ,@p_reff_source_name			= @description
																	   ,@p_transaction_type			= 'FAMMTT'
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
				,mt.transaction_name
				,jgl.name
		from	dbo.master_transaction_parameter mtp
				inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
														and mt.company_code = mtp.company_code
				inner join dbo.journal_gl_link jgl on jgl.code				= mtp.gl_link_code
		where	process_code		 = @p_process_code
				and mtp.company_code = @p_company_code ;

		open c_inf_jour_gl ;

		fetch c_inf_jour_gl
		into @sp_name
			 ,@debit_or_credit
			 ,@gl_link_code
			 ,@transaction_name 
			 ,@gl_link_name ;

		while @@fetch_status = 0
		begin
		
			-- cursor assets mutation
			declare c_mutation_asset cursor fast_forward for
			select	asset_code
					,ast.item_name
					,md.cost_center_code
					,md.cost_center_name
			from	dbo.mutation_detail md
					inner join dbo.asset ast on (md.asset_code = ast.code)
			where	mutation_code = @p_mutation_code
			and		md.asset_code = @p_reff_source_no; -- jurnal at received by asset

			open c_mutation_asset ;

			fetch c_mutation_asset
			into @asset_code
				 ,@asset_name 
				 ,@cost_center_code
				 ,@cost_center_name ;

			while @@fetch_status = 0
			begin

				-- if asset . get real gl link category

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

				set @remark_detail = 'RECEIVE MUTATION ASSET : ' + @asset_code + ' FROM ' + @from_branch_name + ' - ' + @transaction_name + ' ' + @asset_name ;
				-- get exch rate

				-- set debit credit base orig * exch
				set @base_amount = @amount * @exch_rate ;

				-- source
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

				exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code
																					 ,@p_company_code				= @p_company_code
																					 ,@p_branch_code				= @from_branch_code
																					 ,@p_branch_name				= @from_branch_name
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
																					 ,@p_orig_amount_db				= @orig_amount_db --@amount -- decimal(18, 2)
																					 ,@p_orig_amount_cr				= @orig_amount_cr -- decimal(18, 2)
																					 ,@p_exch_rate					= @exch_rate
																					 ,@p_base_amount_db				= @base_amount_db -- decimal(18, 2)
																					 ,@p_base_amount_cr				= @base_amount_cr -- decimal(18, 2)
																					 ,@p_division_code				= @from_division_code	
																					 ,@p_division_name				= @from_division_name	
																					 ,@p_department_code			= @from_department_code 
																					 ,@p_department_name			= @from_department_name 
																					 ,@p_remarks					= @remark_detail
																					 ---
																					 ,@p_cre_date					= @p_mod_date	  
																					 ,@p_cre_by						= @p_mod_by		  
																					 ,@p_cre_ip_address				= @p_mod_ip_address
																					 ,@p_mod_date					= @p_mod_date	  
																					 ,@p_mod_by						= @p_mod_by		  
																					 ,@p_mod_ip_address				= @p_mod_ip_address

				-- target			
				
				if @debit_or_credit <> 'DEBIT'
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

				set @remark_detail  = 'SEND MUTATION ASSET : '+@asset_code+'  TO '+@from_branch_name +' - '+@transaction_name + ' ' + @asset_name
				exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gllink_trx_code -- nvarchar(50)
																					 ,@p_company_code				= @p_company_code
																					 ,@p_branch_code				= @to_branch_code
																					 ,@p_branch_name				= @to_branch_name
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
																					 ,@p_orig_amount_db				= @orig_amount_db --@amount -- decimal(18, 2)
																					 ,@p_orig_amount_cr				= @orig_amount_cr -- decimal(18, 2)
																					 ,@p_exch_rate					= @exch_rate
																					 ,@p_base_amount_db				= @base_amount_db -- decimal(18, 2)
																					 ,@p_base_amount_cr				= @base_amount_cr -- decimal(18, 2)
																					 ,@p_division_code				= @to_division_code	
																					 ,@p_division_name				= @to_division_name	
																					 ,@p_department_code			= @to_department_code 
																					 ,@p_department_name			= @to_department_name 
																					 ,@p_remarks					= @remark_detail
																					 ---
																					 ,@p_cre_date					= @p_mod_date	  
																					 ,@p_cre_by						= @p_mod_by		  
																					 ,@p_cre_ip_address				= @p_mod_ip_address
																					 ,@p_mod_date					= @p_mod_date	  
																					 ,@p_mod_by						= @p_mod_by		  
																					 ,@p_mod_ip_address				= @p_mod_ip_address
				delete @myTampTable ;

				fetch c_mutation_asset
				into @asset_code
					 ,@asset_name 
					 ,@cost_center_code
					 ,@cost_center_name ;
			end ;

			close c_mutation_asset ;
			deallocate c_mutation_asset ;

			fetch c_inf_jour_gl
			into @sp_name
				 ,@debit_or_credit
				 ,@gl_link_code
				 ,@transaction_name 
				 ,@gl_link_name ;
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

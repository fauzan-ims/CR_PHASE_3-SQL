CREATE PROCEDURE dbo.xsp_job_eom_reverse_depre
as
begin
	declare @msg					nvarchar(max)
			,@sysdate				nvarchar(250)
			,@mod_date				datetime		  = dbo.xfn_get_system_date()--getdate()
			,@mod_by				nvarchar(15)	  = N'EOM'
			,@mod_ip_address		nvarchar(15)	  = N'SYSTEM'
			,@year					int
			,@month					int
			,@asset_code			nvarchar(50)
			,@gllink_trx_code		nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@periode				nvarchar(6)
			,@sp_name				nvarchar(250)
			,@debit_or_credit		nvarchar(50)
			,@category_code			nvarchar(50)
			,@category_name			nvarchar(250)
			,@gl_linl_code			nvarchar(50)
			,@transaction_name		nvarchar(250)
			,@currency_code			nvarchar(3)	  = N'IDR'
			,@exch_rate				decimal(18, 2) = 1
			,@amount				decimal(18, 2)
			,@orig_amount_db		decimal(18, 2)
			,@orig_amount_cr		decimal(18, 2)
			,@base_amount			decimal(18, 2)
			,@base_amount_db		decimal(18, 2)
			,@base_amount_cr		decimal(18, 2)
			,@detail_desc			nvarchar(250)
			,@description			nvarchar(250)
			,@cost_center_code		nvarchar(50)
			,@cost_center_name		nvarchar(250)
			,@trx_cost_center_code	nvarchar(50)
			,@trx_cost_center_name	nvarchar(250)
			,@validation_mssg		nvarchar(max)
			,@is_expense			int
			,@agreement_no			nvarchar(50)
			,@transaction_code		nvarchar(50)	  = N''
			,@source_name			nvarchar(250)
			,@return_value			decimal(18,2)
			,@id					int

	begin try
		begin
			if (convert(varchar(30), dbo.xfn_get_system_date(), 103) = convert(varchar(30), eomonth(dbo.xfn_get_system_date()), 103))
			begin
				set @year = year(dbo.xfn_get_system_date()) ;
				set @month = 0 + month(dbo.xfn_get_system_date()) ;

				--- cursor select branch
				declare c_branch cursor fast_forward for
				select	distinct
						ass.branch_code
						,sb.name
						,tasc.asset_code
				from	dbo.temp_asset_schedule_commercial tasc
						inner join dbo.asset			   ass on tasc.asset_code = ass.code
						inner join ifinsys.dbo.sys_branch  sb on sb.code		  = ass.branch_code
				where	tasc.status = 'HOLD' ;

				open c_branch ;

				fetch c_branch
				into @branch_code
					 ,@branch_name
					 ,@asset_code ;

				while @@fetch_status = 0
				begin
					set @source_name = N'REVERSE FIXED ASSET DEPRECIATION, ASSET : ' + @asset_code + N' BRANCH ' + @branch_name ;
					set @transaction_code = N'FAD.' + @branch_code + N'.' + @asset_code ;

					exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																				   ,@p_company_code				= 'DSF'
																				   ,@p_branch_code				= @branch_code
																				   ,@p_branch_name				= @branch_name
																				   ,@p_transaction_status		= 'HOLD'
																				   ,@p_transaction_date			= @mod_date
																				   ,@p_transaction_value_date	= @mod_date
																				   ,@p_transaction_code			= @transaction_code
																				   ,@p_transaction_name			= 'REVERSE FIXED ASSET DEPRECIATION'
																				   ,@p_reff_module_code			= 'IFINAMS'
																				   ,@p_reff_source_no			= @transaction_code
																				   ,@p_reff_source_name			= @source_name
																				   ,@p_transaction_type			= 'FAMDPR'
																					---
																				   ,@p_cre_date					= @mod_date
																				   ,@p_cre_by					= @mod_by
																				   ,@p_cre_ip_address			= @mod_ip_address
																				   ,@p_mod_date					= @mod_date
																				   ,@p_mod_by					= @mod_by
																				   ,@p_mod_ip_address			= @mod_ip_address ;

					-- coursor journal gl
					declare c_inf_jour_gl cursor fast_forward for
					select		mt.sp_name
								,mtp.debet_or_credit
								,mtp.gl_link_code
								,mt.transaction_name
								,tasc.id
					from		dbo.master_transaction_parameter  mtp
								inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
																		and mt.company_code = mtp.company_code
								inner join dbo.temp_asset_schedule_commercial tasc on tasc.asset_code = @asset_code
					where		process_code = 'RDEPRE'
					order by	mtp.order_key ;

					open c_inf_jour_gl ;

					fetch c_inf_jour_gl
					into @sp_name
						 ,@debit_or_credit
						 ,@gl_linl_code
						 ,@transaction_name
						 ,@id

					while @@fetch_status = 0
					begin
						-- nilainya exec dari MASTER_TRANSACTION.sp_name
						exec @return_value = @sp_name @id ; -- sp ini mereturn value angka 

						if(right(@return_value,2) <> '00')
						BEGIN
							set @msg = 'Nominal is not allowed for process.' ;
							raiserror(@msg, 16, -1) ;
						end
                        
						begin
							if (@debit_or_credit ='DEBIT')
							begin
								set @orig_amount_cr = 0
								SET @orig_amount_db = @return_value
							END
							ELSE
							BEGIN
									set @orig_amount_cr = abs(@return_value)
									SET @orig_amount_db = 0
							END		
						END

						set @detail_desc  = @transaction_name + N' .' + N' Asset : ' + @asset_code ;
						set @agreement_no = @asset_code + N' ' + @branch_name ;

						update dbo.temp_asset_schedule_commercial
						set status			= 'POST'
						--
							,mod_date		= @mod_date
							,mod_by			= @mod_by
							,mod_ip_address = @mod_ip_address
						where id = @id


						exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @gllink_trx_code
																							  ,@p_company_code					= 'DSF'
																							  ,@p_branch_code					= @branch_code
																							  ,@p_branch_name					= @branch_name
																							  ,@p_cost_center_code				= null
																							  ,@p_cost_center_name				= null
																							  ,@p_gl_link_code					= @gl_linl_code
																							  ,@p_agreement_no					= @agreement_no
																							  ,@p_facility_code					= ''
																							  ,@p_facility_name					= ''
																							  ,@p_purpose_loan_code				= ''
																							  ,@p_purpose_loan_name				= ''
																							  ,@p_purpose_loan_detail_code		= ''
																							  ,@p_purpose_loan_detail_name		= ''
																							  ,@p_orig_currency_code			= @currency_code
																							  ,@p_orig_amount_db				= @orig_amount_cr --@orig_amount_db
																							  ,@p_orig_amount_cr				= @orig_amount_db --@orig_amount_cr
																							  ,@p_exch_rate						= @exch_rate
																							  ,@p_base_amount_db				= @orig_amount_cr --@base_amount_db
																							  ,@p_base_amount_cr				= @orig_amount_db --@base_amount_cr
																							  ,@p_division_code					= ''
																							  ,@p_division_name					= ''
																							  ,@p_department_code				= ''
																							  ,@p_department_name				= ''
																							  ,@p_remarks						= @detail_desc
																							  ---
																							  ,@p_cre_date						= @mod_date
																							  ,@p_cre_by						= @mod_by
																							  ,@p_cre_ip_address				= @mod_ip_address
																							  ,@p_mod_date						= @mod_date
																							  ,@p_mod_by						= @mod_by
																							  ,@p_mod_ip_address				= @mod_ip_address ;

						fetch c_inf_jour_gl
						into @sp_name
							 ,@debit_or_credit
							 ,@gl_linl_code
							 ,@transaction_name
							 ,@id
					end ;

					close c_inf_jour_gl ;
					deallocate c_inf_jour_gl ;

					select	@orig_amount_db	 = sum(orig_amount_db)
							,@orig_amount_cr = sum(orig_amount_cr)
					from	dbo.efam_interface_journal_gl_link_transaction_detail
					where	gl_link_transaction_code = @gl_linl_code ;

					--+ validasi : total detail =  payment_amount yang di header
					if (@orig_amount_db <> @orig_amount_cr)
					begin
						set @msg = N'Journal does not balance' ;

						raiserror(@msg, 16, -1) ;
					end ;

					-- end cursor assets
					fetch c_branch
					into @branch_code
						 ,@branch_name
						 ,@asset_code
				end ;

				close c_branch ;
				deallocate c_branch ;
			end ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;There is an error.' + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

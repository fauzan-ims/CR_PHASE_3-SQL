CREATE PROCEDURE dbo.xsp_efam_journal_depreciation_register
(
	@p_process_code		 nvarchar(50) --- code general subcode
	,@p_company_code	 NVARCHAR(50)
	,@p_reff_source_no	 NVARCHAR(50)
	,@p_reff_source_name NVARCHAR(250)
	,@p_to_date			 DATETIME
	--
	,@p_mod_date		 DATETIME
	,@p_mod_by			 NVARCHAR(15)
	,@p_mod_ip_address	 NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg				NVARCHAR(MAX)
			,@asset_code		NVARCHAR(50)
			,@gllink_trx_code	NVARCHAR(50)
			,@branch_code		NVARCHAR(50)
			,@branch_name		NVARCHAR(250)
			,@periode			NVARCHAR(6)
			,@sp_name			NVARCHAR(250)
			,@debit_or_credit	NVARCHAR(50)
			,@category_code		NVARCHAR(50)
			,@category_name		NVARCHAR(250)
			,@gl_linl_code		NVARCHAR(50)
			,@transaction_name	NVARCHAR(250)
			,@currency_code		NVARCHAR(3)	  = 'IDR'
			,@exch_rate			DECIMAL(18, 2) = 1
			,@amount			DECIMAL(18, 2)
			,@orig_amount_db	DECIMAL(18, 2)
			,@orig_amount_cr	DECIMAL(18, 2)
			,@base_amount		DECIMAL(18, 2)
			,@base_amount_db	DECIMAL(18, 2)
			,@base_amount_cr	DECIMAL(18, 2)
			,@detail_desc		NVARCHAR(250) 
			,@description		NVARCHAR(250) 
			,@cost_center_code	NVARCHAR(50)
			,@cost_center_name	NVARCHAR(250)
			,@trx_cost_center_code	NVARCHAR(50)
			,@trx_cost_center_name	NVARCHAR(250)
			,@validation_mssg	NVARCHAR(MAX)
			,@is_expense		int
            ,@agreement_no		nvarchar(50)
			,@transaction_code	NVARCHAR(50) = ''

	BEGIN TRY
		-- ambil description - by @p_process_code
		SELECT	@description = description
		FROM	dbo.sys_general_subcode
		WHERE	code = @p_process_code ;
	 
		--- cursor select branch
		DECLARE c_branch CURSOR FAST_FORWARD FOR
		SELECT DISTINCT
				ast.branch_code
				,sb.name--,ast.branch_name
				,CONVERT(NVARCHAR(6), ad.depreciation_date , 112)
				--,ad.cost_center_code
				--,ad.cost_center_name
		FROM	dbo.asset_depreciation ad
				INNER JOIN dbo.asset ast ON ast.code = ad.asset_code
				inner join ifinsys.dbo.sys_branch sb on sb.code = ast.branch_code
				INNER JOIN dbo.master_category mc ON mc.code = ast.category_code
		WHERE	ad.status			 = 'HOLD'
				AND CAST(depreciation_date AS DATE) <= CAST(@p_to_date AS DATE)

		OPEN c_branch ;

		fetch c_branch
		into @branch_code
			 ,@branch_name 
			 ,@periode 
			 --,@cost_center_code
			 --,@cost_center_name ;

		while @@fetch_status = 0
		begin
			set @p_reff_source_name = 'FIXED ASSET DEPRECIATION, PERIODE :' + @periode +' BRANCH ' + @branch_name 
			-- sepria 12mar2024: penomoran transaction code dijadikan unik, di dalam sp insertnya di tambahkan kode transaksi
			set @transaction_code = 'FAD' + '.' + @branch_code + '.' + @periode

			exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																		   ,@p_company_code				= @p_company_code
																		   ,@p_branch_code				= @branch_code
																		   ,@p_branch_name				= @branch_name
																		   ,@p_transaction_status		= 'HOLD'
																		   ,@p_transaction_date			= @p_to_date
																		   ,@p_transaction_value_date	= @p_to_date
																		   ,@p_transaction_code			= @transaction_code--@periode
																		   ,@p_transaction_name			= @description
																		   ,@p_reff_module_code			= 'IFINAMS'
																		   ,@p_reff_source_no			= @transaction_code--'' --@periode -- dont have transaction number
																		   ,@p_reff_source_name			= @p_reff_source_name
																		   ,@p_transaction_type			= 'FAMDPR'
																		   ---
																		   ,@p_cre_date					= @p_mod_date	  
																		   ,@p_cre_by					= @p_mod_by		  
																		   ,@p_cre_ip_address			= @p_mod_ip_address
																		   ,@p_mod_date					= @p_mod_date	  
																		   ,@p_mod_by					= @p_mod_by		  
																		   ,@p_mod_ip_address			= @p_mod_ip_address
			update	dbo.efam_interface_journal_gl_link_transaction
			set		reff_source_no	= @gllink_trx_code
			where	code			= @gllink_trx_code
		
			set @validation_mssg = ''
			
			select  @trx_cost_center_code = @cost_center_code
					,@trx_cost_center_name = @cost_center_name

			-- update bagas 6 Septermber 2022
			update	dbo.asset_depreciation_schedule_commercial
			set		transaction_code = @gllink_trx_code
			where	asset_code in ( 
									select distinct
											ad.asset_code
									from	dbo.asset_depreciation ad
											inner join dbo.asset ast on ast.code = ad.asset_code
											inner join dbo.master_category mc on mc.code = ast.category_code
									where	ad.status			 = 'HOLD'
											and ast.company_code = @p_company_code
											and cast(depreciation_date as date) <= cast(@p_to_date as date)
											and ast.branch_code = @branch_code
									)
			and		year(asset_depreciation_schedule_commercial.depreciation_date) = left(@periode,4) --year(@p_to_date)
			and		month(asset_depreciation_schedule_commercial.depreciation_date) = right(@periode,2) --month(@p_to_date)
			and		transaction_code = '' -- Arga 12-Nov-2022 ket : exclude data already post (+)


			-- Trisna 31-Oct-2022 ket : for WOM (+) ====
			update	dbo.asset_depreciation
			set		journal_code = @gllink_trx_code
			where	asset_code in ( 
									select distinct
											ad.asset_code
									from	dbo.asset_depreciation ad
											inner join dbo.asset ast on ast.code = ad.asset_code
											inner join dbo.master_category mc on mc.code = ast.category_code
									where	ad.status			 = 'HOLD'
											and ast.company_code = @p_company_code
											and cast(depreciation_date as date) <= cast(@p_to_date as date)
											and ast.branch_code = @branch_code
									) 
			and		convert(nvarchar(6), depreciation_date , 112) = @periode -- Arga 12-Nov-2022 ket : based on periode (+)
			and		asset_depreciation.status = 'HOLD' -- Arga 12-Nov-2022 ket : exclude data already post (+)



			declare c_depre_asset cursor fast_forward for
			select		ast.category_code
						,mc.description
						,sum(ad.depreciation_commercial_amount)
						--,ad.asset_code
			from		dbo.asset_depreciation ad
						inner join dbo.asset ast on ast.code = ad.asset_code
						inner join dbo.master_category mc on mc.code = ast.category_code
			where		ast.branch_code = @branch_code
						and ad.status		= 'HOLD'
						and convert(nvarchar(6), ad.depreciation_date , 112) = @periode
						--and cast(depreciation_date as date) <= cast(@p_to_date as date)
			group by	ast.category_code  
						,mc.description
						--,ad.asset_code

			open c_depre_asset ;

			fetch c_depre_asset
			into @category_code
				 ,@category_name
				 ,@amount 
				 --,@asset_code;

			while @@fetch_status = 0
			begin
				
				select		top 1 @asset_code = ad.asset_code
				from		dbo.asset_depreciation ad
							inner join dbo.asset ast on ast.code = ad.asset_code
							inner join dbo.master_category mc on mc.code = ast.category_code
				where		ast.company_code	= @p_company_code
							and ast.branch_code = @branch_code
							and ad.status		= 'HOLD'
							and cast(depreciation_date as date) <= cast(@p_to_date as date)
							and	ast.category_code = @category_code

				-- coursor journal gl
				declare c_inf_jour_gl cursor fast_forward for
				select	mt.sp_name
						,mtp.debet_or_credit
						,mtp.gl_link_code
						,mt.transaction_name
				from	dbo.master_transaction_parameter mtp
						inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
																and mt.company_code = mtp.company_code
				where	process_code		 = @p_process_code
						--and mtp.company_code = @p_company_code
				order by mtp.order_key ;

				open c_inf_jour_gl ;

				fetch c_inf_jour_gl
				into @sp_name
					 ,@debit_or_credit
					 ,@gl_linl_code
					 ,@transaction_name ;

				while @@fetch_status = 0
				begin

					set @orig_amount_db = 0 ;
					set @orig_amount_cr = 0 ;
					set @base_amount_db = 0 ;
					set @base_amount_cr = 0 ;

					if(right(@amount,2) <> '00')
					BEGIN
						set @msg = 'Nominal is not allowed for process.' ;
						raiserror(@msg, 16, -1) ;
					eND

					if @debit_or_credit = 'DEBIT'
					begin
						set @orig_amount_db = @amount ;
						set @base_amount_db = @amount * @exch_rate  ;
					end ;
					else
					begin
						set @orig_amount_cr = @amount ;
						set @base_amount_cr = @amount * @exch_rate  ;
					end ;

					-- Arga 24-Oct-2022 ket : auto get value from master category (+)
					select @gl_linl_code = dbo.xfn_get_gl_code_from_category(@asset_code, @p_company_code, @gl_linl_code)
					
					select @is_expense = dbo.xfn_checking_gl_expense(@gl_linl_code)	
				
					if @is_expense = 0
					begin
						exec dbo.xsp_get_cost_center_default @p_gl_link_code	 = @gl_linl_code
															,@p_cost_center_code = @cost_center_code output
															,@p_cost_center_name = @cost_center_name output								
					end
					else
					begin
						select @cost_center_code = @trx_cost_center_code
								,@cost_center_name = @trx_cost_center_name
					end

					set @detail_desc = @transaction_name + ' ' + @category_name + ' PERIODE ' + @periode 
					set @agreement_no = @periode + ' ' + @branch_name
					exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert	@p_gl_link_transaction_code		= @gllink_trx_code -- nvarchar(50)
																							,@p_company_code				= @p_company_code
																							,@p_branch_code					= @branch_code
																							,@p_branch_name					= @branch_name
																							,@p_cost_center_code			= @cost_center_code
																							,@p_cost_center_name			= @cost_center_name
																							,@p_gl_link_code				= @gl_linl_code
																							,@p_agreement_no				= @agreement_no
																							,@p_facility_code				= @category_code --'' -- kosong
																							,@p_facility_name				= @category_name --'' -- kosong
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
																							,@p_remarks						= @detail_desc
																							---
																							,@p_cre_date					= @p_mod_date	  
																							,@p_cre_by						= @p_mod_by		  
																							,@p_cre_ip_address				= @p_mod_ip_address
																							,@p_mod_date					= @p_mod_date	  
																							,@p_mod_by						= @p_mod_by		  
																							,@p_mod_ip_address				= @p_mod_ip_address

					fetch c_inf_jour_gl
					into @sp_name
						 ,@debit_or_credit
						 ,@gl_linl_code
						 ,@transaction_name ;
				end ;

				close c_inf_jour_gl ;
				deallocate c_inf_jour_gl ;

				-- end coursor journal gl
				fetch c_depre_asset
				into @category_code
					,@category_name
					 ,@amount
					 --,@asset_code ;
			end ;

			close c_depre_asset ;
			deallocate c_depre_asset ;
			
			select	@orig_amount_db = sum(orig_amount_db) 
				,@orig_amount_cr = sum(orig_amount_cr) 
			from  dbo.efam_interface_journal_gl_link_transaction_detail
			where gl_link_transaction_code = @gl_linl_code

			--+ validasi : total detail =  payment_amount yang di header
			if (@orig_amount_db <> @orig_amount_cr)
			begin
				set @msg = 'Journal does not balance';
				raiserror(@msg, 16, -1) ;
			end	


			-- end cursor assets
			fetch c_branch
			into @branch_code
				 ,@branch_name 
				 ,@periode
				 --,@cost_center_code
				 --,@cost_center_name ;
		end ;

		close c_branch ;
		deallocate c_branch ;
	--- end cursor select branch

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
end ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_efam_journal_depreciation_register] TO [ims-raffyanda]
    AS [dbo];


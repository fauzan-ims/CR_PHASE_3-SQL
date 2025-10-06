CREATE PROCEDURE dbo.xsp_asset_prepaid_post
(
	@p_to_date			 datetime
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
declare @msg					  nvarchar(max)
		,@sysdate				  nvarchar(250)
											--,@mod_date				  datetime		 = getdate()
											--,@mod_by				  nvarchar(15)	 = N'EOM'
											--,@mod_ip_address		  nvarchar(15)	 = N'SYSTEM'
		,@year					  int
		,@month					  int
		,@branch_code			  nvarchar(50)
		,@branch_name			  nvarchar(250)
		,@periode_acc			  nvarchar(15)
		,@enddate				  datetime
		,@prepaid_no			  nvarchar(50)
		,@reff_source_name		  nvarchar(250)
		,@gllink_trx_code		  nvarchar(50)
		,@sp_name				  nvarchar(250)
		,@debit_or_credit		  nvarchar(50)
		,@category_code			  nvarchar(50)
		,@category_name			  nvarchar(250)
		,@gl_link_code			  nvarchar(50)
		,@transaction_name		  nvarchar(250)
		,@currency_code			  nvarchar(3)	 = N'IDR'
		,@exch_rate				  decimal(18, 2) = 1
		,@amount				  decimal(18, 2)
		,@orig_amount_db		  bigint	--decimal(18, 2)
		,@orig_amount_cr		  bigint	--decimal(18, 2)
		,@base_amount			  decimal(18, 2)
		,@return_value			  decimal(18, 2)
		,@id_deatil				  int
		,@detail_remark			  nvarchar(4000)
		,@default_branch_code	  nvarchar(50)
		,@default_branch_name	  nvarchar(250)
		,@journal_branch_code	  nvarchar(50)
		,@journal_branch_name	  nvarchar(250)
		,@date					  datetime		 = dbo.xfn_get_system_date() 
		,@prepaid_amount_schedule decimal(18, 2)
		,@agreement_no			  nvarchar(50)
		,@periode				  nvarchar(6)
		,@status				  nvarchar(50)
		,@transaction_code		  nvarchar(50) ;

	begin try
		set @year = year(dbo.xfn_get_system_date()) ;
		set @month = month(dbo.xfn_get_system_date()) ;
		set @enddate = eomonth(dbo.xfn_get_system_date()) ;
		set @periode_acc = convert(nvarchar(4), @year) + convert(nvarchar(4), @month) ;

		-- untuk mengakomodir data migrasi yang tidak memiliki asset maka mengambil salah satu branh yang di jurnal
		select	top 1
				@default_branch_code  = ass.branch_code
				,@default_branch_name = ass.branch_name
		from	dbo.asset_prepaid_main				  apm
				left join dbo.asset					  ass on (ass.code		 = apm.fa_code)
				inner join dbo.asset_prepaid_schedule aps on (apm.prepaid_no = aps.prepaid_no)
		where	month(aps.prepaid_date)				 = month(eomonth(dbo.xfn_get_system_date()))
				and year(aps.prepaid_date)			 = year(eomonth(dbo.xfn_get_system_date()))
				and ass.branch_code is not null
				and isnull(aps.accrue_reff_code, '') = ''
				and ass.BRANCH_CODE					 <> '1000' ;

		declare curr_branch_asset cursor fast_forward read_only for
		select	distinct
				isnull(ass.branch_code, '')
				,isnull(sb.name, '')
				,convert(nvarchar(6), ap.prepaid_date, 112)
		from	dbo.asset_prepaid				  ap
				inner join dbo.asset_prepaid_main apm on ap.prepaid_no = apm.prepaid_no
				left join dbo.asset			  ass on ass.code	   = apm.fa_code
				left join ifinsys.dbo.sys_branch sb on sb.code		   = ass.branch_code
		where	ap.status						  = 'HOLD'
				--and cast(ap.prepaid_date as date) <= cast('2024-08-31' as date) ;

		open curr_branch_asset ;

		fetch next from curr_branch_asset
		into @branch_code
			 ,@branch_name
			 ,@periode ;

		while @@fetch_status = 0
		begin
			set @reff_source_name = N'PREPAID FIXED ASSET, PERIODE : ' + @periode + N'. Branch : ' + @branch_name ;
			set @journal_branch_code = @branch_code ;
			set @journal_branch_name = @branch_name ;

			-- untuk mengakomodir data migrasi yang tidak memiliki asset maka mengambil salah satu branh yang di jurnal
			if (@branch_code = '')
			begin
				set @journal_branch_code = @default_branch_code ;
				set @journal_branch_name = @default_branch_name ;
				set @reff_source_name = N'PREPAID FIXED ASSET (OUTSTANDING), PERIODE : ' + @periode + N'. Branch : ' + @journal_branch_name ;
			end ;

			set @transaction_code = 'FAP.' + @branch_code + '.' + @periode

			--Region Journal
			exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																		   ,@p_company_code				= 'DSF'
																		   ,@p_branch_code				= @journal_branch_code
																		   ,@p_branch_name				= @journal_branch_name
																		   ,@p_transaction_status		= 'HOLD'
																		   ,@p_transaction_date			= @date
																		   ,@p_transaction_value_date	= @date
																		   ,@p_transaction_code			= @transaction_code
																		   ,@p_transaction_name			= 'FIXED ASSET PREPAID'
																		   ,@p_reff_module_code			= 'IFINAMS'
																		   ,@p_reff_source_no			= @periode
																		   ,@p_reff_source_name			= @reff_source_name
																		   ,@p_transaction_type			= 'FAMDSP'
																			---
																		   ,@p_cre_date					= @p_mod_date
																		   ,@p_cre_by					= @p_mod_by
																		   ,@p_cre_ip_address			= @p_mod_ip_address
																		   ,@p_mod_date					= @p_mod_date
																		   ,@p_mod_by					= @p_mod_by
																		   ,@p_mod_ip_address			= @p_mod_ip_address ;

			--update prepaid schedule
			update	dbo.asset_prepaid_schedule
			set		accrue_reff_code = @gllink_trx_code
					,accrue_date = dbo.xfn_get_system_date()
			where	prepaid_no in
					(
						select	distinct
								ap.prepaid_no
						from	dbo.asset_prepaid				  ap
								inner join dbo.asset_prepaid_main apm on ap.prepaid_no = apm.prepaid_no
								left join dbo.asset			  ass on ass.code	   = apm.fa_code
						where	ap.status					   = 'HOLD'
								and cast(ap.prepaid_date as date) <= cast(dbo.xfn_get_system_date() as date)
								and ass.branch_code			   = @journal_branch_code
					)
					and isnull(accrue_reff_code, '')			   = ''
					and year(asset_prepaid_schedule.prepaid_date)  = left(@periode, 4)
					and month(asset_prepaid_schedule.prepaid_date) = right(@periode, 2) ;

			--update prepaid
			update	dbo.asset_prepaid
			set		journal_code = @gllink_trx_code
			where	prepaid_no in
					(
						select	distinct
								ap.prepaid_no
						from	dbo.asset_prepaid				  ap
								inner join dbo.asset_prepaid_main apm on ap.prepaid_no = apm.prepaid_no
								left join dbo.asset			  ass on ass.code	   = apm.fa_code
						where	ap.status					   = 'HOLD'
								and cast(ap.prepaid_date as date) <= cast(dbo.xfn_get_system_date() as date)
								and ass.branch_code			   = @journal_branch_code
					)
					and convert(nvarchar(6), asset_prepaid.prepaid_date, 112) = @periode
					and asset_prepaid.status								  = 'HOLD' ;

			declare c_inf_jour_gl cursor fast_forward for
			select	mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
			from	dbo.master_transaction_parameter  mtp
					inner join dbo.master_transaction mt on mt.code = mtp.transaction_code
			where	process_code = 'PRPD' ;

			open c_inf_jour_gl ;

			fetch c_inf_jour_gl
			into @sp_name
				 ,@debit_or_credit
				 ,@gl_link_code
				 ,@transaction_name ;

			while @@fetch_status = 0
			begin
				-- nilainya exec dari MASTER_TRANSACTION.sp_name
				exec @return_value = @sp_name @branch_code, @periode ;	-- sp ini mereturn value angka 

				if (right(@return_value, 2) <> '00')
				begin
					set @msg = N'Nominal is not allowed for process.' ;

					raiserror(@msg, 16, -1) ;
				end ;

				--if(@return_value <> 0 )
				begin
					if (@debit_or_credit = 'DEBIT')
					begin
						set @orig_amount_cr = 0 ;
						set @orig_amount_db = @return_value ;
					end ;
					else
					begin
						set @orig_amount_cr = abs(@return_value) ;
						set @orig_amount_db = 0 ;
					end ;
				end ;

				set @detail_remark = @transaction_name + N' ' + N'PERIODE : ' + @periode_acc ;
				set @agreement_no = @periode_acc + N' ' + @branch_name ;

				if (@branch_code = '')
				begin
					set @agreement_no = @periode_acc + N' ' + @default_branch_name ;
				end ;

				exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @gllink_trx_code	-- nvarchar(50)
																					  ,@p_company_code					= 'DSF'
																					  ,@p_branch_code					= @journal_branch_code
																					  ,@p_branch_name					= @journal_branch_name
																					  ,@p_cost_center_code				= null
																					  ,@p_cost_center_name				= null
																					  ,@p_gl_link_code					= @gl_link_code
																					  ,@p_agreement_no					= @agreement_no
																					  ,@p_facility_code					= ''
																					  ,@p_facility_name					= ''
																					  ,@p_purpose_loan_code				= ''
																					  ,@p_purpose_loan_name				= ''
																					  ,@p_purpose_loan_detail_code		= ''
																					  ,@p_purpose_loan_detail_name		= ''
																					  ,@p_orig_currency_code			= 'IDR'
																					  ,@p_orig_amount_db				= @orig_amount_db
																					  ,@p_orig_amount_cr				= @orig_amount_cr
																					  ,@p_exch_rate						= @exch_rate
																					  ,@p_base_amount_db				= @orig_amount_db
																					  ,@p_base_amount_cr				= @orig_amount_cr
																					  ,@p_division_code					= ''
																					  ,@p_division_name					= ''
																					  ,@p_department_code				= ''
																					  ,@p_department_name				= ''
																					  ,@p_remarks						= @detail_remark
																					   --
																					  ,@p_cre_date						= @p_mod_date
																					  ,@p_cre_by						= @p_mod_by
																					  ,@p_cre_ip_address				= @p_mod_ip_address
																					  ,@p_mod_date						= @p_mod_date
																					  ,@p_mod_by						= @p_mod_by
																					  ,@p_mod_ip_address				= @p_mod_ip_address ;

				fetch c_inf_jour_gl
				into @sp_name
					 ,@debit_or_credit
					 ,@gl_link_code
					 ,@transaction_name ;
			end ;

			close c_inf_jour_gl ;
			deallocate c_inf_jour_gl ;

			select	@orig_amount_db	 = sum(orig_amount_db)
					,@orig_amount_cr = sum(orig_amount_cr)
			from	dbo.efam_interface_journal_gl_link_transaction_detail
			where	gl_link_transaction_code = @gllink_trx_code ;

			--+ validasi : total detail =  payment_amount yang di header
			if (@orig_amount_db <> @orig_amount_cr)
			begin
				set @msg = N'Journal does not balance' ;

				raiserror(@msg, 16, -1) ;
			end ;

			--EndRegion Journal Maintenance
			fetch next from curr_branch_asset
			into @branch_code
				 ,@branch_name
				 ,@periode ;
		end ;

		close curr_branch_asset ;
		deallocate curr_branch_asset ;


		--update prepaid main
		declare curr_update_accrue cursor fast_forward read_only for
		select		sum(prepaid_amount)
					,prepaid_no
		from		dbo.asset_prepaid_schedule
		where		isnull(accrue_reff_code, '') <> ''
		group by	prepaid_no ;

		open curr_update_accrue ;

		fetch next from curr_update_accrue
		into @prepaid_amount_schedule
			 ,@prepaid_no ;

		while @@fetch_status = 0
		begin
			update	dbo.asset_prepaid_main
			set		total_accrue_amount		= @prepaid_amount_schedule
					,last_accue_period		= @periode_acc
			where	prepaid_no = @prepaid_no ;

			fetch next from curr_update_accrue
			into @prepaid_amount_schedule
				 ,@prepaid_no ;
		end ;

		close curr_update_accrue ;
		deallocate curr_update_accrue ;

		--update prepaid post
		declare curr_prepaid_post cursor fast_forward read_only for
		select	prepaid_no
				,status
				,convert(varchar(6), prepaid_date, 112)
		from	dbo.asset_prepaid
		where	status = 'HOLD' ;
		
		open curr_prepaid_post
		
		fetch next from curr_prepaid_post 
		into @prepaid_no
			,@status
			,@periode
		
		while @@fetch_status = 0
		begin
			if(@status = 'HOLD')
			begin
				update	dbo.asset_prepaid
				set		status				= 'POST'
						--
						,mod_by				= @p_mod_by
						,mod_date			= @p_mod_date
						,mod_ip_address		= @p_mod_ip_address
				where	prepaid_no			= @prepaid_no
				and convert(varchar(6), prepaid_date, 112) = @periode
			end
		
		    fetch next from curr_prepaid_post 
			into @prepaid_no
				,@status
				,@periode
		end
		
		close curr_prepaid_post
		deallocate curr_prepaid_post
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

--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_profitability_asset
(
	@p_user_id			nvarchar(50) = ''
	,@p_is_condition	nvarchar(50) = ''
	,@p_asset_code		nvarchar(50) = ''
)
as
BEGIN

	delete dbo.rpt_profitability_asset
	where	user_id = @p_user_id ;

	delete dbo.rpt_profitability_asset_expense
	where	user_id = @p_user_id ;

	delete dbo.rpt_profitability_asset_income
	where	user_id = @p_user_id ;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@report_address				nvarchar(250)
			,@purchase_price				decimal(18,2)
			,@netbook_value					decimal(18,2)
			,@rv							decimal(18,2)
			,@profit_loss_actual			decimal(18,2)
			,@sell							decimal(18,2)
			,@gain_loss_penjualan			decimal(18,2)
			,@net_profit_loss				decimal(18,2)
			,@nilai_sisa_sewa				decimal(18,2)
			,@maturity_date					datetime
			,@kontrak						decimal(18,2)
			,@expense_amount				decimal(18,2)
			,@agreement_no_code				nvarchar(50)
			,@agreement_no_code_2			nvarchar(50)
			,@agreement_ext_code			nvarchar(50)
			,@nilai_sisa					decimal(18,2)
			,@asset_no						nvarchar(50)
			,@rv_2							decimal(18,2)
			,@asset_code					nvarchar(50)
			,@income_budget					decimal(18,2)
			,@income_amount					decimal(18,2)
			,@replacement_budget_amount		decimal(18,2)
			,@registration_budget_amount	decimal(18,2)
			,@maintenance_budget_amount		decimal(18,2)
			,@insurance_budget_amount		decimal(18,2)
			,@mobilisasi_budget_amount		decimal(18,2)
			,@replacement_actual_amount		decimal(18,2)
			,@registration_actual_amount	decimal(18,2)
			,@maintenance_actual_amount		decimal(18,2)
			,@insurance_actual_amount		decimal(18,2)
			,@mobilisasi_actual_amount		decimal(18,2)
			,@profit_loss_amount			decimal(18,2)
			,@sell_budget					decimal(18,2)
			,@sell_actual					decimal(18,2)
			,@borrow_budget					decimal(18,2)
			,@borrow_actual					decimal(18,2)
			,@total_budget					decimal(18,2)
			,@sale_fee_budget				decimal(18,2)
			,@sale_fee_actual				decimal(18,2)

	begin TRY
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Profitability Asset';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		select @report_address = value 
		from	dbo.sys_global_param
		where	code = 'COMADD2'

		begin
			select	@asset_no = asset_no
			from	ifinams.dbo.asset
			where	code = @p_asset_code ;

			--select	@nilai_sisa = sum(installment_amount)
			--from	ifinopl.dbo.agreement_information ai
			--where	ai.agreement_no in
			--		(
			--			select	asat.agreement_no
			--			from	ifinams.dbo.asset ass
			--					left join ifinams.dbo.sale_detail sd on (sd.asset_code		= ass.code)
			--					left join ifinopl.dbo.agreement_asset asat on (asat.fa_code = ass.code)
			--			where	ass.code = @p_asset_code
			--		) ;


			select	@rv_2 = sum(ama.billing_amount)
			from	ifinopl.dbo.agreement_asset asat
					inner join ifinopl.dbo.agreement_asset_amortization ama on ama.asset_no = asat.asset_no
					left join ifinopl.dbo.invoice_detail ind on ind.invoice_no		= ama.invoice_no
																and ind.asset_no	= ama.asset_no
																and ind.billing_no	= ama.billing_no
					left join ifinopl.dbo.invoice inv on inv.invoice_no				= ama.invoice_no
			where	(
						inv.invoice_status in
							(
								'NEW', 'POST'
							)
						or	inv.invoice_status is null
							)
							and ama.agreement_no in (
								select	asat.agreement_no
								from	ifinams.dbo.asset ass
										left join ifinams.dbo.sale_detail sd on (sd.asset_code		= ass.code)
										left join ifinopl.dbo.agreement_asset asat on (asat.fa_code = ass.code)
								where	ass.code = @p_asset_code
							) 
					and ama.asset_no	 = @asset_no ;

			insert into dbo.rpt_profitability_asset
			(
				user_id
				,report_company
				,report_title
				,report_image
				,report_address
				,filter_asset_code
				,filter_asset_name
				,filter_is_condition
				,purchase_price
				,netbook_value
				,rv
				,rv_2
				,profit_loss_actual
				,sell
				,gain_loss_penjualan
				,net_profit_loss
				,nilai_sisa_sewa
				,maturity_date
				,kontrak
				,kontrak_ext
				,client_name
				,cop
				,is_condition
			)
			select	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@report_address
					,@p_asset_code
					,isnull(ass.item_name, '') + ' - ' + isnull(avi.built_year, '') + ' - ' + isnull(avi.plat_no, '')
					,''
					,isnull(ass.purchase_price, 0)
					,isnull(ass.net_book_value_comm, 0)
					,isnull(ass.residual_value, 0)
					,isnull(asat.asset_rv_amount,0) --isnull(@rv_2, 0)
					,0
					,isnull(sd.sold_amount, 0)
					,isnull(ass.net_book_value_comm, 0) - isnull(ass.sale_amount, 0)
					,0
					,isnull(tes2.nilai_sisa,0) --@nilai_sisa
					,isnull(tes.date,0)
					,case
						 when isnull(aman.agreement_no, '-') = '-' then '-'
						 when aman.agreement_no = '' then '-'
						 else aman.agreement_no
					 end
					,case
						 when isnull(aman.agreement_external_no, '-') = '-' then '-'
						 when aman.agreement_external_no = '' then '-'
						 else aman.agreement_external_no
					 end
					,isnull(ass.client_name, '') + ' - (' + isnull(convert(nvarchar(50), period.jumlah), '-') + ' Of ' + isnull(convert(nvarchar(50), aman.periode), '-') + ' Bulan)'
					,case
						 when aman.IS_PURCHASE_REQUIREMENT_AFTER_LEASE = '1' then 'Yes'
						 else 'No'
					 end
					,@p_is_condition
			from	dbo.asset ass
					left join asset_vehicle avi on avi.asset_code = ass.code
					left join dbo.sale_detail sd on (sd.asset_code = ass.code)
					left join ifinopl.dbo.agreement_asset asat on (asat.fa_code = ass.code)
					left join ifinopl.dbo.agreement_main aman on aman.agreement_no = asat.agreement_no
					outer apply
					(
						select	case
									when count(*) = 0 then null
									else count(*)
								end 'jumlah'
						from	ifinopl.dbo.agreement_asset_amortization aaa
								inner join ifinopl.dbo.invoice inv on inv.invoice_no = aaa.invoice_no
						where	isnull(inv.invoice_type, '') <> ''
								and aaa.agreement_no		 = aman.agreement_no
								and aaa.asset_no			 = ass.asset_no
					) period
					outer apply
					(
						select	max(aaa.due_date) 'date'
						from	ifinopl.dbo.agreement_asset_amortization aaa
						where	aaa.agreement_no = asat.agreement_no
					) tes
					outer apply
					(
						select	sum(aaa.billing_amount) 'nilai_sisa'
						from	ifinopl.dbo.agreement_asset_amortization aaa
								left join ifinopl.dbo.invoice inv on (inv.invoice_no = aaa.invoice_no)
						where	aaa.agreement_no				   = asat.agreement_no
								and aaa.asset_no				   = ass.asset_no
								and isnull(inv.invoice_status, '') = ''
					) tes2
			where	ass.code = @p_asset_code ;

			declare curr_agreement cursor local fast_forward read_only for
			select	isnull(asat.agreement_no,'')
					,case
						when isnull(asat.agreement_no,'-')='-' then '-'
						when asat.agreement_no = '' then '-'
						else asat.agreement_no
					end	
					,ass.code
			from	dbo.asset ass
					left join dbo.sale_detail sd on (sd.asset_code = ass.code)
					left join ifinopl.dbo.agreement_asset asat on (asat.fa_code = ass.code)
					left join ifinopl.dbo.agreement_main aman on (aman.agreement_no = asat.agreement_no)
			where	ass.code = @p_asset_code ;
		
			open curr_agreement 
		
			fetch next from curr_agreement 
			into @agreement_no_code
				 ,@agreement_no_code_2
				 ,@asset_code
		
			while @@fetch_status = 0
			begin
				--select	@income_budget = sum(total_amount)
				--from	ifinopl.dbo.invoice_detail
				--where	agreement_no = @agreement_no_code ;

				select @income_budget = sum(billing_amount) 
				from ifinopl.dbo.agreement_asset_amortization
				where agreement_no = @agreement_no_code
				and asset_no = @asset_no

				select @income_amount = isnull(sum(income_amount), 0) 
				from dbo.asset_income_ledger
				where agreement_no = @agreement_no_code
				and asset_code = @p_asset_code
				and REFF_NAME <> 'INSURANCE REFUND'
				group by agreement_no

				select @sell_actual = isnull(sum(income_amount), 0) 
				from dbo.asset_income_ledger
				where agreement_no = @agreement_no_code
				and asset_code = @p_asset_code
				and reff_name = 'INSURANCE REFUND'
				group by agreement_no

				insert dbo.rpt_profitability_asset_income
				(
					user_id
					,kontrak_income
					,description_income
					,budget_income
					,actual_income
					,budget_sell
					,actual_sell
				)
				values
				(
					@p_user_id
					,@agreement_no_code
					,'INCOME'
					,isnull(@income_budget,0)
					,isnull(@income_amount,0)
					,0
					,isnull(@sell_actual,0)
				)
				--select		@p_user_id
				--			,@agreement_no_code
				--			,'INCOME'
				--			,isnull(@income_budget, 0)
				--			,isnull(sum(ail.income_amount), 0)
				--from		dbo.asset_income_ledger ail
				--where		ail.agreement_no = @agreement_no_code 
				--and ail.asset_code = @p_asset_code
				--group by	ail.agreement_no ;

				--select @replacement_budget_amount = isnull(sum(asd.budget_amount), 0) 
				--from ifinopl.dbo.application_asset_budget asd
				--inner join ifinopl.dbo.application_asset asat on (asat.asset_no = asd.asset_no)
				--inner join ifinopl.dbo.agreement_main aman on (asat.agreement_no = aman.agreement_no)
				--where aman.agreement_no = @agreement_no_code
				--and asd.asset_no = @asset_no
				--and asd.cost_code = 'MBDC.2208.000001'

				--budget
				select @replacement_budget_amount		=  isnull(budget_replacement_amount,0)
						,@registration_budget_amount	= isnull(budget_registration_amount,0)
						,@maintenance_budget_amount		= isnull(budget_maintenance_amount,0)
						,@insurance_budget_amount		= isnull(budget_insurance_amount,0)
						,@mobilisasi_budget_amount		= isnull(mobilization_amount,0)
				from ifinopl.dbo.agreement_asset
				where agreement_no = @agreement_no_code

				--select @registration_budget_amount = isnull(sum(asd.budget_amount), 0) 
				--from ifinopl.dbo.application_asset_budget asd
				--inner join ifinopl.dbo.application_asset asat on (asat.asset_no = asd.asset_no)
				--inner join ifinopl.dbo.agreement_main aman on (asat.agreement_no = aman.agreement_no)
				--where aman.agreement_no = @agreement_no_code
				--and asd.asset_no = @asset_no
				--and asd.cost_code = 'MBDC.2301.000001'

				--select @maintenance_budget_amount = isnull(sum(asd.budget_amount), 0) 
				--from ifinopl.dbo.application_asset_budget asd
				--inner join ifinopl.dbo.application_asset asat on (asat.asset_no = asd.asset_no)
				--inner join ifinopl.dbo.agreement_main aman on (asat.agreement_no = aman.agreement_no)
				--where aman.agreement_no = @agreement_no_code
				--and asd.asset_no = @asset_no
				--and asd.cost_code = 'MBDC.2211.000003'

				--select @insurance_budget_amount = isnull(sum(asd.budget_amount), 0) 
				--from ifinopl.dbo.application_asset_budget asd
				--inner join ifinopl.dbo.application_asset asat on (asat.asset_no = asd.asset_no)
				--inner join ifinopl.dbo.agreement_main aman on (asat.agreement_no = aman.agreement_no)
				--where aman.agreement_no = @agreement_no_code
				--and asd.asset_no = @asset_no
				--and asd.cost_code = 'MBDC.2211.000001'

				--select	@mobilisasi_budget_amount = isnull(mobilization_amount,0)
				--from	ifinopl.dbo.application_asset asat
				--inner join ifinopl.dbo.agreement_main aman on (aman.agreement_no = asat.agreement_no)
				--where	asset_no = @asset_no
				--and aman.AGREEMENT_NO = @agreement_no_code

				insert into dbo.rpt_profitability_asset_expense
				(
					user_id
					,kontrak_expense
					,description_expense
					,insurance_budget_expense
					,maintenance_budget_expense
					,mobilization_budget_expense
					,replacement_car_budget_expense
					,stnk_keur_budget_expense
					,borrow_burget_expense
					,SALE_FEE_BUDGET
				)
				select	distinct @p_user_id
						,case
							when isnull(@agreement_no_code,'-')='-' then '-'
							when @agreement_no_code = '' then '-'
							else @agreement_no_code
						end
						,'-'
						,@insurance_budget_amount--isnull(insurance.insurance_amount,0)
						,@maintenance_budget_amount--isnull(maintenance.maintenance_amount,0)
						,isnull(@mobilisasi_budget_amount,0)--isnull(mobilization.mobilisasi_amount,0)
						,@replacement_budget_amount--isnull(replacement.replacement_amount,0)
						,@registration_budget_amount--isnull(registration.registration_amount,0)
						,0
						,0
				from	asset ass
				where	ass.code = @p_asset_code;

				-- Actual
				select	@insurance_actual_amount		= isnull(insurance_actual.amount,0)
						,@maintenance_actual_amount		= isnull(maintenance_actual.amount,0)
						,@mobilisasi_actual_amount		= isnull(mobilisasi_actual.amount,0)
						,@replacement_actual_amount		= isnull(replacement_actual.replacement_actual,0)
						,@registration_actual_amount	= isnull(stnk_actual.amount,0)
						,@borrow_actual					= 0
						,@sale_fee_actual				= 0
				from	dbo.asset_expense_ledger ael
					outer apply
						(
							SELECT sum (ael2.EXPENSE_AMOUNT) 'amount'
							from ifinams.dbo.ASSET_EXPENSE_LEDGER ael2
							where reff_name = 'WORK ORDER'
							and ael2.agreement_no = ael.agreement_no
							and ael2.asset_code = @asset_code
						) maintenance_actual
					outer apply
						(
							SELECT sum (ael2.EXPENSE_AMOUNT) 'amount'
							from ifinams.dbo.ASSET_EXPENSE_LEDGER ael2
							where reff_name = 'INSURANCE POLICY'
							and ael2.agreement_no = ael.agreement_no
							and ael2.asset_code = @asset_code
						) insurance_actual
					outer apply
						(
							select sum (ael2.expense_amount) 'amount'
							from ifinams.dbo.asset_expense_ledger ael2
							where reff_name = 'REGISTER'
							--where reff_name = 'REALIZATION'
							and ael2.agreement_no = ael.agreement_no
							and ael2.asset_code = @asset_code
						) stnk_actual
					outer apply
						(
							select sum (ael2.expense_amount) 'amount'
							from ifinams.dbo.asset_expense_ledger ael2
							where reff_name = 'PROCUREMENT MOBILISASI'
							and ael2.agreement_no = ael.agreement_no
							and ael2.asset_code = @asset_code
						) mobilisasi_actual
					outer apply
						(
							select	sum (ael2.expense_amount) 'replacement_actual'
							from	ifinopl.dbo.asset_replacement_detail arp
									inner join ifinams.dbo.asset ast on ast.code					  = arp.new_fa_code
									inner join ifinams.dbo.asset_expense_ledger ael2 on ael2.asset_code = arp.new_fa_code
							where	ael2.agreement_no = ael.agreement_no and arp.new_fa_code=ael.asset_code
						) replacement_actual
				where	ael.agreement_no = @agreement_no_code and ael.asset_code = @p_asset_code;

				select	@sale_fee_actual = sum(expense_amount)
				from	dbo.asset_expense_ledger
				where	asset_code		 = @p_asset_code
						and agreement_no = @agreement_no_code
						and reff_name = 'SALE FEE';

				update	dbo.rpt_profitability_asset_expense
				set		insurance_actual_expense			= isnull(@insurance_actual_amount, 0)
						,maintenance_actual_expense			= isnull(@maintenance_actual_amount, 0)
						,mobilization_actual_expense		= isnull(@mobilisasi_actual_amount, 0)
						,replacement_car_actual_expense		= isnull(dbo.xfn_get_expense_replacement_asset(@p_asset_code), 0)
						,stnk_keur_actual_expense			= isnull(@registration_actual_amount, 0)
						,borrow_actual_expense				= isnull(dbo.xfn_get_amount_borrowing_asset(@p_asset_code, dbo.xfn_get_system_date(), @agreement_no_code_2), 0)
						,sale_fee_actual					= isnull(@sale_fee_actual, 0)
				where	kontrak_expense = @agreement_no_code_2
						and user_id		= @p_user_id ;
				
				--if @insurance_actual_amount is null and @maintenance_actual_amount is null and @mobilisasi_actual_amount is null and @replacement_actual_amount is null and @registration_actual_amount is null and @sale_fee_actual is null and isnull(dbo.xfn_get_amount_borrowing_asset(@p_asset_code,dbo.xfn_get_system_date(),@agreement_no_code),0)=0
				--begin
				--	update	dbo.rpt_profitability_asset_expense
				--	set		insurance_actual_expense			= isnull(0,0)
				--			,maintenance_actual_expense			= isnull(0,0)
				--			,mobilization_actual_expense		= isnull(0,0)
				--			,replacement_car_actual_expense		= isnull(0,0)
				--			,stnk_keur_actual_expense			= isnull(0,0)
				--			,borrow_actual_expense				= isnull(0,0)
				--	where	user_id = @p_user_id;
				--end;

				--dikomen karena ganti field
				select		@profit_loss_actual = isnull(rpai.actual_income,0)+isnull(rpai.actual_sell,0)-isnull(rpae.insurance_actual_expense,0)-isnull(rpae.maintenance_actual_expense,0)-isnull(rpae.replacement_car_actual_expense,0)-isnull(rpae.mobilization_actual_expense,0)-isnull(rpae.stnk_keur_actual_expense,0)-isnull(rpae.borrow_actual_expense,0)-isnull(rpae.sale_fee_actual,0)
							,@total_budget = (isnull(rpai.budget_income,0)+isnull(rpai.budget_sell,0)) - (isnull(rpae.insurance_budget_expense,0) + isnull(rpae.maintenance_budget_expense,0) + isnull(rpae.replacement_car_budget_expense,0) + isnull(rpae.mobilization_budget_expense,0) + isnull(rpae.stnk_keur_budget_expense,0)+isnull(rpae.borrow_burget_expense,0)+isnull(rpae.sale_fee_budget,0))
							--@profit_loss_actual = isnull(sum(rpai.actual_income+isnull(rpai.actual_sell,0)), 0) - isnull(sum(rpae.insurance_actual_expense + rpae.maintenance_actual_expense + rpae.replacement_car_actual_expense + rpae.mobilization_actual_expense + rpae.stnk_keur_actual_expense+rpae.borrow_actual_expense+rpae.sale_fee_actual), 0)
							--,@total_budget	= isnull(sum(rpai.budget_income+isnull(rpai.budget_sell,0)), 0) - isnull(sum(rpae.insurance_budget_expense + rpae.maintenance_budget_expense + rpae.replacement_car_budget_expense + rpae.mobilization_budget_expense + rpae.stnk_keur_budget_expense+isnull(rpae.borrow_burget_expense,0)+rpae.sale_fee_budget), 0)
				--from		dbo.rpt_profitability_asset rpa
				--			left join dbo.rpt_profitability_asset_expense rpae on rpae.kontrak_expense = rpa.kontrak
				--			left join dbo.rpt_profitability_asset_income rpai on rpai.kontrak_income   = rpa.kontrak
				--where		rpa.kontrak = @agreement_no_code_2 and rpa.user_id=@p_user_id;
				from		dbo.rpt_profitability_asset rpa
							--left join dbo.rpt_profitability_asset_expense rpae on rpae.kontrak_expense = rpa.kontrak
							--left join dbo.rpt_profitability_asset_income rpai on rpai.kontrak_income   = rpa.kontrak
							outer apply(
								select	*
								from	dbo.rpt_profitability_asset_expense
								where	kontrak_expense = rpa.kontrak
										and user_id		= rpa.user_id
							)rpae
							outer apply(
								select	*
								from	dbo.rpt_profitability_asset_income
								where	kontrak_income = rpa.kontrak
										and user_id	   = rpa.user_id
							)rpai
				where		rpa.kontrak =  @agreement_no_code_2 and rpae.user_id = @p_user_id;
				select @agreement_no_code_2,@profit_loss_actual,@total_budget
				update		dbo.rpt_profitability_asset
				set			profit_loss_actual	= @profit_loss_actual
							,net_profit_loss	= @profit_loss_actual + gain_loss_penjualan
							,total_budget       = @total_budget
				where		user_id		= @p_user_id
							and kontrak = @agreement_no_code_2 ;

				--select @nilai_sisa = sum(aaa.billing_amount) 
				--from ifinopl.dbo.agreement_asset_amortization aaa
				--left join ifinopl.dbo.invoice inv on (inv.invoice_no = aaa.invoice_no)
				--where aaa.agreement_no = @agreement_no_code
				--and aaa.asset_no = @asset_no
				--and inv.invoice_status <> 'PAID'

				
			--if not exists(select 1 from dbo.rpt_profitability_asset_expense where user_id=@p_user_id and KONTRAK_EXPENSE=@agreement_no_code_2)
			--	insert into dbo.rpt_profitability_asset_expense
			--	(
			--		user_id
			--		,kontrak_expense
			--		,description_expense
			--		,insurance_budget_expense
			--		,insurance_actual_expense
			--		,maintenance_budget_expense
			--		,maintenance_actual_expense
			--		,mobilization_budget_expense
			--		,mobilization_actual_expense
			--		,replacement_car_budget_expense
			--		,replacement_car_actual_expense
			--		,stnk_keur_budget_expense
			--		,stnk_keur_actual_expense
			--		,profit_loss_actual
			--	)
			--	values
			--	(
			--		 @p_user_id 
			--		,@agreement_no_code_2
			--		,null
			--		,0 
			--		,0 
			--		,0 
			--		,0 
			--		,0 
			--		,0 
			--		,0 
			--		,0 
			--		,0 
			--		,0 
			--		,0 
			--	) ;

			if not exists(select 1 from dbo.rpt_profitability_asset_income where user_id=@p_user_id and KONTRAK_INCOME = @agreement_no_code_2)
				insert into dbo.rpt_profitability_asset_income
				(
					user_id
					,kontrak_income
					,description_income
					,budget_income
					,actual_income
					,budget_sell
					,actual_sell
				)
				values
				(	@p_user_id -- user_id - nvarchar(50)
					,@agreement_no_code_2 -- kontrak_income - nvarchar(50)
					,'-' -- description_income - nvarchar(100)
					,0 -- budget_income - decimal(18, 2)
					,0 -- actual_income - decimal(18, 2)
					,0
					,0
				) ;

			fetch next from curr_agreement
			into @agreement_no_code
				 ,@agreement_no_code_2
				 ,@asset_code
			end
		
			close curr_agreement
			deallocate curr_agreement

			--select @expense_amount = isnull(sum(budget_expense),0)
			--from dbo.rpt_profitability_asset_expense
			--where user_id = @p_user_id ;

			--select @income_amount = isnull(sum(budget_income),0)
			--from dbo.rpt_profitability_asset_income
			--where user_id = @p_user_id ;

			--select @kontrak			= aa.agreement_no
			--from	dbo.sale_detail sd
			--		left join ifinopl.dbo.agreement_asset aa on (sd.asset_code = aa.fa_code)
			--		left join ifinopl.dbo.agreement_asset_amortization aaa on (aaa.asset_no = aa.asset_no)
			--		left join ifinopl.dbo.agreement_invoice_payment aip on (aip.asset_no = aaa.asset_no)
			--where	sd.asset_code = @p_asset_code
			--group by aa.agreement_no

			--update dbo.rpt_profitability_asset
			--set	profit_loss_actual	 = isnull(@expense_amount,0) + isnull(@income_amount,0)
			--	,net_profit_loss	 = (isnull(@expense_amount,0) + isnull(@income_amount,0)) + isnull(gain_loss_penjualan,0)
			--where user_id = @p_user_id 
		END
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;



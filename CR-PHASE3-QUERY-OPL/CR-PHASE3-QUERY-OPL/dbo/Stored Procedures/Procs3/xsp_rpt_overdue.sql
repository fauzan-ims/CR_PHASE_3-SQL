--Created by, Rian at 22/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_overdue
(
	@p_user_id		   nvarchar(50)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_as_of_date	   datetime
	,@p_is_condition   nvarchar(1)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	delete dbo.rpt_overdue
	where	user_id = @p_user_id ;

	declare @msg					 nvarchar(max)
			,@branch_name			 nvarchar(250)
			,@month					 nvarchar(25)
			,@year					 int
			,@report_company		 nvarchar(250)
			,@report_image			 nvarchar(250)
			,@report_title			 nvarchar(250)
			,@agreement_no			 nvarchar(50)
			,@customer_code			 nvarchar(50)
			,@customer_name			 nvarchar(250)
			,@total_periode			 int
			,@running_period		 int
			,@top_period			 int
			,@top_days				 int
			,@top_date				 datetime
			,@rental_fee_exclude_vat decimal(18, 2)
			,@rental_fee_include_vat decimal(18, 2)
			,@od_pct				 decimal(9, 6)
			,@amount_od_exclude_vat	 decimal(18, 2)
			,@od_days				 int
			,@agreement_status		 nvarchar(50)
			,@marketing				 nvarchar(250)
			,@marketing_leader		 nvarchar(250)
			,@status_unit			 nvarchar(50)
			,@ppn_pct				 decimal(9, 6) ;

	begin try
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@ppn_pct = value
		from	dbo.sys_global_param
		where	code = ('RTAXPPN') ;

		set @report_title = 'Report Overdue' ;

		-- (+) Ari 04-09-2023 ket : add table temp
		declare @table_temp		table
		(
			user_id					nvarchar(50)
			,filter_branch			nvarchar(250)
			,branch_code			nvarchar(50)
			,branch_name			nvarchar(250)
			,as_of_date				datetime
			,report_company			nvarchar(250)
			,report_image			nvarchar(250)
			,report_title			nvarchar(250)
			,agreement_no			nvarchar(50)
			,customer_code			nvarchar(50)
			,customer_name			nvarchar(250)
			,total_periode			int
			,running_period			nvarchar(50)
			,top_period				int
			,top_days				int
			,top_date				datetime
			,rental_fee_exclude_vat	decimal(18,2)
			,rental_fee_include_vat	decimal(18,2)
			,od_pct					decimal(18,2)
			,amount_od_exclude_vat	decimal(18,2)
			,amount_od_include_vat	decimal(18,2)
			,od_days				int
			,agreement_status		nvarchar(50)
			,marketing				nvarchar(250)
			,marketing_leader		nvarchar(250)
			,status_unit			nvarchar(50)
			,invoice_paid			nvarchar(50)
			,invoice_not_due		nvarchar(50)
			,is_condition			nvarchar(1)
			--	
			,cre_date				datetime
			,cre_by					nvarchar(15)
			,cre_ip_address			nvarchar(15)
			,mod_date				datetime
			,mod_by					nvarchar(15)
			,mod_ip_address			nvarchar(15)
		)

		declare @table_temp2	table
		(
			agreement_ext	nvarchar(50)
			,paid			decimal(18,2)
			--,period			nvarchar(10)
		)

		-- (+) Ari 04-09-2023 ket : insert to table temp
		insert into @table_temp
		(
			user_id
			,filter_branch
			,branch_code
			,branch_name
			,as_of_date
			,report_company
			,report_image
			,report_title
			,agreement_no
			,customer_code
			,customer_name
			,total_periode
			,running_period
			,top_period
			,top_days
			,top_date
			,rental_fee_exclude_vat
			,rental_fee_include_vat
			,od_pct
			,amount_od_exclude_vat
			,amount_od_include_vat
			,od_days
			,agreement_status
			,marketing
			,marketing_leader
			,status_unit
			,invoice_paid
			,invoice_not_due
			,is_condition
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select		distinct
					@p_user_id
					,@branch_name
					,am.BRANCH_CODE
					,am.branch_name
					,@p_as_of_date
					,@report_company
					,@report_image
					,@report_title
					,am.agreement_external_no
					,am.client_no
					,am.client_name
					--,am.periode
					,periode.periode -- (+) Ari 2023-10-31
					--,runperiod.running_period
					,0
					,topdate.top_period
					,am.credit_term
					,topdate.top_date
					,topdate2.rental_fee_exclude_vat
					,topdate2.rental_fee_include_vat
					--,isnull(cast((agi.ovd_penalty_amount/topdate.rental_fee_exclude_vat) as decimal(9,6)),0)
					--,isnull(agi.ovd_penalty_amount,0)/isnull(topdate.rental_fee_exclude_vat,0)  'od_x'
					,isnull(nullif(od_amount.rental_fee_exclude_vat_last_month,0)/nullif(topdate2.rental_fee_exclude_vat,0),0) 'odx'
					,isnull(od_amount.rental_fee_exclude_vat_last_month,0)
					,isnull(od_amount.rental_fee_include_vat_last_month,0)
					,agi.ovd_days
					,am.agreement_status
					,sem.marketing_name
					,sem.marketing_head
					,case
						 when agas.is_request_gts = '1'
							  and	isnull(agas.replacement_fa_code, '') <> '' then 'GTS'
						 when agas.is_request_gts = '0'
							  and	isnull(agas.replacement_fa_code, '') <> '' then 'REPLACEMENT'
						 else 'UNIT UTAMA'
					 end
					--,isnull(convert(nvarchar(50),paid.billing_no),'0') + '/' + convert(nvarchar(50),am.periode) -- (+) Ari 2023-10-16 ket : get invoice paid
					,'0/' + convert(nvarchar(50),periode.periode)
					--,isnull(convert(nvarchar(50),not_due.due),'0') + '/' + convert(nvarchar(50),am.periode) -- (+) Ari 2023-10-16 ket : get invoice not due
					,'0/' + convert(nvarchar(50),periode.periode)
					,@p_is_condition
					--
					,@p_cre_date	   
					,@p_cre_by		   
					,@p_cre_ip_address 
					,@p_mod_date	   
					,@p_mod_by		   
					,@p_mod_ip_address 
					
		from		dbo.agreement_main am
					inner join dbo.agreement_information agi on (agi.agreement_no = am.agreement_no)
					--outer apply (
					--				select	count(iv.invoice_no) 'running_period'
					--				from	dbo.invoice iv 
					--						--inner join dbo.invoice_detail ivd on(iv.invoice_no = ivd.invoice_no)
					--				where	exists (select 1 from dbo.invoice_detail ivd where ivd.invoice_no = iv.invoice_no and ivd.agreement_no = am.agreement_no)
					--				and		iv.invoice_status = 'POST'
					--				and		iv.invoice_date <= @p_as_of_date
					--			) runperiod
					outer apply (
									select	max(iv.invoice_due_date) 'top_date'
											,count(iv.invoice_no) 'top_period'
									from	dbo.invoice iv 
											inner join invoice_detail invd on invd.invoice_no=iv.invoice_no
											inner join agreement_asset asat on asat.asset_no = invd.asset_no and invd.agreement_no = asat.agreement_no
									where	--exists (select 1 from dbo.invoice_detail ivd where ivd.invoice_no = iv.invoice_no and ivd.agreement_no = am.agreement_no)
											-- (+) Ari 2023-10-03 ket : ganti dari exist jadi yg biasa
											invd.invoice_no = iv.invoice_no and invd.agreement_no = am.agreement_no
									and		iv.invoice_status = 'POST'
									and		iv.invoice_due_date <= @p_as_of_date
								) topdate
					outer apply (
									--select	sum(aaa.billing_amount) 'rental_fee_exclude_vat'
									--		,sum(aaa.billing_amount +  case
									--											when asat.billing_to_faktur_type='01' then aaa.billing_amount * @ppn_pct
									--											else 0
									--										end) 'rental_fee_include_vat'
									--from	dbo.invoice iv 
									--		inner join invoice_detail invd on invd.invoice_no=iv.invoice_no and invd.agreement_no = am.agreement_no
									--		inner join agreement_asset asat on asat.asset_no = invd.asset_no and invd.agreement_no = asat.agreement_no
									--		inner join dbo.agreement_asset_amortization aaa on aaa.asset_no = asat.asset_no and aaa.agreement_no = asat.agreement_no

									-- (+) Ari 2023-10-03 ket : change get data billing langsung 
									select	sum(asat.lease_rounded_amount) 'rental_fee_exclude_vat'
											,sum(asat.lease_rounded_amount +  case
																		when asat.billing_to_faktur_type='01' then asat.lease_rounded_amount * @ppn_pct/100
																		else 0
																	end) 'rental_fee_include_vat' 
									from	dbo.agreement_asset asat
									where	asat.agreement_no = am.agreement_no
								) topdate2
					outer apply (
								select	sum(aaa.billing_amount) 'rental_fee_exclude_vat_last_month'
										,sum(invd.billing_amount +  case
																		when asat.billing_to_faktur_type='01' then invd.ppn_amount
																		else 0
																	end) 'rental_fee_include_vat_last_month'
										--,sum(iv.total_billing_amount) 'rental_fee_include_vat_last_month'
										--,sum(iv.total_billing_amount + case
										--										when asat.billing_to_faktur_type='01' then iv.total_ppn_amount
										--										else 0
										--									end) 'rental_fee_include_vat_last_month'
								from	dbo.invoice_detail invd
										inner join invoice iv on invd.invoice_no=iv.invoice_no and iv.invoice_type='rental' and iv.invoice_status='POST' --and iv.invoice_due_date<=dbo.xfn_get_system_date() (+) ari 2023-10-03 ket : dicomment karena sudah ada kondisi dibawah
										inner join agreement_asset asat on asat.asset_no = invd.asset_no and invd.agreement_no = asat.agreement_no
										inner join dbo.agreement_asset_amortization aaa on aaa.asset_no = asat.asset_no and aaa.agreement_no = asat.agreement_no and aaa.invoice_no = iv.invoice_no
								where	asat.agreement_no = am.agreement_no
								--where	exists (select 1 from dbo.invoice_detail ivd where ivd.invoice_no = iv.invoice_no and ivd.agreement_no = am.agreement_no)
								and		cast(iv.invoice_due_date as date)<=cast(@p_as_of_date as date)
							) od_amount
					-- (+) Ari 2023-09-04 ket : change to outher apply
					outer apply (
									select	sem.name 'marketing_name'
											,head.name 'marketing_head'
									from	ifinsys.dbo.sys_employee_main sem
									inner	join ifinsys.dbo.sys_employee_main head on (sem.head_emp_code = head.code)
									where	sem.code = am.marketing_code
								)sem
					-- (+) Ari 2023-09-04
					outer apply (
									select	aas.is_request_gts 'is_request_gts'
											,aas.replacement_fa_code 'replacement_fa_code'
									from	dbo.agreement_asset aas
									where	aas.agreement_no = am.agreement_no
								) agas
					-- (+) Ari 2023-10-16 ket : get invoice paid and invoice not due
					--outer apply (
					--				--select	count(1) 'billing_no'
					--				--from	dbo.invoice_detail id
					--				--where	id.agreement_no = am.agreement_no
					--				--and		id.invoice_no in (
					--				--							select	i.invoice_no 
					--				--							from	dbo.invoice i 
					--				--							where	i.invoice_no = id.invoice_no
					--				--							and		i.invoice_status = 'PAID'
					--				--						 )
					--				--and		id.asset_no in   (
					--				--							select	top 1 aa.asset_no 
					--				--							from	dbo.agreement_asset	aa
					--				--							where	aa.agreement_no = am.agreement_no
					--				--						 )

					--				select sum(total.bil) 'billing_no'
					--				from ( 
					--						select	cast(cast(count(id.billing_no) as decimal(18,2)) / cast(qty.asset as decimal(18,2)) as decimal(18,2)) 'bil'
					--						from	dbo.invoice_detail id
					--						outer	apply (
					--										select	count(aa.asset_no) 'asset'
					--										from	dbo.agreement_asset aa
					--										where	aa.agreement_no = am.agreement_no
					--									  ) qty
					--						where	id.agreement_no = am.agreement_no
					--						and		id.invoice_no in (
					--													select	aaa.invoice_no
					--													from	dbo.agreement_asset_amortization aaa with (nolock)
					--													where	aaa.agreement_no = id.agreement_no
					--													and		aaa.asset_no = id.asset_no
					--													and		aaa.billing_no = id.billing_no
					--													and		id.invoice_no in (
					--																				select	aip.invoice_no 
					--																				from	dbo.agreement_invoice_payment aip with (nolock)
					--																				where	aip.agreement_no = id.agreement_no
					--																				and		aip.asset_no = id.asset_no
					--																				)
					--												)
					--						group	by	id.billing_no
					--									,qty.asset
					--					) total

					--			) paid
					--outer apply (
										--select	count(1) 'due' 
										--from	dbo.agreement_asset_amortization aaa
										--where	aaa.billing_no  in (

										--							select	id.billing_no
										--							from	dbo.invoice_detail id 
										--							where	id.agreement_no = am.agreement_no
										--							and		id.invoice_no in (
										--														select	i.invoice_no 
										--														from	dbo.invoice i 
										--														where	i.invoice_no = id.invoice_no
										--														and		i.invoice_status = 'POST'
										--														and		i.invoice_due_date > dbo.xfn_get_system_date()
										--													 )
										--						)
										--and		aaa.agreement_no = am.agreement_no

										-- (+) Ari 2023-10-27 ket : change not due
								--		select	sum(due.due) 'due'
								--		from	( 
								--					select	cast(cast(count(aaa.billing_no) as decimal(18,2)) / cast(qty.asset as decimal(18,2)) as decimal(18,2)) 'due' 
								--					from	dbo.agreement_asset_amortization aaa with (nolock)
								--					outer	apply (
								--									select	count(aa.asset_no) 'asset'
								--									from	dbo.agreement_asset aa
								--									where	aa.agreement_no = aaa.agreement_no
								--									) qty
								--					where	aaa.agreement_no = am.agreement_no
								--					and		( 
								--								isnull(aaa.invoice_no,'') in (
								--																	select	isnull(id.invoice_no,'')
								--																	from	dbo.invoice_detail id 
								--																	where	id.agreement_no = aaa.agreement_no
								--																	and		id.invoice_no in (select i.invoice_no from dbo.invoice i where i.invoice_no = id.invoice_no and ( i.invoice_status = 'NEW' or i.invoice_status = 'POST' and i.invoice_due_date < dbo.xfn_get_system_date()))
								--																	--and		exists (select 1 from dbo.invoice i where i.invoice_no = id.invoice_no and ( i.invoice_status = 'NEW' and i.invoice_due_date < dbo.xfn_get_system_date() or i.invoice_status = 'POST' and i.invoice_due_date > dbo.xfn_get_system_date()))
								--																	--and		id.asset_no = aaa.asset_no
								--																)
								--								--or isnull(aaa.invoice_no,'') = ''
								--							)
								--					group	by qty.asset
								--				) due
								--		-- (+) Ari 2023-10-27
								--) not_due
					--(+) Ari 2023-10-31 ket : get max installment (jika ada change due date)
					outer apply (
									select	max(aaa.billing_no) 'periode'
									from	dbo.agreement_asset_amortization aaa
									where	aaa.agreement_no = am.agreement_no
								) periode
					--(+) Ari 2023-10-31
		where		am.branch_code	= case @p_branch_code
												when 'ALL' then am.branch_code
												else @p_branch_code
											end 
					and	am.agreement_status = 'GO LIVE'
					and od_amount.rental_fee_include_vat_last_month > 0 ; -- (+) Ari 2023-09-04 ket : only status GO LIVE
		
		insert @table_temp2
		(
			agreement_ext
			,paid
			--,period
		)
		select	temp.agreement_no
				,cast(cast(count(id.billing_no) as decimal(18,2)) / cast(qty.asset as decimal(18,2)) as decimal(18,2))
				--,am.periode
		from	@table_temp temp
		inner	join dbo.agreement_main am with (nolock) on (am.agreement_external_no = temp.agreement_no)
		inner	join dbo.invoice_detail id with (nolock) on (id.agreement_no = am.agreement_no)
		outer	apply (
						select	count(aa.asset_no) 'asset'
						from	dbo.agreement_asset aa with (nolock)
						where	aa.agreement_no = am.agreement_no
					  ) qty
		where	id.agreement_no = am.agreement_no
		and		id.invoice_no in (
									select	aaa.invoice_no
									from	dbo.agreement_asset_amortization aaa with (nolock) 
									where	aaa.agreement_no = id.agreement_no
									and		aaa.asset_no = id.asset_no
									and		aaa.billing_no = id.billing_no
									and		id.invoice_no in (
																select	aip.invoice_no 
																from	dbo.agreement_invoice_payment aip with (nolock) 
																where	aip.agreement_no = id.agreement_no
																and		aip.asset_no = id.asset_no
															  )
								)
		group	by	temp.agreement_no
					,qty.asset
					--,am.periode

		declare @agreement_ext	nvarchar(50)
				,@paid			nvarchar(50)
				,@period		nvarchar(10)
				,@run_period	nvarchar(10)

		declare curr_paid cursor fast_forward read_only for
		select	agreement_ext
			   ,paid 
			   --,period
		from	@table_temp2
		open curr_paid
		
		fetch next from curr_paid 
		into @agreement_ext
			,@paid
			--,@period
		
		while @@fetch_status = 0
		begin
			
			set @paid = isnull(@paid,0)

			select	@period = max(aaa.billing_no) 
			from	dbo.agreement_asset_amortization aaa with (nolock)
			inner	join dbo.agreement_main am with (nolock) on (am.agreement_no = aaa.agreement_no)
			where	am.agreement_external_no = @agreement_ext

			update	@table_temp
			set		invoice_paid = (@paid + '/' + @period)
			where	agreement_no = @agreement_ext
		
		    fetch next from curr_paid 
			into @agreement_ext
				,@paid
				--,@period
		end
		
		close curr_paid
		deallocate curr_paid


		declare @remaining	nvarchar(50)
		
		declare curr_notdue cursor fast_forward read_only for 
		select	cast(count(invoice_no) / cast(ins.qty as decimal(18,2)) as decimal(18,2)) + outstanding.period
				,am.agreement_external_no
		from	dbo.invoice_detail id with (nolock)
		inner	join dbo.agreement_main am with (nolock) on (am.agreement_no = id.agreement_no)
		outer	apply (
						--select	aa.periode
						--		,count(aa.asset_no) 'qty'
						--from	dbo.agreement_asset aa
						--where	aa.agreement_no = am.agreement_no
						--group  by aa.periode

						select	aaa.periode
								,count(aas.asset_no) 'qty'
						from	dbo.agreement_asset aas with (nolock)
						outer	apply (
										select	max(aaa.billing_no) 'periode' 
										from	dbo.agreement_asset_amortization aaa with (nolock)
										where	aaa.agreement_no = aas.agreement_no
										and		aaa.asset_no = aas.asset_no
										) aaa
						where	aas.agreement_no = am.agreement_no
						group  by aaa.periode
						) ins
		outer	apply (
						select	ins.periode - cast(count(invoice_no) / cast(ins.qty as decimal(18,2)) as decimal(18,2)) 'period'
						from	dbo.invoice_detail idt
						outer	apply (
										--select	aas.periode
										--		,count(aas.asset_no) 'qty'
										--from	dbo.agreement_asset aas
										--where	aas.agreement_no = am.agreement_no
										--group  by aas.periode
										
										select	aaa.periode
												,count(aas.asset_no) 'qty'
										from	dbo.agreement_asset aas with (nolock)
										outer	apply (
														select	max(aaa.billing_no) 'periode' 
														from	dbo.agreement_asset_amortization aaa with (nolock)
														where	aaa.agreement_no = aas.agreement_no
														and		aaa.asset_no = aas.asset_no
													  ) aaa
										where	aas.agreement_no = am.agreement_no
										group  by aaa.periode
										) ins
						where	idt.agreement_no = am.agreement_no
						and		idt.invoice_no in (select i.invoice_no from dbo.invoice i where i.invoice_no = idt.invoice_no and i.invoice_status in ('new','post','paid'))
						group	by ins.qty
									,ins.periode
						) outstanding
		where	id.invoice_no in (select i.invoice_no from dbo.invoice i where i.invoice_no = id.invoice_no and ((i.invoice_status = 'POST' and i.invoice_due_date > dbo.xfn_get_system_date()) or i.INVOICE_STATUS = 'NEW')) --(select i.invoice_no from dbo.invoice i where i.invoice_no = id.invoice_no and i.invoice_status in ('NEW','POST') and i.invoice_due_date > dbo.xfn_get_system_date())
		group by ins.qty
				,outstanding.period
				,am.agreement_external_no

		open curr_notdue
		
		fetch next from curr_notdue 
		into @remaining
			 ,@agreement_ext
		
		while @@fetch_status = 0
		begin

			select	@run_period = count(id.invoice_no) / ast.qty
			from	dbo.invoice_detail id
			inner	join dbo.invoice i on (i.invoice_no = id.invoice_no)
			inner	join dbo.agreement_main am on (am.agreement_no = id.agreement_no)
			outer	apply (
							select	count(aa.asset_no) 'qty'
							from	dbo.agreement_asset aa
							where	aa.agreement_no = am.agreement_no
						  ) ast
			where	i.invoice_status = 'POST'
			and		i.invoice_due_date <= dbo.xfn_get_system_date()
			and		am.agreement_external_no = @agreement_ext
			group by ast.qty

		    update	@table_temp
			set		invoice_not_due = isnull(@remaining,0) + '/' + cast(total_periode as nvarchar(50))
					,running_period = (isnull(@run_period,0) + '/' + cast(total_periode as nvarchar(50)))
			where	agreement_no = @agreement_ext
		
		    fetch next from curr_notdue 
			into @remaining
				,@agreement_ext
		end
		
		close curr_notdue
		deallocate curr_notdue

		insert into dbo.rpt_overdue
		(
			user_id
			,filter_branch
			,branch_code
			,branch_name
			,as_of_date
			,report_company
			,report_image
			,report_title
			,agreement_no
			,customer_code
			,customer_name
			,total_periode
			,running_period
			,top_period
			,top_days
			,top_date
			,rental_fee_exclude_vat
			,rental_fee_include_vat
			,od_pct
			,amount_od_exclude_vat
			,amount_od_include_vat
			,od_days
			,agreement_status
			,marketing
			,marketing_leader
			,status_unit
			,invoice_paid -- (+) Ari 2023-10-16 ket : get invoice paid
			,invoice_not_due -- (+) Ari 2023-10-16 ket : get invoice not due
			,is_condition
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		--select		@p_user_id
		--			,@branch_name
		--			,inv.BRANCH_CODE
		--			,inv.branch_name
		--			,@p_as_of_date
		--			,@report_company
		--			,@report_image
		--			,@report_title
		--			,am.agreement_external_no
		--			,am.client_no
		--			,am.client_name
		--			,am.periode
		--			,cast(oapinvd.invoice_no as int)--agi.current_installment_no
		--			,cast(oapivd.invoice_no as int)--max(invd.billing_no)
		--			,cast(oapivd.invoice_date as int)--am.credit_term
		--			,inv.invoice_due_date
		--			,sum(invd.billing_amount)
		--			,sum(invd.billing_amount) + sum(invd.ppn_amount)
		--			,0--ac.charges_rate
		--			,oapivd.total_billing_amount--ago.obligation_amount
		--			,oapidgi.ovd_days--ago.obligation_day
		--			,am.agreement_status
		--			,am.marketing_name
		--			,sbs.signer_name
		--			,case
		--				 when agas.is_request_gts = '1'
		--					  and	isnull(agas.replacement_fa_code, '') <> '' then 'GTS'
		--				 when agas.is_request_gts = '0'
		--					  and	isnull(agas.replacement_fa_code, '') <> '' then 'REPLACEMENT'
		--				 else 'UNIT UTAMA'
		--			 end
		--			,@p_is_condition
		--			--
		--			,@p_cre_date	   
		--			,@p_cre_by		   
		--			,@p_cre_ip_address 
		--			,@p_mod_date	   
		--			,@p_mod_by		   
		--			,@p_mod_ip_address 
		--from		dbo.invoice inv
		--			left join dbo.invoice_detail invd on (invd.invoice_no = inv.invoice_no)
		--			left join dbo.agreement_obligation ago on (ago.agreement_no = invd.agreement_no and ago.asset_no = invd.asset_no and ago.invoice_no = invd.invoice_no and ago.obligation_type = 'OVDP')
		--			left join dbo.agreement_invoice ai on (ai.invoice_no = inv.invoice_no)
		--			left join dbo.agreement_main am on (am.agreement_no = ai.agreement_no)
		--			left join dbo.agreement_information agi on (agi.agreement_no = ai.agreement_no)
		--			left join dbo.agreement_charges ac on (
		--													  ac.agreement_no = am.agreement_no
		--													  and  ac.charges_code = 'ovdp'
		--												  )
		--			left join ifinsys.dbo.sys_branch_signer sbs on (
		--															   sbs.branch_code = inv.branch_code
		--															   and sbs.signer_type_code = 'depthead'
		--														   )
		--			outer apply (
		--							select	aas.is_request_gts 'is_request_gts'
		--									,aas.replacement_fa_code 'replacement_fa_code'
		--							from	dbo.agreement_asset aas
		--							where	aas.agreement_no = am.agreement_no
		--						) agas
		--			outer apply (
		--						select	count(ivc.invoice_no)'invoice_no'
		--								,max(invoice_date)'invoice_date'
		--								,sum(total_billing_amount)'total_billing_amount'
		--						from	dbo.invoice ivc
		--						where	ivc.invoice_due_date < cast(@p_as_of_date as date) 
		--								and ivc.invoice_status = 'POST' 
		--								and ivc.invoice_no = inv.invoice_no
		--						) oapivd
		--			outer apply (
		--						select	count(ivc.invoice_no)'invoice_no'
		--						from	dbo.invoice ivc
		--						where	ivc.invoice_date < cast(@p_as_of_date as date)
		--								and ivc.invoice_status = 'POST' 
		--								and ivc.invoice_no = inv.invoice_no
		--						) oapinvd
		--			outer apply (
		--						select	max(ovd_days) 'ovd_days'
		--						from	dbo.invoice_detail ivd 
		--								inner join dbo.agreement_information ai on(ai.agreement_no = invd.agreement_no)
		--						where	ivd.invoice_no = inv.invoice_no
		--						) oapidgi
		--where		inv.invoice_status	= 'POST'
		--			and inv.branch_code	= case @p_branch_code
		--										when 'ALL' then inv.branch_code
		--										else @p_branch_code
		--									end 
		--			and cast(inv.invoice_date as date) <= cast(@p_as_of_date as date)
		--group by	am.agreement_external_no
		--			,am.client_no
		--			,am.client_name
		--			,am.periode
		--			,oapinvd.invoice_no--agi.current_installment_no
		--			,oapivd.invoice_no--max(invd.billing_no)
		--			,oapivd.invoice_date--am.credit_term
		--			,ac.charges_rate
		--			,oapivd.total_billing_amount--ago.obligation_amount
		--			,oapidgi.ovd_days--ago.obligation_day
		--			,am.agreement_status
		--			,am.marketing_name
		--			,sbs.signer_name
		--			,inv.invoice_no
		--			,agas.replacement_fa_code
		--			,agas.is_request_gts
		--			,inv.branch_code
		--			,inv.branch_name
		--			,inv.invoice_due_date

		-- (+) Ari 04-09-2023
		select	user_id
			    ,filter_branch
			    ,branch_code
			    ,branch_name
			    ,as_of_date
			    ,report_company
			    ,report_image
			    ,report_title
			    ,agreement_no
			    ,customer_code
			    ,customer_name
			    ,total_periode
			    ,case running_period
					when '0'
					then cast(('0/' + cast(total_periode as nvarchar(50))) as nvarchar(50))
					else running_period
				end
			    ,top_period
			    ,top_days
			    ,top_date
			    ,rental_fee_exclude_vat
			    ,rental_fee_include_vat
			    ,od_pct
			    ,amount_od_exclude_vat
				,amount_od_include_vat
			    ,od_days
			    ,agreement_status
			    ,marketing
			    ,marketing_leader
			    ,status_unit
				,invoice_paid -- (+) Ari 2023-10-16 ket : get invoice paid
				,invoice_not_due -- (+) Ari 2023-10-16 ket : get invoice not due
			    ,is_condition
			    ,cre_date
			    ,cre_by
			    ,cre_ip_address
			    ,mod_date
			    ,mod_by
			    ,mod_ip_address 
		from	@table_temp

		if not exists
		(
			select	1
			from	dbo.rpt_overdue
			where	user_id = @p_user_id
		)
		begin
			insert into dbo.rpt_overdue
			(
				user_id
				,branch_code
				,branch_name
				,as_of_date
				,report_company
				,report_image
				,report_title
				,agreement_no
				,customer_code
				,customer_name
				,total_periode
				,running_period
				,top_period
				,top_days
				,top_date
				,rental_fee_exclude_vat
				,rental_fee_include_vat
				,od_pct
				,amount_od_exclude_vat
				,amount_od_include_vat
				,od_days
				,agreement_status
				,marketing
				,marketing_leader
				,status_unit
				,invoice_paid
				,invoice_not_due
				,is_condition
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_user_id
				,@p_branch_code
				,@p_branch_name
				,@p_as_of_date
				,@report_company
				,@report_image
				,@report_title
				,''
				,''
				,''
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,''
				,''
				,''
				,''
				,null
				,null
				,@p_is_condition
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
		end ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

CREATE PROCEDURE dbo.xsp_rpt_agreement_amortization_backup
(
	@p_user_id		 NVARCHAR(50)
	,@p_agreement_no nvarchar(50)
)
as
begin
	delete	dbo.rpt_agreement_amortization
	where	user_id = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_image	 nvarchar(250)
			,@report_title	 nvarchar(50)
			,@report_company nvarchar(50)
			,@ext_agreement  nvarchar(50)
			-- (+) Ari 2023-10-30
			,@asset_no		 nvarchar(50)
			,@branch		 nvarchar(250)
			,@client_name	 nvarchar(250)
			,@agreement_date datetime
			,@asset_name	 nvarchar(250)
			,@plat_no		 nvarchar(250)
			,@period		 nvarchar(10)
			-- (+) Ari 2023-10-30

	begin try
		set @report_title = N'Statement of Account' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		declare @temptable table 
		(
			billing_date	datetime
			,agreement_no	nvarchar(50)
			,invoice_no		nvarchar(50)
		)

		insert into @temptable
		(
		    billing_date
			,agreement_no
			,invoice_no
		)
		select	aaa.billing_date
				,aaa.AGREEMENT_NO
				,aaa.INVOICE_NO
		from	dbo.agreement_asset_amortization aaa with(nolock)
		--where	aaa.agreement_no = @p_agreement_no
		--and		aaa.invoice_no = agiv.invoice_no

		insert into dbo.rpt_agreement_amortization
		(
			user_id
			,report_image
			,report_title
			,report_company
			,agreement_no
			,asset_no
			,client_name
			,branch
			,agreement_date
			,asset_name
			,billing_no
			,due_date
			,billing_date
			,billing_amount
			,invoice_no
			,billing_status
			,paid_date
			,voucher_no
			,invoice_due_date
			,payment_amount
			,plat_no
			,OVD_DAYS
			,OVD_BILLING_AMOUNT
			,PERIOD
		)
		select	distinct @p_user_id
				,@report_image
				,@report_title
				,@report_company
				,am.agreement_external_no
				,isnull(aas.asset_no,'-')
				,ai.client_name
				,ai.branch_name
				,am.agreement_date
				,aas.asset_name
				,agiv.billing_no
				--,isnull(ai.new_invoice_date,ai.invoice_date)
				,due_date.billing_date
				,''--ast.billing_date
				,agiv.ar_amount
				,ai.invoice_external_no
				,ai.invoice_status 'status'
				--,aaa.payment_date
				,pay_date.received_reff_date -- (+) Ari 2023-10-23
				,case when isnull(aaa.PAYMENT_AMOUNT, 0) > 0 and isnull(aaa.VOUCHER_NO, '') = '' then 'MIGRASI' else aaa.voucher_no end
				,ai.invoice_due_date
				,isnull(aaa.payment_amount,0)
				,isnull(aas.fa_reff_no_01, aas.replacement_fa_reff_no_01)
				--,case
				--	when payment_date is null then datediff(day,ai.INVOICE_DUE_DATE,dbo.xfn_get_system_date())
				--	else datediff(day,ai.INVOICE_DUE_DATE,aaa.PAYMENT_DATE)
				--end	
				,case
					when case
						--when payment_date is null then datediff(day,ai.invoice_due_date,dbo.xfn_get_system_date())
						--else datediff(day,ai.invoice_due_date,aaa.payment_date)
						 --(+) Ari 2023-10-23
						 when pay_date.received_reff_date is null then datediff(day,ai.invoice_due_date,dbo.xfn_get_system_date())
						 else datediff(day,ai.invoice_due_date,pay_date.received_reff_date)
						 --(+) Ari 2023-10-23
					end	 <=0 then 0
					else case
						--when payment_date is null then datediff(day,ai.invoice_due_date,dbo.xfn_get_system_date())
						--else datediff(day,ai.invoice_due_date,aaa.payment_date)
						--(+) Ari 2023-10-23
						when pay_date.received_reff_date is null then datediff(day,ai.invoice_due_date,dbo.xfn_get_system_date())
						else datediff(day,ai.invoice_due_date,pay_date.received_reff_date)
						--(+) Ari 2023-10-23
					end
				end
				--,case
				--								when ach.CALCULATE_BY = 'PCT' then ach.CHARGES_RATE
				--								when ach.CALCULATE_BY = 'AMOUNT' then ach.CHARGES_AMOUNT
				--								else 0
				--							end
				--,isnull(case
				--	when case
				--		when payment_date is null then datediff(day,ai.invoice_due_date,dbo.xfn_get_system_date()) 
				--		else datediff(day,ai.invoice_due_date,aaa.payment_date) * oapidgi2.amount
				--	end	 <=0 then 0
				--	else case
				--		when payment_date is null then datediff(day,ai.invoice_due_date,dbo.xfn_get_system_date()) 
				--		else datediff(day,ai.invoice_due_date,aaa.payment_date) * oapidgi2.amount
				--	end * case
				--								when ach.CALCULATE_BY = 'PCT' then ach.CHARGES_RATE * oapidgi2.amount
				--								when ach.CALCULATE_BY = 'AMOUNT' then ach.CHARGES_AMOUNT
				--								else 0
				--							end
				--end,0)
				--,isnull(oapidgi2.ovd_billing_amount, 0) 
				-- (+) Ari 2023-10-30 ket : change get ovd billing amount
				,case 
					when ai.invoice_due_date < dbo.xfn_get_system_date()
					then case	isnull(aaa.payment_amount,0)
								when 0
								then isnull(agiv.ar_amount, 0) 
								else isnull((agiv.ar_amount - aaa.payment_amount),0) 
						 end
					else 0
				end
				-- (+) Ari 2023-10-30
				,am.periode
		from	dbo.agreement_main am with(nolock)
				inner join dbo.agreement_asset aas with(nolock) on (aas.agreement_no = am.agreement_no)
				inner join dbo.agreement_invoice agiv with(nolock) on (agiv.asset_no = aas.asset_no)
				left join dbo.agreement_information ain with(nolock) on (ain.agreement_no = am.agreement_no)
				outer apply
				(
					select	aip.voucher_no
							--,aip.payment_date
							,aip.invoice_no
							,aip.payment_amount
					from	agreement_invoice_payment aip with(nolock)
							--inner join dbo.agreement_invoice agi with(nolock) on (
							--											agi.code		   = aip.agreement_invoice_code
							--											and agi.billing_no = agiv.billing_no
							--										)

					where	(
								aip.agreement_no = agiv.AGREEMENT_NO
								and aip.asset_no = agiv.asset_no
								and aip.invoice_no = agiv.invoice_no
								and aip.payment_amount > 0 
							)
				) aaa
				inner join dbo.invoice ai with(nolock) on (
												 ai.invoice_no			 = agiv.invoice_no
												 and   ai.invoice_status <> 'NEW'
											 )
				--left join dbo.agreement_charges ach with(nolock) on ach.agreement_no = am.agreement_no and ach.charges_code='OVDP'
				--outer apply
				--(
				--	-- (+) Ari 2023-10-26 ket : change to ovd billing amount
				--	select	isnull(id.billing_amount,0) 'ovd_billing_amount'
				--	from	dbo.invoice_detail id with(nolock)
				--	where	agreement_no = am.agreement_no
				--	and		id.invoice_no in (
				--								select	i.invoice_no 
				--								from	dbo.invoice i with(nolock) 
				--								where	i.invoice_no = id.invoice_no
				--								and		i.invoice_status = 'POST'
				--								and		dbo.xfn_get_system_date() > i.invoice_due_date
				--							 )
				--	and		id.billing_no = agiv.billing_no

				--) oapidgi2
				outer apply (
								--select	aaa.billing_date 
								--from	dbo.agreement_asset_amortization aaa with(nolock)
								--where	aaa.agreement_no = @p_agreement_no
								--and		aaa.invoice_no = agiv.invoice_no
								--and		aaa.hold_billing_status = 'POST'
								select	aaa.billing_date 
								from	@temptable aaa 
								where	aaa.agreement_no = @p_agreement_no
								and		aaa.invoice_no = agiv.invoice_no
							) due_date
				-- (+) Ari 2023-10-23
				-- (+) Ari 2023-10-23 ket : change payment date
				outer apply
				(
					select	i.received_reff_date
					from	dbo.invoice_detail ad with(nolock)
					inner	join dbo.invoice i with(nolock) on (i.invoice_no = ad.invoice_no)
					where	ad.agreement_no = am.agreement_no
					and		ad.invoice_no = agiv.invoice_no
					and		ad.billing_no = agiv.billing_no
				) pay_date
		where	am.agreement_no = @p_agreement_no 
		and		isnull(agiv.invoice_no, '') <> ''

		select	@ext_agreement = agreement_external_no
		from	ifinopl.dbo.agreement_main
		where	agreement_no = @p_agreement_no;

		if not exists(select 1 from dbo.rpt_agreement_amortization where user_id = @p_user_id)
		begin
				declare curr_agreement cursor fast_forward read_only for 
			select	asset_no
					,am.client_name
					,am.branch_name
					,am.agreement_date
					,aa.asset_name
					,am.periode
					,isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)
			from	dbo.agreement_asset aa
			inner	join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
			where	aa.agreement_no = @p_agreement_no
			open curr_agreement
			
			fetch next from curr_agreement 
			into @asset_no
				 ,@client_name
				 ,@branch
				 ,@agreement_date
				 ,@asset_name
				 ,@period
				 ,@plat_no

			while @@fetch_status = 0
			begin
			    insert into dbo.RPT_AGREEMENT_AMORTIZATION
				(
					USER_ID
					,AGREEMENT_NO
					,ASSET_NO
					,CLIENT_NAME
					,BRANCH
					,AGREEMENT_DATE
					,ASSET_NAME
					,BILLING_NO
					,DUE_DATE
					,BILLING_DATE
					,BILLING_AMOUNT
					,REPORT_IMAGE
					,REPORT_TITLE
					,REPORT_COMPANY
					,INVOICE_NO
					,BILLING_STATUS
					,PAID_DATE
					,VOUCHER_NO
					,INVOICE_DUE_DATE
					,PAYMENT_AMOUNT
					,PLAT_NO
					,OVD_DAYS
					,OVD_BILLING_AMOUNT
					,PERIOD
				)
				values
				(
					@p_user_id -- USER_ID - nvarchar(50)
					,@ext_agreement -- AGREEMENT_NO - nvarchar(50)
					,@asset_no
					,@client_name
					,@branch
					,@agreement_date
					,@asset_name
					,'-' -- BILLING_NO - nvarchar(50)
					,null -- DUE_DATE - datetime
					,null -- BILLING_DATE - datetime
					,0 -- BILLING_AMOUNT - decimal(18, 2)
					,@report_image -- REPORT_IMAGE - nvarchar(250)
					,@report_title -- REPORT_TITLE - nvarchar(50)
					,@report_company -- REPORT_COMPANY - nvarchar(50)
					,null -- INVOICE_NO - nvarchar(50)
					,null -- BILLING_STATUS - nvarchar(50)
					,null -- PAID_DATE - datetime
					,null -- VOUCHER_NO - nvarchar(50)
					,null -- INVOICE_DUE_DATE - datetime
					,null -- PAYMENT_AMOUNT - decimal(18, 2)
					,@plat_no
					,null -- OVD_DAYS - int
					,null -- OVD_AMOUNT - decimal(18, 2)
					,@period
				)
			
			    fetch next from curr_agreement 
				into @asset_no
					 ,@client_name
					 ,@branch
					 ,@agreement_date
					 ,@asset_name
					 ,@period
					 ,@plat_no
			end
			
			close curr_agreement
			deallocate curr_agreement
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

CREATE PROCEDURE dbo.xsp_ar_daily_balancing_insert_20250602
(
	@p_eod_date		datetime = null
)
as
begin
	declare @msg	   nvarchar(max)
			,@eod_date datetime = @p_eod_date --dbo.xfn_get_system_date() ; -- (+) Ari 2024-02-26 ket : ubah konsep dari eod menjadi parameterize

	begin try

	if(isnull(@eod_date,'') = '')
	begin
		set @eod_date = dbo.xfn_get_system_date()
	end
    

		delete	dbo.ar_daily_balancing 
		where	eod_date = @eod_date

		declare @tabel_agreement_due table
		(
			agreement_no nvarchar(50)
			,client_name nvarchar(250)
			,amount		 decimal(18, 2)
		) ;

		declare @tabel_agreement_not_due table
		(
			agreement_no nvarchar(50)
			,client_name nvarchar(250)
			,amount		 decimal(18, 2)
		) ;

		begin
			insert into @tabel_agreement_due
			(
				agreement_no
				,client_name
				,amount
			)
			select		agr.agreement_no
						,agr.client_name
						,sum(ai.AR_AMOUNT) - sum(isnull(aip.payment_amount, 0)) as ar_due
			from		[IFINOPL].dbo.AGREEMENT_INVOICE ai with (nolock)
						outer apply
			(
				select	crr.INVOICE_NO
						,ct.CASHIER_TRX_DATE
				from	ifinfin.dbo.CASHIER_TRANSACTION ct with (nolock)
						inner join ifinfin.dbo.CASHIER_TRANSACTION_DETAIL ctd with (nolock) on (ctd.CASHIER_TRANSACTION_CODE = ct.CODE)
						inner join ifinfin.dbo.CASHIER_RECEIVED_REQUEST crr with (nolock) on (crr.CODE					   = ctd.RECEIVED_REQUEST_CODE)
				where	crr.INVOICE_NO		  = ai.INVOICE_NO
						and ct.CASHIER_STATUS = 'PAID'
			) csh
						outer apply
			(
				select	crr.invoice_no
						,depa.allocation_trx_date
				from	[ifinfin].dbo.DEPOSIT_ALLOCATION depa with (nolock)
						inner join [ifinfin].dbo.DEPOSIT_ALLOCATION_DETAIL depad with (nolock) on depad.DEPOSIT_ALLOCATION_CODE = depa.CODE
						inner join [ifinfin].dbo.CASHIER_RECEIVED_REQUEST crr with (nolock) on (crr.CODE						  = depad.RECEIVED_REQUEST_CODE)
				where	crr.INVOICE_NO			   = ai.INVOICE_NO
						and depa.allocation_status = 'APPROVE'
			) dep
						outer apply
			(
				select		ap.INVOICE_NO
							,sum(ap.PAYMENT_AMOUNT) as payment_amount
							,isnull(isnull(max(ct.CASHIER_TRX_DATE), max(DA.ALLOCATION_TRX_DATE)), max(ap.PAYMENT_DATE)) as trx_date
				from		[IFINOPL].dbo.agreement_invoice_payment ap with (nolock)
							left join ifinfin.dbo.CASHIER_TRANSACTION ct with (nolock) on ct.CODE = ap.TRANSACTION_NO
							left join IFINFIN.dbo.DEPOSIT_ALLOCATION DA with (nolock) on DA.CODE	= ap.TRANSACTION_NO
				where		ai.CODE																										= ap.AGREEMENT_INVOICE_CODE
							and ap.PAYMENT_AMOUNT																						<> 0
							and convert(nvarchar(8), isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DATE), ap.PAYMENT_DATE), 112) <= convert(nvarchar(8), @eod_date, 112)
				group by	ap.INVOICE_NO
			) aip
						inner join [IFINOPL].dbo.Invoice inv with (nolock) on inv.Invoice_No			= ai.invoice_no
						inner join [IFINOPL].dbo.Agreement_Main agr with (nolock) on agr.agreement_no = ai.agreement_no
			where		((
							 convert(nvarchar(8), isnull(csh.CASHIER_TRX_DATE, isnull(dep.allocation_trx_date, aip.trx_date)), 112) > convert(nvarchar(8), @eod_date, 112)
							 or aip.trx_date is null
							 or ((ai.AR_AMOUNT - isnull(aip.payment_amount, 0))															> 0)
						 )
						)
						--and ai.AGREEMENT_NO																								= '0001095.4.01.07.2022'
						and inv.INVOICE_TYPE																							<> 'PENALTY' -- (+) 20240104 - Anas - invoice penalty tidak ikut dihitung
						and convert(nvarchar(8), inv.is_journal_date, 112)																<= convert(nvarchar(8), @eod_date, 112)
						and inv.INVOICE_NO not in ('06778.INV.2001.03.2025')
			group by	agr.agreement_no
						,agr.client_name 


			--from		[IFINOPL].dbo.AGREEMENT_INVOICE ai
			--			outer apply
			--(
			--	select	crr.INVOICE_NO
			--			,ct.CASHIER_TRX_DATE
			--	from	ifinfin.dbo.CASHIER_TRANSACTION ct
			--			inner join ifinfin.dbo.CASHIER_TRANSACTION_DETAIL ctd on (ctd.CASHIER_TRANSACTION_CODE = ct.CODE)
			--			inner join ifinfin.dbo.CASHIER_RECEIVED_REQUEST crr on (crr.CODE					   = ctd.RECEIVED_REQUEST_CODE)
			--	where	crr.INVOICE_NO		  = ai.INVOICE_NO
			--			and ct.CASHIER_STATUS = 'PAID'
			--) csh
			--			outer apply
			--(
			--	select	crr.invoice_no
			--			,depa.allocation_trx_date
			--	from	[ifinfin].dbo.DEPOSIT_ALLOCATION depa
			--			inner join [ifinfin].dbo.DEPOSIT_ALLOCATION_DETAIL depad on depad.DEPOSIT_ALLOCATION_CODE = depa.CODE
			--			inner join [ifinfin].dbo.CASHIER_RECEIVED_REQUEST crr on (crr.CODE						  = depad.RECEIVED_REQUEST_CODE)
			--	where	crr.INVOICE_NO			   = ai.INVOICE_NO
			--			and depa.allocation_status = 'APPROVE'
			--) dep
			--			outer apply
			--(
			--	select	ap.*
			--			,isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DATE), ap.PAYMENT_DATE) as trx_date
			--	from	[IFINOPL].dbo.agreement_invoice_payment ap
			--			left join ifinfin.dbo.CASHIER_TRANSACTION ct on ct.CODE = ap.TRANSACTION_NO
			--			left join IFINFIN.dbo.DEPOSIT_ALLOCATION DA on DA.CODE	= ap.TRANSACTION_NO
			--	where	ai.CODE																										= ap.AGREEMENT_INVOICE_CODE
			--			and ap.PAYMENT_AMOUNT																						> 0
			--			and convert(nvarchar(8), isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DATE), ap.PAYMENT_DATE), 112) <= convert(nvarchar(8), @eod_date, 112)
			--) aip
			--			inner join [IFINOPL].dbo.Invoice inv on inv.Invoice_No			= ai.invoice_no
			--			inner join [IFINOPL].dbo.Agreement_Main agr on agr.agreement_no = ai.agreement_no
			--where		((
			--				 convert(nvarchar(8), isnull(csh.CASHIER_TRX_DATE, isnull(dep.allocation_trx_date, aip.payment_date)), 112) > convert(nvarchar(8), @eod_date, 112)
			--				 or aip.payment_date is null
			--				 or ((ai.AR_AMOUNT - isnull(aip.payment_amount, 0))															> 0)
			--			 )
			--			)
			--			--and ai.AGREEMENT_NO = '0001184.4.08.10.2023'
			--			and inv.INVOICE_TYPE																							<> 'PENALTY' -- (+) 20240104 - Anas - invoice penalty tidak ikut dihitung
			--			and convert(nvarchar(8), inv.is_journal_date, 112)																<= convert(nvarchar(8), @eod_date, 112)
			--group by	agr.agreement_no
			--			,agr.client_name 

			--,ai.ASSET_NO

			insert into @tabel_agreement_not_due
			(
				agreement_no
				,client_name
				,amount
			)
			select		am.AGREEMENT_NO
						,am.CLIENT_NAME
						,case -- menampilkan ar wapu yang terbentuk pada saat invoice tergenerate sampai dengan akhir bulan
							 when adh.BILLING_TO_FAKTUR_TYPE = '01' then isnull(sum((aid.AR_AMOUNT) - isnull(aippp.AR_PAYMENT_AMOUNT, 0)) + 0, 0)
							 else isnull(sum((aid.AR_AMOUNT) - isnull(aippp.AR_PAYMENT_AMOUNT, 0)), 0) + isnull(sum(ppnwapu.ppn_amount_wapu), 0)
						 end 'Not Due'
			from		[IFINOPL].dbo.AGREEMENT_INVOICE ai with (nolock)
						inner join [IFINOPL].dbo.AGREEMENT_MAIN am with (nolock) on am.AGREEMENT_NO = ai.AGREEMENT_NO
						inner join [IFINOPL].dbo.INVOICE inv with (nolock) on (inv.INVOICE_NO = ai.INVOICE_NO)
						outer apply
			(
				--select	isnull(sum(det.ppn_amount), 0) ppn_amount_wapu
				select	isnull(sum(ISNULL(det.ppn_amount - case
														when isnull(cnd.adjustment_amount, 0) > 0 then (isnull(det.ppn_amount, 0) - isnull(cnd.new_ppn_amount, 0))
														else 0
													end, 0)), 0) ppn_amount_wapu
				from	[IFINOPL].dbo.INVOICE hd with (nolock)
						inner join [IFINOPL].dbo.INVOICE_DETAIL det with (nolock) on det.INVOICE_NO = hd.INVOICE_NO
						left join dbo.credit_note cn with (nolock) on (
															cn.invoice_no					  = hd.invoice_no
															and cn.status					  = 'post'
														)
						left join dbo.credit_note_detail cnd with (nolock) on (
																	cnd.credit_note_code	  = cn.code
																	and cnd.invoice_detail_id = det.id
																)
				where	hd.INVOICE_DATE			   <= @eod_date
						and det.AGREEMENT_NO	   = ai.AGREEMENT_NO
						and det.ASSET_NO		   = ai.ASSET_NO
						and hd.INVOICE_NO		   = ai.INVOICE_NO
						and hd.CRE_BY			   <> 'MIGRASI'
						and hd.IS_JOURNAL_PPN_WAPU = '0'
						and hd.INVOICE_STATUS not in
			(
				'NEW', 'CANCEL'
			)
			) ppnwapu
						outer apply
			(
				select	sum(aid.ar_amount) ar_amount
				from	IFINOPL.dbo.AGREEMENT_INVOICE aid with (nolock)
						inner join IFINOPL.dbo.INVOICE inv with (nolock) on (inv.INVOICE_NO = aid.INVOICE_NO)
				where	aid.CODE					= ai.CODE
						and
						(
							inv.is_journal_date is null
							or	inv.is_journal_date > @eod_date
						)
			) aid
						outer apply
			(
				select		isnull(sum(aip.PAYMENT_AMOUNT), 0) 'AR_PAYMENT_AMOUNT'
							--,(isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DAte), aip.payment_date)) payment_date
				from		[IFINOPL].dbo.AGREEMENT_INVOICE_PAYMENT aip with (nolock)
							inner join [IFINOPL].dbo.INVOICE IVP with (nolock) on IVP.INVOICE_NO	= aip.INVOICE_NO
							left join ifinfin.dbo.CASHIER_TRANSACTION ct with (nolock) on ct.CODE = aip.TRANSACTION_NO
							left join IFINFIN.dbo.DEPOSIT_ALLOCATION DA with (nolock) on DA.CODE	= aip.TRANSACTION_NO
				where		aip.AGREEMENT_INVOICE_CODE																		= ai.CODE
							and cast(isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DATE), aip.PAYMENT_DATE) as date) <= @eod_date
							and aip.PAYMENT_AMOUNT																			<> 0 -- Louis Rabu, 28 Februari 2024 20.54.30 -- 
							and
							(
								IVP.IS_JOURNAL_DATE is null
								or	IVP.IS_JOURNAL_DATE																		> @eod_date
							)
				--group by	(isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DATE), aip.PAYMENT_DATE))
				--			,isnull(ivp.total_ppn_amount, 0)
			) aippp
						outer apply
			(
				select	xiv.is_journal_date
						,xiv.IS_JOURNAL
						,xiv.BILLING_TO_FAKTUR_TYPE
				from	[IFINOPL].dbo.INVOICE xiv with (nolock)
				where	xiv.INVOICE_NO = inv.INVOICE_NO
			) adh
			where		ai.INVOICE_DATE		 <= @eod_date
						and inv.INVOICE_TYPE <> 'PENALTY'
						or inv.INVOICE_NO in ('06778.INV.2001.03.2025')
			group by	am.AGREEMENT_NO
						,am.CLIENT_NAME
						,adh.BILLING_TO_FAKTUR_TYPE
						--,ppnwapu.ppn_amount_wapu ;
			--select		am.AGREEMENT_NO
			--			,am.CLIENT_NAME
			--			,case -- menampilkan ar wapu yang terbentuk pada saat invoice tergenerate sampai dengan akhir bulan
			--				 when max(adh.BILLING_TO_FAKTUR_TYPE) = '01' then sum((ai.AR_AMOUNT) - isnull(aippp.AR_PAYMENT_AMOUNT, 0)) + 0
			--				 else sum((ai.AR_AMOUNT) - isnull(aippp.AR_PAYMENT_AMOUNT, 0)) + isnull(sum(adh3.ppn_amount_wapu), 0)
			--			 end 'Not Due'
			--from		[IFINOPL].dbo.AGREEMENT_INVOICE ai
			--			inner join [IFINOPL].dbo.AGREEMENT_MAIN am on am.AGREEMENT_NO = ai.AGREEMENT_NO
			--			inner join [IFINOPL].dbo.INVOICE inv on (inv.INVOICE_NO = ai.INVOICE_NO)
			--			outer apply
			--(
			--	select		isnull(sum(aip.PAYMENT_AMOUNT), 0) 'AR_PAYMENT_AMOUNT'
			--				,(isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DAte), aip.payment_date)) payment_date
			--	from		[IFINOPL].dbo.AGREEMENT_INVOICE_PAYMENT aip
			--				inner join [IFINOPL].dbo.INVOICE IVP on IVP.INVOICE_NO	= aip.INVOICE_NO
			--				left join ifinfin.dbo.CASHIER_TRANSACTION ct on ct.CODE = aip.TRANSACTION_NO
			--				left join IFINFIN.dbo.DEPOSIT_ALLOCATION DA on DA.CODE	= aip.TRANSACTION_NO
			--	where		aip.AGREEMENT_INVOICE_CODE																		= ai.CODE
			--				and cast(isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DATE), aip.PAYMENT_DATE) as date) <= @eod_date
			--				and aip.PAYMENT_AMOUNT																			> 0
			--	group by	(isnull(isnull(ct.CASHIER_TRX_DATE, DA.ALLOCATION_TRX_DATE), aip.PAYMENT_DATE))
			--				,isnull(ivp.total_ppn_amount, 0)
			--) aippp
			--			outer apply
			--(
			--	select		isnull(sum(det.PPN_AMOUNT), 0) ppn_amount
			--				,det.INVOICE_NO
			--	from		[IFINOPL].dbo.INVOICE_DETAIL det
			--	where		ai.INVOICE_NO											= det.INVOICE_NO
			--				and det.AGREEMENT_NO									= ai.AGREEMENT_NO
			--				and det.ASSET_NO										= ai.ASSET_NO
			--				and det.BILLING_NO										= ai.BILLING_NO
			--				and (ai.AR_AMOUNT) - isnull(aippp.AR_PAYMENT_AMOUNT, 0) > 0
			--	group by	det.INVOICE_NO
			--) adh2
			--			outer apply
			--(
			--	select	isnull(sum(det.PPN_AMOUNT), 0) ppn_amount_wapu
			--	from	[IFINOPL].dbo.INVOICE_DETAIL det
			--			inner join [IFINOPL].dbo.INVOICE hd on hd.INVOICE_NO					 = det.INVOICE_NO
			--			inner join [IFINOPL].dbo.AGREEMENT_INVOICE aginv on aginv.INVOICE_NO	 = hd.INVOICE_NO
			--																and aginv.ASSET_NO	 = det.ASSET_NO
			--																and aginv.BILLING_NO = det.BILLING_NO
			--	where	aginv.AGREEMENT_NO								  = ai.AGREEMENT_NO
			--			and aginv.INVOICE_NO							  = ai.INVOICE_NO
			--			and aginv.ASSET_NO								  = ai.ASSET_NO
			--			and aginv.BILLING_NO							  = ai.BILLING_NO
			--			and convert(nvarchar(6), aginv.INVOICE_DATE, 112) >= convert(nvarchar(6), @eod_date, 112)
			--) adh3
			--			outer apply
			--(
			--	select	xiv.is_journal_date
			--			,xiv.IS_JOURNAL
			--			,xiv.BILLING_TO_FAKTUR_TYPE
			--	from	[IFINOPL].dbo.INVOICE xiv
			--	where	xiv.INVOICE_NO = inv.INVOICE_NO
			--) adh
			--where		ai.INVOICE_DATE				<= @eod_date
			--			and inv.INVOICE_TYPE		<> 'PENALTY'
			--			and
			--			(
			--				adh.IS_JOURNAL_DATE is null
			--				or	adh.IS_JOURNAL_DATE > @eod_date
			--			)
			--group by	am.AGREEMENT_NO
			--			,am.CLIENT_NAME ;
		end ;

		insert into dbo.ar_daily_balancing
		(
			agreement_no
			,client_name
			,ar_due
			,ar_not_due
			,eod_date
		)
		select	am.agreement_no
				,am.client_name
				,isnull(ard.amount, 0)
				,isnull(arnd.amount, 0)
				,cast(@eod_date as date)
		from	dbo.agreement_main am with (nolock)
				outer apply
		(
			select	ard.agreement_no
					,ard.client_name
					,sum(ard.amount) amount
			from	@tabel_agreement_due ard
			where	ard.agreement_no = am.agreement_no
			group by ard.agreement_no, ard.client_name
		) ard
				outer apply
		(
			select	arnd.agreement_no
					,arnd.client_name
					,sum(arnd.amount) amount
			from	@tabel_agreement_not_due arnd
			where	arnd.agreement_no = am.agreement_no
			group by arnd.agreement_no, arnd.client_name
		) arnd ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'v' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'e;there is an error.' + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

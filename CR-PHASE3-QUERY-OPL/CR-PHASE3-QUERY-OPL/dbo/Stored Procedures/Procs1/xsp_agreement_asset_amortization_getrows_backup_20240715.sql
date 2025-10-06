CREATE PROCEDURE [dbo].[xsp_agreement_asset_amortization_getrows_backup_20240715]
(
	@p_keywords		 NVARCHAR(50)
	,@p_pagenumber	 INT
	,@p_rowspage	 INT
	,@p_order_by	 INT
	,@p_sort_by		 NVARCHAR(5)
	--
	,@p_agreement_no NVARCHAR(50)
	,@p_asset_no	 NVARCHAR(50)
)
AS
BEGIN
	DECLARE @rows_count INT = 0 ;

	declare @temp_table table
	(
		agreement_no		 nvarchar(50)
		,billing_no			 int
		,asset_no			 nvarchar(50)
		,due_date			 datetime
		,billing_date		 nvarchar(30)
		,billing_amount		 decimal(18, 2)
		,invoice_no			 nvarchar(50)
		,invoice_external_no nvarchar(50)
		,hold_billing_status nvarchar(50)
		,hold_date			 nvarchar(30)
		,is_due_date		 nvarchar(10)
		,paid_date			 nvarchar(30)
		,paid_trx_date		 nvarchar(30)
		,status				 nvarchar(50)
		,voucher_no			 nvarchar(50)
		,invoice_due_date	 nvarchar(30)
		,obligation_day		 int
		,obligation_amount	 decimal(18, 2)
	) ;

	insert into @temp_table
	(
		agreement_no
		,billing_no
		,asset_no
		,due_date
		,billing_date
		,billing_amount
		,invoice_no
		,invoice_external_no
		,hold_billing_status
		,hold_date
		,is_due_date
		,paid_date
		,paid_trx_date
		,status
		,voucher_no
		,invoice_due_date
		,obligation_day
		,obligation_amount
	)
	select	*
	from
			(
				select	ast.agreement_no 'agreement_no'
						,ast.billing_no 'billing_no'
						,ast.asset_no 'asset_no'
						,ast.due_date 'due_date' --convert(varchar(20), ast.due_date, 103) 'due_date'
						,convert(varchar(20), ast.billing_date, 103) 'billing_date'
						,ast.billing_amount
						,ast.invoice_no
						,ai.invoice_external_no
						,isnull(ast.hold_billing_status, '') 'hold_billing_status'
						,convert(varchar(20), ast.hold_date, 103) 'hold_date'
						,case
							 when (ai.invoice_due_date < dbo.xfn_get_system_date())
								  and	(ai.invoice_status <> 'PAID') then 'red'
							 when (ast.billing_date < dbo.xfn_get_system_date())
								  and	(ast.invoice_no is null) then 'yellow'
							 else 'false'
						 end 'is_due_date'
						,convert(nvarchar(20), aaa.payment_date, 103) 'paid_date'
						,convert(nvarchar(20), aaa.cashier_trx_date, 103) 'paid_trx_date'
						,ai.invoice_status 'status'
						,aaa.voucher_no
						,convert(varchar(20), ai.invoice_due_date, 103) 'invoice_due_date'
						,ao.obligation_day
						,ao.obligation_amount
				from	agreement_asset_amortization ast
						outer apply
				(
					select	max(aip.voucher_no) voucher_no
							,max(aip.payment_date) payment_date
							,max(aip.invoice_no) invoice_no
							,isnull(max(da.allocation_trx_date),isnull(max(ct.cashier_trx_date),max(sa.allocation_trx_date))) cashier_trx_date
					from	agreement_invoice_payment aip
							inner join dbo.agreement_invoice agi on (
																		agi.code		   = aip.agreement_invoice_code
																		and agi.billing_no = ast.billing_no
																	)
							left join ifinfin.dbo.cashier_transaction ct on (ct.voucher_no = aip.voucher_no)
							left join ifinfin.dbo.deposit_allocation da on (da.voucher_no = aip.voucher_no)
							left join ifinfin.dbo.suspend_allocation sa on (sa.voucher_no = aip.voucher_no)
					where	(
								aip.agreement_no = ast.agreement_no
								and aip.asset_no = ast.asset_no
								and aip.invoice_no = ast.invoice_no
								and aip.transaction_type not in
									(
										N'CREDIT NOTE',N'INVOICE CANCEL'
									)
							) group by aip.transaction_no
					having	sum(aip.PAYMENT_AMOUNT) > 0
				) aaa
						outer apply
				(
					select	ao.obligation_day
							,ao.obligation_amount
					from	dbo.agreement_obligation ao
					where	ao.asset_no		  = ast.asset_no
							and ao.invoice_no = ast.invoice_no
							and ao.cre_by	  <> 'MIGRASI'
							and ao.OBLIGATION_TYPE in
	(
		N'OVDP', N'LRAP'
	)
				) ao
						left join dbo.invoice ai on (
														ai.invoice_no = ast.invoice_no
														and ai.invoice_status not in
	(
		'NEW', 'CANCEL'
	)
													)
				where	ast.agreement_no = @p_agreement_no
						and ast.asset_no = case @p_asset_no
											   when 'ALL' then ast.ASSET_NO
											   else @p_asset_no
										   end
				union -- (+) Penambahan Additional Invoice 
				select	aind.AGREEMENT_NO 'agreement_no'
						,0
						,aind.ASSET_NO 'asset_no'
						,ain.INVOICE_DATE 'due_date' --convert(varchar(20), ain.INVOICE_DUE_DATE, 103) 'due_date'
						,convert(varchar(20), ain.INVOICE_DATE, 103) 'billing_date'
						,aind.BILLING_AMOUNT
						,ain.INVOICE_NO
						,replace(ain.INVOICE_NO, '.', '/') + ' ' + ain.INVOICE_TYPE
						,''
						,''
						,''
						,convert(nvarchar(20), payment.paid_date, 103) 'paid_date'
						,convert(nvarchar(20), payment.cashier_trx_date, 103) 'paid_trx_date'
						,ain.INVOICE_STATUS
						,payment.voucher_no
						,convert(varchar(20), ain.invoice_due_date, 103) 'invoice_due_date'
						,ao.obligation_day
						,ao.obligation_amount
				from	dbo.INVOICE ain
						inner join dbo.INVOICE_DETAIL aind on aind.invoice_no = ain.INVOICE_NO
						outer apply
						(
							select	max(ainp.voucher_no) 'voucher_no'
									,max(ainp.payment_date) 'paid_date'
									,isnull(max(da.allocation_trx_date),isnull(max(ct.cashier_trx_date),max(sa.allocation_trx_date))) cashier_trx_date
							from	dbo.agreement_invoice_payment ainp
									left join ifinfin.dbo.cashier_transaction ct on (ct.voucher_no = ainp.voucher_no)
									left join ifinfin.dbo.deposit_allocation da on (da.voucher_no = ainp.voucher_no)
									left join ifinfin.dbo.suspend_allocation sa on (sa.voucher_no = ainp.voucher_no)
							where	(
										ainp.agreement_no = aind.agreement_no
										and ainp.asset_no = aind.asset_no
										and ain.invoice_no = ainp.invoice_no
										and ainp.transaction_type not in
											(
												N'CREDIT NOTE',N'INVOICE CANCEL'
											)
									) group by ainp.transaction_no
							having	sum(ainp.PAYMENT_AMOUNT) > 0
						) payment
						outer apply
						(	
							select	ao.obligation_day
									,ao.obligation_amount
							from	dbo.agreement_obligation ao
							where	ao.asset_no		  = @p_asset_no
									and ao.invoice_no = ain.invoice_no
									and ao.cre_by	  <> 'MIGRASI'
									and ao.OBLIGATION_TYPE in
										(
											N'OVDP', N'LRAP'
										)
						) ao
				where	aind.agreement_no							= @p_agreement_no
						and aind.asset_no							= @p_asset_no
						and isnull(ain.invoice_no, '') not in
							(
								select	isnull(invoice_no, '')
								from	dbo.agreement_asset_amortization
							)
						and ain.invoice_status not in
							(
								'CANCEL', 'NEW'
							)
						and isnull(ain.additional_invoice_code, '') <> ''
			) as amortisasi
	where	(
				amortisasi.billing_no									 like '%' + @p_keywords + '%'
				or	convert(varchar(30), amortisasi.due_date, 103)		 like '%' + @p_keywords + '%'
				or	convert(varchar(30), amortisasi.billing_date, 103)	 like '%' + @p_keywords + '%'
				or	amortisasi.billing_amount							 like '%' + @p_keywords + '%'
				or	amortisasi.invoice_external_no						 like '%' + @p_keywords + '%'
				or	amortisasi.status									 like '%' + @p_keywords + '%'
				or	amortisasi.voucher_no								 like '%' + @p_keywords + '%'
				or	convert(nvarchar(20), amortisasi.paid_date, 103)	 like '%' + @p_keywords + '%'
				or	convert(nvarchar(20), amortisasi.paid_trx_date, 103) like '%' + @p_keywords + '%'
				or	amortisasi.obligation_day							 like '%' + @p_keywords + '%'
				or	amortisasi.obligation_amount						 like '%' + @p_keywords + '%'
			) ;

	select	@rows_count = count(1)
	from	@temp_table ;

	select		agreement_no
				,billing_no
				,asset_no
				,convert(varchar(30), due_date, 103) 'due_date'
				,billing_date
				,billing_amount
				,invoice_no
				,invoice_external_no
				,hold_billing_status
				,hold_date
				,is_due_date
				,paid_date
				,paid_trx_date
				,status
				,voucher_no
				,invoice_due_date
				,obligation_day
				,obligation_amount
				,@rows_count 'rowcount'
	from		@temp_table
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(due_date as date) --billing_no
												 --when 2 then due_date
												 --when 3 then billing_date
												 --when 4 then cast(billing_amount as sql_variant)
												 --when 5 then invoice_external_no
												 --when 6 then voucher_no
												 --when 7 then paid_date
												 --when 8 then paid_date
												 --when 9 then invoice_due_date
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then cast(due_date as date)
												   --when 2 then due_date
												   --when 3 then billing_date
												   --when 4 then cast(billing_amount as sql_variant)
												   --when 5 then invoice_external_no
												   --when 6 then voucher_no
												   --when 7 then paid_date
												   --when 8 then paid_date
												   --when 9 then invoice_due_date
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

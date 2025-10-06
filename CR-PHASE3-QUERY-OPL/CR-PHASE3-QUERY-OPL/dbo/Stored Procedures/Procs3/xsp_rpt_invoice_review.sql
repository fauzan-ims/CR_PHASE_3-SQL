CREATE PROCEDURE [dbo].[xsp_rpt_invoice_review]
as
begin
	declare @table_last_month table
	(
		agreement_no		  nvarchar(50)
		,total_billing_amount decimal(18, 2)
	) ;

	declare @table_this_month table
	(
		agreement_no		  nvarchar(50)
		,total_billing_amount decimal(18, 2)
	) ;

	insert into @table_last_month
	(
		agreement_no
		,total_billing_amount
	)
	select		invd.AGREEMENT_NO
				,sum(invd.BILLING_AMOUNT)
	from		dbo.INVOICE_DETAIL invd with (nolock)
				outer apply
	(
		select	inv.INVOICE_DATE
		from	dbo.INVOICE inv with (nolock)
		where	inv.INVOICE_NO = invd.INVOICE_NO and inv.INVOICE_STATUS <> 'CANCEL'
	) inv
	where		convert(nvarchar(6), inv.INVOICE_DATE, 112) = convert(nvarchar(6), dateadd(month, -1, dbo.xfn_get_system_date()), 112)
	group by	invd.AGREEMENT_NO ;

	insert into @table_this_month
	(
		agreement_no
		,total_billing_amount
	)
	select		invd.AGREEMENT_NO
				,sum(invd.BILLING_AMOUNT)
	from		dbo.INVOICE_DETAIL invd with (nolock)
				outer apply
	(
		select	inv.INVOICE_DATE
		from	dbo.INVOICE inv with (nolock)
		where	inv.INVOICE_NO = invd.INVOICE_NO and inv.INVOICE_STATUS <> 'CANCEL'
	) inv
	where		convert(nvarchar(6), inv.INVOICE_DATE, 112) = convert(nvarchar(6), dbo.xfn_get_system_date(), 112)
	group by	invd.AGREEMENT_NO ;

	select	am.AGREEMENT_EXTERNAL_NO 'AGREEMENT_NO'
			,am.CLIENT_NAME
			,am.AGREEMENT_DATE
			,am.TERMINATION_DATE
			,isnull(ttm.total_billing_amount, 0) 'TOTAL  BILLING AMOUNT THIS MONTH'
			,isnull(tlm.total_billing_amount, 0) 'TOTAL  BILLING AMOUNT LAST_MONTH'
			,isnull(ttm.total_billing_amount, 0) - isnull(tlm.total_billing_amount, 0) 'TOTAL SELISIH BILLING AMOUNT'
			,case
				 when convert(nvarchar(6), am.AGREEMENT_DATE, 112) = convert(nvarchar(6), dbo.xfn_get_system_date(), 112) then 'GO LIVE This Month'
				 when convert(nvarchar(6), am.TERMINATION_DATE, 112) = convert(nvarchar(6), dbo.xfn_get_system_date(), 112) then 'TERMINATE This Month'
			 end 'REMARKS'
	from	@table_this_month ttm
			full outer join @table_last_month tlm on (tlm.agreement_no = ttm.agreement_no)
			inner join dbo.agreement_main am on (am.agreement_no	   = isnull(ttm.agreement_no, tlm.agreement_no))
	where	isnull(ttm.total_billing_amount, 0) <> isnull(tlm.total_billing_amount, 0) ;
end ;

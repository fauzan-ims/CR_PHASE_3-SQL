CREATE PROCEDURE dbo.xsp_agreement_invoice_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	-- 
	,@p_settlement_status	nvarchar(10)
	,@p_agreement_no		nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	declare @tempTable table
	(
		invoice_no			 nvarchar(50)
		,invoice_external_no nvarchar(50)
		,client_name		 nvarchar(250)
		,faktur_no			 nvarchar(50)
		,invoice_date		 nvarchar(50)
		,invoice_name		 nvarchar(250)
		,invoice_status		 nvarchar(10)
		,currency_code		 nvarchar(3)
		,total_pph_amount	 decimal(18, 2)
		,settlement_status	 nvarchar(10)
		,payment_reff_no	 nvarchar(50)
		,payment_reff_date	 nvarchar(50)
	) ;

	insert into @temptable
	(
		invoice_no
		,invoice_external_no
		,client_name
		,faktur_no
		,invoice_date
		,invoice_name
		,invoice_status
		,currency_code
		,total_pph_amount
		,settlement_status
		,payment_reff_no
		,payment_reff_date
	)
	select	distinct
			invd.invoice_no
			,invoice_external_no
			,am.client_name
			,faktur_no
			,invoice_date
			,invoice_name
			,invoice_status
			,am.currency_code
			,invp.total_pph_amount
			,settlement_status
			,payment_reff_no
			,payment_reff_date
	from	dbo.agreement_main am
			inner join dbo.invoice_detail invd on (invd.agreement_no = am.agreement_no)
			inner join dbo.invoice inv on (inv.invoice_no			 = invd.invoice_no)
			inner join dbo.invoice_pph invp on (invp.invoice_no		 = invd.invoice_no)
	where	invp.settlement_status = case @p_settlement_status
											when 'ALL' then invp.settlement_status
											else @p_settlement_status
										end
			and am.agreement_no	   = @p_agreement_no
			and
			(
				inv.invoice_no like '%' + @p_keywords + '%'
				or	inv.invoice_external_no like '%' + @p_keywords + '%'
				or	inv.client_name like '%' + @p_keywords + '%'
				or	inv.faktur_no like '%' + @p_keywords + '%'
				or	convert(varchar(30), inv.invoice_date, 103) like '%' + @p_keywords + '%'
				or	inv.invoice_name like '%' + @p_keywords + '%'
				or	inv.invoice_status like '%' + @p_keywords + '%'
				or	inv.currency_code like '%' + @p_keywords + '%'
				or	invp.total_pph_amount like '%' + @p_keywords + '%'
				or	invp.settlement_status like '%' + @p_keywords + '%'
				or	invp.payment_reff_no like '%' + @p_keywords + '%'
				or	convert(varchar(30), invp.payment_reff_date, 103) like '%' + @p_keywords + '%'
			) ;

	select	@rows_count = count(1)
	from	@temptable 

	select	invoice_no
		   ,invoice_external_no
		   ,client_name
		   ,faktur_no
		   ,invoice_date
		   ,invoice_name
		   ,invoice_status
		   ,currency_code
		   ,total_pph_amount 'total_amount'
		   ,settlement_status
		   ,payment_reff_no
		   ,payment_reff_date
			,@rows_count 'rowcount'
	from	@temptable
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then invoice_external_no
													 when 2 then faktur_no
													 when 3 then cast(invoice_date as sql_variant)
													 when 4 then cast(total_pph_amount as sql_variant)
													 when 5 then payment_reff_no
													 when 6 then cast(payment_reff_date as sql_variant)
													 when 7 then settlement_status

												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then invoice_external_no
													 when 2 then faktur_no
													 when 3 then cast(invoice_date as sql_variant)
													 when 4 then cast(total_pph_amount as sql_variant)
													 when 5 then payment_reff_no
													 when 6 then cast(payment_reff_date as sql_variant)
													 when 7 then settlement_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


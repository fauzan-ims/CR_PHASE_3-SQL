CREATE PROCEDURE dbo.xsp_warning_letter_delivery_invoice_getrows_backup_2592025
(
	@p_keywords NVARCHAR(50)
	,@p_pagenumber INT
	,@p_rowspage INT
	,@p_order_by INT
	,@p_sort_by NVARCHAR(5)
	,@p_code NVARCHAR(50)
)
AS
BEGIN
	DECLARE @rows_count		INT = 0 
			,@client_no		NVARCHAR(50)
			,@client_no_1	NVARCHAR(59);

	SELECT	@client_no = wld.CLIENT_NO 
	FROM	dbo.WARNING_LETTER_DELIVERY wld
	WHERE	wld.CODE = @p_code;

	SELECT	@client_no_1 = CLIENT_NO
	FROM	dbo.WARNING_LETTER 
	WHERE	CODE = @p_code

	select	@rows_count = count(*)
	FROM
	(
		SELECT
		c.invoice_no,
		d.invoice_type
	FROM dbo.agreement_main a
	INNER JOIN dbo.agreement_asset b ON b.agreement_no = a.agreement_no
	INNER JOIN dbo.invoice_detail c ON c.asset_no = b.asset_no
	INNER JOIN dbo.invoice d ON d.invoice_no = c.invoice_no
	INNER JOIN dbo.agreement_asset_amortization e ON e.asset_no = c.asset_no
	INNER JOIN dbo.agreement_obligation f ON f.asset_no = c.asset_no
	WHERE a.client_no = isnull(@client_no, @client_no_1)
		AND d.invoice_status IN ('POST', 'PAID')
		AND 
		(
			c.invoice_no LIKE '%' + @p_keywords + '%'
			OR d.invoice_type LIKE '%' + @p_keywords + '%'
			OR CONVERT(VARCHAR(15), e.billing_date, 102) LIKE '%' + @p_keywords + '%'
			OR CONVERT(VARCHAR(15), e.due_date, 102) LIKE '%' + @p_keywords + '%'
			OR d.total_billing_amount LIKE '%' + @p_keywords + '%'
			OR d.invoice_status LIKE '%' + @p_keywords + '%'
		)
	GROUP BY c.invoice_no, d.invoice_type
	) AS count_table;

	select	c.invoice_no											'invoice_no'
			,d.invoice_type											'invoice_type'
			,CONVERT(VARCHAR(30), max(e.billing_date), 103)			'billing_date'
			,CONVERT(VARCHAR(30), max(e.due_date), 103)				'billing_due_date'
			,SUM(d.total_billing_amount)							'os_invoice_amount'
			,SUM(d.total_ppn_amount)								'total_ppn_amount'
			,SUM(d.total_pph_amount)								'total_pph_amount'
			,CONVERT(VARCHAR(30), max(f.obligation_day), 103)		'ovd_days'
			,MAX(d.invoice_status)									'invoice_status'
			,CONVERT(VARCHAR(30), max(a.payment_promise_date), 103)	'promise_date'
			,@rows_count											'rowcount'
	FROM		dbo.agreement_main								a
					INNER JOIN dbo.agreement_asset				b ON b.agreement_no = a.agreement_no
					INNER JOIN dbo.invoice_detail				c ON c.asset_no		= b.asset_no
					INNER JOIN dbo.invoice						d ON d.invoice_no	= c.invoice_no
					INNER JOIN dbo.agreement_asset_amortization e ON e.asset_no		= c.asset_no
					INNER JOIN dbo.agreement_obligation			f ON f.asset_no		= c.asset_no
		WHERE		a.client_no = isnull(@client_no, @client_no_1)
					AND d.invoice_status IN
		(
			'POST', 'PAID'
		)
		AND (
				c.invoice_no								LIKE '%' + @p_keywords + '%'
			or d.invoice_type								LIKE '%' + @p_keywords + '%'
			or convert(varchar(15), e.billing_date, 102)	LIKE '%' + @p_keywords + '%'
			or convert(varchar(15), e.due_date, 102)		LIKE '%' + @p_keywords + '%'
			or d.total_billing_amount						LIKE '%' + @p_keywords + '%'
			or d.invoice_status								LIKE '%' + @p_keywords + '%'
			)
	GROUP BY
			c.invoice_no,
			d.invoice_type
	order by
		case
			when @p_sort_by = 'asc' then
				case @p_order_by
					when 1 then
						c.INVOICE_NO
					when 2 then
						d.INVOICE_TYPE
					when 3 then
						CONVERT(VARCHAR(15), MAX(e.billing_date), 102)
					--when 4 then
					--	AGREEMENT_MAIN.CLIENT_NAME
					--when 5 then
					--	convert(varchar(15), OBLIGATION_DAY, 102)
					--when 6 then
					--	LETTER_TYPE
					--when 7 then
					--	LETTER_STATUS
				end
		end asc
		,case
			when @p_sort_by = 'desc' then
				case @p_order_by
					when 1 then
						c.INVOICE_NO
					when 2 then
						d.INVOICE_TYPE
					when 3 then
						CONVERT(VARCHAR(15), MAX(e.billing_date), 102)
					--when 4 then
					--	AGREEMENT_MAIN.CLIENT_NAME
					--when 5 then
					--	convert(varchar(15), OBLIGATION_DAY, 102)
					--when 6 then
					--	LETTER_TYPE
					--when 7 then
					--	LETTER_STATUS
				end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;


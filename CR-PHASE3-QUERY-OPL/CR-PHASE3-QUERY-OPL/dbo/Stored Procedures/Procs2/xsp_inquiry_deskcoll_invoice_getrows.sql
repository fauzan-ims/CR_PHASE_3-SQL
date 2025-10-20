CREATE PROCEDURE dbo.xsp_inquiry_deskcoll_invoice_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_deskcoll_main_id	BIGINT = null
    ,@p_id_task_main		bigint = NULL
)
as
BEGIN
		DECLARE @p_client_no VARCHAR(50)
				,@rows_count INT = 0;

	
	IF EXISTS (SELECT 1 FROM dbo.deskcoll_main WHERE id = @p_deskcoll_main_id)
	BEGIN

		SELECT	@rows_count = COUNT(1)
		FROM	dbo.deskcoll_invoice a WITH (NOWAIT)
		INNER JOIN dbo.invoice b WITH (NOWAIT) ON a.invoice_no = b.invoice_no
		WHERE	deskcoll_main_id = @p_deskcoll_main_id
		AND		b.INVOICE_STATUS = 'POST'
		AND	(
				 a.invoice_no LIKE '%' + @p_keywords + '%'
			  OR a.invoice_type LIKE '%' + @p_keywords + '%'
			  OR CONVERT(VARCHAR(30), billing_date, 103) LIKE '%' + @p_keywords + '%'
			);

		SELECT
			 a.id
			,CONVERT(VARCHAR(30), billing_date, 103)  'billing_date'
			,a.invoice_no
			,a.invoice_type
			,CONVERT(VARCHAR(30), billing_due_date, 103)  'billing_due_date'
			,b.total_billing_amount
			,b.total_ppn_amount
			,b.total_pph_amount
			,a.ovd_days
			,b.invoice_status
			,@rows_count 'rowcount'
		FROM	dbo.deskcoll_invoice a WITH (NOWAIT) 
		INNER JOIN dbo.invoice b WITH (NOWAIT) ON a.invoice_no = b.invoice_no
		WHERE	deskcoll_main_id = @p_deskcoll_main_id
		AND		b.INVOICE_STATUS = 'POST'
		AND	(
				 a.invoice_no LIKE '%' + @p_keywords + '%'
			  OR a.invoice_type LIKE '%' + @p_keywords + '%'
			  OR CONVERT(VARCHAR(30), billing_date, 103) LIKE '%' + @p_keywords + '%'
			)
		ORDER BY
			CASE
				WHEN @p_sort_by = 'asc' THEN
					CASE @p_order_by
						WHEN 1 THEN a.invoice_no
					END
			END ASC,
			CASE
				WHEN @p_sort_by = 'desc' THEN
					CASE @p_order_by
						WHEN 1 THEN a.invoice_no
					END
			END DESC
		OFFSET ((@p_pagenumber - 1) * @p_rowspage) ROWS
		FETCH NEXT @p_rowspage ROWS ONLY;
	END
	-- Jika deskcoll_main_id kosong → gunakan task_main & client_no
	ELSE
	BEGIN

		SELECT @p_client_no = client_no
		FROM dbo.task_main
		WHERE id = @p_id_task_main;

		SELECT	@rows_count = COUNT(DISTINCT b.invoice_no)
		FROM	dbo.invoice b WITH (NOWAIT)
		INNER JOIN dbo.invoice_detail invd WITH (NOWAIT) ON invd.invoice_no = b.invoice_no
		INNER JOIN dbo.agreement_asset_amortization e WITH (NOWAIT) ON e.asset_no = invd.asset_no AND e.billing_no = invd.billing_no AND e.invoice_no = b.invoice_no
		LEFT JOIN dbo.agreement_obligation f WITH (NOWAIT) ON f.asset_no = invd.asset_no
		WHERE	b.client_no = @p_client_no
		AND		b.invoice_status IN ('POST')
		AND	(
				 b.invoice_no LIKE '%' + @p_keywords + '%'
			  OR b.invoice_type LIKE '%' + @p_keywords + '%'
			  OR CONVERT(VARCHAR(30), e.BILLING_DATE, 103) LIKE '%' + @p_keywords + '%'
			);

		SELECT
			0 AS 'id'
			,CONVERT(VARCHAR(30), MAX(e.billing_date), 103) 'billing_date'
			,b.invoice_no
			,b.invoice_type
			,CONVERT(VARCHAR(30), MAX(e.due_date), 103)  'billing_due_date'
			,b.total_billing_amount
			,b.total_ppn_amount
			,b.total_pph_amount
			,MAX(f.obligation_day)  'ovd_days'
			,b.invoice_status
			,@rows_count  'rowcount'
		FROM	dbo.invoice b WITH (NOWAIT)
		INNER JOIN dbo.invoice_detail invd WITH (NOWAIT) ON invd.invoice_no = b.invoice_no
		INNER JOIN dbo.agreement_asset_amortization e WITH (NOWAIT) ON e.asset_no = invd.asset_no AND e.billing_no = invd.billing_no AND e.invoice_no = b.invoice_no
		LEFT JOIN dbo.agreement_obligation f WITH (NOWAIT) ON f.asset_no = invd.asset_no
		WHERE	b.client_no = @p_client_no
		AND		b.invoice_status IN ('POST')
		AND	(
				 b.invoice_no LIKE '%' + @p_keywords + '%'
			  OR b.invoice_type LIKE '%' + @p_keywords + '%'
			  OR CONVERT(VARCHAR(30), e.BILLING_DATE, 103) LIKE '%' + @p_keywords + '%'
			)
		GROUP BY
			b.invoice_no
			,b.invoice_type
			,b.total_billing_amount
			,b.total_ppn_amount
			,b.total_pph_amount
			,b.invoice_status
		ORDER BY
			CASE
				WHEN @p_sort_by = 'asc' THEN
					CASE @p_order_by
						WHEN 1 THEN b.invoice_no
					END
			END ASC,
			CASE
				WHEN @p_sort_by = 'desc' THEN
					CASE @p_order_by
						WHEN 1 THEN b.invoice_no
					END
			END DESC
		OFFSET ((@p_pagenumber - 1) * @p_rowspage) ROWS
		FETCH NEXT @p_rowspage ROWS ONLY;
	END
END;
-- Stored Procedure

CREATE PROCEDURE dbo.xsp_warning_letter_invoice_agreement_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
    ,@p_invoice_no		NVARCHAR(50)	= NULL
)
as
begin
	declare @rows_count int = 0 ;

	BEGIN
		SELECT	@rows_count = COUNT(1)
		FROM	dbo.invoice_detail							b WITH (NOWAIT)
				INNER JOIN dbo.agreement_asset				c WITH (NOWAIT) ON b.asset_no		= c.asset_no
				INNER JOIN dbo.agreement_asset_amortization d WITH (NOWAIT) ON d.asset_no	= b.asset_no
				INNER JOIN dbo.agreement_main				e WITH (NOWAIT) ON e.agreement_no	= c.agreement_no
		WHERE	b.invoice_no = @p_invoice_no
				AND (
					b.billing_amount	LIKE '%' + @p_keywords + '%'
					OR b.asset_no		LIKE '%' + @p_keywords + '%'
				)

		SELECT
				e.agreement_external_no
				,b.asset_no
				,c.asset_name
				,b.billing_no
				,d.billing_amount
				,d.description
				,c.monthly_rental_rounded_amount
				,b.ppn_amount
				,b.pph_amount
				,@rows_count AS 'rowcount'
		FROM	dbo.invoice_detail							b WITH (NOWAIT)
				INNER JOIN dbo.agreement_asset				c WITH (NOWAIT) ON b.asset_no		= c.asset_no
				INNER JOIN dbo.agreement_asset_amortization d WITH (NOWAIT) ON d.asset_no	= b.asset_no
				INNER JOIN dbo.agreement_main				e WITH (NOWAIT) ON e.agreement_no	= c.agreement_no
		WHERE	b.invoice_no = @p_invoice_no
				AND (
					b.billing_amount	LIKE '%' + @p_keywords + '%'
					OR b.asset_no		LIKE '%' + @p_keywords + '%'
				)
		ORDER BY
			CASE WHEN @p_sort_by = 'asc' THEN
				CASE @p_order_by
					when 1 then e.agreement_external_no
					when 2 then b.asset_no
				END
			END ASC,
			CASE WHEN @p_sort_by = 'desc' THEN
				CASE @p_order_by
					when 1 then e.agreement_external_no
					when 2 then b.asset_no
				END
			END DESC
		OFFSET ((@p_pagenumber - 1) * @p_rowspage) ROWS
		FETCH NEXT @p_rowspage ROWS ONLY
	END
end ;

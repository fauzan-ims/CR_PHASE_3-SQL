CREATE PROCEDURE [dbo].[xsp_warning_letter_delivery_invoice_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select
             b.invoice_no                         AS invoice_no
            ,b.invoice_type                       AS invoice_type
            ,f.OBLIGATION_DAY                     AS ovd_days
            ,f.billing_date                       AS billing_date
            ,f.billing_due_date                   AS billing_due_date
            ,b.total_billing_amount               AS billing_amount
            ,b.total_billing_amount               AS total_billing_amount
            ,b.total_ppn_amount                   AS total_ppn_amount
            ,b.total_pph_amount                   AS total_pph_amount
            ,''                                   AS remark
            ,''                                   AS result_name
        FROM dbo.invoice b 
        OUTER APPLY (
            SELECT 
                 MAX(f.OBLIGATION_DAY)       AS OBLIGATION_DAY
                ,MAX(mas.billing_date)       AS billing_date
                ,MAX(mas.due_date)           AS billing_due_date
            FROM dbo.invoice_detail invd WITH (NOWAIT)
            INNER JOIN dbo.agreement_asset_amortization mas WITH (NOWAIT)
                ON mas.asset_no = invd.asset_no 
                AND mas.billing_no = invd.billing_no 
                AND mas.invoice_no = invd.invoice_no
            LEFT JOIN dbo.agreement_obligation f WITH (NOWAIT)
                ON f.asset_no = invd.asset_no
            WHERE invd.invoice_no = b.invoice_no
        ) f
        WHERE b.invoice_no = @p_code;
end ;


CREATE PROCEDURE dbo.xsp_withholding_tax_history_getrow
(
	@p_id bigint
)
as
begin
	select	id,
            branch_code,
            branch_name,
            payment_date,
            payment_amount,
            tax_payer_reff_code,
            tax_type,
            tax_file_no,
            tax_file_name,
            tax_pct,
            tax_amount,
            reff_no,
            reff_name,
            remark
	from	withholding_tax_history 
	where	id = @p_id ;
end ;

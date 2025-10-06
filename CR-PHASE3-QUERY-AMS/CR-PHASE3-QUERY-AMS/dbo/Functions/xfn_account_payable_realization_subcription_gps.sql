CREATE FUNCTION [dbo].[xfn_account_payable_realization_subcription_gps]
(
	@p_realization_no	NVARCHAR(50)
	,@p_invoice_code	nvarchar(50)
	,@p_fa_code			nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @total_amount decimal(18, 2) ;

	BEGIN
		SELECT	@total_amount = isnull(sum(grs.invoice_amout), 0)
		from	dbo.GPS_REALIZATION_SUBCRIBE grs
		where	grs.REALIZATION_NO	= @p_realization_no
				and grs.INVOICE_NO	= @p_invoice_code
				and grs.FA_CODE		= @p_fa_code ;
	end ;

	return @total_amount ;
end ;

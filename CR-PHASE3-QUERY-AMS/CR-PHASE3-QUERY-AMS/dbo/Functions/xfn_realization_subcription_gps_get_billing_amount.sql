CREATE FUNCTION [dbo].[xfn_realization_subcription_gps_get_billing_amount]
(
	@p_realization_no nvarchar(50)
	,@p_invoice_code	nvarchar(50)
	,@p_fa_code			nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @total_buy_amount decimal(18, 2) ;

	begin
		select	@total_buy_amount = isnull(sum(grs.billing_amount), 0)
		from	dbo.gps_realization_subcribe grs
		where	grs.REALIZATION_NO	= @p_realization_no
				and grs.INVOICE_NO	= @p_invoice_code
				and grs.FA_CODE		= @p_fa_code ;
	end ;

	return @total_buy_amount ;
end ;

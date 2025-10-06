CREATE FUNCTION [dbo].[xfn_realization_subcription_gps_get_pph]
(
	@p_realization_no		nvarchar(50)
	,@p_invoice_code		nvarchar(50)
	,@p_fa_code				nvarchar(50)
)
RETURNS decimal(18, 2)
as
begin
	
	declare @return_amount				 decimal(18, 2)

		select @return_amount =	isnull(sum(grs.pph_amount),0)
		from	dbo.gps_realization_subcribe grs
		where grs.REALIZATION_NO	= @p_realization_no
			and grs.INVOICE_NO		= @p_invoice_code
			and grs.FA_CODE			= @p_fa_code
            
	return @return_amount ;
end

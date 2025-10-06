CREATE FUNCTION [dbo].[xfn_realization_subcription_gps_get_ppn]
(
	@p_realization_no		nvarchar(50)
	,@p_invoice_code		nvarchar(50)
	,@p_fa_code				nvarchar(50)
)
returns decimal(18, 2)
as
begin
declare @return_amount				 decimal(18, 2)

		select @return_amount =	isnull(sum(grs.ppn_amount),0)
		from	dbo.gps_realization_subcribe grs
		where grs.realization_no = @p_realization_no
		and grs.invoice_no		 = @p_invoice_code
		and grs.fa_code			 = @p_fa_code

	return @return_amount ;
end ;

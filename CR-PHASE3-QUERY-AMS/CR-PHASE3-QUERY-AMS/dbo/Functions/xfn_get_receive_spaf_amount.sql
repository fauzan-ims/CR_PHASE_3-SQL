create FUNCTION [dbo].[xfn_get_receive_spaf_amount]
(
	@p_code nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @amount	decimal(18,2)

	select @amount = claim_amount + ppn_amount
	from dbo.spaf_claim
	where code = @p_code
	

	return @amount ;
end ;

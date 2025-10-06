CREATE FUNCTION [dbo].[xfn_get_ar_subvention_amount]
(
	@p_id	int
)
returns nvarchar(50)
as
begin
	declare @amount			decimal(18,2)

	select	@amount = scd.claim_amount + scd.ppn_amount_detail --cast(scd.claim_amount * (sc.ppn_amount / sc.claim_amount) as int)
	from	dbo.spaf_claim					 sc
			inner join dbo.spaf_claim_detail scd on (sc.code = scd.spaf_claim_code)
	where	scd.id =  @p_id
	and sc.claim_type not in ('OPL SPAF', 'OPL SPAF MMKSI')


	return @amount ;
end ;

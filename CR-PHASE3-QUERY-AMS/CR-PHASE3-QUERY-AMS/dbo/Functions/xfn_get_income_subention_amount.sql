create FUNCTION dbo.xfn_get_income_subention_amount
(
	@p_id	int
)
returns nvarchar(50)
as
begin
	declare @amount	decimal(18,2)

	select @amount = scd.claim_amount
	from dbo.spaf_claim_detail scd
	inner join dbo.spaf_claim sc on (sc.code = scd.spaf_claim_code)
	where id = @p_id
	and sc.claim_type not in ('OPL SPAF','OPL SPAF MMKSI')
	

	return @amount ;
end ;

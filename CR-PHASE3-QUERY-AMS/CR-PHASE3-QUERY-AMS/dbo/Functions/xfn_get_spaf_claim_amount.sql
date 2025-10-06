create FUNCTION dbo.xfn_get_spaf_claim_amount
(
	@p_id bigint
)
returns nvarchar(50)
as
begin
	declare @amount	decimal(18,2)

	select @amount = claim_amount 
	from dbo.spaf_claim_detail
	where id = @p_id
	

	return @amount ;
end ;

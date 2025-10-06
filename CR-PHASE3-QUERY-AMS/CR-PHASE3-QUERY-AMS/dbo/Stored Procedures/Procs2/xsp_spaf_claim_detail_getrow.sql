CREATE PROCEDURE [dbo].[xsp_spaf_claim_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,spaf_claim_code
			,spaf_pct
			,claim_amount
			,ppn_amount_detail
			,pph_amount_detail
	from	spaf_claim_detail
	where	id = @p_id ;
end ;

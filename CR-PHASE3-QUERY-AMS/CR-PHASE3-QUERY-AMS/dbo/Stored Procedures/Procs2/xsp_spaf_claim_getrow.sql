CREATE PROCEDURE [dbo].[xsp_spaf_claim_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,date
			,status
			,total_claim_amount
			,remark
			,claim_type
			,receipt_no
			,reff_claim_req_no
			,ppn_amount
			,pph_amount
			,claim_amount + ppn_amount - pph_amount 'total_receive'
			,faktur_no
			,faktur_date
			,claim_amount
	from	spaf_claim
	where	code = @p_code ;
end ;

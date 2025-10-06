CREATE procedure dbo.xsp_settlement_agreement_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
		   ,settlement_id
		   ,asset_no
		   ,confirmation_date
		   ,confirmation_remark
		   ,confirmation_result 
	from	dbo.settlement_agreement_detail
	where	id = @p_id ;
end ;

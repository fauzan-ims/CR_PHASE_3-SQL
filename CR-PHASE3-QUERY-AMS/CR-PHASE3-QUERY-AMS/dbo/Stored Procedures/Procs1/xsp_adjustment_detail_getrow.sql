CREATE PROCEDURE dbo.xsp_adjustment_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,adjustment_code
			,adjusment_transaction_code
			,amount
	from	dbo.adjustment_detail
	where	id = @p_id ;
end ;

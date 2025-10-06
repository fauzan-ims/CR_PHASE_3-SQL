create procedure [dbo].[xsp_deposit_move_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,deposit_move_code
			,to_agreement_no
			,to_deposit_type_code
			,to_amount
	from	dbo.deposit_move_detail
	where	id = @p_id ;
end ;

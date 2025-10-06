
CREATE procedure [dbo].[xsp_waived_obligation_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,waived_obligation_code
			,installment_no
			,obligation_amount
			,waived_amount
	from	waived_obligation_detail
	where	id = @p_id ;
end ;


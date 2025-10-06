CREATE PROCEDURE dbo.xsp_settlement_agreement_getrow
(
	@p_id bigint
)
as
begin
	select	sa.id
		   ,sa.branch_code
		   ,sa.branch_name
		   ,sa.status
		   ,sa.remark
		   ,sa.date
		   ,sa.agreement_no 
		   ,am.agreement_external_no
		   ,am.client_name
	from	dbo.settlement_agreement sa
			inner join dbo.agreement_main am on (am.agreement_no = sa.agreement_no)
	where	id = @p_id ;
end ;

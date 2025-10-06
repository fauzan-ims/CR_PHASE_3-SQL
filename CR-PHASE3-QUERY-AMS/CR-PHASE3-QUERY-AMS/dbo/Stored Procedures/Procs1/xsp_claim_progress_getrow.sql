CREATE procedure [dbo].[xsp_claim_progress_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,claim_code
			,claim_progress_code
			,sgs.description 'claim_progress_code_desc'
			,claim_progress_date
			,claim_progress_remarks
	from	claim_progress cps
			inner join dbo.sys_general_subcode sgs on (sgs.code = cps.claim_progress_code)
	where	id = @p_id ;
end ;


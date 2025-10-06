
CREATE PROCEDURE [dbo].[xsp_reverse_disposal_history_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	rd.code
			,rd.company_code
			,rd.disposal_code
			,rd.disposal_date
			,rd.reverse_disposal_date
			,rd.branch_code
			,rd.branch_name
			,rd.location_code
			,rd.location_name
			,rd.description
			,rd.reason_type
			,sgs.description 'general_subcode_desc'
			,rd.remarks
			,rd.status
	from	dbo.reverse_disposal_history rd
	left join dbo.sys_general_subcode sgs on (sgs.code = rd.reason_type) and (sgs.company_code = rd.company_code)
	where	rd.code = @p_code ;
end ;

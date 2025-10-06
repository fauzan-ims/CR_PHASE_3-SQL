CREATE procedure dbo.xsp_receipt_void_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	rv.code
			,rv.branch_code
			,rv.branch_name
			,rv.void_status
			,rv.void_date
			,rv.void_reason_code
			,rv.void_remarks
			,sgs.description 'void_reason_desc'
	from	receipt_void rv
	inner join dbo.sys_general_subcode sgs on (sgs.code = rv.void_reason_code)
	where	rv.code = @p_code ;
end ;

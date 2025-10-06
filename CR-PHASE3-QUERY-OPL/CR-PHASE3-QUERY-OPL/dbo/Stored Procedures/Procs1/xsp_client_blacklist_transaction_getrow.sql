CREATE procedure [dbo].[xsp_client_blacklist_transaction_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	cbt.code
			,cbt.transaction_status
			,cbt.transaction_type
			,cbt.transaction_date
			,cbt.transaction_remarks
			,cbt.register_source
			,sgs.description 'register_source_desc'
	from	client_blacklist_transaction cbt
			inner join dbo.sys_general_subcode sgs on (sgs.code = cbt.register_source)
	where	cbt.code = @p_code ;
end ;


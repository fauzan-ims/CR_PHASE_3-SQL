--created by, Rian at 16/05/2023 

CREATE procedure dbo.xsp_area_blacklist_transaction_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	abt.code
			,abt.transaction_status
			,abt.transaction_type
			,abt.transaction_date
			,abt.transaction_remarks
			,abt.register_source
			,sgs.description 'register_source_desc'
	from	area_blacklist_transaction abt
			inner join dbo.sys_general_subcode sgs on (sgs.code = abt.register_source)
	where	abt.code = @p_code ;
end ;

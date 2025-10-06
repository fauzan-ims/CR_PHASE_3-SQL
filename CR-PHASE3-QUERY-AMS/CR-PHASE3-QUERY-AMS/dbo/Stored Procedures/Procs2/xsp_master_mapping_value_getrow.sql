CREATE procedure dbo.xsp_master_mapping_value_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,transaction_type
			,view_name
			,is_active
	from	master_mapping_value
	where	code = @p_code ;
end ;

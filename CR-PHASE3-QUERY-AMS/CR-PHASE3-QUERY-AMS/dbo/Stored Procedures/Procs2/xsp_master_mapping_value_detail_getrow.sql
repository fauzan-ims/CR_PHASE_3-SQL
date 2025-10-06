CREATE procedure dbo.xsp_master_mapping_value_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,mapping_value_code
			,column_name
			,field_name
	from	master_mapping_value_detail
	where	id = @p_id ;
end ;

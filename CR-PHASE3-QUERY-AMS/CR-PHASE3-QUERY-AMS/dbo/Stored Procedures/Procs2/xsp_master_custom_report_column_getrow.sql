CREATE procedure dbo.xsp_master_custom_report_column_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,custom_report_code
			,column_name
			,header_name
			,order_key
	from	master_custom_report_column
	where	id = @p_id ;
end ;

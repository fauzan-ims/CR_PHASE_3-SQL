CREATE procedure dbo.xsp_master_custom_report_condition_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,custom_report_code
			,logical_operator
			,column_name
			,comparison_operator
			,start_value
			,end_value
			,order_key
	from	master_custom_report_condition
	where	id = @p_id ;
end ;

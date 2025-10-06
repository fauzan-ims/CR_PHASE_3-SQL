create PROCEDURE dbo.xsp_master_custom_report_condition_order_up
	@p_id					  bigint
	,@p_custom_report_code    nvarchar(50)
as
begin
	declare @order_tamp int ;

	select @order_tamp = order_key 
	from dbo.master_custom_report_condition
	where id = @p_id

	if (@order_tamp > 1)
	begin
		update	dbo.master_custom_report_condition
		set		order_key				= @order_tamp
		where	order_key 				= @order_tamp - 1
				and custom_report_code  = @p_custom_report_code ;

		update	dbo.master_custom_report_condition
		set		order_key	= @order_tamp - 1
		where	id			= @p_id ;
	end ;
end ;

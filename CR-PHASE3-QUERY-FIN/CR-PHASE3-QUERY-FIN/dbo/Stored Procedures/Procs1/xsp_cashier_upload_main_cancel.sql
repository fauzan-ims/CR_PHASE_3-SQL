CREATE procedure dbo.xsp_cashier_upload_main_cancel
	@p_code nvarchar(50)
as
begin
	update	dbo.cashier_upload_main
	set		status = 'CANCEL'
	where	code = @p_code ;
end ;

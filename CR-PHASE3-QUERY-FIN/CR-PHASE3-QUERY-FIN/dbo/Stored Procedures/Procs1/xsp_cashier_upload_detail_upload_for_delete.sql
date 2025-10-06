CREATE PROCEDURE dbo.xsp_cashier_upload_detail_upload_for_delete
	@p_cashier_upload_code nvarchar(50)
as
begin
	delete dbo.cashier_upload_detail
	where	cashier_upload_code = @p_cashier_upload_code ;
end ;

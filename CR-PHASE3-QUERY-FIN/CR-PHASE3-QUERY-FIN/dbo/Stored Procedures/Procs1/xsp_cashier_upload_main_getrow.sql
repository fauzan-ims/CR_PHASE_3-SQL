CREATE PROCEDURE dbo.xsp_cashier_upload_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,batch_no
			,fintech_code
			,fintech_name
			,value_date
			,trx_date
			,branch_bank_code
			,branch_bank_name
			,bank_gl_link_code
			,status
	from	cashier_upload_main
	where	code = @p_code ;
end ;

CREATE PROCEDURE dbo.xsp_reconcile_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,reconcile_status
			,reconcile_date
			,reconcile_from_value_date
			,reconcile_to_value_date
			,reconcile_remarks
			,branch_bank_code
			,branch_bank_name
			,bank_gl_link_code
			,system_amount
			,upload_amount
			,file_name
			,paths
	from	reconcile_main
	where	code = @p_code ;
end ;

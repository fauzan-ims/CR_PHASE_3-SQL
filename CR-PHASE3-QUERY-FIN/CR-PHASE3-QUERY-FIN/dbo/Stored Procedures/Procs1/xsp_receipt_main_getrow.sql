
create procedure xsp_receipt_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,receipt_status
			,receipt_use_date
			,receipt_no
			,cashier_code
			,max_print_count
			,print_count
	from	receipt_main
	where	code = @p_code ;
end ;

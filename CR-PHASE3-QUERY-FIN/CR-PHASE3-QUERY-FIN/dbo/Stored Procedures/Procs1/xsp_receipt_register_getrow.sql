
create procedure xsp_receipt_register_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,register_status
			,register_date
			,register_remarks
			,receipt_prefix
			,receipt_sequence
			,receipt_postfix
			,receipt_number
	from	receipt_register
	where	code = @p_code ;
end ;

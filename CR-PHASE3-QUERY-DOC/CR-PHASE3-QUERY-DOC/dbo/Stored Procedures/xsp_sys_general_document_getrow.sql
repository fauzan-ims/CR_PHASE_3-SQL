create procedure xsp_sys_general_document_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,document_name
			,is_temp
			,is_physical
			,is_allow_out
			,is_collateral
			,is_active
	from	sys_general_document
	where	code = @p_code ;
end ;

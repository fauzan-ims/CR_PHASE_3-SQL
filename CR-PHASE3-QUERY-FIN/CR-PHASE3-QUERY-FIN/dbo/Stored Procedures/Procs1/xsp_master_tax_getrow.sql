CREATE PROCEDURE dbo.xsp_master_tax_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,tax_file_type
			,is_active
	from	master_tax
	where	code = @p_code ;
end ;
